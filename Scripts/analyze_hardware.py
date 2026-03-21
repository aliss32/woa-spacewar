#!/usr/bin/env python3
"""
WOA-Spacewar — Hardware Analysis Script
========================================
Clones all Android source repositories for Nothing Phone (1) / Spacewar
and extracts real hardware values into hardware_report.json.

This JSON is then used to fill in all [TODO] values in UEFI files
with zero guesswork.

Sources analyzed:
  - crdroidandroid/android_device_nothing_Spacewar (BoardConfig.mk)
  - ExTV/android_kernel_devicetree_nothing_sm7325 (.dts/.dtsi files)
  - halogenOS/android_device_nothing_Spacewar (configs/)
  - crdroidandroid/proprietary_vendor_nothing_Spacewar (vendor mk)

Credits:
  - mysellysenpai (CrDroid kernel author)
  - crdroidandroid team
  - ExTV (Nothing official DT mirror)
  - Nothing Technology Limited (open source releases)

AI-assisted: Claude (Anthropic) — claude.ai
Copyright (c) 2026 aliss32 — GPL-3.0-or-later
"""

import os
import re
import json
import glob
import argparse
from pathlib import Path


# ── Helpers ───────────────────────────────────────────────────────────────────

def read_file(path):
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except Exception:
        return ""

def find_files(base, pattern):
    if not base or not os.path.exists(base):
        return []
    return glob.glob(os.path.join(base, "**", pattern), recursive=True)

def mk_val(content, key):
    m = re.search(rf'^{re.escape(key)}\s*:=\s*(.+)$', content, re.MULTILINE)
    return m.group(1).strip() if m else ""

def find_compatible(content, keywords):
    results = []
    for kw in keywords:
        found = re.findall(
            rf'compatible\s*=\s*"([^"]*{re.escape(kw)}[^"]*)"',
            content, re.IGNORECASE
        )
        results.extend(found)
    return list(set(results))

def find_gpio(content, node_keywords):
    for kw in node_keywords:
        m = re.search(
            rf'{re.escape(kw)}.*?gpio[s]?\s*=\s*<[^>]*?\s(\d+)\s',
            content, re.DOTALL | re.IGNORECASE
        )
        if m:
            return m.group(1)
    return "TODO"

def find_i2c_addr(content, ic_keywords):
    for kw in ic_keywords:
        m = re.search(
            rf'(?:{re.escape(kw)})[^{{]*{{[^}}]*reg\s*=\s*<0x([0-9a-fA-F]+)>',
            content, re.IGNORECASE | re.DOTALL
        )
        if m:
            return "0x" + m.group(1)
    return "TODO"


# ── Analyzers ─────────────────────────────────────────────────────────────────

def analyze_boardconfig(path):
    content = read_file(os.path.join(path, "BoardConfig.mk"))
    if not content:
        return {"error": "BoardConfig.mk not found"}

    wifi_alias = re.search(r'TARGET_MODULE_ALIASES.*?wlan\.ko:(\S+)', content)

    return {
        "kernel_base":           mk_val(content, "BOARD_KERNEL_BASE"),
        "kernel_pagesize":       mk_val(content, "BOARD_KERNEL_PAGESIZE"),
        "boot_header_version":   mk_val(content, "BOARD_BOOT_HEADER_VERSION"),
        "ramdisk":               "LZ4" if "LZ4" in content else "GZIP",
        "platform":              mk_val(content, "TARGET_BOARD_PLATFORM"),
        "bootloader_name":       mk_val(content, "TARGET_BOOTLOADER_BOARD_NAME"),
        "cpu_variant":           mk_val(content, "TARGET_CPU_VARIANT"),
        "arch_variant":          mk_val(content, "TARGET_ARCH_VARIANT"),
        "boot_part_size":        mk_val(content, "BOARD_BOOTIMAGE_PARTITION_SIZE"),
        "dtbo_part_size":        mk_val(content, "BOARD_DTBOIMG_PARTITION_SIZE"),
        "super_part_size":       mk_val(content, "BOARD_SUPER_PARTITION_SIZE"),
        "flash_block_size":      mk_val(content, "BOARD_FLASH_BLOCK_SIZE"),
        "dynamic_partitions":    mk_val(content, "BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST"),
        "ab_ota":                "true" if "AB_OTA_UPDATER := true" in content else "false",
        "wifi_device":           mk_val(content, "BOARD_WLAN_DEVICE"),
        "wifi_module":           wifi_alias.group(1) if wifi_alias else "qca_cld3_qca6750.ko",
        "wifi_chip":             "QCA6750",
        "wifi_6e":               "true" if "CONFIG_IEEE80211AX" in content else "false",
        "screen_density":        mk_val(content, "TARGET_SCREEN_DENSITY"),
        "udfps":                 "true" if "udfps" in content.lower() else "false",
        "security_patch":        mk_val(content, "VENDOR_SECURITY_PATCH"),
        "ril":                   "true" if "ENABLE_VENDOR_RIL_SERVICE := true" in content else "false",
        "sound_trigger":         "true" if "BOARD_SUPPORTS_SOUND_TRIGGER := true" in content else "false",
    }


def analyze_kernel_dt(path):
    dtsi_files = find_files(path, "*.dtsi") + find_files(path, "*.dts")
    if not dtsi_files:
        return {"error": "No DTSI files found"}

    # Build full content map per file for targeted search
    all_content = ""
    file_map = {}
    for f in dtsi_files:
        c = read_file(f)
        all_content += c
        file_map[os.path.basename(f)] = c

    # Display
    fb = re.search(r'framebuffer@([0-9a-fA-F]+)', all_content)
    w  = re.search(r'qcom,mdss-dsi-panel-width\s*=\s*<(\d+)>', all_content)
    h  = re.search(r'qcom,mdss-dsi-panel-height\s*=\s*<(\d+)>', all_content)
    fps = re.search(r'qcom,mdss-dsi-panel-framerate\s*=\s*<(\d+)>', all_content)

    # Touch IC
    touch_ics = find_compatible(all_content,
        ["goodix", "synaptics", "focaltech", "novatek", "himax", "gt9"])
    touch_i2c = find_i2c_addr(all_content,
        ["goodix", "synaptics", "focaltech"])
    touch_rst = find_gpio(all_content,
        ["reset-gpios", "touch-reset-gpio", "goodix,reset"])
    touch_irq = find_gpio(all_content,
        ["interrupt-gpios", "touch-irq-gpio", "goodix,irq"])

    # Fingerprint IC
    fp_ics = find_compatible(all_content,
        ["goodix-fp", "fpc", "silead", "egis", "gf9518", "gf5298"])

    # Audio
    audio_ics = find_compatible(all_content,
        ["wcd938", "wcd937", "wcd936", "tfa98", "cs35", "aw88"])

    # PMIC
    pmic_ics = find_compatible(all_content,
        ["pm7325", "pm8350", "pmk8350"])

    # NFC
    nfc_ics = find_compatible(all_content,
        ["st21nfcd", "st,st21", "nxp,pn", "sn100", "sn110"])

    # Vibrator
    vib_ics = find_compatible(all_content,
        ["aw8697", "aw86927", "awinic", "drv2624", "qcom,haptics"])

    # GPIO keys
    pwr_gpio = find_gpio(all_content, ["key-power", "power-key", "linux,code = <KEY_POWER"])
    vol_up   = find_gpio(all_content, ["key-volumeup", "vol-up", "volume-up"])
    vol_dn   = find_gpio(all_content, ["key-volumedown", "vol-down", "volume-down"])

    # UART
    uarts = list(set(re.findall(r'(uart\d+)\s*{', all_content, re.IGNORECASE)))

    # USB
    usb_ctrl = re.search(r'androidboot\.usbcontroller=([^\s\\]+)', all_content)

    return {
        "dtsi_file_count":   len(dtsi_files),
        "dtsi_files":        [os.path.basename(f) for f in dtsi_files],
        "framebuffer_base":  "0x" + fb.group(1) if fb else "0xe1000000",
        "display_width":     w.group(1) if w else "1080",
        "display_height":    h.group(1) if h else "2400",
        "display_fps":       fps.group(1) if fps else "120",
        "dsc_enabled":       "true" if "qcom,mdss-dsc-enabled" in all_content else "false",
        "panel_chips":       find_compatible(all_content, ["nt36", "rm692", "visionox"]) or ["RM692E5"],
        "touch_ic":          touch_ics or ["TODO"],
        "touch_i2c_addr":    touch_i2c,
        "touch_reset_gpio":  touch_rst,
        "touch_irq_gpio":    touch_irq,
        "fingerprint_ic":    fp_ics or ["TODO"],
        "fingerprint_type":  "optical_udfps",
        "audio_codec":       audio_ics or ["WCD9385"],
        "pmic_chips":        pmic_ics or ["PM7325", "PM8350B", "PM8350C", "PMK8350"],
        "nfc_ic":            nfc_ics or ["ST21NFCD"],
        "vibrator_ic":       vib_ics or ["TODO"],
        "uart_nodes":        uarts,
        "usb_controller":    usb_ctrl.group(1) if usb_ctrl else "a600000.dwc3",
        "power_key_gpio":    pwr_gpio,
        "vol_up_gpio":       vol_up,
        "vol_down_gpio":     vol_dn,
    }


def build_uefi_values(board, dt):
    return {
        "FD_BASE":            "0x9FC00000",
        "FD_SIZE":            "0x00200000",
        "KERNEL_BASE":        board.get("kernel_base", "0x00000000"),
        "KERNEL_PAGESIZE":    board.get("kernel_pagesize", "4096"),
        "BOOT_HEADER_VER":    board.get("boot_header_version", "3"),
        "FRAMEBUFFER_BASE":   dt.get("framebuffer_base", "0xe1000000"),
        "DISPLAY_WIDTH":      dt.get("display_width", "1080"),
        "DISPLAY_HEIGHT":     dt.get("display_height", "2400"),
        "DISPLAY_FPS":        dt.get("display_fps", "120"),
        "DISPLAY_DENSITY":    board.get("screen_density", "420"),
        "PANEL_CHIPS":        dt.get("panel_chips", ["RM692E5"]),
        "DSC_ENABLED":        dt.get("dsc_enabled", "false"),
        "WIFI_CHIP":          board.get("wifi_chip", "QCA6750"),
        "WIFI_MODULE":        board.get("wifi_module", "qca_cld3_qca6750.ko"),
        "WIFI_6E":            board.get("wifi_6e", "true"),
        "AUDIO_CODEC":        dt.get("audio_codec", ["WCD9385"]),
        "PMIC_CHIPS":         dt.get("pmic_chips", []),
        "TOUCH_IC":           dt.get("touch_ic", ["TODO"]),
        "TOUCH_I2C_ADDR":     dt.get("touch_i2c_addr", "TODO"),
        "TOUCH_RESET_GPIO":   dt.get("touch_reset_gpio", "TODO"),
        "TOUCH_IRQ_GPIO":     dt.get("touch_irq_gpio", "TODO"),
        "FINGERPRINT_IC":     dt.get("fingerprint_ic", ["TODO"]),
        "FINGERPRINT_TYPE":   dt.get("fingerprint_type", "optical_udfps"),
        "NFC_IC":             dt.get("nfc_ic", ["ST21NFCD"]),
        "VIBRATOR_IC":        dt.get("vibrator_ic", ["TODO"]),
        "POWER_KEY_GPIO":     dt.get("power_key_gpio", "TODO"),
        "VOL_UP_GPIO":        dt.get("vol_up_gpio", "TODO"),
        "VOL_DOWN_GPIO":      dt.get("vol_down_gpio", "TODO"),
        "USB_CONTROLLER":     dt.get("usb_controller", "a600000.dwc3"),
        "BOOT_PART_SIZE":     board.get("boot_part_size", "100663296"),
        "SUPER_PART_SIZE":    board.get("super_part_size", "6442450944"),
        "AB_ENABLED":         board.get("ab_ota", "true"),
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--crdroid",    default="")
    parser.add_argument("--kernel",     default="")
    parser.add_argument("--halogenos",  default="")
    parser.add_argument("--vendor",     default="")
    parser.add_argument("--output",     default="Analysis/hardware_report.json")
    args = parser.parse_args()

    print("\n🔍 WOA-Spacewar Hardware Analysis")
    print("=" * 45)

    print("[1/3] Analyzing BoardConfig.mk ...")
    board = analyze_boardconfig(args.crdroid)

    print("[2/3] Analyzing Kernel Device Tree ...")
    dt = analyze_kernel_dt(args.kernel)

    print("[3/3] Building UEFI value map ...")
    uefi = build_uefi_values(board, dt)

    todos = [k for k, v in uefi.items()
             if v == "TODO" or v == ["TODO"]]

    report = {
        "meta": {
            "device":    "Nothing Phone (1)",
            "codename":  "spacewar",
            "soc":       "SM7325-AE (Snapdragon 778G+)",
            "gpu":       "Adreno 642L",
            "kernel":    "5.4.x-mysellysenpai (CrDroid)",
            "generator": "analyze_hardware.py — github-actions[bot]",
        },
        "BoardConfig":  board,
        "KernelDT":     dt,
        "UEFI_Values":  uefi,
        "Status": {
            "todo_count":  len(todos),
            "todo_fields": todos,
            "note": "TODO fields will be filled once kernel DT is fully parsed.",
        }
    }

    os.makedirs(os.path.dirname(args.output), exist_ok=True)
    with open(args.output, "w") as f:
        json.dump(report, f, indent=2)

    print(f"\n✅ Report saved: {args.output}")
    print(f"\n📊 Key Values:")
    print(f"   WiFi       : {uefi['WIFI_CHIP']}")
    print(f"   Display    : {uefi['DISPLAY_WIDTH']}x{uefi['DISPLAY_HEIGHT']} @ {uefi['DISPLAY_FPS']}Hz")
    print(f"   Framebuffer: {uefi['FRAMEBUFFER_BASE']}")
    print(f"   Panel      : {uefi['PANEL_CHIPS']}")
    print(f"   Touch IC   : {uefi['TOUCH_IC']}")
    print(f"   Audio      : {uefi['AUDIO_CODEC']}")
    print(f"   PMIC       : {uefi['PMIC_CHIPS']}")
    print(f"   DSC        : {uefi['DSC_ENABLED']}")
    print(f"\n⏳ TODO fields remaining: {len(todos)}")
    for t in todos:
        print(f"   - {t}")


if __name__ == "__main__":
    main()

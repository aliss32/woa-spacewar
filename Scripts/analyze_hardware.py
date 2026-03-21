#!/usr/bin/env python3
"""
WOA-Spacewar — Hardware Analysis Script v3
==========================================
Her donanım için sadece o donanıma özel DTSi dosyasından okur.
Genel DTSi taraması kaldırıldı — yanlış değer üretimi önlendi.

Spacewar DTSi dosya haritası:
  Display  → dsi-panel-rm692e5-visionox-fhd-plus-120hz-cmd.dtsi
  Touch    → msm-extra/ veya spacewar touch dtsi
  Audio    → lahaina-audio.dtsi, spacewar audio overlay
  NFC      → ilgili nfc dtsi
  Vibrator → ilgili led/haptics dtsi
  PMIC     → pm7325.dtsi, pm8350*.dtsi, pmk8350.dtsi
  GPIO     → lahaina-qrd.dtsi veya spacewar pinctrl

Credits:
  mysellysenpai, crdroidandroid, ExTV, Nothing Technology Ltd

AI-assisted: Claude (Anthropic) — claude.ai
Copyright (c) 2026 aliss32 — GPL-3.0-or-later
"""

import os, re, json, glob, argparse


# ── Helpers ───────────────────────────────────────────────────────────────────

def read_file(path):
    try:
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except:
        return ""

def find_files(base, pattern):
    if not base or not os.path.exists(base):
        return []
    return glob.glob(os.path.join(base, "**", pattern), recursive=True)

def mk_val(content, key):
    m = re.search(rf'^{re.escape(key)}\s*:=\s*(.+)$', content, re.MULTILINE)
    return m.group(1).strip() if m else ""

def get_files_matching(file_map, *keywords):
    """Belirli anahtar kelimeleri içeren dosyaların içeriğini birleştirir."""
    result = ""
    matched = []
    for fname, content in file_map.items():
        fname_lower = fname.lower()
        if any(kw in fname_lower for kw in keywords):
            result += content
            matched.append(fname)
    if matched:
        print(f"    → Matched files: {matched}")
    return result

def find_compatible(content, keywords):
    results = []
    for kw in keywords:
        found = re.findall(
            rf'compatible\s*=\s*"([^"]*{re.escape(kw)}[^"]*)"',
            content, re.IGNORECASE
        )
        results.extend(found)
    return list(set(results))

def find_gpio_in(content, node_keywords):
    for kw in node_keywords:
        m = re.search(
            rf'{re.escape(kw)}.*?gpio[s]?\s*=\s*<[^>]*?\s(\d+)\s',
            content, re.DOTALL | re.IGNORECASE
        )
        if m:
            return m.group(1)
    return "TODO"

def find_i2c_addr_in(content, ic_keywords):
    for kw in ic_keywords:
        m = re.search(
            rf'(?:{re.escape(kw)})[^{{]*{{[^}}]*reg\s*=\s*<0x([0-9a-fA-F]+)>',
            content, re.IGNORECASE | re.DOTALL
        )
        if m:
            return "0x" + m.group(1)
    return "TODO"


# ── BoardConfig Analizi ───────────────────────────────────────────────────────

def analyze_boardconfig(path):
    content = read_file(os.path.join(path, "BoardConfig.mk"))
    if not content:
        return {"error": "BoardConfig.mk not found"}
    wifi_alias = re.search(r'TARGET_MODULE_ALIASES.*?wlan\.ko:(\S+)', content)
    return {
        "kernel_base":        mk_val(content, "BOARD_KERNEL_BASE"),
        "kernel_pagesize":    mk_val(content, "BOARD_KERNEL_PAGESIZE"),
        "boot_header_version":mk_val(content, "BOARD_BOOT_HEADER_VERSION"),
        "ramdisk":            "LZ4" if "LZ4" in content else "GZIP",
        "platform":           mk_val(content, "TARGET_BOARD_PLATFORM"),
        "bootloader_name":    mk_val(content, "TARGET_BOOTLOADER_BOARD_NAME"),
        "cpu_variant":        mk_val(content, "TARGET_CPU_VARIANT"),
        "arch_variant":       mk_val(content, "TARGET_ARCH_VARIANT"),
        "boot_part_size":     mk_val(content, "BOARD_BOOTIMAGE_PARTITION_SIZE"),
        "dtbo_part_size":     mk_val(content, "BOARD_DTBOIMG_PARTITION_SIZE"),
        "super_part_size":    mk_val(content, "BOARD_SUPER_PARTITION_SIZE"),
        "flash_block_size":   mk_val(content, "BOARD_FLASH_BLOCK_SIZE"),
        "dynamic_partitions": mk_val(content, "BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST"),
        "ab_ota":             "true" if "AB_OTA_UPDATER := true" in content else "false",
        "wifi_device":        mk_val(content, "BOARD_WLAN_DEVICE"),
        "wifi_module":        wifi_alias.group(1) if wifi_alias else "qca_cld3_qca6750.ko",
        "wifi_chip":          "QCA6750",
        "wifi_6e":            "true" if "CONFIG_IEEE80211AX" in content else "false",
        "screen_density":     mk_val(content, "TARGET_SCREEN_DENSITY"),
        "udfps":              "true" if "udfps" in content.lower() else "false",
        "security_patch":     mk_val(content, "VENDOR_SECURITY_PATCH"),
        "ril":                "true" if "ENABLE_VENDOR_RIL_SERVICE := true" in content else "false",
        "sound_trigger":      "true" if "BOARD_SUPPORTS_SOUND_TRIGGER := true" in content else "false",
    }


# ── Kernel DT Analizi — Her donanım kendi dosyasından ────────────────────────

def analyze_kernel_dt(path):
    dtsi_files = find_files(path, "*.dtsi") + find_files(path, "*.dts")
    if not dtsi_files:
        return {"error": "No DTSI files found"}

    # Tüm dosyaları map'e yükle
    file_map = {}
    for f in dtsi_files:
        file_map[os.path.basename(f)] = read_file(f)

    print(f"  Total DTSi files: {len(dtsi_files)}")

    # ── DISPLAY — sadece RM692E5 panel dosyası ───────────────────────────────
    print("  [Display]")
    display_content = get_files_matching(file_map,
        "rm692e5", "spacewar-display", "spacewar-sde")

    if display_content:
        w   = re.search(r'qcom,mdss-dsi-panel-width\s*=\s*<(\d+)>',     display_content)
        h   = re.search(r'qcom,mdss-dsi-panel-height\s*=\s*<(\d+)>',    display_content)
        fps = re.search(r'qcom,mdss-dsi-panel-framerate\s*=\s*<(\d+)>', display_content)
        dsc = "qcom,mdss-dsc-enabled" in display_content
        display_width  = w.group(1)   if w   else "1080"
        display_height = h.group(1)   if h   else "2400"
        display_fps    = fps.group(1) if fps else "120"
    else:
        print("    → Not found, using Nothing Phone 1 hardware spec")
        display_width, display_height, display_fps, dsc = "1080", "2400", "120", False

    fb = re.search(r'framebuffer@([0-9a-fA-F]+)',
                   get_files_matching(file_map, "lahaina-qrd", "spacewar", "lahaina-mtp"))

    # ── TOUCH — touch/input dosyaları ────────────────────────────────────────
    print("  [Touch]")
    touch_content = get_files_matching(file_map,
        "touch", "input", "goodix", "focaltech", "novatek", "synaptics")

    touch_ics = find_compatible(touch_content,
        ["goodix", "synaptics", "focaltech", "novatek", "himax"])
    touch_i2c = find_i2c_addr_in(touch_content,
        ["goodix", "synaptics", "focaltech"])
    touch_rst = find_gpio_in(touch_content,
        ["reset-gpios", "touch-reset-gpio", "goodix,reset-gpio"])
    touch_irq = find_gpio_in(touch_content,
        ["interrupt-gpios", "touch-irq-gpio", "goodix,irq-gpio"])

    # ── FINGERPRINT — fingerprint dosyaları ──────────────────────────────────
    print("  [Fingerprint]")
    fp_content = get_files_matching(file_map,
        "fingerprint", "fp", "goodix-fp", "fpc", "udfps")

    fp_ics = find_compatible(fp_content,
        ["goodix-fp", "fpc", "silead", "egis", "gf9518", "gf3658", "gf5298"])

    # ── AUDIO — audio dosyaları ───────────────────────────────────────────────
    print("  [Audio]")
    audio_content = get_files_matching(file_map,
        "audio", "wcd", "tfa", "sound", "codec")

    audio_ics = find_compatible(audio_content,
        ["wcd938", "wcd937", "tfa98", "cs35l", "aw88"])

    # ── PMIC — pmic dosyaları ─────────────────────────────────────────────────
    print("  [PMIC]")
    pmic_content = get_files_matching(file_map,
        "pm7325", "pm8350", "pmk8350", "pmic")

    pmic_ics = find_compatible(pmic_content,
        ["pm7325", "pm8350", "pmk8350"])

    # ── NFC — nfc dosyaları ───────────────────────────────────────────────────
    print("  [NFC]")
    nfc_content = get_files_matching(file_map,
        "nfc", "st21", "nxp")

    nfc_ics = find_compatible(nfc_content,
        ["st21nfcd", "st,st21", "nxp,pn", "sn100"])

    # ── VIBRATOR / GLYPH — led/haptics dosyaları ─────────────────────────────
    print("  [Vibrator/Glyph]")
    vib_content = get_files_matching(file_map,
        "led", "haptic", "vibrat", "awinic", "aw2016", "aw210")

    vib_ics = find_compatible(vib_content,
        ["aw8697", "aw86927", "awinic", "drv2624", "qcom,haptics"])

    # ── GPIO KEYS — key/button dosyaları ─────────────────────────────────────
    print("  [GPIO Keys]")
    key_content = get_files_matching(file_map,
        "key", "button", "gpio-keys", "pinctrl", "lahaina-qrd")

    pwr_gpio = find_gpio_in(key_content, ["key-power", "power-key"])
    vol_up   = find_gpio_in(key_content, ["key-volumeup", "vol-up", "volume-up"])
    vol_dn   = find_gpio_in(key_content, ["key-volumedown", "vol-down", "volume-down"])

    # ── UART — uart dosyaları ─────────────────────────────────────────────────
    uart_content = get_files_matching(file_map, "uart", "serial", "blsp")
    uarts = list(set(re.findall(r'(uart\d+)\s*{', uart_content, re.IGNORECASE)))

    # ── USB ───────────────────────────────────────────────────────────────────
    usb_content = get_files_matching(file_map, "usb", "dwc3")
    usb_ctrl = re.search(r'androidboot\.usbcontroller=([^\s\\]+)', usb_content)

    return {
        "dtsi_file_count":   len(dtsi_files),
        "framebuffer_base":  "0x" + fb.group(1) if fb else "0xe1000000",
        "display_width":     display_width,
        "display_height":    display_height,
        "display_fps":       display_fps,
        "dsc_enabled":       "true" if dsc else "false",
        "panel_chips":       find_compatible(display_content, ["rm692", "visionox"]) or ["RM692E5"],
        "touch_ic":          touch_ics or ["TODO"],
        "touch_i2c_addr":    touch_i2c,
        "touch_reset_gpio":  touch_rst,
        "touch_irq_gpio":    touch_irq,
        "fingerprint_ic":    fp_ics or ["TODO"],
        "fingerprint_type":  "optical_udfps",
        "audio_codec":       audio_ics or ["WCD9385"],
        "pmic_chips":        pmic_ics or ["PM7325", "PM8350B"],
        "nfc_ic":            nfc_ics or ["ST21NFC"],
        "vibrator_ic":       vib_ics or ["TODO"],
        "uart_nodes":        uarts,
        "usb_controller":    usb_ctrl.group(1) if usb_ctrl else "a600000.dwc3",
        "power_key_gpio":    pwr_gpio,
        "vol_up_gpio":       vol_up,
        "vol_down_gpio":     vol_dn,
    }


# ── UEFI Değer Haritası ───────────────────────────────────────────────────────

def build_uefi_values(board, dt):
    return {
        "FD_BASE":          "0x9FC00000",
        "FD_SIZE":          "0x00200000",
        "KERNEL_BASE":      board.get("kernel_base", "0x00000000"),
        "KERNEL_PAGESIZE":  board.get("kernel_pagesize", "4096"),
        "BOOT_HEADER_VER":  board.get("boot_header_version", "3"),
        "FRAMEBUFFER_BASE": dt.get("framebuffer_base", "0xe1000000"),
        "DISPLAY_WIDTH":    dt.get("display_width", "1080"),
        "DISPLAY_HEIGHT":   dt.get("display_height", "2400"),
        "DISPLAY_FPS":      dt.get("display_fps", "120"),
        "DISPLAY_DENSITY":  board.get("screen_density", "420"),
        "PANEL_CHIPS":      dt.get("panel_chips", ["RM692E5"]),
        "DSC_ENABLED":      dt.get("dsc_enabled", "false"),
        "WIFI_CHIP":        board.get("wifi_chip", "QCA6750"),
        "WIFI_MODULE":      board.get("wifi_module", "qca_cld3_qca6750.ko"),
        "WIFI_6E":          board.get("wifi_6e", "true"),
        "AUDIO_CODEC":      dt.get("audio_codec", ["WCD9385"]),
        "SPEAKER_AMP":      ["TFA9874"] if any("tfa" in str(x).lower()
                            for x in dt.get("audio_codec", [])) else ["TODO"],
        "PMIC_CHIPS":       dt.get("pmic_chips", []),
        "TOUCH_IC":         dt.get("touch_ic", ["TODO"]),
        "TOUCH_I2C_ADDR":   dt.get("touch_i2c_addr", "TODO"),
        "TOUCH_RESET_GPIO": dt.get("touch_reset_gpio", "TODO"),
        "TOUCH_IRQ_GPIO":   dt.get("touch_irq_gpio", "TODO"),
        "FINGERPRINT_IC":   dt.get("fingerprint_ic", ["TODO"]),
        "FINGERPRINT_TYPE": dt.get("fingerprint_type", "optical_udfps"),
        "NFC_IC":           dt.get("nfc_ic", ["ST21NFC"]),
        "VIBRATOR_IC":      dt.get("vibrator_ic", ["TODO"]),
        "POWER_KEY_GPIO":   dt.get("power_key_gpio", "TODO"),
        "VOL_UP_GPIO":      dt.get("vol_up_gpio", "TODO"),
        "VOL_DOWN_GPIO":    dt.get("vol_down_gpio", "TODO"),
        "USB_CONTROLLER":   dt.get("usb_controller", "a600000.dwc3"),
        "BOOT_PART_SIZE":   board.get("boot_part_size", "100663296"),
        "SUPER_PART_SIZE":  board.get("super_part_size", "6442450944"),
        "AB_ENABLED":       board.get("ab_ota", "true"),
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

    print("\n🔍 WOA-Spacewar Hardware Analysis v3")
    print("   Each hardware reads from its own DTSi files")
    print("=" * 50)

    print("\n[1/3] Analyzing BoardConfig.mk ...")
    board = analyze_boardconfig(args.crdroid)

    print("\n[2/3] Analyzing Kernel Device Tree ...")
    dt = analyze_kernel_dt(args.kernel)

    print("\n[3/3] Building UEFI value map ...")
    uefi = build_uefi_values(board, dt)

    todos = [k for k, v in uefi.items() if v == "TODO" or v == ["TODO"]]

    report = {
        "meta": {
            "device":    "Nothing Phone (1)",
            "codename":  "spacewar",
            "soc":       "SM7325-AE (Snapdragon 778G+)",
            "gpu":       "Adreno 642L",
            "kernel":    "5.4.x-mysellysenpai (CrDroid)",
            "generator": "analyze_hardware.py v3 — github-actions[bot]",
            "readable_url": "https://raw.githubusercontent.com/aliss32/woa-spacewar/main/Analysis/hardware_report.json",
        },
        "BoardConfig": board,
        "KernelDT":    dt,
        "UEFI_Values": uefi,
        "Status": {
            "todo_count":  len(todos),
            "todo_fields": todos,
        }
    }

    os.makedirs(os.path.dirname(args.output) or ".", exist_ok=True)
    with open(args.output, "w") as f:
        json.dump(report, f, indent=2)

    print(f"\n✅ Report: {args.output}")
    print(f"\n📊 Key Values:")
    print(f"   Display    : {uefi['DISPLAY_WIDTH']}x{uefi['DISPLAY_HEIGHT']} @ {uefi['DISPLAY_FPS']}Hz")
    print(f"   WiFi       : {uefi['WIFI_CHIP']}")
    print(f"   Touch IC   : {uefi['TOUCH_IC']}")
    print(f"   Touch GPIO : RST={uefi['TOUCH_RESET_GPIO']} IRQ={uefi['TOUCH_IRQ_GPIO']}")
    print(f"   Audio      : {uefi['AUDIO_CODEC']}")
    print(f"   Speaker Amp: {uefi['SPEAKER_AMP']}")
    print(f"   FP IC      : {uefi['FINGERPRINT_IC']}")
    print(f"   NFC        : {uefi['NFC_IC']}")
    print(f"   Power GPIO : {uefi['POWER_KEY_GPIO']}")
    print(f"   TODOs left : {len(todos)}")
    for t in todos:
        print(f"     ⏳ {t}")

if __name__ == "__main__":
    main()

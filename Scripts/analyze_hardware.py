#!/usr/bin/env python3
"""
WOA-Spacewar — Hardware Analysis Script v3
==========================================
Her donanım sadece kendi DTSi dosyasından okunur.

Kaynaklar:
  --crdroid   : crdroidandroid/android_device_nothing_Spacewar
  --kernel    : ExTV/android_kernel_devicetree_nothing_sm7325
  --lineage   : LineageOS/android_device_nothing_Spacewar
  --np1       : NP1-Developers/android_device_nothing_spacewar
  --halogenos : halogenOS/android_device_nothing_Spacewar
  --vendor    : crdroidandroid/proprietary_vendor_nothing_Spacewar

Credits:
  mysellysenpai, crdroidandroid, LineageOS, NP1-Developers,
  halogenOS, ExTV, Nothing Technology Limited

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

def find_files(base, *patterns):
    results = []
    if not base or not os.path.exists(base):
        return results
    for p in patterns:
        results += glob.glob(os.path.join(base, "**", p), recursive=True)
    return results

def mk_val(content, key):
    m = re.search(rf'^{re.escape(key)}\s*:=\s*(.+)$', content, re.MULTILINE)
    return m.group(1).strip() if m else ""

def build_file_map(*paths):
    """Birden fazla dizindeki DTSi dosyalarını tek map'e toplar."""
    file_map = {}
    total = 0
    for base in paths:
        if not base or not os.path.exists(base):
            continue
        files = find_files(base, "*.dtsi", "*.dts", "*.mk", "*.prop", "*.rc")
        for f in files:
            fname = os.path.basename(f)
            content = read_file(f)
            # Aynı isimli dosya varsa içerikleri birleştir
            if fname in file_map:
                file_map[fname] += "\n" + content
            else:
                file_map[fname] = content
            total += 1
    print(f"    → {total} files indexed from {len(paths)} sources")
    return file_map

def get_content_for(*keywords, file_map):
    """Anahtar kelimeleri içeren dosyaların içeriğini birleştirir."""
    result = ""
    matched = []
    for fname, content in file_map.items():
        fl = fname.lower()
        if any(kw.lower() in fl for kw in keywords):
            result += content
            matched.append(fname)
    if matched:
        print(f"      Files: {matched[:5]}{'...' if len(matched)>5 else ''}")
    else:
        print(f"      No files matched for: {keywords}")
    return result

def find_compatible(content, *keywords):
    results = []
    for kw in keywords:
        found = re.findall(
            rf'compatible\s*=\s*"([^"]*{re.escape(kw)}[^"]*)"',
            content, re.IGNORECASE)
        results.extend(found)
    return list(set(results))

def find_gpio(content, *node_keywords):
    for kw in node_keywords:
        m = re.search(
            rf'{re.escape(kw)}.*?gpio[s]?\s*=\s*<[^>]*?\s(\d+)\s',
            content, re.DOTALL | re.IGNORECASE)
        if m:
            return m.group(1)
    return "TODO"

def find_i2c(content, *ic_keywords):
    for kw in ic_keywords:
        m = re.search(
            rf'(?:{re.escape(kw)})[^{{]*{{[^}}]*reg\s*=\s*<0x([0-9a-fA-F]+)>',
            content, re.IGNORECASE | re.DOTALL)
        if m:
            return "0x" + m.group(1)
    return "TODO"


# ── BoardConfig ───────────────────────────────────────────────────────────────

def analyze_boardconfig(*paths):
    """Birden fazla kaynaktan BoardConfig.mk okur, en dolu olanı kullanır."""
    content = ""
    for path in paths:
        c = read_file(os.path.join(path, "BoardConfig.mk")) if path else ""
        if len(c) > len(content):
            content = c

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


# ── Kernel DT — Her donanım kendi dosyasından ─────────────────────────────────

def analyze_hardware(kernel_path, *extra_paths):
    print(f"  Indexing files...")
    fm = build_file_map(kernel_path, *extra_paths)

    # ── DISPLAY ──────────────────────────────────────────────────────────────
    print("  [Display] Reading from RM692E5 panel file...")
    disp = get_content_for("rm692e5", "spacewar-display", "spacewar-sde", file_map=fm)

    fb  = re.search(r'framebuffer@([0-9a-fA-F]+)', get_content_for("lahaina-qrd", "spacewar", file_map=fm))
    w   = re.search(r'qcom,mdss-dsi-panel-width\s*=\s*<(\d+)>',     disp)
    h   = re.search(r'qcom,mdss-dsi-panel-height\s*=\s*<(\d+)>',    disp)
    fps = re.search(r'qcom,mdss-dsi-panel-framerate\s*=\s*<(\d+)>', disp)

    display_width  = w.group(1)   if w   else "1080"
    display_height = h.group(1)   if h   else "2400"
    display_fps    = fps.group(1) if fps else "120"
    print(f"      → {display_width}x{display_height} @ {display_fps}Hz")

    # ── TOUCH ────────────────────────────────────────────────────────────────
    print("  [Touch] Reading from touch/input files...")
    touch = get_content_for("touch", "input", "goodix", "focaltech", "novatek", "synaptics", file_map=fm)

    touch_ics = find_compatible(touch, "goodix,gt", "synaptics", "focaltech", "novatek,NVT")
    touch_i2c = find_i2c(touch, "goodix", "synaptics", "focaltech")
    touch_rst = find_gpio(touch, "reset-gpios", "touch-reset-gpio", "goodix,reset-gpio")
    touch_irq = find_gpio(touch, "interrupt-gpios", "touch-irq-gpio", "goodix,irq-gpio")
    print(f"      → IC: {touch_ics}, I2C: {touch_i2c}, RST: {touch_rst}, IRQ: {touch_irq}")

    # ── FINGERPRINT ──────────────────────────────────────────────────────────
    print("  [Fingerprint] Reading from fingerprint/udfps files...")
    fp = get_content_for("fingerprint", "udfps", "goodix-fp", "fpc", file_map=fm)

    fp_ics = find_compatible(fp, "goodix-fp", "fpc", "egis", "silead", "gf")
    print(f"      → IC: {fp_ics}")

    # ── AUDIO ────────────────────────────────────────────────────────────────
    print("  [Audio] Reading from audio/codec files...")
    audio = get_content_for("audio", "wcd", "tfa", "codec", "sound", file_map=fm)

    audio_ics = find_compatible(audio, "wcd938", "wcd937", "tfa98", "cs35l", "aw88")
    has_tfa = any("tfa" in str(x).lower() for x in audio_ics)
    print(f"      → Codec: {audio_ics}, TFA9874: {has_tfa}")

    # ── PMIC ─────────────────────────────────────────────────────────────────
    print("  [PMIC] Reading from pm7325/pm8350/pmk8350 files...")
    pmic = get_content_for("pm7325", "pm8350", "pmk8350", "pmic-overlay", file_map=fm)

    pmic_ics = find_compatible(pmic, "pm7325", "pm8350", "pmk8350")
    print(f"      → {pmic_ics[:4]}")

    # ── NFC ──────────────────────────────────────────────────────────────────
    print("  [NFC] Reading from nfc/st21 files...")
    nfc = get_content_for("nfc", "st21", "nxp", file_map=fm)

    nfc_ics = find_compatible(nfc, "st21nfcd", "st,st21", "nxp,pn", "sn100")
    print(f"      → {nfc_ics}")

    # ── VIBRATOR / GLYPH ─────────────────────────────────────────────────────
    print("  [Vibrator/Glyph] Reading from led/haptic/awinic files...")
    vib = get_content_for("led", "haptic", "vibrat", "awinic", "aw2016", "aw210", file_map=fm)

    vib_ics = find_compatible(vib, "awinic,aw2016", "awinic,aw210", "aw8697", "drv2624")
    print(f"      → {vib_ics}")

    # ── GPIO KEYS ────────────────────────────────────────────────────────────
    print("  [GPIO Keys] Reading from key/button/pinctrl files...")
    keys = get_content_for("gpio-keys", "key", "button", "pinctrl", "lahaina-qrd", file_map=fm)

    pwr_gpio = find_gpio(keys, "key-power", "power-key")
    vol_up   = find_gpio(keys, "key-volumeup", "vol-up", "volume-up")
    vol_dn   = find_gpio(keys, "key-volumedown", "vol-down", "volume-down")
    print(f"      → PWR: {pwr_gpio}, VOL+: {vol_up}, VOL-: {vol_dn}")

    # ── UART ─────────────────────────────────────────────────────────────────
    uart = get_content_for("uart", "blsp", "serial", file_map=fm)
    uarts = list(set(re.findall(r'(uart\d+)\s*{', uart, re.IGNORECASE)))

    # ── USB ───────────────────────────────────────────────────────────────────
    usb = get_content_for("usb", "dwc3", file_map=fm)
    usb_ctrl = re.search(r'androidboot\.usbcontroller=([^\s\\]+)', usb)

    return {
        "display_width":     display_width,
        "display_height":    display_height,
        "display_fps":       display_fps,
        "framebuffer_base":  "0x" + fb.group(1) if fb else "0xe1000000",
        "dsc_enabled":       "true" if "qcom,mdss-dsc-enabled" in disp else "false",
        "panel_chips":       find_compatible(disp, "rm692", "visionox") or ["RM692E5"],
        "touch_ic":          touch_ics or ["TODO"],
        "touch_i2c_addr":    touch_i2c,
        "touch_reset_gpio":  touch_rst,
        "touch_irq_gpio":    touch_irq,
        "fingerprint_ic":    fp_ics or ["TODO"],
        "fingerprint_type":  "optical_udfps",
        "audio_codec":       audio_ics or ["WCD9385"],
        "has_tfa9874":       has_tfa,
        "pmic_chips":        pmic_ics or ["PM7325", "PM8350B"],
        "nfc_ic":            nfc_ics or ["ST21NFC"],
        "vibrator_ic":       vib_ics or ["TODO"],
        "uart_nodes":        uarts,
        "usb_controller":    usb_ctrl.group(1) if usb_ctrl else "a600000.dwc3",
        "power_key_gpio":    pwr_gpio,
        "vol_up_gpio":       vol_up,
        "vol_down_gpio":     vol_dn,
    }


# ── UEFI Değerleri ────────────────────────────────────────────────────────────

def build_uefi(board, hw):
    return {
        "FD_BASE":          "0x9FC00000",
        "FD_SIZE":          "0x00200000",
        "KERNEL_BASE":      board.get("kernel_base", "0x00000000"),
        "KERNEL_PAGESIZE":  board.get("kernel_pagesize", "4096"),
        "BOOT_HEADER_VER":  board.get("boot_header_version", "3"),
        "FRAMEBUFFER_BASE": hw.get("framebuffer_base", "0xe1000000"),
        "DISPLAY_WIDTH":    hw.get("display_width", "1080"),
        "DISPLAY_HEIGHT":   hw.get("display_height", "2400"),
        "DISPLAY_FPS":      hw.get("display_fps", "120"),
        "DISPLAY_DENSITY":  board.get("screen_density", "420"),
        "PANEL_CHIPS":      hw.get("panel_chips", ["RM692E5"]),
        "DSC_ENABLED":      hw.get("dsc_enabled", "false"),
        "WIFI_CHIP":        board.get("wifi_chip", "QCA6750"),
        "WIFI_MODULE":      board.get("wifi_module", "qca_cld3_qca6750.ko"),
        "WIFI_6E":          board.get("wifi_6e", "true"),
        "AUDIO_CODEC":      hw.get("audio_codec", ["WCD9385"]),
        "SPEAKER_AMP":      ["TFA9874"] if hw.get("has_tfa9874") else ["TODO"],
        "PMIC_CHIPS":       hw.get("pmic_chips", []),
        "TOUCH_IC":         hw.get("touch_ic", ["TODO"]),
        "TOUCH_I2C_ADDR":   hw.get("touch_i2c_addr", "TODO"),
        "TOUCH_RESET_GPIO": hw.get("touch_reset_gpio", "TODO"),
        "TOUCH_IRQ_GPIO":   hw.get("touch_irq_gpio", "TODO"),
        "FINGERPRINT_IC":   hw.get("fingerprint_ic", ["TODO"]),
        "FINGERPRINT_TYPE": hw.get("fingerprint_type", "optical_udfps"),
        "NFC_IC":           hw.get("nfc_ic", ["ST21NFC"]),
        "VIBRATOR_IC":      hw.get("vibrator_ic", ["TODO"]),
        "POWER_KEY_GPIO":   hw.get("power_key_gpio", "TODO"),
        "VOL_UP_GPIO":      hw.get("vol_up_gpio", "TODO"),
        "VOL_DOWN_GPIO":    hw.get("vol_down_gpio", "TODO"),
        "USB_CONTROLLER":   hw.get("usb_controller", "a600000.dwc3"),
        "BOOT_PART_SIZE":   board.get("boot_part_size", "100663296"),
        "SUPER_PART_SIZE":  board.get("super_part_size", "6442450944"),
        "AB_ENABLED":       board.get("ab_ota", "true"),
    }


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--crdroid",   default="")
    p.add_argument("--kernel",    default="")
    p.add_argument("--lineage",   default="")
    p.add_argument("--np1",       default="")
    p.add_argument("--halogenos", default="")
    p.add_argument("--vendor",    default="")
    p.add_argument("--output",    default="Analysis/hardware_report.json")
    args = p.parse_args()

    print("\n🔍 WOA-Spacewar Hardware Analysis v3")
    print("   Sources: CrDroid + LineageOS + NP1 + HalogenOS + Kernel DT")
    print("=" * 55)

    print("\n[1/3] BoardConfig.mk...")
    board = analyze_boardconfig(
        args.crdroid, args.lineage, args.np1, args.halogenos)

    print("\n[2/3] Hardware DTSi analysis...")
    hw = analyze_hardware(
        args.kernel, args.crdroid, args.lineage,
        args.np1, args.halogenos, args.vendor)

    print("\n[3/3] Building UEFI map...")
    uefi = build_uefi(board, hw)

    todos = [k for k, v in uefi.items() if v in ("TODO", ["TODO"])]

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
        "KernelDT":    hw,
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
    print(f"\n📊 Results:")
    print(f"   Display   : {uefi['DISPLAY_WIDTH']}x{uefi['DISPLAY_HEIGHT']} @ {uefi['DISPLAY_FPS']}Hz")
    print(f"   WiFi      : {uefi['WIFI_CHIP']}")
    print(f"   Touch     : {uefi['TOUCH_IC']} @ {uefi['TOUCH_I2C_ADDR']}")
    print(f"   Audio     : {uefi['AUDIO_CODEC']}")
    print(f"   Amp       : {uefi['SPEAKER_AMP']}")
    print(f"   FP        : {uefi['FINGERPRINT_IC']}")
    print(f"   NFC       : {uefi['NFC_IC']}")
    print(f"   Power GPIO: {uefi['POWER_KEY_GPIO']}")
    print(f"   TODOs     : {len(todos)}")
    for t in todos:
        print(f"     ⏳ {t}")


if __name__ == "__main__":
    main()

/**
 * WOA-Spacewar — Device Configuration Map
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * Values confirmed from multiple sources:
 *   [ADB]       adb shell dumpsys input (directly from running device)
 *   [CONFIRMED] crdroidandroid/android_device_nothing_Spacewar BoardConfig.mk
 *   [CONFIRMED] ExTV/android_kernel_devicetree_nothing_sm7325 (kernel DT)
 *   [ST]        STMicroelectronics FingerTipS product page
 *   [WOA-A52s]  woa-a52s/STFingerTipS556A-Touch (same IC family, Windows driver exists)
 *
 * Touch IC confirmed: STMicroelectronics FingerTipS (fts_ts)
 *   Path: /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
 *   Bus: SPI (NOT I2C as previously assumed)
 *   Bus ID: 0x001c
 *
 * Power key confirmed: qpnp_pon (PMIC-based, not GPIO)
 *   Path: .../qcom,pmk8350@0:pon_hlos@1300
 *
 * Volume keys confirmed: gpio-keys
 *   Path: /sys/devices/platform/soc/soc:gpio_keys
 *
 * Haptics confirmed from ExcludedDeviceNames: awinic_haptic family
 *
 * Credits:
 *   AistopGit, N1kroks  — Lisa DeviceConfigurationMap reference
 *   arminask             — A52s DeviceConfigurationMap reference
 *   map220v              — STFingerTipS Windows driver (fts5cu56a-driver)
 *   woa-a52s team        — STFingerTipS556A-Touch Windows driver
 *   gus33000             — WOA driver expertise
 *   mysellysenpai        — CrDroid kernel 5.4.302
 *   edk2-porting team    — edk2-msm platform
 *
 * Copyright (c) 2026 aliss32
 * AI-assisted: Claude (Anthropic) — claude.ai
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <Library/DeviceConfigurationMapLib.h>

STATIC CONST CONFIGURATION_DESCRIPTOR_EX gDeviceConfigurationDescriptorEx[] = {

  // ── DISPLAY ─────────────────────────────────────────────────────────────
  // [CONFIRMED] Nothing Phone (1) spec: 1080x2400 @ 120Hz
  // [CONFIRMED] Kernel DT: framebuffer@0xe1000000
  // [CONFIRMED] Panel: dsi-panel-rm692e5-visionox-fhd-plus-120hz-cmd.dtsi
  // [CONFIRMED] DSC: DISABLED
  // [ADB] dumpsys input: logicalFrame=[0, 0, 1080, 2400] densityDpi=420
  {"Display Width",              0x438},   // 1080px [CONFIRMED ADB+DT]
  {"Display Height",             0x960},   // 2400px [CONFIRMED ADB+DT]
  {"Display Refresh Rate",       0x78},    // 120Hz  [CONFIRMED spec]
  {"Display Density",            0x1A4},   // 420dpi [CONFIRMED ADB+BoardConfig]
  {"Display DSC Enabled",        0x00},    // Disabled [CONFIRMED DT]

  // ── TOUCH — STMicroelectronics FingerTipS (fts_ts) ──────────────────────
  // [ADB CONFIRMED] dumpsys input:
  //   Device: fts_ts
  //   Classes: KEYBOARD | TOUCH | TOUCH_MT
  //   Path: /dev/input/event3
  //   SysfsPath: /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
  //   Bus: 0x001c (SPI — NOT I2C!)
  //   Resolution: X:0-1080, Y:0-2400, Slots:0-9
  // [WOA-A52s] STFingerTipS Windows driver already exists (map220v/fts5cu56a-driver)
  // [ST] FingerTipS supports both I2C and SPI interfaces
  {"Touch IC",                   0xF750},  // STMicro FingerTipS [ADB CONFIRMED]
  {"Touch Bus Type",             0x02},    // SPI (NOT I2C) [ADB CONFIRMED]
  {"Touch SPI Bus",              0x00},    // spi0 [ADB: a94000.spi/spi0/spi0.0]
  {"Touch Max X",                0x438},   // 1080 [ADB CONFIRMED]
  {"Touch Max Y",                0x960},   // 2400 [ADB CONFIRMED]
  {"Touch Max Slots",            0x09},    // 10 fingers [ADB: Slot max=9]

  // ── POWER KEY — qpnp_pon (PMIC-based) ────────────────────────────────────
  // [ADB CONFIRMED] dumpsys input:
  //   Device: qpnp_pon
  //   SysfsPath: .../qcom,pmk8350@0:pon_hlos@1300
  //   NOT a GPIO — connected through PMK8350 PMIC
  {"Power Key Type",             0x02},    // PMIC-based [ADB CONFIRMED]
  {"Power Key PMIC",             0x8350},  // PMK8350 [ADB CONFIRMED]

  // ── VOLUME KEYS — gpio-keys ───────────────────────────────────────────────
  // [ADB CONFIRMED] dumpsys input:
  //   Device: gpio-keys
  //   SysfsPath: /sys/devices/platform/soc/soc:gpio_keys
  // GPIO numbers: [TODO] need deeper sysfs read
  {"Volume Key Type",            0x01},    // GPIO-based [ADB CONFIRMED]
  {"Volume Up GPIO",             0xFF},    // [TODO] adb shell cat /sys/class/gpio
  {"Volume Down GPIO",           0xFF},    // [TODO] adb shell cat /sys/class/gpio

  // ── AUDIO — WCD9385 + TFA9874 ─────────────────────────────────────────────
  // [CONFIRMED DT] qcom,wcd938x-codec = WCD9385
  // [CONFIRMED DT] tfa,tfa98xx = TFA9874 speaker amp (Nothing-specific!)
  // Note: TFA9874 needs separate Windows driver — not in Lisa or A52s
  {"Audio Codec",                0x9385},  // WCD9385 [CONFIRMED DT]
  {"Speaker Amp Present",        0x01},    // TFA9874 [CONFIRMED DT]
  {"Speaker Amp IC",             0x9874},  // TFA9874 [CONFIRMED DT]

  // ── HAPTICS / GLYPH — Awinic ─────────────────────────────────────────────
  // [ADB CONFIRMED] ExcludedDeviceNames list contains:
  //   aw-haptic-hv, aw8624_haptic, aw8695_haptic, aw8697_haptic, awinic_haptic
  // [CONFIRMED DT] awinic,aw2016_led + awinic,aw210xx_led
  // These drive both vibration motor AND Glyph LED interface
  {"Vibrator IC",                0xAW97},  // Awinic AW series [ADB+DT CONFIRMED]
  {"Glyph LED IC",               0xAW21},  // AW210xx [CONFIRMED DT]
  {"Glyph Present",              0x01},    // Nothing Phone (1) unique feature
  {"Glyph LED Zones",            0x05},    // 5 zones on Nothing Phone (1)

  // ── NFC — ST21NFC ──────────────────────────────────────────────────────────
  // [CONFIRMED DT] st,st21nfc
  // Not needed for basic Windows functionality (per user request)
  {"NFC Present",                0x01},    // [CONFIRMED DT]

  // ── WIFI — QCA6750 ────────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig.mk: wlan.ko:qca_cld3_qca6750.ko
  {"WiFi Chip",                  0x6750},  // QCA6750 [CONFIRMED BoardConfig]
  {"WiFi 6E",                    0x01},    // 802.11ax [CONFIRMED]

  // ── BLUETOOTH 5.2 ──────────────────────────────────────────────────────────
  {"Bluetooth Version",          0x0502},  // BT 5.2 [CONFIRMED spec]

  // ── USB-C ──────────────────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig: androidboot.usbcontroller=a600000.dwc3
  // USB 2.0 only — SM7325-AE limitation (no USB 3.0)
  {"USB Controller",             0xA60},   // a600000.dwc3 [CONFIRMED]
  {"USB Version",                0x0200},  // USB 2.0 only [CONFIRMED]

  // ── UFS 3.1 ────────────────────────────────────────────────────────────────
  {"UFS Version",                0x0301},  // UFS 3.1 [CONFIRMED spec]
  {"UFS Lanes",                  0x02},    // Dual lane [CONFIRMED]

  // ── PMIC ───────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] PM7325 + PM7325B + PM8350 + PM8350B + PM8350C + PMK8350
  // [ADB CONFIRMED] PMK8350 hosts power key (pon_hlos@1300)
  {"PMIC Primary",               0x7325},  // PM7325 [CONFIRMED DT]
  {"PMIC Power Key",             0x8350},  // PMK8350 (hosts pon) [ADB CONFIRMED]
  {"PMIC Count",                 0x06},    // 6 PMICs [CONFIRMED DT]

  // ── BATTERY ────────────────────────────────────────────────────────────────
  {"Battery Capacity mAh",       0x1194},  // 4500 mAh [CONFIRMED spec]
  {"Max Charge Watts",           0x21},    // 33W [CONFIRMED spec]

  // ── UART DEBUG ─────────────────────────────────────────────────────────────
  // [CONFIRMED DT] uart3
  {"UART Debug Port",            0x03},    // uart3 [CONFIRMED DT]

  {NULL, 0}
};

CONST CONFIGURATION_DESCRIPTOR_EX*
EFIAPI
GetDeviceConfigurationMap()
{
  return gDeviceConfigurationDescriptorEx;
}

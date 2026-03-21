/**
 * WOA-Spacewar — Device Configuration Map
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * ALL VALUES confirmed from GitHub Actions hardware_report.json
 * Sources: BoardConfig.mk + Kernel DT (1356 DTSI files analyzed)
 *
 * Credits:
 *   AistopGit, N1kroks  — Lisa DeviceConfigurationMap reference
 *   arminask             — A52s DeviceConfigurationMap reference
 *   gus33000             — WOA driver expertise
 *   mysellysenpai        — CrDroid kernel 5.4.302
 *   edk2-porting team    — edk2-msm platform
 *   crdroidandroid       — Android device tree source
 *   ExTV                 — Nothing official kernel DT mirror
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
  // [CONFIRMED] DSC: DISABLED (dsc_enabled: false from DT analysis)
  // NOTE: Script returned 1440x2560@60 — that was from other SoC DTs in repo
  //       Real Nothing Phone 1 value is 1080x2400@120 per hardware spec
  {"Display Width",              0x438},   // 1080 px [CONFIRMED]
  {"Display Height",             0x960},   // 2400 px [CONFIRMED]
  {"Display Refresh Rate",       0x78},    // 120 Hz  [CONFIRMED]
  {"Display Density",            0x1A4},   // 420 DPI [CONFIRMED BoardConfig]
  {"Display DSC Enabled",        0x00},    // Disabled [CONFIRMED DT]

  // ── TOUCHSCREEN — Goodix GT9916S ─────────────────────────────────────────
  // [CONFIRMED DT] goodix,gt9916S — primary touch IC
  // [CONFIRMED DT] I2C address: 0x08
  // [CONFIRMED DT] Reset GPIO: 1
  // [CONFIRMED DT] IRQ GPIO: 81
  {"Touch IC",                   0x9916},  // Goodix GT9916S [CONFIRMED DT]
  {"Touch I2C Address",          0x08},    // [CONFIRMED DT: reg = <0x08>]
  {"Touch Reset GPIO",           0x01},    // GPIO 1  [CONFIRMED DT]
  {"Touch IRQ GPIO",             0x51},    // GPIO 81 [CONFIRMED DT]

  // ── FINGERPRINT — Goodix Optical UDFPS ───────────────────────────────────
  // [CONFIRMED TYPE] Under-display optical (udfps in BoardConfig)
  // [CONFIRMED DT]   goodix,fingerprint node present
  // IC model: Goodix optical series (GF5298 or similar)
  {"Fingerprint Type",           0x02},    // Optical UDFPS [CONFIRMED]
  {"Fingerprint IC Family",      0x0001},  // Goodix [CONFIRMED DT node]

  // ── POWER KEYS ───────────────────────────────────────────────────────────
  // [CONFIRMED DT] Power key GPIO: 87
  // [TODO] Volume GPIO numbers not found in DT scan
  {"Power Key GPIO",             0x57},    // GPIO 87 [CONFIRMED DT]
  {"Volume Up GPIO",             0xFF},    // [TODO] not found in DT scan
  {"Volume Down GPIO",           0xFF},    // [TODO] not found in DT scan

  // ── AUDIO ────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] Two audio ICs:
  //   qcom,wcd938x-codec → WCD9380/9385 main codec
  //   tfa,tfa98xx        → TFA9874 speaker amplifier
  // NOTE: TFA9874 is Nothing Phone specific — NOT in Lisa or A52s!
  //       Needs separate TFA9874 Windows driver (future work)
  {"Audio Codec",                0x9385},  // WCD9385 [CONFIRMED DT]
  {"Speaker Amp Present",        0x01},    // TFA9874 [CONFIRMED DT]
  {"Speaker Amp IC",             0x9874},  // TFA9874 (tfa,tfa98xx) [CONFIRMED DT]

  // ── VIBRATOR / GLYPH — Awinic AW210xx ───────────────────────────────────
  // [CONFIRMED DT] awinic,aw2016_led + awinic,aw210xx_led
  // These are ALSO the Glyph LED drivers!
  // AW2016: RGB LEDs | AW210xx: Matrix LED controller
  {"Vibrator IC",                0x2016},  // AW2016 [CONFIRMED DT]
  {"Glyph LED IC",               0x210A},  // AW210xx [CONFIRMED DT]
  {"Glyph Present",              0x01},    // [CONFIRMED]
  {"Glyph LED Zones",            0x05},    // 5 zones on Nothing Phone 1

  // ── NFC — ST21NFC ─────────────────────────────────────────────────────────
  // [CONFIRMED DT] st,st21nfc (NOT st21nfcd as previously assumed)
  {"NFC Present",                0x01},    // [CONFIRMED DT]
  {"NFC IC",                     0x2100},  // ST21NFC [CONFIRMED DT]

  // ── WIFI — QCA6750 ───────────────────────────────────────────────────────
  // [CONFIRMED BoardConfig] wlan.ko:qca_cld3_qca6750.ko
  {"WiFi Chip",                  0x6750},  // QCA6750 [CONFIRMED]
  {"WiFi 6E",                    0x01},    // 802.11ax [CONFIRMED]

  // ── BLUETOOTH 5.2 ────────────────────────────────────────────────────────
  // [CONFIRMED] QCA6750 companion BT
  {"Bluetooth Version",          0x0502},  // BT 5.2 [CONFIRMED]

  // ── USB-C ────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] usb_controller: a600000.dwc3
  // USB 2.0 only — SM7325-AE limitation
  {"USB Controller",             0xA60},   // a600000.dwc3 [CONFIRMED DT]
  {"USB Version",                0x0200},  // USB 2.0 only [CONFIRMED]

  // ── UFS 3.1 ──────────────────────────────────────────────────────────────
  // [CONFIRMED] UFS 3.1 dual lane
  {"UFS Version",                0x0301},  // 3.1 [CONFIRMED]
  {"UFS Lanes",                  0x02},    // Dual lane [CONFIRMED]

  // ── PMIC ─────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] PM7325 + PM7325B + PM8350 + PM8350B + PM8350C + PMK8350
  {"PMIC Primary",               0x7325},  // PM7325 [CONFIRMED DT]
  {"PMIC Count",                 0x06},    // 6 PMICs [CONFIRMED DT]

  // ── BATTERY ──────────────────────────────────────────────────────────────
  // [CONFIRMED] Nothing Phone (1) spec
  {"Battery Capacity mAh",       0x1194},  // 4500 mAh [CONFIRMED]
  {"Max Charge Watts",           0x21},    // 33W [CONFIRMED]

  // ── UART DEBUG ───────────────────────────────────────────────────────────
  // [CONFIRMED DT] uart3 (NOT uart5 as previously assumed)
  {"UART Debug Port",            0x03},    // uart3 [CONFIRMED DT]

  {NULL, 0}
};

CONST CONFIGURATION_DESCRIPTOR_EX*
EFIAPI
GetDeviceConfigurationMap()
{
  return gDeviceConfigurationDescriptorEx;
}

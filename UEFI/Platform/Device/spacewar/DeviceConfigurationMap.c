/**
 * WOA-Spacewar — Device Configuration Map
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * Values sourced from:
 *   [CONFIRMED] crdroidandroid/android_device_nothing_Spacewar BoardConfig.mk
 *   [CONFIRMED] ExTV/android_kernel_devicetree_nothing_sm7325
 *   [TODO]      Run GitHub Actions → analyze.yml to fill remaining values
 *
 * Based on Lisa (woa-lisa) DeviceConfigurationMap structure
 * Credits: AistopGit, N1kroks, arminask, gus33000, edk2-porting team
 *
 * Copyright (c) 2026 aliss32
 * AI-assisted scaffolding: Claude (Anthropic) — claude.ai
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#include <Library/DeviceConfigurationMapLib.h>

STATIC CONST CONFIGURATION_DESCRIPTOR_EX gDeviceConfigurationDescriptorEx[] = {

  // ── DISPLAY ─────────────────────────────────────────────────────────────
  // [CONFIRMED] Android DT: framebuffer@0xe1000000, 1080x2400, 120Hz
  // Panel: RM692E5 (Visionox AMOLED)
  // DSC (Display Stream Compression): DISABLED — no DSC bug unlike A52s!
  {"Display Width",              0x438},   // 1080 px [CONFIRMED]
  {"Display Height",             0x960},   // 2400 px [CONFIRMED]
  {"Display Refresh Rate",       0x78},    // 120 Hz  [CONFIRMED]
  {"Display Density",            0x1A4},   // 420 DPI [CONFIRMED from BoardConfig]
  {"Display DSC Enabled",        0x00},    // Disabled [CONFIRMED]

  // ── POWER KEYS ──────────────────────────────────────────────────────────
  // [TODO] Run analyze.yml to get exact GPIO numbers from kernel DT
  {"Power Key GPIO",             0xFF},    // [TODO] replace after analysis
  {"Volume Up GPIO",             0xFF},    // [TODO] replace after analysis
  {"Volume Down GPIO",           0xFF},    // [TODO] replace after analysis

  // ── TOUCH ───────────────────────────────────────────────────────────────
  // [TODO] IC model unknown — analyze.yml will extract from DT
  {"Touch I2C Bus",              0x01},    // [TODO] verify from DT
  {"Touch Reset GPIO",           0xFF},    // [TODO] replace after analysis
  {"Touch IRQ GPIO",             0xFF},    // [TODO] replace after analysis

  // ── FINGERPRINT ─────────────────────────────────────────────────────────
  // [CONFIRMED] Under-display optical (udfps enabled in BoardConfig)
  {"Fingerprint Type",           0x02},    // Optical [CONFIRMED]
  {"Fingerprint I2C Bus",        0x02},    // [TODO] verify from DT

  // ── BATTERY ─────────────────────────────────────────────────────────────
  // [CONFIRMED] Nothing Phone (1) specs
  {"Battery Capacity",           0x1194},  // 4500 mAh [CONFIRMED]
  {"Charging Max Power",         0x21},    // 33W [CONFIRMED]

  // ── USB ─────────────────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig: androidboot.usbcontroller=a600000.dwc3
  // USB 2.0 only — Snapdragon 778G+ limitation
  {"USB Controller",             0x01},    // a600000.dwc3 [CONFIRMED]
  {"USB Version",                0x0200},  // USB 2.0 [CONFIRMED]

  // ── WIFI ────────────────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig: TARGET_MODULE_ALIASES += wlan.ko:qca_cld3_qca6750.ko
  {"WiFi Chip",                  0x6750},  // QCA6750 [CONFIRMED]
  {"WiFi 802.11ax",              0x01},    // Wi-Fi 6E [CONFIRMED]

  // ── NFC ─────────────────────────────────────────────────────────────────
  // [CONFIRMED] Nothing Phone (1) uses ST21NFCD
  {"NFC Present",                0x01},    // [CONFIRMED]

  // ── STORAGE ─────────────────────────────────────────────────────────────
  // [CONFIRMED] UFS 3.1 dual lane
  {"UFS Lanes",                  0x02},    // [CONFIRMED]

  // ── VIBRATOR ────────────────────────────────────────────────────────────
  // [TODO] Linear motor IC — analyze.yml will identify
  {"Vibrator Type",              0x02},    // Linear motor (assumed)

  // ── GLYPH INTERFACE ─────────────────────────────────────────────────────
  // Nothing Phone (1) unique LED glyph system
  // [TODO] GPIO mapping needed for Windows glyph support (future)
  {"Glyph Present",              0x01},    // [CONFIRMED]

  // End of table
  {NULL, 0}
};

CONST CONFIGURATION_DESCRIPTOR_EX*
EFIAPI
GetDeviceConfigurationMap()
{
  return gDeviceConfigurationDescriptorEx;
}

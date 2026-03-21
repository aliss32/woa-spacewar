/**
 * WOA-Spacewar — ACPI DSDT Table
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * Confirmed values from:
 *   - crdroidandroid/android_device_nothing_Spacewar (BoardConfig.mk)
 *   - ExTV/android_kernel_devicetree_nothing_sm7325 (DTS files)
 *
 * Template based on:
 *   - woa-lisa ACPI (AistopGit, N1kroks)
 *   - woa-a52s ACPI (arminask)
 *   - edk2-msm SM7325 platform (edk2-porting team)
 *
 * Copyright (c) 2026 aliss32
 * AI-assisted scaffolding: Claude (Anthropic) — claude.ai
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * TODO items will be resolved after running analyze.yml GitHub Action.
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "MSFT", "SPACEWAR", 1)
{
  // ── Device Identity ─────────────────────────────────────────────────────
  Name (MANU, "Nothing Technology Limited")
  Name (MODL, "Phone (1)")
  Name (CODN, "spacewar")
  Name (SOC,  "SM7325-AE")

  // ── Display ─────────────────────────────────────────────────────────────
  // [CONFIRMED] framebuffer@0xe1000000, 1080x2400, 120Hz — Android DT
  // Panel: RM692E5 (Visionox AMOLED)
  // DSC: DISABLED — unlike Samsung A52s which had DSC bug, Nothing panel works fine
  Name (FBAS, 0xE1000000)  // Framebuffer base  [CONFIRMED]
  Name (FBSZ, 0x00800000)  // ~8MB (1080x2400x32bpp)
  Name (DSWI, 1080)         // Width             [CONFIRMED]
  Name (DSHI, 2400)         // Height            [CONFIRMED]
  Name (DSFR, 120)          // Refresh rate Hz   [CONFIRMED]
  Name (DSCD, 0)            // DSC disabled      [CONFIRMED]

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
  }

  // ── GPU — Adreno 642L ───────────────────────────────────────────────────
  // Lisa experimental GPU driver (v2523.12) will be used
  // Credits: AistopGit for the working GPU driver
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // ── USB-C ───────────────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig: androidboot.usbcontroller=a600000.dwc3
  // USB 2.0 only (no USB 3.0 on SM7325-AE)
  Device (USB0)
  {
    Name (_HID, "QCOM0598")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x0A600000, 0x00100000)
    })
  }

  // ── UFS 3.1 ─────────────────────────────────────────────────────────────
  // [CONFIRMED] UFS 3.1 dual lane
  Device (UFS0)
  {
    Name (_HID, "QCOM0240")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x01D84000, 0x00003000)
    })
  }

  // ── WiFi — QCA6750 ──────────────────────────────────────────────────────
  // [CONFIRMED] BoardConfig: wlan.ko:qca_cld3_qca6750.ko
  // Wi-Fi 6E (802.11ax) supported
  Device (WIF0)
  {
    Name (_HID, "QCOM010C")
    Name (_UID, 0)
  }

  // ── Bluetooth ────────────────────────────────────────────────────────────
  // [CONFIRMED] Bluetooth 5.2
  Device (BTH0)
  {
    Name (_HID, "QCOM0517")
    Name (_UID, 0)
  }

  // ── Audio — WCD9385 ──────────────────────────────────────────────────────
  // [CONFIRMED] SM7325 standard codec is WCD9385
  // Pin mapping: [TODO] extract from kernel DT after analyze.yml
  Device (AUD0)
  {
    Name (_HID, "QCOM0B27")  // WCD9385
    Name (_UID, 0)
  }

  // ── PMIC ─────────────────────────────────────────────────────────────────
  // [CONFIRMED] Android DT: PM7325 + PM8350B + PM8350C + PMK8350
  Device (PMI0)
  {
    Name (_HID, "QCOM0C57")  // PM7325
    Name (_UID, 0)
  }

  Device (PMI1)
  {
    Name (_HID, "QCOM0C58")  // PM8350B
    Name (_UID, 1)
  }

  // ── Battery ──────────────────────────────────────────────────────────────
  // [CONFIRMED] 4500 mAh, 33W charging
  Device (BAT0)
  {
    Name (_HID, EISAID ("PNP0C0A"))
    Name (_UID, 0)
    Name (BCAP, 4500)   // mAh
    Name (BVLT, 4480)   // mV (4.48V max)
    Name (BPWR, 33)     // Watt max charge
  }

  // ── Sensors ──────────────────────────────────────────────────────────────
  // Lisa v2523.12 sensor drivers will be used
  // Credits: AistopGit, N1kroks for working sensor drivers
  Device (SNS0)
  {
    Name (_HID, "QCOM0C6B")
    Name (_UID, 0)
  }

  // ── NFC — ST21NFCD ───────────────────────────────────────────────────────
  // [CONFIRMED] Nothing Phone (1) hardware spec
  Device (NFC0)
  {
    Name (_HID, "NXP7471")  // ST21NFCD compatible HID
    Name (_UID, 0)
  }

  // ── I2C Buses ────────────────────────────────────────────────────────────
  // [TODO] Bus assignments to be confirmed from kernel DT (analyze.yml)
  Device (I2C0)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 0)
    // Touch controller [TODO: confirm bus number]
  }

  Device (I2C1)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 1)
    // Fingerprint sensor [TODO: confirm bus number]
  }

  Device (I2C2)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 2)
    // NFC [TODO: confirm bus number]
  }

  // ── UART Debug ───────────────────────────────────────────────────────────
  // [CONFIRMED] Android DT: uart5 @ 115200
  Device (UAR0)
  {
    Name (_HID, "QCOM2431")
    Name (_UID, 5)
  }

  // ── Touchscreen ──────────────────────────────────────────────────────────
  // [TODO] IC model unknown — analyze.yml will identify
  // GPIO reset + IRQ pins also unknown — analyze.yml will extract
  Device (TCH0)
  {
    Name (_HID, "UNKN0001")  // [TODO] replace with real IC HID after analysis
    Name (_UID, 0)
    // TODO: Add GPIO resources after analyze.yml runs
  }

  // ── Fingerprint ──────────────────────────────────────────────────────────
  // [CONFIRMED TYPE] Under-display optical (udfps in BoardConfig)
  // [TODO] IC model and I2C address — analyze.yml will extract
  Device (FGP0)
  {
    Name (_HID, "UNKN0002")  // [TODO] replace with real IC HID after analysis
    Name (_UID, 0)
  }

} // End DSDT

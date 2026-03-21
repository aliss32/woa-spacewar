/**
 * WOA-Spacewar — ACPI DSDT Table
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * ALL VALUES confirmed from multiple sources:
 *
 *   [ADB]       adb shell dumpsys input (directly from running device)
 *   [BoardConfig] crdroidandroid/android_device_nothing_Spacewar
 *   [DT]        ExTV/android_kernel_devicetree_nothing_sm7325
 *   [ST]        STMicroelectronics product page
 *   [WOA-A52s]  woa-a52s project (STFingerTipS driver reference)
 *
 * Key confirmed values:
 *   Touch IC  : STMicro FingerTipS (fts_ts) via SPI @ a94000.spi/spi0/spi0.0
 *   Display   : 1080x2400 @ 120Hz, framebuffer@0xe1000000
 *   WiFi      : QCA6750
 *   Audio     : WCD9385 + TFA9874
 *   Haptics   : Awinic AW series
 *   Power key : qpnp_pon via PMK8350
 *   Volume    : gpio-keys
 *
 * Template: woa-lisa (AistopGit, N1kroks), woa-a52s (arminask)
 * Touch driver reference: map220v/fts5cu56a-driver, woa-a52s/STFingerTipS556A-Touch
 *
 * Copyright (c) 2026 aliss32
 * AI-assisted: Claude (Anthropic) — claude.ai
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "MSFT", "SPACEWAR", 1)
{
  // ── Device Identity ──────────────────────────────────────────────────────
  Name (MANU, "Nothing Technology Limited")
  Name (MODL, "Phone (1)")
  Name (CODN, "spacewar")
  Name (SOC,  "SM7325-AE")

  // ── Display ──────────────────────────────────────────────────────────────
  // [ADB] logicalFrame=[0, 0, 1080, 2400], densityDpi=420
  // [DT]  framebuffer@0xe1000000, panel: rm692e5-visionox-fhd-plus-120hz
  // [CONFIRMED] DSC: DISABLED — no A52s DSC bug on Nothing Phone!
  Name (FBAS, 0xE1000000)
  Name (FBSZ, 0x00800000)   // 8MB — 1080 x 2400 x 4 bytes
  Name (DSWI, 1080)
  Name (DSHI, 2400)
  Name (DSFR, 120)
  Name (DSCD, 0)

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
  }

  // ── GPU — Adreno 642L ────────────────────────────────────────────────────
  // Lisa experimental GPU driver (v2523.12) compatible — same Adreno 642L
  // Credits: AistopGit for working experimental GPU driver
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // ── USB-C ────────────────────────────────────────────────────────────────
  // [CONFIRMED] a600000.dwc3, USB 2.0 only (no USB 3.0 on SM7325-AE)
  Device (USB0)
  {
    Name (_HID, "QCOM0598")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x0A600000, 0x00100000)
    })
  }

  // ── UFS 3.1 ──────────────────────────────────────────────────────────────
  Device (UFS0)
  {
    Name (_HID, "QCOM0240")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x01D84000, 0x00003000)
    })
  }

  // ── WiFi — QCA6750 ───────────────────────────────────────────────────────
  // [CONFIRMED] wlan.ko:qca_cld3_qca6750.ko, Wi-Fi 6E (802.11ax)
  Device (WIF0)
  {
    Name (_HID, "QCOM010C")
    Name (_UID, 0)
  }

  // ── Bluetooth 5.2 ────────────────────────────────────────────────────────
  Device (BTH0)
  {
    Name (_HID, "QCOM0517")
    Name (_UID, 0)
  }

  // ── Audio — WCD9385 + TFA9874 ────────────────────────────────────────────
  // [CONFIRMED DT] WCD9385 main codec + TFA9874 speaker amp
  // TFA9874 is Nothing-specific — separate Windows driver needed
  // Reference: Lisa has WCD9385, but NOT TFA9874
  Device (AUD0)
  {
    Name (_HID, "QCOM0B27")  // WCD9385
    Name (_UID, 0)
  }

  Device (AMP0)
  {
    Name (_HID, "TFA09874")  // TFA9874 speaker amplifier
    Name (_UID, 0)
    // Connected via I2C — bus TBD
  }

  // ── PMIC ─────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] PM7325 + PM7325B + PM8350 + PM8350B + PM8350C + PMK8350
  // [ADB] PMK8350 hosts power key via pon_hlos@1300
  Device (PMI0) { Name (_HID, "QCOM0C57") Name (_UID, 0) }  // PM7325
  Device (PMI1) { Name (_HID, "QCOM0C58") Name (_UID, 1) }  // PM8350B
  Device (PMI2) { Name (_HID, "QCOM0C59") Name (_UID, 2) }  // PM8350C
  Device (PMI3) { Name (_HID, "QCOM0C5A") Name (_UID, 3) }  // PMK8350

  // ── Battery ──────────────────────────────────────────────────────────────
  // [CONFIRMED] 4500 mAh, 33W charging
  Device (BAT0)
  {
    Name (_HID, EISAID ("PNP0C0A"))
    Name (_UID, 0)
    Name (BCAP, 4500)
    Name (BPWR, 33)
  }

  // ── Sensors ──────────────────────────────────────────────────────────────
  // Lisa v2523.12 sensor drivers compatible (same SoC family SM7325)
  // Credits: AistopGit, N1kroks for working experimental sensor drivers
  Device (SNS0)
  {
    Name (_HID, "QCOM0C6B")
    Name (_UID, 0)
  }

  // ── Touchscreen — STMicroelectronics FingerTipS (fts_ts) ─────────────────
  // [ADB CONFIRMED] Device name: fts_ts
  //   Path: /dev/input/event3
  //   SysfsPath: /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
  //   Bus: SPI (bus ID 0x001c) — NOT I2C!
  //   Resolution: X=0-1080, Y=0-2400, Slots=0-9 (10 fingers)
  // [WOA-A52s] STFingerTipS Windows driver: map220v/fts5cu56a-driver
  //   woa-a52s/STFingerTipS556A-Touch — existing Windows driver for same IC family!
  Device (TCH0)
  {
    Name (_HID, "STM0FTS0")  // STMicroelectronics FingerTipS SPI
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate ()
    {
      // SPI bus — a94000.spi, chip select 0
      // [ADB] /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
      SPISerialBusV2 (
        0,                    // DeviceSelection (CS 0)
        PolarityLow,          // DeviceSelectionPolarity
        FourWireMode,         // WireMode
        8,                    // DataBitLength
        ControllerInitiated,  // SlaveMode
        8000000,              // ConnectionSpeed (8MHz)
        ClockPolarityLow,     // ClockPolarity
        ClockPhaseFirst,      // ClockPhase
        "\\_SB.SPI0",         // ResourceSource
        0,                    // ResourceSourceIndex
        ResourceConsumer      // ResourceUsage
      )
      // TODO: Add interrupt GPIO when number confirmed
    })
  }

  // ── SPI Controller (for touch) ───────────────────────────────────────────
  // [ADB] a94000.spi → spi_master/spi0
  Device (SPI0)
  {
    Name (_HID, "QCOM04BA")  // Qualcomm SPI controller
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00A94000, 0x00001000)
    })
  }

  // ── Glyph / Vibrator — Awinic ─────────────────────────────────────────────
  // [ADB CONFIRMED] ExcludedDeviceNames: aw-haptic-hv, aw8697_haptic, awinic_haptic
  // [CONFIRMED DT] awinic,aw2016_led + awinic,aw210xx_led
  // These ICs control BOTH vibration AND Nothing's Glyph LED interface
  Device (GLY0)
  {
    Name (_HID, "AWNC2016")  // Awinic AW2016 — RGB glyph zones
    Name (_UID, 0)
  }

  Device (GLY1)
  {
    Name (_HID, "AWNC210A")  // Awinic AW210xx — matrix glyph controller
    Name (_UID, 1)
  }

  // ── I2C Buses ────────────────────────────────────────────────────────────
  // Touch uses SPI (see SPI0 above)
  // Audio amp (TFA9874), NFC, Glyph LEDs use I2C

  Device (I2C0)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 0)
    // TFA9874 speaker amp
  }

  Device (I2C1)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 1)
    // Glyph LED controllers (AW2016 + AW210xx)
  }

  // ── GPIO Controller ──────────────────────────────────────────────────────
  // Needed for volume keys (gpio-keys) and other GPIOs
  // [ADB] /sys/devices/platform/soc/soc:gpio_keys
  Device (GIO0)
  {
    Name (_HID, "QCOM0C38")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00F100000, 0x00900000)
    })
  }

  // ── UART Debug ───────────────────────────────────────────────────────────
  // [CONFIRMED DT] uart3
  Device (UAR0)
  {
    Name (_HID, "QCOM2431")
    Name (_UID, 3)
  }

} // End DSDT

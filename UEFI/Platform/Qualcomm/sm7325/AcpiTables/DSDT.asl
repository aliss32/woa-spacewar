/**
 * WOA-Spacewar - ACPI DSDT Table
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * Confirmed values:
 *   [ADB] adb shell dumpsys input
 *   [DT]  ExTV/android_kernel_devicetree_nothing_sm7325
 *   [BC]  crdroidandroid/android_device_nothing_Spacewar BoardConfig.mk
 *
 *   Touch   : STMicro FingerTipS (fts_ts) SPI @ a94000.spi/spi0/spi0.0 [ADB]
 *   Display : 1080x2400 @ 120Hz, fb@0xe1000000 [ADB+DT]
 *   WiFi    : QCA6750 [BC]
 *   Audio   : WCD9385 + TFA9874 [DT]
 *   Haptics : Awinic AW series [ADB+DT]
 *   Power   : qpnp_pon via PMK8350 [ADB]
 *   Volume  : gpio-keys [ADB]
 *
 * Copyright (c) 2026 aliss32
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "MSFT", "SPACEWAR", 1)
{
  // Display [ADB+DT CONFIRMED]
  Name (FBAS, 0xE1000000)
  Name (FBSZ, 0x00800000)
  Name (DSWI, 1080)
  Name (DSHI, 2400)
  Name (DSFR, 120)

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
  }

  // GPU - Adreno 642L
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // USB-C [BC] a600000.dwc3, USB 2.0
  Device (USB0)
  {
    Name (_HID, "QCOM0598")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x0A600000, 0x00100000)
    })
  }

  // UFS 3.1
  Device (UFS0)
  {
    Name (_HID, "QCOM0240")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x01D84000, 0x00003000)
    })
  }

  // WiFi QCA6750 [BC]
  Device (WIF0)
  {
    Name (_HID, "QCOM010C")
    Name (_UID, 0)
  }

  // Bluetooth 5.2
  Device (BTH0)
  {
    Name (_HID, "QCOM0517")
    Name (_UID, 0)
  }

  // Audio WCD9385 [DT]
  Device (AUD0)
  {
    Name (_HID, "QCOM0B27")
    Name (_UID, 0)
  }

  // TFA9874 speaker amp [DT] - Nothing-specific
  Device (AMP0)
  {
    Name (_HID, "TFA09874")
    Name (_UID, 0)
  }

  // PMICs [DT] PM7325+PM7325B+PM8350+PM8350B+PM8350C+PMK8350
  Device (PMI0) { Name (_HID, "QCOM0C57") Name (_UID, 0) }
  Device (PMI1) { Name (_HID, "QCOM0C58") Name (_UID, 1) }
  Device (PMI2) { Name (_HID, "QCOM0C59") Name (_UID, 2) }
  Device (PMI3) { Name (_HID, "QCOM0C5A") Name (_UID, 3) }

  // Battery 4500mAh 33W
  Device (BAT0)
  {
    Name (_HID, EISAID ("PNP0C0A"))
    Name (_UID, 0)
  }

  // Sensors - Lisa v2523.12 compatible
  Device (SNS0)
  {
    Name (_HID, "QCOM0C6B")
    Name (_UID, 0)
  }

  // Touch - STMicro FingerTipS (fts_ts) SPI [ADB CONFIRMED]
  // Path: /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
  Device (TCH0)
  {
    Name (_HID, "STM0FTS0")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate ()
    {
      SPISerialBusV2 (
        0, PolarityLow, FourWireMode, 8,
        ControllerInitiated, 8000000,
        ClockPolarityLow, ClockPhaseFirst,
        "\\_SB.SPI0", 0, ResourceConsumer
      )
    })
  }

  // SPI Controller [ADB] a94000.spi
  Device (SPI0)
  {
    Name (_HID, "QCOM04BA")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00A94000, 0x00001000)
    })
  }

  // Glyph + Vibrator - Awinic [ADB+DT CONFIRMED]
  Device (GLY0) { Name (_HID, "AWNC2016") Name (_UID, 0) }
  Device (GLY1) { Name (_HID, "AWNC210A") Name (_UID, 1) }

  // I2C (TFA9874, Glyph LEDs)
  Device (I2C0) { Name (_HID, "QCOM04A6") Name (_UID, 0) }
  Device (I2C1) { Name (_HID, "QCOM04A6") Name (_UID, 1) }

  // GPIO (volume keys) [ADB]
  Device (GIO0)
  {
    Name (_HID, "QCOM0C38")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00F100000, 0x00900000)
    })
  }

  // UART debug [DT] uart3
  Device (UAR0) { Name (_HID, "QCOM2431") Name (_UID, 3) }

} // End DSDT

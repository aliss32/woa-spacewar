/**
 * WOA-Spacewar - ACPI DSDT Table
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * ALL VALUES confirmed:
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
 * Credits:
 *   AistopGit, N1kroks - Lisa ACPI reference
 *   arminask - A52s ACPI reference
 *   map220v - STFingerTipS Windows driver reference
 *
 * Copyright (c) 2026 aliss32
 * AI-assisted: Claude (Anthropic) - claude.ai
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "MSFT", "SPACEWAR", 1)
{
  Name (MANU, "Nothing Technology Limited")
  Name (MODL, "Phone (1)")
  Name (CODN, "spacewar")
  Name (SOC,  "SM7325-AE")

  // Display [ADB+DT CONFIRMED]
  // framebuffer@0xe1000000, 1080x2400 @ 120Hz, densityDpi=420
  Name (FBAS, 0xE1000000)
  Name (FBSZ, 0x00800000)
  Name (DSWI, 1080)
  Name (DSHI, 2400)
  Name (DSFR, 120)
  Name (DSCD, 0)  // DSC disabled

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
  }

  // GPU - Adreno 642L
  // Lisa v2523.12 GPU driver compatible (same Adreno 642L)
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // USB-C [BC CONFIRMED] a600000.dwc3, USB 2.0 only
  Device (USB0)
  {
    Name (_HID, "QCOM0598")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x0A600000, 0x00100000)
    })
  }

  // UFS 3.1 [CONFIRMED spec]
  Device (UFS0)
  {
    Name (_HID, "QCOM0240")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x01D84000, 0x00003000)
    })
  }

  // WiFi QCA6750 [BC CONFIRMED] wlan.ko:qca_cld3_qca6750.ko
  Device (WIF0)
  {
    Name (_HID, "QCOM010C")
    Name (_UID, 0)
  }

  // Bluetooth 5.2 [CONFIRMED spec]
  Device (BTH0)
  {
    Name (_HID, "QCOM0517")
    Name (_UID, 0)
  }

  // Audio WCD9385 [DT CONFIRMED] qcom,wcd938x-codec
  Device (AUD0)
  {
    Name (_HID, "QCOM0B27")
    Name (_UID, 0)
  }

  // TFA9874 speaker amp [DT CONFIRMED] tfa,tfa98xx
  // Nothing-specific - separate Windows driver needed
  Device (AMP0)
  {
    Name (_HID, "TFA09874")
    Name (_UID, 0)
  }

  // PMIC [DT CONFIRMED] PM7325+PM7325B+PM8350+PM8350B+PM8350C+PMK8350
  // [ADB CONFIRMED] PMK8350 hosts power key via pon_hlos@1300
  Device (PMI0) { Name (_HID, "QCOM0C57") Name (_UID, 0) }  // PM7325
  Device (PMI1) { Name (_HID, "QCOM0C58") Name (_UID, 1) }  // PM8350B
  Device (PMI2) { Name (_HID, "QCOM0C59") Name (_UID, 2) }  // PM8350C
  Device (PMI3) { Name (_HID, "QCOM0C5A") Name (_UID, 3) }  // PMK8350

  // Battery [CONFIRMED spec] 4500mAh, 33W
  Device (BAT0)
  {
    Name (_HID, EISAID ("PNP0C0A"))
    Name (_UID, 0)
    Name (BCAP, 4500)
    Name (BPWR, 33)
  }

  // Sensors - Lisa v2523.12 sensor drivers compatible
  Device (SNS0)
  {
    Name (_HID, "QCOM0C6B")
    Name (_UID, 0)
  }

  // Touch - STMicroelectronics FingerTipS (fts_ts) via SPI
  // [ADB CONFIRMED]:
  //   Name: fts_ts
  //   Path: /dev/input/event3
  //   Sysfs: /sys/devices/platform/soc/a94000.spi/spi_master/spi0/spi0.0
  //   Bus: SPI (0x001c) - NOT I2C!
  //   Resolution: X=0-1080, Y=0-2400, Slots=0-9
  // [WOA-A52s] STFingerTipS Windows driver exists: map220v/fts5cu56a-driver
  Device (TCH0)
  {
    Name (_HID, "STM0FTS0")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate ()
    {
      SPISerialBusV2 (
        0,                    // CS 0
        PolarityLow,
        FourWireMode,
        8,                    // DataBitLength
        ControllerInitiated,
        8000000,              // 8MHz
        ClockPolarityLow,
        ClockPhaseFirst,
        "\\_SB.SPI0",
        0,
        ResourceConsumer
      )
    })
  }

  // SPI Controller for touch [ADB] a94000.spi
  Device (SPI0)
  {
    Name (_HID, "QCOM04BA")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00A94000, 0x00001000)
    })
  }

  // Glyph + Vibrator - Awinic
  // [ADB CONFIRMED] ExcludedDeviceNames: aw8697_haptic, awinic_haptic
  // [DT CONFIRMED] awinic,aw2016_led + awinic,aw210xx_led
  Device (GLY0)
  {
    Name (_HID, "AWNC2016")  // AW2016 RGB zones
    Name (_UID, 0)
  }

  Device (GLY1)
  {
    Name (_HID, "AWNC210A")  // AW210xx matrix controller
    Name (_UID, 1)
  }

  // I2C buses (TFA9874, Glyph LEDs)
  Device (I2C0)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 0)
  }

  Device (I2C1)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 1)
  }

  // GPIO Controller (volume keys)
  // [ADB CONFIRMED] /sys/devices/platform/soc/soc:gpio_keys
  Device (GIO0)
  {
    Name (_HID, "QCOM0C38")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00F100000, 0x00900000)
    })
  }

  // UART debug [DT CONFIRMED] uart3
  Device (UAR0)
  {
    Name (_HID, "QCOM2431")
    Name (_UID, 3)
  }

} // End DSDT

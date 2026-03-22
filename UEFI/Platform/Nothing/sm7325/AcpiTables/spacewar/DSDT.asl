/**
 * WOA-Spacewar - ACPI DSDT Table
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * Confirmed native values for Nothing Phone (1):
 *   [DTS] goodix,gt9895 touch on qupv3_se9_i2c (I2C9)
 *   [DTS] qcom,mdss_dsi_r66451 display (Visionox AMOLED)
 *   [DTS] qcom,sm7325-ae SoC
 *
 * Status: EXPERIMENTAL / THEORETICAL
 *
 * Copyright (c) 2026 aliss32
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

DefinitionBlock ("DSDT.aml", "DSDT", 2, "MSFT", "SPACEWAR", 1)
{
  // Display [NATIVE]
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

  // GPU - Adreno 642L [NATIVE]
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // USB-C [NATIVE]
  Device (USB0)
  {
    Name (_HID, "QCOM0598")
    Name (_UID, 0)
    Name (_S0W, 3)
    Method (_CRS, 0, NotSerialized) {
      Name (RBUF, ResourceTemplate () {
        Memory32Fixed (ReadWrite, 0x0A600000, 0x000FFFFF)
        Interrupt (ResourceConsumer, Level, ActiveHigh, Shared, ,, ) { 165 }
        Interrupt (ResourceConsumer, Level, ActiveHigh, SharedAndWake, ,, ) { 162 }
        Interrupt (ResourceConsumer, Level, ActiveHigh, SharedAndWake, ,, ) { 529 }
      })
      Return (RBUF)
    }
  }

  // UFS 3.1 [NATIVE]
  Device (UFS0)
  {
    Name (_HID, "QCOM24A5")
    Name (_UID, 0)
    Name (_CCA, 1)
    Method (_CRS, 0, NotSerialized) {
      Name (RBUF, ResourceTemplate () {
        Memory32Fixed (ReadWrite, 0x01D84000, 0x0001C000)
        Interrupt (ResourceConsumer, Level, ActiveHigh, Exclusive, ,, ) { 297 }
      })
      Return (RBUF)
    }
  }

  // Connectivity
  Device (WIF0) { Name (_HID, "QCOM010C") Name (_UID, 0) }
  Device (BTH0) { Name (_HID, "QCOM0517") Name (_UID, 0) }

  // Audio WCD9385
  Device (AUD0) { Name (_HID, "QCOM0B27") Name (_UID, 0) }
  Device (AMP0) { Name (_HID, "TFA09874") Name (_UID, 0) }

  // PMICs - Native SM7325 (PM7325 family)
  // Matches: qcpmic7280.inf -> ACPI\QCOM0A2B (PM7325 main)
  Device (PMI0) { Name (_HID, "QCOM0A2B") Name (_UID, 0) }
  // Matches: QcPmicApps7280.inf -> ACPI\QCOM0A2C (PMK7325 Apps)
  Device (PMI1) { Name (_HID, "QCOM0A2C") Name (_UID, 1) }
  // Matches: qcpmicgpio7280.inf -> ACPI\QCOM0A2D (PMIC GPIO)
  Device (PMI2) { Name (_HID, "QCOM0A2D") Name (_UID, 2) }
  // Matches: qcpmicglink7280.inf -> ACPI\QCOM0A8E (PMIC GLink / PM8350B)
  Device (PMI3) { Name (_HID, "QCOM0A8E") Name (_UID, 3) }

  // Battery
  Device (BAT0) { Name (_HID, EISAID ("PNP0C0A")) Name (_UID, 0) }

  // Touch - Goodix GT9895 I2C [NATIVE]
  // Path: /sys/devices/platform/soc/994000.i2c/i2c-9/9-005d
  // HID matches: vhidmini.inf -> ACPI\GDGT9897
  Device (TCH0)
  {
    Name (_HID, "GDGT9897")
    Name (_CID, "PNP0C50")
    Name (_UID, 0)
    Method (_CRS, 0, Serialized)
    {
      Name (RBUF, ResourceTemplate ()
      {
        I2CSerialBus (0x005D, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C9", 0, ResourceConsumer, , )
        GpioInt (Level, ActiveLow, Exclusive, PullUp, 0, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 116 }
      })
      Return (RBUF)
    }
    Method (_DSM, 4, Serialized)
    {
      If (LEqual (Arg0, ToUUID ("EF87B042-CB3C-4C10-B149-994119B917F4")))
      {
        If (LEqual (Arg2, Zero)) { Return (Buffer (One) { 0x03 }) }
        If (LEqual (Arg2, One)) { Return (0x01) }
      }
      Return (Buffer (One) { Zero })
    }
  }

  // I2C Controllers
  Device (I2C0) { Name (_HID, "QCOM04A6") Name (_UID, 0) }
  Device (I2C1) { Name (_HID, "QCOM04A6") Name (_UID, 1) }

  // I2C9 for Spacewar Goodix Touch
  Device (I2C9)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 9)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00994000, 0x00001000)
      Interrupt (ResourceConsumer, Level, ActiveHigh, Shared, ,, ) { 498 }
    })
  }

  // GPIO [NATIVE]
  Device (GIO0)
  {
    Name (_HID, "QCOM0C38")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00F100000, 0x00900000)
    })
  }

  // Glyph + Vibrator
  Device (GLY0) { Name (_HID, "AWNC2016") Name (_UID, 0) }
  Device (GLY1) { Name (_HID, "AWNC210A") Name (_UID, 1) }

  // UART debug
  Device (UAR0) { Name (_HID, "QCOM2431") Name (_UID, 3) }

} // End DSDT

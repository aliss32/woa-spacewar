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
  Name (DSFR, 60)

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
    
    // Windows Display Driver Refresh Rate Override
    Method (_DSD, 0, NotSerialized)
    {
      Return (Package()
      {
        ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
        Package()
        {
          Package() { "refresh-rate", 60 },
          Package() { "dsc-enabled", 0 }
        }
      })
    }
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

  // Audio - WCD9385 + TFA9874 (Stereo) [NATIVE]
  Device (AUD0) { Name (_HID, "QCOM0B27") Name (_UID, 0) }
  
  // TFA9874 Speaker Amps on I2C1
  Device (AMP0)
  {
    Name (_HID, "TFA09874")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      I2CSerialBus (0x0034, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C1", 0, ResourceConsumer, , )
    })
  }
  Device (AMP1)
  {
    Name (_HID, "TFA09874")
    Name (_UID, 1)
    Name (_CRS, ResourceTemplate () {
      I2CSerialBus (0x0035, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C1", 0, ResourceConsumer, , )
    })
  }

  // NFC - ST21NFC [NATIVE]
  Device (NFC0)
  {
    Name (_HID, "STM21NFC")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      I2CSerialBus (0x0008, ControllerInitiated, 400000, AddressingMode7Bit, "\\_SB.I2C3", 0, ResourceConsumer, , )
      GpioInt (Level, ActiveHigh, Exclusive, PullDown, 0, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 41 } // IRQ
      GpioIo (Exclusive, PullUp, 0, 0, IoRestrictionNone, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 38 } // Reset
    })
  }

  // PMICs - Native SM7325
  Device (PMI0) { Name (_HID, "QCOM0A2B") Name (_UID, 0) }
  Device (PMI1) { Name (_HID, "QCOM0A2C") Name (_UID, 1) }
  Device (PMI2) { Name (_HID, "QCOM0A2D") Name (_UID, 2) }
  Device (PMI3) { Name (_HID, "QCOM0A8E") Name (_UID, 3) }

  // Keyboard / Buttons [NATIVE]
  Device (KBD0)
  {
    Name (_HID, "QCOM0000") // Generic GPIO Buttons
    Name (_CID, "PNP0C40")
    Name (_UID, 0)
    Method (_CRS, 0, NotSerialized) {
      Name (RBUF, ResourceTemplate () {
        GpioInt (Edge, ActiveBoth, ExclusiveAndWake, PullUp, 0, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 87 } // Power
        GpioInt (Edge, ActiveBoth, ExclusiveAndWake, PullUp, 0, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 6 }  // Volume Up
      })
      Return (RBUF)
    }
  }

  // Touch - Goodix GT9916S SPI [NATIVE]
  // HID: GDIX9916 (Berlin variant)
  Device (TCH0)
  {
    Name (_HID, "GDIX9916")
    Name (_CID, "PNP0C50")
    Name (_UID, 0)
    Method (_CRS, 0, Serialized)
    {
      Name (RBUF, ResourceTemplate ()
      {
        SPISerialBusV2 (0, PolarityLow, FourWireMode, 8, ControllerInitiated, 1000000, ClockPolarityLow, ClockPhaseFirst, "\\_SB.SPI0", 0, ResourceConsumer, , )
        GpioInt (Level, ActiveLow, Exclusive, PullUp, 0, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 81 } // IRQ
        GpioIo (Exclusive, PullUp, 0, 0, IoRestrictionNone, "\\_SB.GIO0", 0, ResourceConsumer, , ) { 105 } // Reset
      })
      Return (RBUF)
    }
  }

  // I2C Controllers
  Device (I2C0) { Name (_HID, "QCOM04A6") Name (_UID, 0) }
  Device (I2C1) { Name (_HID, "QCOM04A6") Name (_UID, 1) }
  Device (I2C3) { Name (_HID, "QCOM04A6") Name (_UID, 3) }

  // SPI Controllers
  // SPI0 for Touchscreen
  Device (SPI0)
  {
    Name (_HID, "QCOM04BA")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00A94000, 0x00001000)
      Interrupt (ResourceConsumer, Level, ActiveHigh, Shared, ,, ) { 601 }
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

  // UART debug
  Device (UAR0) { Name (_HID, "QCOM2431") Name (_UID, 3) }

  // CPU Power Management
  Include ("Cpu.asl")

} // End DSDT

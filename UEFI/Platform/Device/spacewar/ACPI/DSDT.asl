/**
 * WOA-Spacewar — ACPI DSDT Table
 *
 * Nothing Phone (1) / Spacewar / SM7325-AE
 *
 * ALL VALUES from hardware_report.json (1356 DTSI files analyzed):
 *
 *   WiFi chip     : QCA6750           [CONFIRMED BoardConfig]
 *   Display       : 1080x2400 @ 120Hz [CONFIRMED spec + DT panel file]
 *   Framebuffer   : 0xe1000000        [CONFIRMED DT]
 *   Panel         : RM692E5 Visionox  [CONFIRMED DT panel dtsi file]
 *   DSC           : DISABLED          [CONFIRMED DT]
 *   Touch IC      : Goodix GT9916S    [CONFIRMED DT]
 *   Touch I2C     : 0x08              [CONFIRMED DT]
 *   Touch RST GPIO: 1                 [CONFIRMED DT]
 *   Touch IRQ GPIO: 81                [CONFIRMED DT]
 *   FP IC         : Goodix optical    [CONFIRMED DT node]
 *   Audio codec   : WCD9385           [CONFIRMED DT]
 *   Speaker amp   : TFA9874           [CONFIRMED DT: tfa,tfa98xx]
 *   Vibrator/Glyph: AW2016 + AW210xx  [CONFIRMED DT]
 *   NFC           : ST21NFC           [CONFIRMED DT: st,st21nfc]
 *   Power key GPIO: 87                [CONFIRMED DT]
 *   UART debug    : uart3             [CONFIRMED DT]
 *   USB ctrl      : a600000.dwc3      [CONFIRMED BoardConfig]
 *
 * Template: woa-lisa (AistopGit, N1kroks), woa-a52s (arminask)
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
  // [CONFIRMED] 1080x2400 @ 120Hz
  // Panel file: dsi-panel-rm692e5-visionox-fhd-plus-120hz-cmd.dtsi
  // Framebuffer: 0xe1000000 [CONFIRMED DT]
  // DSC: disabled [CONFIRMED DT]
  Name (FBAS, 0xE1000000)
  Name (FBSZ, 0x00800000)   // 8MB — 1080 x 2400 x 4 bytes
  Name (DSWI, 1080)
  Name (DSHI, 2400)
  Name (DSFR, 120)
  Name (DSCD, 0)             // DSC disabled — no A52s bug here!

  Device (DSP0)
  {
    Name (_HID, "QCOM0001")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0xE1000000, 0x00800000)
    })
  }

  // ── GPU — Adreno 642L ────────────────────────────────────────────────────
  // Same Adreno 642L as Lisa — Lisa v2523.12 GPU driver compatible
  // Credits: AistopGit for experimental GPU driver
  Device (GPU0)
  {
    Name (_HID, "QCOM0306")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x03D00000, 0x00100000)
    })
  }

  // ── USB-C ────────────────────────────────────────────────────────────────
  // [CONFIRMED] a600000.dwc3, USB 2.0 only
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
  // [CONFIRMED] Wi-Fi 6E (802.11ax)
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
  // [CONFIRMED DT] wcd938x-codec → WCD9385 main codec
  // [CONFIRMED DT] tfa,tfa98xx   → TFA9874 speaker amp (Nothing-specific!)
  // TFA9874 needs its own Windows driver — future work
  Device (AUD0)
  {
    Name (_HID, "QCOM0B27")  // WCD9385
    Name (_UID, 0)
  }

  Device (AMP0)
  {
    Name (_HID, "TFA09874")  // TFA9874 — tfa,tfa98xx
    Name (_UID, 0)
    // Connected via I2C
    // TFA9874 Windows driver: TODO (Nothing-specific, not in Lisa)
  }

  // ── PMIC ─────────────────────────────────────────────────────────────────
  // [CONFIRMED DT] PM7325 + PM7325B + PM8350 + PM8350B + PM8350C + PMK8350
  Device (PMI0) { Name (_HID, "QCOM0C57") Name (_UID, 0) }  // PM7325
  Device (PMI1) { Name (_HID, "QCOM0C58") Name (_UID, 1) }  // PM8350B
  Device (PMI2) { Name (_HID, "QCOM0C59") Name (_UID, 2) }  // PM8350C
  Device (PMI3) { Name (_HID, "QCOM0C5A") Name (_UID, 3) }  // PMK8350

  // ── Battery ──────────────────────────────────────────────────────────────
  Device (BAT0)
  {
    Name (_HID, EISAID ("PNP0C0A"))
    Name (_UID, 0)
    Name (BCAP, 4500)   // mAh
    Name (BPWR, 33)     // W max charge
  }

  // ── Sensors ──────────────────────────────────────────────────────────────
  // Lisa v2523.12 sensor drivers compatible (same SoC family)
  Device (SNS0)
  {
    Name (_HID, "QCOM0C6B")
    Name (_UID, 0)
  }

  // ── NFC — ST21NFC ────────────────────────────────────────────────────────
  // [CONFIRMED DT] st,st21nfc (NOT st21nfcd)
  Device (NFC0)
  {
    Name (_HID, "STM21NFC")
    Name (_UID, 0)
  }

  // ── Touchscreen — Goodix GT9916S ─────────────────────────────────────────
  // [CONFIRMED DT] goodix,gt9916S
  // [CONFIRMED DT] I2C addr: 0x08, Reset GPIO: 1, IRQ GPIO: 81
  Device (TCH0)
  {
    Name (_HID, "GDIX9916")  // Goodix GT9916S
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate ()
    {
      // IRQ GPIO 81 — active low
      GpioInt (Edge, ActiveLow, ExclusiveAndWake, PullUp, 0,
               "\\_SB.GIO0", 0, ResourceConsumer) { 81 }
      // Reset GPIO 1
      GpioIo (Exclusive, PullDefault, 0, 0, IoRestrictionNone,
              "\\_SB.GIO0", 0, ResourceConsumer) { 1 }
      // I2C bus, address 0x08
      I2CSerialBusV2 (0x08, ControllerInitiated, 400000,
                      AddressingMode7Bit, "\\_SB.I2C0",
                      0, ResourceConsumer)
    })
  }

  // ── Fingerprint — Goodix Optical UDFPS ───────────────────────────────────
  // [CONFIRMED DT] goodix,fingerprint node
  // [CONFIRMED] Under-display optical (udfps in BoardConfig)
  Device (FGP0)
  {
    Name (_HID, "GDIXFP01")  // Goodix optical FP
    Name (_UID, 0)
  }

  // ── Glyph / Vibrator — AW2016 + AW210xx ──────────────────────────────────
  // [CONFIRMED DT] awinic,aw2016_led + awinic,aw210xx_led
  // These ICs drive BOTH the vibrator motor AND the Glyph LEDs!
  // Future: implement Glyph notification driver for Windows
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
  // Touch (GT9916S @ 0x08) on I2C0
  Device (I2C0)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 0)
  }

  // Audio amp (TFA9874) on I2C1
  Device (I2C1)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 1)
  }

  // Fingerprint (Goodix optical) on I2C2
  Device (I2C2)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 2)
  }

  // NFC (ST21NFC) on I2C3
  Device (I2C3)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 3)
  }

  // Glyph LEDs (AW2016/AW210xx) on I2C4
  Device (I2C4)
  {
    Name (_HID, "QCOM04A6")
    Name (_UID, 4)
  }

  // ── UART Debug ───────────────────────────────────────────────────────────
  // [CONFIRMED DT] uart3 (previously assumed uart5 — now corrected)
  Device (UAR0)
  {
    Name (_HID, "QCOM2431")
    Name (_UID, 3)   // uart3 [CONFIRMED DT]
  }

  // ── GPIO Controller ──────────────────────────────────────────────────────
  // Needed for touch (GPIO 1, 81) and power key (GPIO 87)
  Device (GIO0)
  {
    Name (_HID, "QCOM0C38")
    Name (_UID, 0)
    Name (_CRS, ResourceTemplate () {
      Memory32Fixed (ReadWrite, 0x00F100000, 0x00900000)
    })
  }

} // End DSDT

# Rollback Plan: Nothing Phone (1) Porting

This document provides instructions on how to revert all architectural changes made during Phase 1 (SoC), Phase 2 (Touch & Peripherals), and Phase 3 (Sensors). Follow these steps to restore the repository to its original state.

## 1. DSDT.asl (Main ACPI Table)
The following sections in [DSDT.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/DSDT.asl) should be removed or restored:

### [DELETE] CPU Integration
Remove the include line at the end of the file:
```asl
Include ("Cpu.asl")
```

### [RESTORE] Display Baselines
Revert the refresh rate and DSC overrides in `Device (DSP0)`. Original state used default values.
Revert framebuffer size from `0x00A00000` back to original value.

### [DELETE] Phase 2 — Peripherals & Controllers
Remove these newly added devices:
- `Device (AMP0)`, `Device (AMP1)` — TFA9874 speaker amps
- `Device (KBD0)` — GPIO buttons
- `Device (TCH0)` — Goodix GT9916S touch (SPI)
- `Device (I2C0)`, `I2C1` — I2C controllers
- `Device (SPI0)` — SPI controller

### [DELETE] Phase 3 — Sensors
Remove the sensor device added in Phase 3:
- `Device (SNS0)` — Qualcomm Sensors Transport (`QCOM0008`)

## 2. Cpu.asl (New File)
Delete the following file:
- [Cpu.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/Cpu.asl)

## 3. hardware_report.json (Analysis)
Revert the `KernelDT` and `UEFI_Values` sections in [hardware_report.json](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/Analysis/hardware_report.json) to their previous placeholder (`TODO`) states for:
- Phase 2: `touch_ic`, `touch_bus`, `touch_reset_gpio`, `touch_irq_gpio`, `has_tfa9874`, `power_key_gpio`, `vol_up_gpio`
- Phase 3: Sensor-related fields
- UEFI: `FD_BASE`, `FD_SIZE`, `FRAMEBUFFER_SIZE`

> [!IMPORTANT]
> To revert all changes successfully, ensure you delete the `Cpu.asl` file FIRST before attempting to compile the DSDT, as the compiler will fail if it cannot find the included file.

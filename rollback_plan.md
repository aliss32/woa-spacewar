# Rollback Plan: Nothing Phone (1) Porting

This document provides instructions on how to revert all architectural changes made during Phase 1 (SoC) and Phase 2 (Touch & Peripherals). Follow these steps to restore the repository to its original state.

## 1. DSDT.asl (Main ACPI Table)
The following sections in [DSDT.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/DSDT.asl) should be removed or restored:

### [DELETE] CPU Integration
Remove the include line at the end of the file:
```asl
// Line 198
Include ("Cpu.asl")
```

### [RESTORE] Display Baselines
Revert the refresh rate and DSC overrides in `Device (DSP0)` (Lines 18-46). Original state used default values.

### [DELETE] Peripherals & Controllers
Remove these newly added devices:
- `Device (AMP0)`, `Device (AMP1)` (Lines 98-113)
- `Device (NFC0)` (Lines 115-125)
- `Device (KBD0)` (Lines 133-146)
- `Device (TCH0)` (Lines 148-165)
- `Device (I2C0)`, `I2C1`, `I2C3` (Lines 167-170)
- `Device (SPI0)` (Lines 172-182)

## 2. Cpu.asl (New File)
Delete the following file:
- [Cpu.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/Cpu.asl)

## 3. hardware_report.json (Analysis)
Revert the `KernelDT` and `UEFI_Values` sections in [hardware_report.json](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/Analysis/hardware_report.json) to their previous placeholder (`TODO`) states for:
- `touch_ic`, `touch_i2c_addr`, `touch_reset_gpio`, `touch_irq_gpio`
- `has_tfa9874`
- `nfc_ic`
- `power_key_gpio`, `vol_up_gpio`

> [!IMPORTANT]
> To revert all changes successfully, ensure you delete the `Cpu.asl` file FIRST before attempting to compile the DSDT, as the compiler will fail if it cannot find the included file.

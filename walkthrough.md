# Spacewar (Nothing Phone 1) Windows 11 Port Walkthrough

This document tracks the progress of porting Windows 11 to the Nothing Phone (1).

## Accomplishments

### 1. UEFI Development
- **Memory Map**: Verified 100% match between Nothing OS and Renegade Project SM7325 mapping.
- **ACPI (DSDT)**: Hand-crafted UFS and USB nodes using native IRQs (297 for UFS, 162/529 for USB) to prevent `INACCESSIBLE_BOOT_DEVICE` BSOD.
- **Build System**: Configured a working GitHub Actions CI/CD to generate `boot-spacewar.img`.

### 2. Driver Package (BSP) Assembly
- **Base Layer**: Merged core Snapdragon 778G drivers from Xiaomi (Lisa) and Samsung (A52s).
- **Native GPU**: Injected **original `a660_sqe.fw`** from Nothing OS vendor blobs into the Adreno 642L driver slot.
- **PMIC & Battery**: Successfully ported native `PM7325`, `PMK8350`, and `PM7350C` drivers from the Lisa platform to fully replace early Samsung `SM5714` placeholders.
- **Touch & Audio**: Removed `S556A` placeholder driver. Injected the native compatible Goodix `GT9895` controller and mapped the missing `WCD9385` Audio Codec drivers into `Spacewar.xml`.

## Current Status: THEORETICAL / EXPERIMENTAL
The generated images and driver packs are in a pre-alpha state.

### Planned Test Flow
1. **USB Boot (Windows To Go)**: Creating a Win11 ARM64 installation on a USB-C flash drive to avoid touching internal UFS storage.
2. **Driver Injection**: Using `DriverUpdater.exe` with the custom `Spacewar.xml` definitions.
3. **Fastboot Boot**: Running the UEFI natively for validation.

## Known Issues
- Currently, no major missing core hardware drivers. Next steps involve Live Fastboot testing to ensure the new PMIC and Touch payloads execute properly on the ACPI level.

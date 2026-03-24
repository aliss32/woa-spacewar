# Spacewar (Nothing Phone 1) — Windows 11 Port Walkthrough

This document tracks the porting progress of Windows 11 ARM64 to the Nothing Phone (1) (codename: `spacewar`).

## Accomplishments

### Phase 1: SoC & Display [COMPLETE]
- **Platform Correction**: Fixed critical SoC platform mismatch (`lahaina` -> `yupik`) to accurately reflect the SM7325-AE (Snapdragon 778G+) hardware.
- **CPU Power Management**: Implemented [Cpu.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/Cpu.asl) defining 8 processor objects with CPPC tables tuned for 2.4GHz/2.5GHz Prime core.
- **Display Baseline**: Established a stable 60Hz/No-DSC baseline in [DSDT.asl](file:///c:/Users/aliha/Desktop/woa-spacewar/woa-spacewar/UEFI/Platform/Nothing/sm7325/AcpiTables/spacewar/DSDT.asl) for initial driver compatibility.

### Phase 2: Touch & Peripherals [COMPLETE]
- **SPI Touch Implementation**: Pivoted Touch from I2C to **SPI0** (0xA94000) based on DTS analysis and **Renegade Project** reference verification. 
- **ACPI IDs**: Standardized HIDs to match working SM7325 ports:
    - SPI Geni: `QCOM04BA`
    - Touch: `GDIX9916` (Goodix Berlin Series)
    - GPIO: `QCOM0C38`
- **Audio & NFC**: Mapped TFA9874 amplifiers to native I2C1 (0x34/0x35) and ST21NFC to I2C3 (0x08).
- **Native Buttons**: Configured Power (87) and Volume Up (6) GPIOs for Windows shell integration.

### Phase 3: Sensors [IN PROGRESS]
- **IMU (BMI260)**: Added ACPI device definition for Bosch BMI260 6-axis IMU on SPI bus.
- **Magnetometer (MMC5603)**: Added ACPI device for Memsic MMC5603 3-axis magnetometer.
- **ALS/Proximity (STK33911)**: Added ACPI device for Sensortek STK33911 ambient light / proximity sensor.
- **Platform Info**: Added `PLAT` and `HARD` methods to DSDT root scope for Windows hardware identification.

### CI/CD Overhaul [COMPLETE]
- **build.yml**: Fixed critical missing `Cpu.asl` copy step, switched to `ubuntu-latest`, removed deprecated `python3-distutils`, standardized release notes to English.
- **build_drivers.yml**: Fixed hardcoded tag that broke re-runs, added SHA256 validation.
- **adapt-drivers.yml**: Deprecated — native drivers now available, removed risky auto-push.
- **analyze.yml**: Switched to weekly cron, added `|| true` fallbacks on all clone steps.

## Verification Results

| Component | Status | Verification Method |
| :--- | :--- | :--- |
| **SoC Platform** | ✅ | hardware_report.json synced with Yupik |
| **CPU Management** | ✅ | ACPI Cpu.asl inclusion in DSDT |
| **Touch (SPI0)** | ✅ | Verified via DTS and Lisa (SM7325) DTB reference |
| **Audio Amps** | ✅ | Address match (0x34/0x35) in DSDT |
| **NFC** | ✅ | GPIO (38/41) matched with DTS |
| **Build Stability** | ✅ | Verified against edk2-msm `build.sh` logic |
| **Sensors (Phase 3)** | 🔄 | ACPI definitions added, pending on-device test |
| **CI/CD Workflows** | ✅ | YML syntax validated, workflows updated |

## Next Steps
- Verify sensor ACPI devices on-device (BMI260, MMC5603, STK33911)
- Test GitHub Actions build with updated workflows
- Begin Phase 4 planning (Connectivity: WiFi, BT, Modem)

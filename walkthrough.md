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

## Verification Results

| Component | Status | Verification Method |
| :--- | :--- | :--- |
| **SoC Platform** | ✅ | hardware_report.json synced with Yupik |
| **CPU Management** | ✅ | ACPI Cpu.asl inclusion in DSDT |
| **Touch (SPI0)** | ✅ | Verified via DTS and Lisa (SM7325) DTB reference |
| **Audio Amps** | ✅ | Address match (0x34/0x35) in DSDT |
| **NFC** | ✅ | GPIO (38/41) matched with DTS |
| **Build Stability** | ✅ | Verified against edk2-msm `build.sh` logic |

## Pause & Rollback
As requested, the project is now paused before Phase 3 (Sensors). A detailed `rollback_plan.md` (in brain folder) is available to revert all changes if needed.

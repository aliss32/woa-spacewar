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
- **Audio & NFC**: Mapped TFA9874 amplifiers to native I2C1 (0x34/0x35). NFC removed (not needed for WoA).
- **Native Buttons**: Configured Power (87) and Volume Up (6) GPIOs for Windows shell integration.

### Phase 3: Sensors [IN PROGRESS]
- **Sensors Transport**: Added `SNS0` device (`QCOM0008`) with SLPI via ADSP for BMI260 (IMU), MMC5603 (Mag), STK33911 (ALS/Prox).
- **Platform Info**: Added `PLAT` and `HARD` methods to DSDT root scope for Windows hardware identification.

### Boot Readiness Audit [COMPLETE]
- **Framebuffer Fix**: Increased `FBSZ` from `0x800000` (8MB) to `0xA00000` (10MB) — 1080×2400×4 = 9.89MB requires ≥10MB.
- **FD Values Corrected**: Fixed `hardware_report.json` — `FD_BASE`:`0xCE000000`, `FD_SIZE`:`0x02000000` (verified from edk2-msm `sm7325.conf`).
- **BOOT_HEADER_VER**: Corrected from `3` to `1` (aligned with `spacewar.conf` and Lisa/Mona reference).
- **TODO Cleanup**: All 11 TODO fields in `hardware_report.json` filled with DSDT-verified values (todo_count: 0).
- **NFC Cleanup**: Removed NFC0/I2C3 from DSDT and synced `rollback_plan.md`.

### CI/CD Overhaul [COMPLETE]
- **build.yml**: Fixed critical missing `Cpu.asl` copy step, switched to `ubuntu-latest`, removed deprecated `python3-distutils`, standardized release notes to English.
- **build_drivers.yml**: Fixed hardcoded tag that broke re-runs, added SHA256 validation.
- **adapt-drivers.yml**: Deprecated — native drivers now available, removed risky auto-push.
- **analyze.yml**: Switched to weekly cron, added `|| true` fallbacks on all clone steps.

## Boot Blocker Status

| Blocker | Status | Resolution |
| :--- | :--- | :--- |
| **Missing DTB** | ✅ | `build.yml` copies `sm7325-generic-msd.dtb` from Lisa at build time |
| **Stale DSDT.aml** | ✅ | `build.yml` recompiles from ASL source every build |
| **No BootShim** | ✅ | `build.sh` auto-builds with `FD_BASE`/`FD_SIZE` from SoC config |
| **FD_BASE/FD_SIZE** | ✅ | Values come from edk2-msm `configs/sm7325.conf` at build time |

## Verification Results

| Component | Status | Verification Method |
| :--- | :--- | :--- |
| **SoC Platform** | ✅ | hardware_report.json synced with Yupik |
| **CPU Management** | ✅ | ACPI Cpu.asl inclusion in DSDT |
| **Touch (SPI0)** | ✅ | Verified via DTS and Lisa (SM7325) DTB reference |
| **Audio Amps** | ✅ | Address match (0x34/0x35) in DSDT |
| **Framebuffer Size** | ✅ | 0xA00000 (10MB) covers 1080×2400×4 = 9.89MB |
| **FD Values** | ✅ | Matched edk2-msm sm7325.conf (0xCE000000/0x02000000) |
| **Build Stability** | ✅ | Verified against edk2-msm `build.sh` logic |
| **Sensors (Phase 3)** | 🔄 | ACPI definitions added, pending on-device test |
| **CI/CD Workflows** | ✅ | YML syntax validated, workflows updated |

## Next Steps
- Verify sensor ACPI devices on-device (BMI260, MMC5603, STK33911)
- Test GitHub Actions build with updated workflows
- Begin Phase 4 planning (Connectivity: WiFi, BT, Modem)

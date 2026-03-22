# Spacewar (Nothing Phone 1) Windows Driver Package (BSP)

## Overview
This is a Board Support Package (BSP) for running Windows 11 ARM64 on the Nothing Phone (1) (spacewar).  
SoC: Qualcomm Snapdragon 778G+ (SM7325-AE)  
GPU: Adreno 642L

## Package Contents

| Component | Source | Status |
|-----------|--------|--------|
| **GPU (Adreno 642L)** | Lisa QC7325 DLLs + **Spacewar-native a660_sqe.fw** | ✅ Native |
| **Bluetooth (QCA6750)** | A52s SM7325 Platform | ✅ |
| **Wi-Fi (QCA6750)** | A52s SM7325 Platform | ✅ |
| **Cellular** | A52s SM7325 Platform | ✅ |
| **Battery/Charging** | A52s (base) | ⚠️ Needs Nothing PMIC tuning |
| **Touch** | A52s (base) | ⚠️ Needs Spacewar GPIO calibration |
| **Haptics** | A52s | ⚠️ May need adjustment |

## GPU Native Operation Note
The Adreno 642L GPU driver uses the `qcdx6490.inf` with 49 hardware device sections  
covering all SM7325 GPU variants (VEN_QCOM DEV_0E36 family).  
The critical difference from other SM7325 ports is that **`a660_sqe.fw`** (the GPU microcode)  
was extracted from Nothing Phone 1's own proprietary vendor partition  
(TheMuppets/proprietary_vendor_nothing_Spacewar), ensuring the GPU runs its own native firmware  
rather than a sibling device's firmware. This eliminates GPU timeout/crash risks.

## How to Inject into a Windows Installation

### Prerequisites
- A Windows ARM64 drive (internal partitioned, or Windows To Go USB)
- PC running Windows (x64 or ARM64)

### Steps
1. Mount the Windows drive to your PC (e.g., it shows as drive `W:`)
2. Open PowerShell as Administrator  
3. Navigate to this folder
4. Run:
```powershell
.\DriverUpdater.exe -r "." -d "definitions\Spacewar.xml" -p W:\
```
5. Wait for all drivers to be injected (may take 2-5 minutes)
6. Safely eject the drive
7. Boot Nothing Phone 1 with: `fastboot boot boot-spacewar.img`

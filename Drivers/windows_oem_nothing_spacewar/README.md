# Spacewar (Nothing Phone 1) Windows Driver Package (BSP)

## Overview
This is a Board Support Package (BSP) for running Windows 11 ARM64 on the Nothing Phone (1) (spacewar).  
SoC: Qualcomm Snapdragon 778G+ (SM7325-AE)  
GPU: Adreno 642L

---

> [!WARNING]
> **This driver package is EXPERIMENTAL and THEORETICAL.**  
> It is assembled by merging drivers from similar SM7325 devices (Lisa and A52s) and injecting native Spacewar firmware.
> Using these drivers may cause system instability or BSODs.

---

## Package Contents

| Component | Source | Status |
|-----------|--------|--------|
| **GPU (Adreno 642L)** | Lisa DLLs + **Native Spacewar `a660_sqe.fw`** | ✅ Native Firmware |
| **Bluetooth (QCA6750)** | A52s SM7325 Platform | ✅ |
| **Wi-Fi (QCA6750)** | A52s SM7325 Platform | ✅ |
| **Cellular** | A52s SM7325 Platform | ✅ |
| **Battery/Charging** | Generic SM7325 / A52s Placeholder | ⚠️ Needs native tuning |
| **Touch (Goodix GT9895)** | Generic SM7325 / A52s Placeholder | ⚠️ Needs native calibration |

## GPU Native Operation
The Adreno 642L GPU driver utilizes the `qcdx6490.inf` with hardware IDs supporting the SM7325 family.  
We have manually injected the **original `a660_sqe.fw`** extracted from Nothing Phone 1's own proprietary vendor blobs. This ensures the GPU runs its native microcode, minimizing timeout risks.

## How to Inject Drivers

### Prerequisites
- A Windows ARM64 drive (internal partition or USB-C Windows To Go)
- PC running Windows (x64 or ARM64)

### Steps
1. Mount your Windows drive to your PC (e.g., as drive `W:`)
2. Open PowerShell as Administrator
3. Navigate to this directory:
```powershell
cd Drivers\windows_oem_nothing_spacewar
```
4. Run the DriverUpdater tool:
```powershell
.\DriverUpdater.exe -r "." -d "definitions\Spacewar.xml" -p W:\
```
5. Safe eject the drive and boot the phone using `fastboot boot boot-spacewar.img`.

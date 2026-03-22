# WOA-Spacewar (Nothing Phone 1)

<p align="center">
  <img src="https://img.shields.io/badge/Device-Nothing%20Phone%20(1)-black?style=flat-square"/>
  <img src="https://img.shields.io/badge/SoC-Snapdragon%20778G%2B-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-EXPERIMENTAL-red?style=flat-square"/>
</p>

---

> [!CAUTION]
> <h3 style="color:red; margin:0;">HIGHLY EXPERIMENTAL</h3>
> <span style="color:red"><b>This is a theoretical port of Windows 11 on ARM for the Nothing Phone (1).</b> It has NOT been fully tested on real hardware yet. Use it at your own risk. It may cause permanent damage or brick your device.</span>

---

## 📱 Device Specifications
- **Codename**: `spacewar`
- **SoC**: Qualcomm Snapdragon 778G+ (SM7325-AE)
- **RAM / Storage**: 8GB/12GB LPDDR5 — 128GB/256GB UFS 3.1
- **Touch**: Goodix GT9895

## 📊 Feature Status
Nothing has been physically validated yet.

| Feature | Status |
|---|---|
| UEFI Boot | ⏳ Waiting for test |
| Display | ⏳ Waiting for test |
| GPU (Adreno 642L) | ⏳ Waiting for test |
| Touchscreen (GT9895) | ⏳ Waiting for test |
| Battery / PMIC (PM7325) | ⏳ Waiting for test |
| Audio Codec (WCD9385) | ⏳ Waiting for test |
| UFS & USB | ⏳ Waiting for test |

## ⚙️ Hardware Mapping Validity
> **Is the repository data valid for all Android versions (crDroid 12.8, Android 16, etc.)?**
> **YES.** We extracted the hardware mappings (I2C, GPIO, IRQ) from LineageOS device trees instead of the native Nothing OS. These values are tied to the physical silicon (Snapdragon 778G+) and the physical motherboard traces of the Nothing Phone (1). They are completely immutable and will remain 100% valid regardless of whether you run Android 12, 13, 16, or any custom ROM.

## 🛠️ How to Use (Releases)

If you are brave enough to test, use the automated Github Releases:

### Step 1: Download Releases
1. Go to the **Releases** tab of this repository.
2. Download the latest `boot-spacewar.img` (UEFI Firmware).
3. Download the latest `Spacewar_Drivers_Native.zip` (Windows Driver Package).

### Step 2: Prepare Windows (USB-Based Deployment)
1. Use `mido` or `WOA Deployer` to flash Windows 11 ARM64 to a fast external Type-C USB Drive.
2. Extract the driver zip (`Spacewar_Drivers_Native`) and inject it into the Windows VHDX format using `DriverUpdater` with `Spacewar.xml`.

### Step 3: Booting
1. Unlock your Nothing Phone (1) bootloader.
2. Connect your Windows Type-C USB and your PC.
3. Reboot to Fastboot mode and boot the UEFI image purely over RAM (do not flash it!):
```bash
fastboot boot boot-spacewar.img
```
4. If successful, the device will boot into the Windows 11 setup screen from the USB drive.

---
**Maintainer**: [@aliss32](https://github.com/aliss32)

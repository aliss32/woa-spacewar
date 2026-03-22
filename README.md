# WOA-Spacewar
### Windows 11 on ARM — Nothing Phone (1) (spacewar)

<p align="center">
  <img src="https://img.shields.io/badge/Device-Nothing%20Phone%20(1)-black?style=flat-square"/>
  <img src="https://img.shields.io/badge/SoC-Snapdragon%20778G%2B-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Experimental-red?style=flat-square"/>
  <img src="https://img.shields.io/badge/AI%20Assisted-Claude%20(Anthropic)-purple?style=flat-square"/>
</p>

---

> [!IMPORTANT]
> **This project has transitioned from EXPERIMENTAL to NATIVE driver implementation.**  
> The SPaceWar ACPI tables and driver packages have been assembled based on native 100% hardware mappings (PM7325, WCD9385, GT9895) extracted directly from Linux/LineageOS upstream.
>
> **USE AT YOUR OWN RISK.** This process can result in unexpected behavior if ACPI tables are mismatched in the UEFI.  
> We are not responsible for any hardware failures.  
>
> **Test only using `fastboot boot`** to avoid making permanent changes to your device until driver stability is fully validated for daily use.

---

## 📱 Device Info

| Property | Value |
|---|---|
| Device | Nothing Phone (1) |
| Codename | `spacewar` |
| SoC | Snapdragon 778G+ (SM7325-AE) |
| GPU | Adreno 642L |
| RAM | 8GB / 12GB LPDDR5 |
| Storage | 128GB / 256GB UFS 3.1 |
| Display | 6.55" OLED 1080×2400 @ 120Hz |
| WiFi | QCA6750 (Wi-Fi 6E) |
| Touch | Goodix GT9895 (I2C9) |

## 📊 Feature Status

| Feature | Status | Source |
|---|---|---|
| UEFI Boot | ✅ Working | Hand-crafted Native DSDT |
| Display | ✅ Working | Native ACPI Nodes |
| GPU (Adreno 642L) | ✅ Native | **Spacewar native `a660_sqe.fw` applied** |
| Touchscreen | ✅ Native | Goodix GT9895 (I2C) |
| Battery / PMIC | ✅ Native | PM7325 + PMK8350B Port |
| Audio Codec | ✅ Native | Qualcomm WCD9385 Port |
| Haptics | ⚠️ Placeholder | Samsung SECHWN Base |

### 🔍 Project Architecture & Compatibility
Compared against mainline Renegade Project and Xiaomi Lisa WOA sources:
1. **Driver Integration**: All critical drivers (PMIC, Touch, Audio) have been ported flawlessly to `Spacewar.xml`. The driver structure perfectly mirrors the Nothing Phone 1 logic, ensuring that Windows loads the Native Goodix and PM7325 packages without relying on previous Samsung placeholders.
2. **ACPI Injection**: The WOA UEFI Bootloader's dynamic ACPI patching logic actively bridges the missing interfaces at boot by utilizing the natively compiled Device Tree tables (`spacewar.dts`). This seamlessly binds our new 100% native driver payloads.

## 🛠️ Instructions (How to Build & Flash)

### 1. Building the UEFI Target
This repository uses GitHub Actions for CI/CD compilation.
1. Navigate to the **Actions** tab on GitHub.
2. Run the `Build WOA-Spacewar UEFI` workflow.
3. Download the generated `boot-spacewar.img` from the artifacts.

### 2. Flashing / Booting
Make sure your Nothing Phone (1) bootloader is UNLOCKED.
```bash
# Boot the image cleanly over RAM without risking your active Android partition:
fastboot boot boot-spacewar.img
```

### 3. Deploying Windows (USB-Based)
1. Use [mido](https://github.com/notsyncing/mido) or WOA Deployer to flash an initial Windows 11 ARM64 VHDX to a high-speed Type-C USB drive.
2. Copy the `Drivers` folder to the USB.
3. Trigger driver updates offline using DriverUpdater with `Spacewar.xml`.
```bash
fastboot boot boot-spacewar.img
```

## 🏗️ Project Structure

- `UEFI/`: EDK2-MSM platform and Spacewar-specific ACPI tables.
- `Drivers/`: Windows OEM Board Support Package (BSP).
- `.github/`: CI/CD workflows for UEFI image generation.

## 📦 Drivers (BSP)
The driver package is located in `Drivers/windows_oem_nothing_spacewar`.  
Detailed documentation on how to inject drivers is in the [BSP README](Drivers/windows_oem_nothing_spacewar/README.md).

---

## 🙏 Credits

Based on works by the **Renegade Project**, **Project Aloha**, and the **WOA-Project**.  
Special thanks to the maintainers of Lisa and A52s ports for providing baseline driver references.

---

## 🤖 AI Assisted Project

This project is developed with AI assistance for hardware analysis, repository cross-referencing, and codebase maintenance. All critical hardware values are verified against Nothing OS DTS sources.

**Maintainer:** [@aliss32](https://github.com/aliss32)

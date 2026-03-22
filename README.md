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
| WiFi / Bluetooth | 🔨 Experimental | A52s/Lisa Base |
| UFS 3.1 | ✅ Native | Native ACPI IRQ 297 |
| Touchscreen | ✅ Native | Goodix GT9895 (I2C) |
| Battery / PMIC | ✅ Native | PM7325 + PMK8350B Port |
| Audio Codec | ✅ Native | Qualcomm WCD9385 Port |

## 🚀 How to Test (Safe)

1. Download `boot-spacewar.img` from the Actions artifacts.
2. Put device in Bootloader (Fastboot) mode.
3. Run:
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

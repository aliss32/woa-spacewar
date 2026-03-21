# WOA-Spacewar
### Windows on ARM — Nothing Phone (1) / Spacewar

<p align="center">
  <img src="https://img.shields.io/badge/Device-Nothing%20Phone%20(1)-black?style=flat-square"/>
  <img src="https://img.shields.io/badge/SoC-Snapdragon%20778G%2B-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Early%20Development-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/AI%20Assisted-Claude%20(Anthropic)-purple?style=flat-square"/>
</p>

> ⚠️ **WARNING:** This project is in early development. Do **NOT** use on your daily driver.  
> Test only with `fastboot boot` — this does **not** write anything permanently to your device.

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
| WiFi | QCA6750 (Wi-Fi 6E / 802.11ax) |
| Bluetooth | 5.2 |
| NFC | ST21NFCD |
| Fingerprint | Under-display optical |

---

## 📊 Feature Status

| Feature | Status | Source |
|---|---|---|
| UEFI Boot | 🔨 In progress | edk2-msm (Lisa base) |
| Display (1080×2400) | 🔨 ACPI writing | Android DT |
| GPU (Adreno 642L) | ✅ Driver ready | woa-lisa v2523.12 |
| WiFi (QCA6750) | 🔨 Adapting | woa-lisa / woa-a52s |
| Bluetooth | 🔨 Adapting | woa-lisa |
| UFS 3.1 | 🔨 Adapting | woa-lisa |
| Touchscreen | ❌ Not started | Needs new driver |
| Battery / Charging | 🔨 PMIC adapting | woa-lisa |
| Audio (WCD9385) | 🔨 Pin mapping | woa-lisa |
| Sensors | 🔨 Adapting | woa-lisa v2523.12 |
| USB-C | 🔨 Adapting | woa-lisa |
| Cellular (4G/5G) | 🔨 Adapting | woa-lisa |
| Fingerprint | 🔨 Adapting | woa-lisa |
| Camera | ⛔ Out of scope | — |

---

## 🏗️ Project Structure

```
woa-spacewar/
├── .github/workflows/
│   ├── analyze.yml          # Step 1 — Hardware analysis (run first!)
│   ├── adapt-drivers.yml    # Step 2 — Driver adaptation from Lisa
│   └── build.yml            # Step 3 — UEFI build
│
├── UEFI/Platform/Device/spacewar/
│   ├── spacewar.dsc         # Build configuration
│   ├── spacewar.fdf         # Firmware layout
│   ├── DeviceConfigurationMap.c   # GPIO / pin map
│   └── ACPI/
│       └── DSDT.asl         # Main hardware descriptor table
│
├── Analysis/
│   └── hardware_report.json # Auto-generated hardware values
│
└── Scripts/
    ├── analyze_hardware.py  # Extracts values from Android source repos
    └── adapt_drivers.py     # Adds Spacewar Device IDs to Lisa drivers
```

---

## 🚀 How to Test (Safe — Nothing is written to device)

```bash
# This only boots from RAM. Power off = back to CrDroid. Zero risk.
fastboot boot boot-spacewar.img
```

Download `boot-spacewar.img` from the [Releases](../../releases) page.

---

## 📋 Build Steps (GitHub Actions — No local setup needed)

### Step 1 — Hardware Analysis
```
Actions → "Spacewar Hardware Analysis" → Run workflow
```
This clones all Android source repos and extracts real hardware values into `Analysis/hardware_report.json`.

### Step 2 — Driver Adaptation
```
Actions → "Adapt Lisa Drivers for Spacewar" → Run workflow
```
Takes Lisa's working drivers and adds Spacewar's Device IDs.

### Step 3 — UEFI Build
```
Actions → "Build WOA-Spacewar UEFI" → Run workflow
```
Compiles the UEFI firmware and uploads `boot-spacewar.img` as a release artifact.

---

## 📦 Sources & References

| Repository | Usage |
|---|---|
| [edk2-porting/edk2-msm](https://github.com/edk2-porting/edk2-msm) | Base UEFI platform (SM7325) |
| [AistopGit/windows_oem_xiaomi_lisa](https://github.com/AistopGit/windows_oem_xiaomi_lisa) | Lisa driver pack (GPU working!) |
| [n00b69/woa-lisa](https://github.com/n00b69/woa-lisa) | Lisa WOA guide & experimental drivers |
| [woa-a52s/Samsung-A52s-5G-Guides](https://github.com/woa-a52s/Samsung-A52s-5G-Guides) | A52s reference port (SM7325) |
| [ExTV/android_kernel_devicetree_nothing_sm7325](https://github.com/ExTV/android_kernel_devicetree_nothing_sm7325) | Nothing official Android DT |
| [crdroidandroid/android_device_nothing_Spacewar](https://github.com/crdroidandroid/android_device_nothing_Spacewar) | CrDroid device tree (BoardConfig) |
| [WOA-Project/Qualcomm-Reference-Drivers](https://github.com/WOA-Project/Qualcomm-Reference-Drivers) | Qualcomm reference drivers |

---

## 🙏 Credits & Attributions

This project stands on the shoulders of many developers. Full credit goes to:

### Renegade Project / edk2-porting
- **[@edk2-porting](https://github.com/edk2-porting)** — edk2-msm platform, SM7325 UEFI base
- **[@gus33000](https://github.com/gus33000)** — WOA architecture, drivers, ACPI expertise
- **[@Lemon1ice](https://github.com/Lemon1ice)** — WOA-Drivers
- **[@NTAuthority](https://github.com/NTAuthority)** — WOA-Drivers
- **[@imbushuo](https://github.com/imbushuo)** — WOA-Drivers
- **[@strongtz](https://github.com/strongtz)** — WOA-Drivers

### WOA-Lisa Project (GPU working — our primary reference)
- **[@AistopGit](https://github.com/AistopGit)** — windows_oem_xiaomi_lisa driver pack, experimental GPU driver
- **[@N1kroks](https://github.com/N1kroks)** — Lisa port maintainer
- **[@map220v](https://github.com/map220v)** — Touch driver reference
- **[@halal-beef](https://github.com/halal-beef)** — Lisa port contributor
- **[@Project-Silicium](https://github.com/Project-Silicium)** — Lisa port maintainer
- **[@remtrik](https://github.com/remtrik)** — Lisa port contributor
- **[@n00b69](https://github.com/n00b69)** — woa-lisa guide & driver repacking
- **[@TheMorc](https://github.com/TheMorc)** — Lisa contributor
- **[@MollySophia](https://github.com/MollySophia)** — Lisa contributor
- **[@KuatoDev](https://github.com/KuatoDev)** — Lisa contributor
- **[@TrustedFloppa](https://github.com/TrustedFloppa)** — Lisa contributor
- **[@Misha803](https://github.com/Misha803)** — Lisa contributor
- **[@bibarub](https://github.com/bibarub)** — Lisa contributor
- **[@Ilya114](https://github.com/Ilya114)** — Lisa contributor
- **[@ETCHDEV](https://github.com/ETCHDEV)** — Lisa port page
- **[@Kumar-Jy](https://github.com/Kumar-Jy)** — Lisa contributor
- **[@ArturoGC06](https://github.com/ArturoGC06)** — Lisa contributor
- **[@SebastianZSXS](https://github.com/SebastianZSXS)** — Lisa contributor
- **[@haouarihk](https://github.com/haouarihk)** — Lisa contributor
- **[@adomerlee](https://github.com/adomerlee)** — Lisa contributor
- **[@proganime1200](https://github.com/proganime1200)** — Lisa contributor

### WOA-A52s Project (SM7325 reference)
- **[@arminask](https://github.com/arminask)** — woa-a52s project lead, UEFI & drivers

### Nothing / CrDroid / Android Sources
- **[@mysellysenpai](https://github.com/mysellysenpai)** — CrDroid kernel for Spacewar (5.4.302)
- **[@crdroidandroid](https://github.com/crdroidandroid)** — CrDroid device tree & ROM
- **[@ExTV](https://github.com/ExTV)** — Nothing official kernel DT mirror
- **Nothing Technology Limited** — Open source kernel releases

### WOA-Project
- **[@WOA-Project](https://github.com/WOA-Project)** — Qualcomm reference drivers, Surface Duo WOA expertise

---

## 🤖 AI Assistance Disclosure

> This project was **bootstrapped with the assistance of Claude (Anthropic)**, an AI assistant.
>
> Claude helped with:
> - Project architecture and file structure planning
> - GitHub Actions workflow design
> - Hardware analysis script (`analyze_hardware.py`)
> - Driver adaptation script (`adapt_drivers.py`)  
> - Initial ACPI/DSDT table skeleton
> - Hardware research and cross-referencing source repositories
>
> All generated code is reviewed, verified against real Android source repositories,
> and will be corrected based on actual hardware analysis results.
> Claude does not replace human expertise — all critical hardware values are
> extracted from real source repositories, not AI-generated guesses.
>
> **Maintainer:** [@aliss32](https://github.com/aliss32)  
> **AI Tool:** [Claude by Anthropic](https://www.anthropic.com/claude) (claude.ai)

---

## ⚖️ License

```
GPL-3.0 License

Copyright (c) 2026 aliss32

Based on works by:
  Copyright (c) edk2-porting contributors
  Copyright (c) WOA-Project contributors  
  Copyright (c) 2017-2024 Qualcomm Incorporated
  Copyright (c) 2019-2024 Microsoft Corporation
  Copyright (c) Nothing Technology Limited
```

---

## 💬 Community

> If you're a developer with Snapdragon 778G+ or Nothing Phone (1) experience,
> contributions are very welcome! Open an issue or pull request.

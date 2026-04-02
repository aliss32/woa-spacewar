# Spacewar (Nothing Phone 1) - Windows on ARM Driver Package

## Overview
This directory contains the **SM7325 (Kodiak/Yupik)** Windows driver package for the Nothing Phone (1).
The drivers are sourced from [Project-Aloha/Kodiak-Drivers](https://github.com/Project-Aloha/Kodiak-Drivers), which maintains Qualcomm reference drivers adapted for SM7325 SoC devices.

## Driver Categories

### Boot-Critical (BASE_MINIMAL + KODIAK_MINIMAL)
| Category | Description |
|----------|-------------|
| SOC/ACPI | ACPI platform helpers |
| SOC/Buses | I2C, SPI, SPMI bus controllers |
| SOC/GPIO | Pin control / GPIO |
| SOC/PMIC | Power management IC |
| SOC/SMMU | System MMU / IOMMU |
| SOC/System | Core SoC infrastructure |
| I2C | I2C bus enumeration |
| TrEE | TrustZone Runtime Environment |
| UART | Serial debug port |

### Platform Drivers (BASE)
| Category | Description |
|----------|-------------|
| Audio | Sound (ADCM, Slimbus, RPC) |
| Battery | Battery/charging management |
| Bluetooth | BT pairing registry |
| Camera | Camera pipeline |
| Cellular | Modem, IPA, diagnostics |
| GPS | Location services |
| HexagonLoader | DSP firmware loader |
| Shutdown | Power off / reboot |
| USB / USBFn / USBHost | USB Type-C OTG support |

### Device-Specific Drivers (KODIAK)
| Category | Description |
|----------|-------------|
| **Touch** | **Touchscreen controller (I2C HID)** |
| Audio | Miniport + sound model |
| Bluetooth | BT firmware |
| Camera | Front/Aux sensors, ISP, AVS |
| Cellular | Modem firmware |
| Display | GPU/Adreno display extensions |
| LED | Notification LED |
| Sensors | Accelerometer, gyroscope, etc. |
| Wlan | Wi-Fi (WCNSS) |

## How to Use

### Method 1: PowerShell Script (Recommended)
Run `inject_drivers.ps1` as Administrator:

```powershell
# For Windows PE (boot.wim):
.\inject_drivers.ps1 -WimPath "D:\sources\boot.wim" -WimIndex 1

# For Full Windows (install.wim):
.\inject_drivers.ps1 -WimPath "D:\sources\install.wim" -WimIndex 1
```

### Method 2: Manual DISM Injection
```cmd
:: Mount WIM
mkdir C:\WinPE_Mount
dism /Mount-Wim /WimFile:"D:\sources\boot.wim" /Index:1 /MountDir:C:\WinPE_Mount

:: Inject all drivers recursively
dism /Image:C:\WinPE_Mount /Add-Driver /Driver:"Kodiak-Drivers\components\QC7325" /Recurse /ForceUnsigned

:: Unmount and save
dism /Unmount-Wim /MountDir:C:\WinPE_Mount /Commit
```

## Important Notes
- **Touchscreen**: The `Touch` driver under `DEVICE.SOC_QC7325.KODIAK` provides I2C HID touchscreen support. This is what enables touch in Windows PE.
- **USB OTG**: USB drivers are included under `PLATFORM.SOC_QC7325.BASE`, enabling mouse/keyboard via OTG.
- **GPU**: Display extensions are present but Adreno GPU acceleration may be limited.
- **WiFi**: WLAN drivers included; may require firmware from the Android partition.
- This driver package is from the Qualcomm reference platform. Some drivers may need Nothing Phone-specific tuning.

#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Injects SM7325 (Kodiak) Windows drivers into a WIM image for Nothing Phone (1).

.DESCRIPTION
    This script mounts a Windows PE or Install WIM image, injects all QC7325 drivers
    from the Kodiak-Drivers package, and unmounts the image saving changes.

.PARAMETER WimPath
    Full path to the .wim file (e.g., boot.wim or install.wim)

.PARAMETER WimIndex
    Image index inside the WIM (default: 1)

.PARAMETER MountDir
    Directory to mount the WIM image to (default: C:\WinPE_Mount)

.EXAMPLE
    .\inject_drivers.ps1 -WimPath "D:\sources\boot.wim" -WimIndex 1
    .\inject_drivers.ps1 -WimPath "D:\sources\install.wim" -WimIndex 1
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$WimPath,

    [int]$WimIndex = 1,

    [string]$MountDir = "C:\WinPE_Mount"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$DriverRoot = Join-Path $ScriptDir "Kodiak-Drivers\components\QC7325"

# ─── Validation ──────────────────────────────────────────
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  SPACEWAR DRIVER INJECTOR (SM7325/Kodiak)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $WimPath)) {
    Write-Host "[ERROR] WIM file not found: $WimPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $DriverRoot)) {
    Write-Host "[ERROR] Driver directory not found: $DriverRoot" -ForegroundColor Red
    Write-Host "        Run 'git clone' for Kodiak-Drivers first." -ForegroundColor Yellow
    exit 1
}

$infCount = (Get-ChildItem -Path $DriverRoot -Recurse -Filter "*.inf").Count
Write-Host "[INFO] Found $infCount driver INF files in Kodiak package" -ForegroundColor Green

# ─── Create mount directory ──────────────────────────────
if (-not (Test-Path $MountDir)) {
    Write-Host "[INFO] Creating mount directory: $MountDir"
    New-Item -ItemType Directory -Path $MountDir -Force | Out-Null
}

# ─── Mount WIM ───────────────────────────────────────────
Write-Host ""
Write-Host "[STEP 1/4] Mounting WIM image..." -ForegroundColor Yellow
Write-Host "  File : $WimPath"
Write-Host "  Index: $WimIndex"
Write-Host "  Mount: $MountDir"

try {
    Mount-WindowsImage -ImagePath $WimPath -Index $WimIndex -Path $MountDir
    Write-Host "[OK] WIM mounted successfully." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to mount WIM: $_" -ForegroundColor Red
    exit 1
}

# ─── Inject Drivers ──────────────────────────────────────
Write-Host ""
Write-Host "[STEP 2/4] Injecting drivers..." -ForegroundColor Yellow

$driverDirs = @(
    # === MINIMAL / BASE SOC (boot-critical) ===
    "Platform\PLATFORM.SOC_QC7325.BASE_MINIMAL",
    "Device\Kodiak\DEVICE.SOC_QC7325.KODIAK_MINIMAL",
    
    # === FULL PLATFORM DRIVERS ===
    "Platform\PLATFORM.SOC_QC7325.BASE",
    
    # === DEVICE-SPECIFIC DRIVERS ===
    "Device\Kodiak\DEVICE.SOC_QC7325.KODIAK"
)

$totalInjected = 0
$totalFailed = 0

foreach ($dir in $driverDirs) {
    $fullPath = Join-Path $DriverRoot $dir
    if (Test-Path $fullPath) {
        $localInfs = (Get-ChildItem -Path $fullPath -Recurse -Filter "*.inf").Count
        Write-Host "  [+] $dir ($localInfs INFs)" -ForegroundColor Cyan
        try {
            $result = Add-WindowsDriver -Path $MountDir -Driver $fullPath -Recurse -ForceUnsigned
            $totalInjected += $localInfs
            Write-Host "      OK" -ForegroundColor Green
        } catch {
            Write-Host "      WARN: Some drivers failed: $_" -ForegroundColor Yellow
            $totalFailed += $localInfs
        }
    } else {
        Write-Host "  [!] SKIP (not found): $dir" -ForegroundColor DarkYellow
    }
}

Write-Host ""
Write-Host "[INFO] Injected: $totalInjected | Failed/Skipped: $totalFailed" -ForegroundColor Green

# ─── Verify ──────────────────────────────────────────────
Write-Host ""
Write-Host "[STEP 3/4] Verifying injected drivers..." -ForegroundColor Yellow
$installedDrivers = Get-WindowsDriver -Path $MountDir
Write-Host "  Total drivers in image: $($installedDrivers.Count)" -ForegroundColor Green

# Show key categories
$touchDrivers = $installedDrivers | Where-Object { $_.OriginalFileName -like "*Touch*" -or $_.OriginalFileName -like "*hid*" }
$usbDrivers = $installedDrivers | Where-Object { $_.OriginalFileName -like "*USB*" -or $_.OriginalFileName -like "*usb*" }
$gpuDrivers = $installedDrivers | Where-Object { $_.OriginalFileName -like "*Display*" -or $_.OriginalFileName -like "*GPU*" -or $_.OriginalFileName -like "*Adreno*" }
$wlanDrivers = $installedDrivers | Where-Object { $_.OriginalFileName -like "*Wlan*" -or $_.OriginalFileName -like "*wifi*" }

Write-Host "  Touch/HID : $($touchDrivers.Count) drivers" -ForegroundColor $(if ($touchDrivers.Count -gt 0) {"Green"} else {"Red"})
Write-Host "  USB       : $($usbDrivers.Count) drivers" -ForegroundColor $(if ($usbDrivers.Count -gt 0) {"Green"} else {"Red"})
Write-Host "  GPU       : $($gpuDrivers.Count) drivers" -ForegroundColor $(if ($gpuDrivers.Count -gt 0) {"Green"} else {"Red"})
Write-Host "  WiFi/WLAN : $($wlanDrivers.Count) drivers" -ForegroundColor $(if ($wlanDrivers.Count -gt 0) {"Green"} else {"Red"})

# ─── Unmount & Save ──────────────────────────────────────
Write-Host ""
Write-Host "[STEP 4/4] Unmounting WIM and saving changes..." -ForegroundColor Yellow
try {
    Dismount-WindowsImage -Path $MountDir -Save
    Write-Host "[OK] WIM saved successfully!" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to unmount: $_" -ForegroundColor Red
    Write-Host "  Try: Dismount-WindowsImage -Path '$MountDir' -Discard" -ForegroundColor Yellow
    exit 1
}

# ─── Summary ─────────────────────────────────────────────
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  DRIVER INJECTION COMPLETE!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  WIM File  : $WimPath" 
Write-Host "  Drivers   : $totalInjected injected"
Write-Host ""
Write-Host "  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Copy the WIM to a USB drive (FAT32)"
Write-Host "  2. Boot Nothing Phone (1) into UEFI"
Write-Host "  3. Plug in USB via OTG cable"
Write-Host "  4. Windows PE should start with touch + USB support!"
Write-Host ""

$drivers = @(
    "ButtonsDxe", "ChipInfo", "ClockDxe", "CmdDbDxe", "DALSys", "DALTLMM", "DDRInfoDxe",
    "GlinkDxe", "HALIOMMU", "HWIODxeDriver", "I2C", "ICBDxe", "IPCCDxe", "NpaDxe",
    "PlatformInfoDxeDriver", "PmicDxe", "PmicGlinkDxe", "PwrUtilsDxe", "ResetRuntimeDxe",
    "RpmhDxe", "SPMI", "ScmDxeLA", "ShmBridgeDxeLA", "SmemDxe", "TzDxeLA", "UFSDxe",
    "ULogDxe", "UsbConfigDxe", "UsbPwrCtrlDxe", "UsbfnDwc3Dxe", "VcsDxe", "XhciDxe",
    "XhciPciEmulation"
)

$repoBase = "https://github.com/edk2-porting/edk2-msm-binary/raw/d097b8a8bf3641e5e0c8b36ef1ac9d7cc1a0bd94/Drivers/sm7325"
$localBase = "UEFI/Platform/EFI_Binaries/Drivers/sm7325"

foreach ($d in $drivers) {
    $dir = "$localBase/$d"
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force
    }
    
    $efiUrl = "$repoBase/$d/$d.efi"
    $depexUrl = "$repoBase/$d/$d.depex"
    
    Write-Host "Downloading $d..."
    curl.exe -L -o "$dir/$d.efi" $efiUrl
    curl.exe -L -o "$dir/$d.depex" $depexUrl
}

# Also handle device-specific ButtonsDxe for spacewar (using lisa as baseline if needed, but repo has sm7325 version)
$spacewarButtonsDir = "UEFI/Platform/EFI_Binaries/Drivers/Devices/spacewar/ButtonsDxe"
if (!(Test-Path $spacewarButtonsDir)) {
    New-Item -ItemType Directory -Path $spacewarButtonsDir -Force
}
# Since we don't have spacewar specific one, use sm7325 one as initial placeholder or lisa's one
# Lisa is SM7325 too. Let's get lisa's buttons too just in case.
$lisaButtonsRepo = "https://github.com/edk2-porting/edk2-msm-binary/raw/d097b8a8bf3641e5e0c8b36ef1ac9d7cc1a0bd94/Drivers/Devices/lisa/ButtonsDxe"
curl.exe -L -o "$spacewarButtonsDir/ButtonsDxe.efi" "$lisaButtonsRepo/ButtonsDxe.efi"
curl.exe -L -o "$spacewarButtonsDir/ButtonsDxe.depex" "$lisaButtonsRepo/ButtonsDxe.depex"

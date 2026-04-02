# Upstream Mu-Silicium Reference Files

These files are direct copies from the **official** [Project-Silicium/Mu-Silicium](https://github.com/Project-Silicium/Mu-Silicium) repository.

They represent the **correct**, working configurations for the Nothing Phone (1) (`spacewar`) device.

## Purpose

When you need to modify the build configuration, use these files as the ground truth reference.
Our custom files in `UEFI/Platform/Nothing/sm7325/` may diverge for device-specific tweaks,
but any changes should be validated against these upstream originals.

## Source

- Repository: `https://github.com/Project-Silicium/Mu-Silicium`
- Path: `Platforms/Nothing/spacewarPkg/`
- Config: `Resources/Configs/spacewar.conf`
- Snapshot date: 2026-04-02

## Key Differences (Upstream vs Our Custom)

| Parameter | Upstream | Our Custom | Notes |
|-----------|----------|------------|-------|
| `FD_BASE` | `0x9FD00000` | `0x80200000` | Upstream is correct — avoids DDR overlap |
| `FD_SIZE` | `0x200000` | `0x00300000` | Upstream is correct |
| `PLATFORM_GUID` | `852F8D31-E146-...` | `2a2c9e2b-3f4d-...` | Upstream is correct |
| `FLASH_DEFINITION` | `spacewarPkg/spacewar.fdf` | `Platform/Qualcomm/sm7325/sm7325.fdf` | Different build systems |
| `SOC_TYPE` | `1` (SM7325-AE) | Not set | Must be set for correct SoC variant |
| `SerialPortLib` | SoC default (UART active) | Null (disabled) | Upstream allows debug logs |
| Token GUIDs | `gSiliciumPkgTokenSpaceGuid` | `gRenegadePkgTokenSpaceGuid` | Different framework |

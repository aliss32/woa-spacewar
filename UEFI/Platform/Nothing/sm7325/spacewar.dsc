## @file
# WOA-Spacewar - Nothing Phone (1) Build Configuration
# SoC: SM7325-AE (Snapdragon 778G+)
# Credits: AistopGit, N1kroks, arminask, edk2-porting team
# Copyright (c) 2026 aliss32 - GPL-3.0-or-later
##

[Defines]
  PLATFORM_NAME                  = spacewar
  PLATFORM_GUID                  = 2a2c9e2b-3f4d-4a1b-8c5e-1d6f7a8b9c0d
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010005
  OUTPUT_DIRECTORY               = Build/$(PLATFORM_NAME)
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT

[PcdsFixedAtBuild.common]
  gQcomTokenSpaceGuid.PcdMipiFrameBufferAddress|0xE1000000
  gQcomTokenSpaceGuid.PcdMipiFrameBufferWidth|1080
  gQcomTokenSpaceGuid.PcdMipiFrameBufferHeight|2400
  gQcomTokenSpaceGuid.PcdGuiDefaultDPI|420
  gQcomTokenSpaceGuid.PcdDeviceVendor|L"Nothing"
  gQcomTokenSpaceGuid.PcdDeviceProduct|L"Phone (1)"
  gQcomTokenSpaceGuid.PcdDeviceCodeName|L"spacewar"

[BuildOptions]
  GCC:*_*_AARCH64_CC_FLAGS = -DSILICON_PLATFORM=7325

!include SM7325Pkg/SM7325Pkg.dsc.inc

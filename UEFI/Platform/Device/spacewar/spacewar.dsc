## @file
#  WOA-Spacewar — Nothing Phone (1) UEFI Build Configuration
#
#  Based on:
#    - edk2-porting/edk2-msm (SM7325 platform)
#    - woa-lisa (Lisa device tree — SM7325, GPU working)
#    - woa-a52s (A52s device tree — SM7325 reference)
#
#  Hardware values sourced from:
#    - crdroidandroid/android_device_nothing_Spacewar BoardConfig.mk
#    - ExTV/android_kernel_devicetree_nothing_sm7325
#
#  Copyright (c) 2026 aliss32
#  SPDX-License-Identifier: GPL-3.0-or-later
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

  # Memory map — SM7325-AE
  # Framebuffer: 0xe1000000 (confirmed from Android DT)
  # Kernel base: 0x00000000 (confirmed from BoardConfig.mk)
  DEFINE FD_BASE     = 0x9FC00000
  DEFINE FD_SIZE     = 0x00200000
  DEFINE FD_BLOCKS   = 0x200

  DEFINE DEVICE_DXE_FV_COMPONENTS = Platform/Device/spacewar/DXE.fdf.inc

[BuildOptions]
  GCC:*_*_AARCH64_CC_FLAGS = -DSILICON_PLATFORM=7325

!include SM7325Pkg/SM7325Pkg.dsc.inc
!include Platform/Device/spacewar/Device.dsc.inc

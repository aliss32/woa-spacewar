[Defines]
  VENDOR_NAME                    = Nothing
  PLATFORM_NAME                  = spacewar
  PLATFORM_GUID                  = 2a2c9e2b-3f4d-4a1b-8c5e-1d6f7a8b9c0d
  PLATFORM_VERSION               = 0.1
  DSC_SPECIFICATION              = 0x00010019
  OUTPUT_DIRECTORY               = Build/$(PLATFORM_NAME)
  SUPPORTED_ARCHITECTURES        = AARCH64
  BUILD_TARGETS                  = DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT
  FLASH_DEFINITION               = Platform/Qualcomm/sm7325/sm7325.fdf
  DEVICE_DXE_FV_COMPONENTS       = Platform/Nothing/sm7325/spacewar.fdf.inc

!include Platform/Qualcomm/sm7325/sm7325.dsc

[BuildOptions.common]
  GCC:*_*_AARCH64_CC_FLAGS = -DENABLE_SIMPLE_INIT -DENABLE_LINUX_SIMPLE_MASS_STORAGE

[PcdsFixedAtBuild.common]
  # Display - 1080x2400 @ 60Hz (DSC Enabled) [Experimental]
  # PcdMipiFrameBufferAddress|0xE1000000 already defined in sm7325.dsc - do not redefine here
  gQcomTokenSpaceGuid.PcdMipiFrameBufferWidth|1080
  gQcomTokenSpaceGuid.PcdMipiFrameBufferHeight|2400
  gSimpleInitTokenSpaceGuid.PcdGuiDefaultDPI|420
  gRenegadePkgTokenSpaceGuid.PcdDeviceVendor|"Nothing"
  gRenegadePkgTokenSpaceGuid.PcdDeviceProduct|"Phone (1)"
  gRenegadePkgTokenSpaceGuid.PcdDeviceCodeName|"spacewar"
  
  # GIC and UART Fix
  gArmTokenSpaceGuid.PcdGicDistributorBase|0x17A00000
  gArmTokenSpaceGuid.PcdGicRedistributorsBase|0x17B00000
  gEfiMdeModulePkgTokenSpaceGuid.PcdSerialRegisterBase|0x00994000

[LibraryClasses.common]
  PlatformMemoryMapLib|Platform/Nothing/sm7325/Library/PlatformMemoryMapLib/PlatformMemoryMapLib.inf

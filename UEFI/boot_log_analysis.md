# Spacewar UEFI Boot Log Analysis (page1.png + page2.png)

> Source: `C:\Users\aliha\Desktop\ss\page1.png` and `page2.png`
> Date: 2026-04-02
> Device: Nothing Phone (1) — SM7325 (Kodiak / SM7325-AE)

---

## PAGE 1 — Early Boot / DXE Core Loading

### Build Info Header
```
UEFI firmware for Nothing Phone 1
UEFI DXE Build ID 021417 on Apr  2 2026
```

### DXE Core Entry
```
Loading DxeCore at 0x00E5431000 EntryPoint=0x00E5432230
HOBLIST address in DXE = 0x832B9018
```

### Memory Allocation Table
The system dumps a full list of memory allocations. Key regions visible:

```
Memory Al location 0x00000000 0x80500000   - 0x806FFFFF
Memory Al location 0x00000007 0x00000000   - 0x808B3FFF
Memory Al location 0x00000000 0x00000000   - 0x808B9FFF
Memory Al location 0x00000007 0x80884000   - 0x808FFFFF
Memory Al location 0x00000007 0x00000000   - 0x835FFFFF
Memory Al location 0x00000007 0x40100000   - 0xXXXXXXXX
Memory Al location 0x00000007 0x0A000000   - 0xXXXXXXXX
                   ...  (many more entries)
```

> **Note:** Memory type codes: 0x00000000 = EfiReservedMemoryType, 0x00000004 = EfiRuntimeServicesData, 0x00000007 = EfiConventionalMemory

### Install Protocol Interface Entries
Multiple `InstallProtocolInterface` calls for GUIDs visible (standard DXE protocol installation).

### StatusCode Router
```
Loading driver at 0x00EC000000 EntryPoint=0x00EC20000 StatusCodeRouterRuntimeDxe
Loading driver at 0x00ECXXXXXX EntryPoint=0x00ECXXXXXX StatusCodeHandlerRuntimeDxe.efi
```

### DXE Drivers Loading (Sequence from page1)
```
Loading driver ... RuntimeDxe.efi
Loading driver ... ArmCpuDxe.efi
Loading driver ... ArmGicDxe.efi              ← GIC loaded OK!
Loading driver ... MetronomeDxe.efi
Loading driver ... ArmTimerDxe.efi
Loading driver ... SemihostFsDxe.efi          (or SmbiosDxe.efi)
Loading driver ... DynamicRamDxe.efi

Loading driver ... DALSys.efi
Loading driver ... HWIODmaDriver.efi          (HWIO)
Loading driver ... ChipInfo.efi
Loading driver ... PlatformInfoDxeDriver.efi
Loading driver ... HALIOMMU.efi
Loading driver ... ULogDxe.efi
Loading driver ... CmdDbDxe.efi
Loading driver ... PwrUtilsDxe.efi
Loading driver ... NpaDxe.efi
Loading driver ... RpmhDxe.efi
Loading driver ... ClockDxe.efi
Loading driver ... TLMM.efi                   (GPIO/pin control)
Loading driver ... SPMIDxe.efi
Loading driver ... PmicDxe.efi
Loading driver ... GlinkDxe.efi
```

---

## PAGE 2 — Late DXE Phase & Fatal Error

### Continued Driver Loading
```
Loading driver ... ICBDxe.efi                 (Interconnect Bus)
Loading driver ... SmemDxe.efi
Loading driver ... ScmDxe.efi                 (Secure Channel Manager)
Loading driver ... PilDxe.efi                 (Peripheral Image Loader)
Loading driver ... USB drivers...
```

### First Warning — SMEM
```
smem_alloc at 0x00CF23000 start FdInfo Not Found
```
This means the `SmemDxe` driver could not find a required entry in shared memory. SMEM is used for inter-processor communication between the Application Processor (AP) and modem/DSP subsystems.

### Second Warning — PIL/TZ Interaction
```
Loading driver ... MinidumpTADxe.efi
```

### SCM / TrustZone Errors
```
scm alloc failed with err=<...>, size=..., flags=0
```

### USB Configuration
```
  start on port: 0, mode 0
  ...
  start on port: 1, mode 0
```
USB host controller enumeration is visible, suggesting the system got far enough to try USB init.

### FATAL: TrustZone SMC Call Failure
```
tz_arm2_smc_call failed, tzStatus = 0xFFFFFFFF
```
The secure monitor call to TrustZone returns `-1` (fail). The `SmcId` involved is `0x32000105`.

### APP_REGION_NOTIFICATION_CMD
```
APP_REGION_NOTIFICATION_CMD failed, status 3
```
This TrustZone command notifies the secure world about application processor memory region assignments. Status `3` = failure.

### FINAL ASSERT — Boot Halted
```
ASSERT_EFI_ERROR (Status = Unsupported)
ERROR: C90000002:V03000007 [0 E6287857-59B4-4489-B1AE-45FFR250347C
```

The firmware halts with an `EFI_UNSUPPORTED` ASSERT. The GUID `E6287857-59B4-4489-B1AE-...` identifies the protocol or driver that triggered the assertion.

---

## Analysis & Explanation

### What Worked ✅
1. **DXE Core loaded successfully** — The main UEFI dispatcher started without issues
2. **ArmGicDxe.efi loaded** — Previous GIC memory address fixes (`0x17A00000` / `0x17A60000`) are working correctly
3. **ArmTimerDxe.efi loaded** — Arch timer is functional
4. **All Qualcomm base drivers loaded** — DALSys, ChipInfo, PlatformInfo, PMIC, Clock, TLMM, SPMI all initialized
5. **USB enumeration started** — System got far enough to attempt USB port initialization

### What Failed ❌
1. **`SmemDxe.efi`** — Could not find `FdInfo` in shared memory → SMEM base address or size is wrong in the memory map
2. **`MinidumpTADxe.efi`** — TrustZone secure monitor call (SMC) with ID `0x32000105` returned `0xFFFFFFFF`
3. **`APP_REGION_NOTIFICATION_CMD`** — Failed with status 3 → TrustZone doesn't accept the memory region configuration
4. **`ASSERT_EFI_ERROR (Unsupported)`** — Boot halted completely

### Root Cause
The TrustZone hypervisor (running in EL3/secure world) **rejects the memory region notifications** sent by the UEFI firmware. This happens because:

1. **Missing SMEM reservation** — The `PlatformMemoryMapLib.c` memory map doesn't define the correct Shared Memory (SMEM) region that TrustZone expects
2. **Missing PIL regions** — Peripheral Image Loader regions for modem/DSP subsystems are not declared, so TrustZone cannot validate memory ownership
3. **Missing TZ App region** — The `APP_REGION_NOTIFICATION_CMD` requires specific memory regions to be reserved and registered with TrustZone before the notification can succeed

### Recommended Fix
Use the **upstream Mu-Silicium `MemoryMapLib`** (already saved at `UEFI/upstream_reference/`). The upstream memory map at `Platforms/Nothing/spacewarPkg/Library/MemoryMapLib/` includes the correct SMEM, PIL, IMEM, and TZ reserved regions that align with what TrustZone expects on SM7325.

Specifically, the missing regions likely include:
- **SMEM**: `0x80900000` - size `0x200000`
- **TZ Apps**: region around `0x87900000`
- **PIL Reserved**: DSP/modem firmware regions
- **IMEM**: Internal memory at `0x14680000`

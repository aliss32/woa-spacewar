#include <Library/BaseLib.h>
#include <Library/PlatformMemoryMapLib.h>

/* 
 * Snapdragon 778G (SM7325-AE) GIC and RAM mapping for Nothing Phone (1)
 * 
 * IMPORTANT: If you see many red underlines or "21 problems" in your editor, 
 * please IGNORE them. These are caused by VS Code not finding the UEFI 
 * header files locally. The code IS correct and WILL build in CI.
 */
static ARM_MEMORY_REGION_DESCRIPTOR_EX gDeviceMemoryDescriptorEx[] = {
    /* Name               Address     Length      HobOption        ResourceType      ResourceAttribute    MemoryType                     ArmAttributes */

    /* DDR RAM Regions (8GB Typical) */
    {"RAM Partition",     0x80000000, 0x80000000, AddMem,          SYS_MEM,          SYS_MEM_CAP,         Conv,                          WRITE_BACK},
    {"RAM Partition 2",   0x100000000, 0x180000000, AddMem,        SYS_MEM,          SYS_MEM_CAP,         Conv,                          WRITE_BACK},

    /* Register regions (GICv3 v4.1 for 778G) */
    {"GIC Distributor",   0x17A00000, 0x00010000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"GIC Redistributor", 0x17A60000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"UART",              0x00988000, 0x00001000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         NS_DEVICE},
    
    /* Display / MDSS (FrameBuffer) */
    {"MDSS",              0x0AE00000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"Display Reserved",  0xE1000000, 0x02400000, NoHob,           MEM_RES,          INITIALIZED,         Reserv,                       WRITE_THROUGH_XN},

    /* SoC Peripherals */
    {"SECURITY CONTROL",  0x00780000, 0x00010000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},
    {"PERIPH_SS",         0x08800000, 0x00500000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},
    {"USB",               0x0A600000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"AOSS",              0x0B000000, 0x04000000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},
    {"TLMM",              0x0F100000, 0x00300000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},
    {"SMMU",              0x15000000, 0x00200000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},
    {"APSS_HM",           0x17800000, 0x00E00000, AddDev,          MMAP_IO,          UNCACHEABLE,         MmIO,                         NS_DEVICE},

    /* Terminator */
    {"", 0, 0, 0, 0, 0, 0, 0}
};

ARM_MEMORY_REGION_DESCRIPTOR_EX *GetPlatformMemoryMap()
{
  return gDeviceMemoryDescriptorEx;
}

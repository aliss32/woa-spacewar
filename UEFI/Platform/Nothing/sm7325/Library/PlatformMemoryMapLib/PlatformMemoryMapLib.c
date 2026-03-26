#include <Library/BaseLib.h>
#include <Library/PlatformMemoryMapLib.h>

/* Snapdragon 778G (SM7325-AE) GIC and RAM mapping for Nothing Phone (1) */
static ARM_MEMORY_REGION_DESCRIPTOR_EX gDeviceMemoryDescriptorEx[] = {
    /* Name               Address     Length      HobOption        ResourceType      ResourceAttribute    MemoryType                     ArmAttributes */

    /* DDR RAM Regions (8GB Typical) */
    {"RAM Partition",     0x80000000, 0x80000000, AddMem,          SYS_MEM,          SYS_MEM_CAP,         Conv,                          WRITE_BACK},
    {"RAM Partition 2",   0x100000000, 0x180000000, AddMem,        SYS_MEM,          SYS_MEM_CAP,         Conv,                          WRITE_BACK},

    /* Register regions (GICv3 v4.1 for 778G) */
    {"GIC Distributor",   0x17A00000, 0x00010000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"GIC Redistributor", 0x17B00000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"UART",              0x00994000, 0x00001000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    
    /* Display / MDSS (FrameBuffer) */
    {"MDSS",              0x0AE00000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"Display Reserved",  0x9C000000, 0x02400000, NoHob,           MEM_RES,          INITIALIZED,         Reserv,                       WRITE_BACK},

    /* SoC Peripherals */
    {"GPU",               0x03D00000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"USB",               0x0A600000, 0x00100000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},
    {"CAMERA",            0x0AC00000, 0x00800000, AddDev,          MMAP_IO,          INITIALIZED,         MmIO,                         DEVICE},

    /* Terminator */
    {"", 0, 0, 0, 0, 0, 0, 0}
};

ARM_MEMORY_REGION_DESCRIPTOR_EX *GetPlatformMemoryMap()
{
  return gDeviceMemoryDescriptorEx;
}

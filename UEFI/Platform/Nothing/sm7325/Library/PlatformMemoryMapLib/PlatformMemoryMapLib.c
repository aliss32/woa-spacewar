#include <Library/PlatformMemoryMapLib.h>

static ARM_MEMORY_REGION_DESCRIPTOR_EX gDeviceMemoryDescriptorEx[] = {
    /* Name               Address     Length      HobOption        ResourceType      ResourceAttribute             MemoryType                    ArmAttributes */

    /* SoC Peripherals */
    {"IPC_ROUTER_TOP",    0x00400000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"SECURITY CONTROL",  0x00780000, 0x00010000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"QUP",               0x00900000, 0x00200000, AddMem, MMAP_IO, UNCACHEABLE, MmIO, DEVICE},    /* Optimized for UART Debug */
    {"PRNG_CFG_PRNG",     0x010D0000, 0x00010000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"GCC",               0x00100000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"CRYPTO0 CRYPTO",    0x01DC0000, 0x00040000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"TCSR_TCSR_REGS",    0x01FC0000, 0x00030000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"PERIPH_SS_SDC1",    0x007C0000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"PERIPH_SS",         0x08800000, 0x00500000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"LLCC",              0x09200000, 0x00200000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"USB",               0x0A600000, 0x00400000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"VENUS",             0x0AA00000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"CAMERA",            0x0AC00000, 0x00800000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"MDSS",              0x0AE00000, 0x01100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"GPU",               0x03D00000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"AOSS",              0x0B000000, 0x04000000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"TLMM",              0x0F100000, 0x00300000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"SMMU",              0x15000000, 0x00200000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},
    {"APSS_HM",           0x17800000, 0x00E00000, AddMem, MMAP_IO, UNCACHEABLE, MmIO, DEVICE},    /* Optimized for GICv3 Control */

    /* QDSS & Other Bridges */
    {"QDSS",              0x06000000, 0x00100000, AddDev, MMAP_IO, UNCACHEABLE, MmIO, NS_DEVICE},

    /* Terminator */
    {"Terminator", 0, 0, 0, 0, 0, 0, 0}};

ARM_MEMORY_REGION_DESCRIPTOR_EX *GetPlatformMemoryMap() {
    return gDeviceMemoryDescriptorEx;
}

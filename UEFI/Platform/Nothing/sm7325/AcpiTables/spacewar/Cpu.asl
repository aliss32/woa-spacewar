/**
 * SM7325-AE (Snapdragon 778G+) CPU Power Management
 * 8 Cores: 1x Prime (2.5GHz) + 3x Performance (2.4GHz) + 4x Efficiency (1.9GHz)
 */

Scope (\_SB)
{
    // Efficiency Cluster (Cores 0-3)
    Device (PR00) { Name (_HID, "ACPI0007") Name (_UID, 0) Method (_CPC, 0) { Return (CPPL) } }
    Device (PR01) { Name (_HID, "ACPI0007") Name (_UID, 1) Method (_CPC, 0) { Return (CPPL) } }
    Device (PR02) { Name (_HID, "ACPI0007") Name (_UID, 2) Method (_CPC, 0) { Return (CPPL) } }
    Device (PR03) { Name (_HID, "ACPI0007") Name (_UID, 3) Method (_CPC, 0) { Return (CPPL) } }

    // Performance Cluster (Cores 4-6)
    Device (PR04) { Name (_HID, "ACPI0007") Name (_UID, 4) Method (_CPC, 0) { Return (CPPH) } }
    Device (PR05) { Name (_HID, "ACPI0007") Name (_UID, 5) Method (_CPC, 0) { Return (CPPH) } }
    Device (PR06) { Name (_HID, "ACPI0007") Name (_UID, 6) Method (_CPC, 0) { Return (CPPH) } }

    // Prime Core (Core 7)
    Device (PR07) { Name (_HID, "ACPI0007") Name (_UID, 7) Method (_CPC, 0) { Return (CPPP) } }

    // CPPC (Collaborative Processor Performance Control) Tables
    
    // Efficiency (Low) - Max 1.9 GHz
    Name (CPPL, Package()
    {
        54,      // NumEntries
        3,       // Revision
        255,     // Highest Performance
        190,     // Nominal Performance (1.9 GHz)
        100,     // Lowest Non-linear Performance
        50,      // Lowest Performance
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }, // Desired Perf
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }, // Minimum Perf
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }, // Maximum Perf
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }, // Energy Perf Pref
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }  // Reference Perf
    })

    // Performance (High) - Max 2.4 GHz
    Name (CPPH, Package()
    {
        54,
        3,
        255,
        240,     // Nominal Performance (2.4 GHz)
        120,
        60,
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }
    })

    // Prime (Gold Plus) - 2.4 GHz (Standard 778G Baseline)
    // NOTE: SM7325-AE can reach 2.52 GHz (Rating: 252)
    Name (CPPP, Package()
    {
        54,
        3,
        255,
        240,     // Nominal Performance (2.4 GHz)
        125,
        60,
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) },
        ResourceTemplate() { Register(FFixedHW, 64, 0, 0x0, 4) }
    })
}

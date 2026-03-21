# Contributing to WOA-Spacewar

Thank you for your interest in contributing!

## How to Help

### What we need most right now:
- **Touch IC identification** — Check `/proc/bus/input/devices` on your Nothing Phone (1)
- **Fingerprint IC identification** — Check dmesg or vendor logs
- **GPIO pin verification** — Compare our DSDT values against working Android DT
- **ACPI table expertise** — Help adapt Lisa/A52s ACPI to Spacewar hardware
- **Driver testing** — If you have a spare Spacewar device

### Steps to Contribute
1. Fork this repository
2. Create a branch: `git checkout -b feature/your-fix`
3. Make your changes
4. Open a Pull Request with a clear description

### Resources
- [edk2-msm documentation](https://github.com/edk2-porting/edk2-msm)
- [woa-lisa guide](https://github.com/n00b69/woa-lisa) (our primary reference)
- [Renegade Project Discord](https://discord.gg/XXBWfag)

### Important
- Never test permanent flashing on a daily driver device
- Always use `fastboot boot` for testing
- Document all hardware values with their source

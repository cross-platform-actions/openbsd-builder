architecture = "arm64"
// highmem=off if reqiured for enabling hardware acceleration on Apple Silicon.
// acpi=off because OpenBSD 7.x hangs during ACPI attach on the ACPI tables QEMU
// publishes to EDK II. Without them the kernel falls back to the device tree.
machine_type = "virt,highmem=off,acpi=off"
cpu_type = "cortex-a57"
firmware = "edk2-aarch64-code.fd"
memory = 3072 // max memory when hardware acceleration on Apple Silicon is enabled

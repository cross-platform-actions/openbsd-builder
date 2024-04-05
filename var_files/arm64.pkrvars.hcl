architecture = "arm64"
machine_type = "virt,highmem=off" // highmem=off if reqiured for enabling hardware acceleration on Apple Silicon
cpu_type = "cortex-a57"
firmware = "resources/qemu_efi.fd"
memory = 3072 // max memory when hardware acceleration on Apple Silicon is enabled

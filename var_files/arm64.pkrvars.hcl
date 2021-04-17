architecture = "arm64"
machine_type = "virt"
cpu_type = "cortex-a57"
qemu_extra_args = [
   ["-boot", "strict=off"],
   ["-monitor", "none"]
]

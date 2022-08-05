variable "os_version" {
  type = string
  description = "The version of the operating system to download and install"
}

variable "architecture" {
  default = "x86-64"
  type = string
  description = "The type of CPU to use when building"
}

variable "machine_type" {
  default = "pc"
  type = string
  description = "The type of machine to use when building"
}

variable "cpu_type" {
  default = "qemu64"
  type = string
  description = "The type of CPU to use when building"
}

variable "memory" {
  default = 4096
  type = number
  description = "The amount of memory to use when building the VM in megabytes"
}

variable "cpus" {
  default = 2
  type = number
  description = "The number of cpus to use when building the VM"
}

variable "disk_size" {
  default = "12G"
  type = string
  description = "The size in bytes of the hard disk of the VM"
}

variable "net_device" {
  default = "virtio-net"
  type = string
  description = "The driver to use for the network interface"
}

variable "network_interface" {
  default = "vio0"
  type = string
  description = "The network interface as it's named in OpenBSD"
}

variable "checksum" {
  type = string
  description = "The checksum for the virtual hard drive file"
}

variable "root_password" {
  default = "vagrant"
  type = string
  description = "The password for the root user"
}

variable "secondary_user_password" {
  default = "vagrant"
  type = string
  description = "The password for the `secondary_user_username` user"
}

variable "secondary_user_username" {
  default = "vagrant"
  type = string
  description = "The name for the secondary user"
}

variable "headless" {
  default = false
  description = "When this value is set to `true`, the machine will start without a console"
}

variable "use_default_display" {
  default = true
  type = bool
  description = "If true, do not pass a -display option to qemu, allowing it to choose the default"
}

variable "display" {
  default = "cocoa"
  description = "What QEMU -display option to use"
}

variable "accelerator" {
  default = "tcg"
  type = string
  description = "The accelerator type to use when running the VM"
}

variable "firmware" {
  type = string
  description = "The firmware file to be used by QEMU"
}

variable "readonly_boot_media" {
  default = true
  description = "If true, the boot media will be mounted as readonly"
}

variable "sudo_version" {
  type = string
  description = "The version of the sudo package to install"
}

variable "rsync_version" {
  type = string
  description = "The version of the rsync package to install"
}

locals {
  image_architecture = var.architecture == "x86-64" ? "amd64" : var.architecture
  image = "miniroot${replace(var.os_version, ".", "")}.img"
  vm_name = "openbsd-${var.os_version}-${var.architecture}.qcow2"

  iso_target_extension = "img"
  iso_target_path = "packer_cache"
  iso_full_target_path = "${local.iso_target_path}/${sha1(var.checksum)}.${local.iso_target_extension}"

  qemu_architecture = var.architecture == "arm64" ? "aarch64" : (
    var.architecture == "x86-64" ? "x86_64" : var.architecture
  )

  readonly_boot_media = var.readonly_boot_media ? "on" : "off"
}

source "qemu" "qemu" {
  machine_type = var.machine_type
  cpus = var.cpus
  memory = var.memory
  net_device = var.net_device

  disk_compression = true
  disk_interface = "virtio"
  disk_size = var.disk_size
  format = "qcow2"

  headless = var.headless
  use_default_display = var.use_default_display
  display = var.display
  accelerator = var.accelerator
  qemu_binary = "qemu-system-${local.qemu_architecture}"
  firmware = var.firmware

  boot_wait = "30s"

  boot_command = [
    "S<enter><wait>",
    "ifconfig ${var.network_interface} 10.0.2.15 255.255.255.0<enter><wait>",
    "ftp -o install.conf http://{{ .HTTPIP }}:{{ .HTTPPort }}/resources/install.conf<enter><wait>",
    "ftp -o install.sh http://{{ .HTTPIP }}:{{ .HTTPPort }}/resources/install.sh<enter><wait>",
    "SECONDARY_USER_USERNAME=${var.secondary_user_username} ",
    "SECONDARY_USER_PASSWORD=${var.secondary_user_password} ",
    "ROOT_PASSWORD=${var.root_password} ",
    "DISKLABEL_TEMPLATE='http://{{ .HTTPIP }}:{{ .HTTPPort }}/resources/template.disklabel' ",
    "sh install.sh && reboot<enter>"
  ]

  ssh_username = "root"
  ssh_password = var.root_password
  ssh_timeout = "10000s"

  qemuargs = [
    ["-cpu", var.cpu_type],
    ["-boot", "strict=off"],
    ["-monitor", "none"],
    ["-vga", "cirrus"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=drive1,bootindex=1"],
    ["-drive", "if=none,file={{ .OutputDir }}/{{ .Name }},id=drive0,cache=writeback,discard=ignore,format=qcow2"],
    ["-drive", "if=none,file=${local.iso_full_target_path},id=drive1,media=disk,format=raw,readonly=${local.readonly_boot_media}"],
  ]

  iso_checksum = var.checksum
  iso_target_extension = local.iso_target_extension
  iso_target_path = local.iso_target_path
  iso_urls = [
    "http://cdn.openbsd.org/pub/OpenBSD/${var.os_version}/${local.image_architecture}/${local.image}"
  ]

  http_directory = "."
  output_directory = "output"
  shutdown_command = "shutdown -h -p now"
  vm_name = local.vm_name
}

build {
  sources = ["qemu.qemu"]

  provisioner "shell" {
    script = "resources/provision.sh"
    environment_vars = [
      "SECONDARY_USER=${var.secondary_user_username}",
      "SUDO_VERSION=${var.sudo_version}",
      "RSYNC_VERSION=${var.rsync_version}"
    ]
  }

  /*provisioner "shell-local" {
    inline = ["if [ -d packer_cache_backup ]; then cp packer_cache_backup/* ${local.iso_target_path}; fi"]
  }*/
}

os_version = "7.1"
sudo_version = "1.9.10"
rsync_version = "3.2.3p1"
dhcp_client_boot_command = [
  "ifconfig em0 group dhcp<enter><wait>",
  "ifconfig em0 inet autoconf<enter><wait>"
]

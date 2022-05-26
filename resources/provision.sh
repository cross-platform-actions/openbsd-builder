#!/bin/sh

set -exu

install_extra_packages() {
  pkg_add bash
  pkg_add curl
  pkg_add "rsync-$RSYNC_VERSION"
}

setup_sudo() {
  pkg_add "sudo-$SUDO_VERSION"

  cat <<EOF > /etc/sudoers
#includedir /etc/sudoers.d
EOF

  mkdir -p /etc/sudoers.d
  cat <<EOF > "/etc/sudoers.d/$SECONDARY_USER"
Defaults:$SECONDARY_USER !requiretty
$SECONDARY_USER ALL=(ALL) NOPASSWD: ALL
EOF

  chmod 440 "/etc/sudoers.d/$SECONDARY_USER"
}

configure_boot_scripts() {
  cat <<EOF >> /etc/rc.local
RESOURCES_MOUNT_PATH='/mnt/resources'

mount_resources_disk() {
  disk=\$(sysctl -n hw.disknames | sed 's/:[^,]*//g' | cut -d ',' -f 2 -s)

  if [ -n "\$disk" ]; then
    partition=\$(disklabel \$disk | sed -n '/^ *[abd-z]: /s/^ *\([abd-z]\):.*/\1/p')
    dev="/dev/\${disk}\${partition}"
    mkdir -p /mnt/resources
    mount_msdos "\$dev" /mnt/resources
  fi
}

install_authorized_keys() {
  if [ -s "\$RESOURCES_MOUNT_PATH/KEYS" ]; then
    mkdir -p "/home/$SECONDARY_USER/.ssh"
    cp "\$RESOURCES_MOUNT_PATH/KEYS" "/home/$SECONDARY_USER/.ssh/authorized_keys"
    chown "$SECONDARY_USER:$SECONDARY_USER" "/home/$SECONDARY_USER/.ssh/authorized_keys"
    chmod 600 "/home/$SECONDARY_USER/.ssh/authorized_keys"
  fi
}

mount_resources_disk
install_authorized_keys
EOF
}

configure_boot_flags() {
  cat <<EOF >> /etc/boot.conf
set tty com0
set timeout 1
EOF
}

configure_ssh() {
  cp /etc/ssh/sshd_config /tmp/sshd_config
  sed '/^PermitRootLogin/s/ yes$/ no/' /tmp/sshd_config > /etc/ssh/sshd_config
  rm /tmp/sshd_config
  tee -a /etc/ssh/sshd_config <<EOF
AcceptEnv *
UseDNS no
EOF
}

configure_flags() {
  tee /etc/rc.conf.local <<EOF
sndiod_flags=NO
sendmail_flags=NO
EOF
}

setup_work_directory() {
  local work_directory=/Users/runner/work
  local permissions="$SECONDARY_USER:$SECONDARY_USER"

  mkdir -p "$work_directory"
  chown "$permissions" "$work_directory"

  ln -s "$work_directory/" "/home/$SECONDARY_USER/work"
  chown "$permissions" "$work_directory"
}

minimize_disk() {
  for dir in $(mount | awk '{ print $3 }'); do
    dd if=/dev/zero of="$dir/EMPTY" bs=1M || :
    rm "$dir/EMPTY"
  done
}

minimize_swap() {
  swap_device=$(swapctl -l | awk '!/^Device/ { print $1 }')
  swapctl -d "$swap_device"
  dd if=/dev/zero of="$swap_device" bs=1M || :
}

install_extra_packages
setup_sudo
configure_boot_flags
configure_boot_scripts
configure_ssh
configure_flags
setup_work_directory

minimize_disk
minimize_swap

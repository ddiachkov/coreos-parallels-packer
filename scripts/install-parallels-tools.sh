#!/bin/bash

set -e

# By default we are using stable developer image
COREOS_RELEASE="${COREOS_RELEASE:-stable}"

# Mount parallels tools CD
sudo mount /dev/sr1 /mnt

# Download dev container
rm -f coreos_developer_container.bin
wget http://$COREOS_RELEASE.release.core-os.net/amd64-usr/current/coreos_developer_container.bin.bz2
bunzip2 coreos_developer_container.bin.bz2

# Start dev container
sudo systemd-nspawn -i coreos_developer_container.bin --share-system --bind /:/media --bind /mnt:/mnt /usr/bin/bash -c "
  set -e

  ### Install kernel source

  emerge-gitclone
  emerge -gKv coreos-sources
  cd /usr/src/linux
  zcat /proc/config.gz >.config
  make modules_prepare

  # Copy Parallels tools from CD
  mkdir -p ~/parallels_tools && cp -r /mnt/* ~/parallels_tools

  ### Install Parallels kernel modules

  cd ~/parallels_tools/kmods
  tar xzvf prl_mod.tar.gz

  export KERNEL_VERSION=`uname -r`

  make -f Makefile.kmods \
    KVER=\$KERNEL_VERSION \
    KERNEL_DIR=/usr/src/linux \
    SRC=/usr/src/linux

  mkdir -p /media/opt/lib/modules/\$KERNEL_VERSION/parallels

  cp prl_eth/pvmnet/prl_eth.ko /media/opt/lib/modules/\$KERNEL_VERSION/parallels
  cp prl_tg/Toolgate/Guest/Linux/prl_tg/prl_tg.ko /media/opt/lib/modules/\$KERNEL_VERSION/parallels
  cp prl_fs/SharedFolders/Guest/Linux/prl_fs/prl_fs.ko /media/opt/lib/modules/\$KERNEL_VERSION/parallels
  cp prl_fs_freeze/Snapshot/Guest/Linux/prl_freeze/prl_fs_freeze.ko /media/opt/lib/modules/\$KERNEL_VERSION/parallels

  # Generating modules.dep for modprobe
  depmod -b /media/opt

  ### Install Parallels userspace tools

  mkdir -p /media/opt/bin

  cd ~/parallels_tools/tools
  tar xzvf prltools.x64.tar.gz

  for i in bin/*; do
    install -Dm755 \$i /media/opt/\$i
  done

  install -Dm755 sbin/prl_nettool /media/opt/bin/prl_nettool
  install -Dm755 sbin/prl_snapshot /media/opt/bin/prl_snapshot
  install -Dm755 xorg.7.1/usr/bin/prltoolsd /media/opt/bin/prltoolsd
  install -Dm755 ../installer/prlfsmountd.sh /media/opt/bin/prlfsmountd

  # Fix path in binary
  sed \"s,/usr/bin/prl,/opt/bin/prl,\" /media/opt/bin/prltoolsd > /media/opt/bin/prltoolsd_patched
  mv /media/opt/bin/prltoolsd_patched /media/opt/bin/prltoolsd
  chmod 0755 /media/opt/bin/prltoolsd

  ### Install system services and configuration files

  cp parallels-cpu-hotplug.rules /media/etc/udev/rules.d
  cp parallels-memory-hotplug.rules /media/etc/udev/rules.d

   cat <<EOF > /media/etc/systemd/system/prltoolsd.service
[Unit]
Description=Parallels Tools service

[Service]
ExecStartPre=/usr/bin/mkdir -p /media/psf
ExecStartPre=/usr/sbin/modprobe -d /opt prl_tg
ExecStartPre=/usr/sbin/modprobe -d /opt prl_eth
ExecStartPre=/usr/sbin/modprobe -d /opt prl_fs
ExecStartPre=/usr/sbin/modprobe -d /opt prl_fs_freeze
ExecStart=/opt/bin/prltoolsd -f -v -p \\\${PIDFile}
ExecStopPost=/opt/bin/prlfsmountd -u
PIDFile=/run/parallels/prltoolsd.pid

[Install]
WantedBy=multi-user.target
EOF
"

# Start Parallels prltoolsd
sudo systemctl enable prltoolsd.service

# Disable NTP service because Parallels automatically syncs time with host machine
sudo systemctl disable ntpd.service

# Cleanup
sudo umount /mnt
rm coreos_developer_container.bin
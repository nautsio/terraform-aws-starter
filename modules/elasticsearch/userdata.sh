#!/bin/bash

mkdir /data

apt-get update
apt-get --yes install mdadm
umount /mnt
yes | mdadm --create /dev/md0 --level=0 -c64 --raid-devices=2 /dev/xvdf /dev/xvdg
echo 'DEVICE /dev/xvdf /dev/xvdg' >> /etc/mdadm/mdadm.conf
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
mkfs.ext4 /dev/md0
mount /dev/md0 /data

UUID=$(blkid -s UUID -o value /dev/md0)
echo "UUID=$UUID    /data   ext4    defaults    0       2" >> /etc/fstab

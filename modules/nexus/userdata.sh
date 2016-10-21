#!/bin/bash

mkdir -p /data/nexus

umount /mnt
mount /dev/xvdf1 /data/nexus/

UUID=$(blkid -s UUID -o value /dev/xvdf)
echo "UUID=$UUID    /data/nexus/   ext4    defaults    0       2" >> /etc/fstab

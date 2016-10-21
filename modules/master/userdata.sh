#!/bin/bash

mkdir /data

umount /mnt
mkfs.ext4 /dev/xvdf
mount /dev/xvdf /data

UUID=$(blkid -s UUID -o value /dev/xvdf)
echo "UUID=$UUID    /data   ext4    defaults    0       2" >> /etc/fstab

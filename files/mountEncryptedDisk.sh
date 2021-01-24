#!/bin/bash
cryptsetup -q -v -d /root/.secure-key luksOpen /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume secure-mayan-volume
mount -o discard,defaults,noatime /dev/mapper/secure-mayan-volume /mnt/data
echo 'secure-mayan-volume /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume /root/.secure-key luks' | tee -a /etc/crypttab
echo '/dev/mapper/secure-mayan-volume /mnt/data ext4 defaults,nofail,discard 0 0' | tee -a /etc/fstab


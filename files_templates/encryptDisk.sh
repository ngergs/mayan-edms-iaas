#!/bin/bash
# encrypt mayan edms volume
printf '\nWARNING\nThis will initialize the mayen edms volume with LUKS.\n ALL DATA currently stored at /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume will be LOST.\n'
read -p 'Are you sure? (type yes if so) ' -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^yes$ ]]
then
  umount /mnt/mayan_edms_volume
  mkdir /mnt/data
  dd if=/dev/urandom of=/root/.secure-key  bs=1024 count=4
  chmod 0400 /root/.secure-key
  cryptsetup -q -v -d /root/.secure-key luksFormat /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume
  cryptsetup -q -v -d /root/.secure-key luksOpen /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume secure-mayan-volume
  mkfs.ext4 /dev/mapper/secure-mayan-volume
  mount -o discard,defaults,noatime /dev/mapper/secure-mayan-volume /mnt/data
  echo 'secure-mayan-volume /dev/disk/by-id/scsi-0DO_Volume_mayan-edms-volume /root/.secure-key luks' | tee -a /etc/crypttab
  echo '/dev/mapper/secure-mayan-volume /mnt/data ext4 defaults,nofail,discard 0 0' | tee -a /etc/fstab
  printf 'Finished volume initialization.\nYou should store the file at /root/.encrypt-fs safely. If it is lost, the content of the now encrypted mayan edms volume is also LOST.\n'
else
  echo 'Skipping volume initialization.\n'
fi


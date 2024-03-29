#!/bin/bash
# Mass of data
su - emperor -c "rsync --bwlimit=20480 -ahx --delete --info=del,name,stats2 --log-file=/var/log/rsync/music-`date +%F_%T`.log /mnt/Local/Pool-A/Music/ /mnt/Local/Pool-B/Backup/SRV01/Pool-A/Music/"
find /var/log/rsync -name "*.log" -type f -mtime +7 -delete
sleep 5
# Operating system settings
mkdir -v /tmp/confbkp
cd /tmp/confbkp
cp -v /etc/network/interfaces .
cp -v /etc/exports .
cp -v /etc/rc.local .
cp -rv /etc/scripts .
cp -rv /etc/libvirt/qemu .
cp -rv /etc/libvirt/storage .
cp -v /etc/samba/smb.conf .
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
cp -v /etc/hosts .
cp -rv /var/spool/cron/crontabs .
cp -rv /home/emperor/Temp .
cd ../
tar -cvzf confbkp-`date +%F`.tar.gz confbkp > /dev/null 2>&1
rm -v /mnt/Local/Pool-A/Backup/SRV01/Container-A/confbkp-`date +%F`.tar.gz
cp -v confbkp-`date +%F`.tar.gz /mnt/Local/Pool-A/Backup/SRV01/Container-A
rm -r confbkp
rm -v confbkp-`date +%F`.tar.gz
find /mnt/Local/Pool-A/Backup/SRV01/Container-A -name "*.gz" -type f -mtime +15 -delete
sleep 30
# Virtual machines
find /var/log/virsh -name "*.log" -type f -mtime +7 -delete
cd /mnt/Local/Pool-A/Backup/SRV01/Container-A/Virt
find -name "*.bak" -type f -mtime +7 -delete
# VM01
for f in VM01.qcow2.bak
do
    mv -n "$f" "$(date -r "$f" +"VM01-%Y%m%d_%H%M%S").qcow2.bak"
done
sleep 5
virsh backup-begin --domain VM01 --backupxml /etc/scripts/scheduled/virsh/VM01.xml
sleep 300
virsh domjobinfo VM01 --completed > /var/log/virsh/VM01-`date +%F_%T`.log
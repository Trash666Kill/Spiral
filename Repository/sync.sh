#!/bin/bash
{(
set -e
sshfs -p 26 emperor@SRV04.pine:/mnt/Local/A/Music/ /mnt/Remote/Servers/SRV04/Container-A/Music/ -o ro -o allow_other -o compression=no -o StrictHostKeyChecking=false
#
su - emperor -c "rsync --bwlimit=20480 -rtu --delete --info=del,name,stats2 --log-file=/var/log/rsync/syncsrv01-`date +%F_%T`.log /mnt/Local/USB/A/Music/ /mnt/Remote/Servers/SRV04/Container-A/Music/"
find /var/log/rsync/ -name "*.log" -type f -mtime +7 -delete
#
/usr/bin/umount /mnt/Remote/Servers/SRV04/Container-A/Music/
#
)}
{(
mount SRV01.pine:/mnt/Local/Container-C/Backup/SRV02 /mnt/Remote/Servers/SRV01/Container-C/Backup/SRV02
cd /mnt/Remote/Servers/SRV01/Container-C/Backup/SRV02/Virt/Images/
find -name "*qcow2" -type f -mtime +7 -delete 
(for f in VM08.qcow2
do
    mv -n "$f" "$(date -r "$f" +"VM08-%Y%m%d_%H%M%S").qcow2"
done)
sleep 5
cd /etc/scripts/scheduled/
virsh backup-begin --domain VM08 --backupxml VM08.xml
#
)}

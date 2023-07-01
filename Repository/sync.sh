#!/bin/bash
{(
set -e
rsync --bwlimit=20480 -rtu --delete --info=del,name,stats2 --log-file=/var/log/rsync/database-`date +%F_%T`.log -e 'ssh -p 26' /mnt/Local/Container-A/Database/ emperor@SRV01.pine:/mnt/Local/Container-C/Backup/SRV02/Database/
find /var/log/rsync/ -name "*.log" -type f -mtime +7 -delete
)}
#
sleep 5
{(
mount SRV01.pine:/mnt/Local/Container-C/Backup/SRV02 /mnt/Remote/Servers/SRV01/Container-C/Backup/SRV02
cd /mnt/Remote/Servers/SRV01/Container-C/Backup/SRV02/Virt/Images/
find -name "*qcow2" -type f -mtime +7 -delete 
(
for f in VM01.qcow2
do
    mv -n "$f" "$(date -r "$f" +"VM01-%Y%m%d_%H%M%S").qcow2"
done
)
(
for f in VM08.qcow2
do
    mv -n "$f" "$(date -r "$f" +"VM08-%Y%m%d_%H%M%S").qcow2"
done
)
sleep 5
cd /etc/scripts/scheduled/
virsh backup-begin --domain VM01 --backupxml VM01.xml
sleep 300
virsh backup-begin --domain VM08 --backupxml VM08.xml
)}
#

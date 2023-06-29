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
set -e
sshfs -p 26 emperor@SRV01.pine:/mnt/Local/Container-B/Backup/SRV02/ /mnt/Remote/Servers/SRV01/Container-B/Backup/SRV02/Virt/Images -o allow_other -o compression=no -o StrictHostKeyChecking=false
#rsync -avhW --delete --info=del,name,stats2 --log-file=/var/log/rsync/syncsrv01-`date +%F_%T`.log -e "ssh -p 26" /mnt/Local/Container-A/Virt/Images/VM02.qcow2 emperor@SRV1.pine:/mnt/Local/Container-B/Backup/
find /var/log/rsync/ -name "*.log" -type f -mtime +7 -delete
#
)}

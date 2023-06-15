#!/bin/bash
set -e
sshfs -p 26 emperor@SRV04.pine:/mnt/Local/A/Music/ /mnt/Remote/Servers/SRV04/Container-A/Music/ -o ro -o allow_other -o compression=no -o StrictHostKeyChecking=false
#sleep 10s
#
su - emperor -c "rsync -rtu --delete --info=del,name,stats2 --log-file=/var/log/rsync/syncsrv01-`date +%F_%T`.log /mnt/Remote/Servers/SRV01/Container-B/Music/ /mnt/Local/USB/A/Music/"
#
/usr/bin/umount /mnt/Remote/Servers/SRV01/Container-B/Music/

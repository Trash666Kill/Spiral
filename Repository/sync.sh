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
#!/bin/bash
set -e
sshfs -p 26 emperor@SRV04.pine:/mnt/Local/A/Music/ /mnt/Remote/Servers/SRV04/Container-A/Music/ -o ro -o allow_other -o compression=no -o StrictHostKeyChecking=false
#
su - emperor -c "rsync --bwlimit=20480 -rtu --delete --info=del,name,stats2 --log-file=/var/log/rsync/syncsrv01-`date +%F_%T`.log /mnt/Local/USB/A/Music/ /mnt/Remote/Servers/SRV04/Container-A/Music/"
find /var/log/rsync/ -name "*.log" -type f -mtime +7 -delete
#
/usr/bin/umount /mnt/Remote/Servers/SRV04/Container-A/Music/
)}

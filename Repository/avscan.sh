#!/bin/bash
#
#set -e
#systemctl stop clamav-freshclam
#freshclam --quiet
clamscan --recursive --infected --exclude=Backup --exclude=Virt --exclude=Temp/ISO --log=/var/log/clamav/daily/avscan-`date +%F_%T`.log --move=/root/.isolation /mnt/Local/Container-C
find /root/.isolation/ -type f -mtime +7 -delete 
find /var/log/clamav/daily/ -name "*.log" -type f -mtime +2 -delete
#systemctl restart clamav-freshclam
#

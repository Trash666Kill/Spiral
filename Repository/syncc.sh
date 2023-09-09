#!/bin/bash

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as sudo"
        exit 1
else
#
mkdir -v /tmp/vpsbkp/
cd /tmp/vpsbkp/

cp -v /etc/rc.local .

echo "Authorized SSH Keys"
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
cp -rv /etc/scripts .
cp -v /etc/hosts .

cp -rv /var/spool/cron/crontabs/ .
cp -rv /home/emperor/Temp .
cd ../
tar -cvzf vpsbkp-`date +%F`.tar.gz vpsbkp/ > /dev/null 2>&1
chown emperor:emperor vpsbkp-`date +%F`.tar.gz
rm -r vpsbkp
#
fi

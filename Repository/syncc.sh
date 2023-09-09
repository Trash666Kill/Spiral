#!/bin/bash
#
mkdir -v /tmp/vpsbkp
cd /tmp/vpsbkp
cp -v /etc/network/interfaces .
cp -v /etc/rc.local .
cp -rv /etc/scripts .
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
cp -v /etc/hosts .
cp -rv /var/spool/cron/crontabs .
cp -rv /home/emperor/Temp .
cd ../
chown emperor:emperor -R vpsbkp
su - emperor -c "tar -cvzf vpsbkp-`date +%F`.tar.gz vpsbkp/ > /dev/null 2>&1"
chown emperor:emperor vpsbkp-`date +%F`.tar.gz
rm -r vpsbkp
#

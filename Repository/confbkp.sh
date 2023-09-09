#!/bin/bash
#
mkdir -v /tmp/confbkp
cd /tmp/confbkp
cp -v /etc/network/interfaces .
cp -v /etc/exports .
cp -v /etc/rc.local .
cp -rv /etc/scripts .
cp -rv /etc/libvirt/qemu .
cp -rv /etc/libvirt/storage .
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
cp -v /etc/hosts .
cp -rv /var/spool/cron/crontabs .
cp -rv /home/emperor/Temp .
cd ../
chown emperor:emperor -R confbkp
tar -cvzf confbkp-`date +%F`.tar.gz confbkp/ > /dev/null 2>&1
chown emperor:emperor confbkp-`date +%F`.tar.gz
cp -v confbkp-`date +%F`.tar.gz /mnt/Local/Container-C/Backup/SRV01
rm -r confbkp
rm -v confbkp-`date +%F`.tar.gz
#

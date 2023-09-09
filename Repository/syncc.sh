#!/bin/bash

if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as sudo"
        exit 1
else
#
mkdir -v /tmp/vpsbkp/
cd /tmp/vpsbkp/
echo "Copying configuration files"
echo "rc.local"
cp -v /etc/rc.local .
echo "OpenVPN"
cp -rv /etc/openvpn .
echo "Nginx"
cp -rv /etc/nginx/ .
echo "Let's Encrypt certificates"
cp -rv /etc/letsencrypt/ .
echo "Authorized SSH Keys"
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
echo "Custom scripts"
cp -rv /etc/scripts .
echo "Hosts file"
cp -v /etc/hosts .
echo "Cron schedule"
cp -rv /var/spool/cron/crontabs/ .
echo "Emperor user temp"
cp -rv /home/emperor/Temp .
echo "Compressing"
cd ../
tar -cvzf vpsbkp-`date +%F`.tar.gz vpsbkp/ > /dev/null 2>&1
chown emperor:emperor vpsbkp-`date +%F`.tar.gz
rm -r vpsbkp
echo "Finally, backup is stored in /tmp"
#
fi

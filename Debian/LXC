#!/bin/bash
echo "Enter a password for the root user:"
passwd root
echo "Enter a password for the emperor user:"
adduser emperor
sleep 10
#Update and Upgrade
echo "**UPDATING AND UPGRADING**"
apt update && apt upgrade -y
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo vim nfs-common net-tools systemd-timesyncd sshpass python3-apt screen -y
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /root/Temp
mkdir -v /mnt/Temp
mkdir -v /mnt/Services
chown emperor:emperor -R /mnt
mkdir -v /home/emperor/Temp
chown emperor:emperor -R /home/emperor
#Conf Base
echo "**SETTING UP BASE**"
systemctl disable --now systemd-resolved
setcap cap_net_raw+p /bin/ping
{(
printf '#!/bin/bash
# Interfaces
#NIC0
#ifconfig eth0 10.0.1.1/26
#ip route add default via 10.0.1.1 dev eth0
# Mount
#mount SRV01.vsw1:/mnt/Local/Pool-A/Files /mnt/Services/Service/Type/0/
# Services
#systemctl restart service
#' > /etc/scripts/startup.sh
)}
chmod +x /etc/scripts/startup.sh
{(
printf '#!/bin/sh
#/etc/scripts/startup.sh
#' > /etc/rc.local
)}
chmod 755 /etc/rc.local
rm -v /etc/systemd/timesyncd.conf
{(
printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces
rm -v /etc/resolv.conf
touch /etc/resolv.conf
/sbin/usermod -aG sudo emperor
#
#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
echo "End"
rm -- "$0"
su - emperor
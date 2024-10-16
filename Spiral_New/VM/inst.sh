#!/bin/bash
sleep 10
echo "**ADDING NON-FREE REPOSITORIES**"
rm -v /etc/apt/sources.list
{(
printf '#
deb http://deb.debian.org/debian/ bookworm main non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main non-free non-free-firmware
#
deb http://security.debian.org/debian-security bookworm-security main non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main non-free non-free-firmware
#
deb http://deb.debian.org/debian/ bookworm-updates main non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main non-free non-free-firmware
#
#deb http://deb.debian.org/debian bookworm-backports main non-free 
#' > /etc/apt/sources.list
)}
#Update and Upgrade
echo "**UPDATING AND UPGRADING**"
apt update && apt upgrade -y
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo vim sshfs nfs-common systemd-timesyncd unzip xz-utils sshpass bzip2 python3-apt screen -y
echo "2"
apt install htop stress hdparm tree -y
echo "3"
apt install curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh -y
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /var/log/rsync
chown emperor:emperor -R /var/log/rsync
mkdir -v /root/Temp
mkdir -v /root/.crypt
mkdir -v /mnt/Temp
mkdir -v /mnt/Services
chown emperor:emperor -R /mnt
mkdir -v /home/emperor/Temp
mkdir -v /home/emperor/.ssh
mkdir -v /root/.ssh
chown emperor:emperor -R /home/emperor
#Conf Base
echo "**SETTING UP BASE**"
systemctl enable --now serial-getty@ttyS0.service
rm -v /etc/default/grub
{(
printf 'GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyS0,115200n8"
GRUB_CMDLINE_LINUX=""' > /etc/default/grub
)}
chmod 644 /etc/default/grub
update-grub
{(
printf '#!/bin/bash
# Interfaces
#NIC0
#ifconfig enp1s0 10.0.10.1/24
#ip route add default via 10.0.10.254 dev enp1s0
# Mount
#mount SRV01.vsw0:/mnt/Local/Pool-A/Files /mnt/Services/Service/Type/0/
# Services
#systemctl restart service
#' > /etc/scripts/startup.sh
)}
chmod +x /etc/scripts/startup.sh
{(
printf '#!/bin/sh
/etc/scripts/startup.sh
#' > /etc/rc.local
)}
chmod 755 /etc/rc.local
rm -v /etc/systemd/timesyncd.conf
{(
printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces
rm -v /etc/ssh/sshd_config
{(
printf 'Include /etc/ssh/sshd_config.d/*.conf

#Port 22

PubkeyAuthentication yes

ChallengeResponseAuthentication no

UsePAM yes

X11Forwarding yes
PrintMotd no
PrintLastLog no

AcceptEnv LANG LC_*

Subsystem       sftp    /usr/lib/openssh/sftp-server' > /etc/ssh/sshd_config
)}
chmod 644 /etc/ssh/sshd_config
rm -v /etc/motd && touch /etc/motd
chmod 700 /home/emperor/.ssh
su - emperor -c "echo | touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
#su - emperor -c "echo | ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
#ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
/sbin/usermod -aG sudo emperor
#
#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
echo "End"
rm -- "$0"
su - emperor
#!/bin/bash
sleep 10
cd $PWD/Repository
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
apt install htop stress hdparm tree zabbix-agent -y
echo "3"
apt install curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh -y
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /var/log/rsync
chown emperor:emperor -R /var/log/rsync
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
systemctl disable zabbix-agent
{(
printf '#!/bin/bash
# Mount
#mount SRV01.vsw0:/mnt/Local/Pool-A/Files /mnt/Services/Service/Type/0/
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
cp -v timesyncd.conf /etc/systemd
rm -v /etc/network/interfaces
{(
printf 'source /etc/network/interfaces.d/*
# The loopback network interface
auto lo
iface lo inet loopback

# Virtual network interface
allow-hotplug enp1s0
iface enp1s0 inet dhcp

# NIC0
#auto enp1s0
#iface enp1s0 inet static
#address 172.16.10.2/24
#gateway 172.16.10.1

# NIC1
#auto enp7s0
#iface enp7s0 inet static
#address 10.0.0.0/26
#' > /etc/network/interfaces
)}
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
rm -v /etc/motd
touch /etc/motd
cp -v useful /home/emperor/.useful
chmod 700 /home/emperor/.ssh
su - emperor -c "echo |touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
#su - emperor -c "echo |ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
#ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
/sbin/usermod -aG sudo emperor

#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y

#End
echo "**END**"
#Manual settings
echo "1 - Add zabbix server ip address in /etc/zabbix/zabbix_agentd.conf"
su - emperor
#

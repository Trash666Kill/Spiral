#!/bin/bash
echo "Enter a password for the emperor user:"
adduser emperor
sleep 5
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo vim nfs-common net-tools systemd-timesyncd openssh-server sshpass python3-apt screen -y
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
mkdir -v /home/emperor/.ssh
mkdir -v /root/.ssh
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
{(
printf 'nameserver 10.0.1.62' >  /etc/resolv.conf
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
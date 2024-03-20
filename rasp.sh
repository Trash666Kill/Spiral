#!/bin/bash
sleep 10
cd $PWD
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
apt install sudo cryptsetup smartmontools vim sshfs systemd-timesyncd unzip xz-utils bzip2 uuid pigz sshpass python3-apt screen -y
echo "2"
apt install lm-sensors htop stress hdparm x11-xkb-utils bc tree cpulimit -y
echo "3"
apt install curl wget samba net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh -y
echo "4"
apt install btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server -y
#Hypervisor
echo "**INSTALLING HYPERVISOR**"
apt install qemu-kvm libvirt0 bridge-utils libvirt-daemon-system -y
gpasswd libvirt -a emperor
systemctl disable --now libvirtd
touch /etc/modprobe.d/kvm.conf
virsh net-autostart default
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/virsh
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /var/log/rsync
chown emperor:emperor -R /var/log/rsync
mkdir -v /root/Temp
mkdir -v /root/.isolation
mkdir -v /root/.crypt
mkdir -v /mnt/Temp
mkdir -pv /mnt/Local/USB/A
mkdir -v /mnt/Local/USB/B
mkdir -v /mnt/Local/Container-A
mkdir -v /mnt/Local/Container-B
mkdir -pv /mnt/Remote/Servers
chown emperor:emperor -R /mnt
mkdir -v /home/emperor/Temp
mkdir -v /home/emperor/.ssh
mkdir -v /root/.ssh
chown emperor:emperor -R /home/emperor
#Conf Base
echo "**SETTING UP BASE**"
systemctl disable --now smbd
systemctl disable --now nfs-kernel-server
{(
printf '#!/bin/sh
/etc/scripts/startup.sh' > /etc/rc.local
)}
chmod 755 /etc/rc.local
{(
printf '#!/bin/bash
# Mount
#mount -U 74127341-e83a-4843-8c94-6c2de702bef9 /mnt/Local/Container-A
#sleep 5
# Swap
#sysctl vm.swappiness=8 #=1278M
#swapon /swap/swapfile
# Interfaces
modprobe dummy
ip link add zombie0 type dummy
ip link set zombie0 address 52:54:00:e6:21:4c
# Services
#systemctl restart libvirtd
#systemctl restart smbd
#systemctl restart nfs-kernel-server
# Virtual Machines
#virsh start VM01
# Tunnels
#sleep 120
#(
#ssh -f -N -T -R 2222:localhost:26 -p 4634 emperor@strychnine.duckdns.org -o StrictHostKeyChecking=false &
)' > /etc/scripts/startup.sh
)}
chmod +x /etc/scripts/startup.sh
rm -v /etc/systemd/timesyncd.conf
{(
printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces
{(
printf 'source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# Default network interface
allow-hotplug eth0
iface eth0 inet dhcp

# NIC0
#auto nic0
#iface nic0 inet static
#bridge_ports eth0
#bridge_hw eth0
#address 172.16.10.2/24
#gateway 172.16.10.1

# VSW0
auto vsw0
iface vsw0 inet static
bridge_ports zombie0
bridge_hw zombie0
address 10.0.0.62/26' > /etc/network/interfaces
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
{(
printf '#/mnt/Local/Container-A 10.0.0.1(rw,sync,crossmnt,no_subtree_check,no_root_squash)' > /etc/exports
)}
{(
printf '#!/bin/bash
clamscan --recursive --infected --exclude=Backup --exclude=Virt --exclude=Temp/ISO --log=/var/log/clamav/daily/avscan-`date +%F_%T`.log --move=/root/.isolation /mnt/Local/Container-C
find /root/.isolation -type f -mtime +7 -delete 
find /var/log/clamav/daily -name "*.log" -type f -mtime +2 -delete' > /etc/scripts/scheduled/avscan.sh
)}
chmod +x /etc/scripts/scheduled/avscan.sh
printf '#!/bin/bash
# Mass of data
su - emperor -c "rsync --bwlimit=20480 -ahx --delete --info=del,name,stats2 --log-file=/var/log/rsync/music-`date +%F_%T`.log /mnt/Local/Pool-A/Music/ /mnt/Local/Pool-B/Backup/SRV01/Pool-A/Music/"
find /var/log/rsync -name "*.log" -type f -mtime +7 -delete
sleep 5
# Operating system settings
mkdir -v /tmp/confbkp
cd /tmp/confbkp
cp -v /etc/network/interfaces .
cp -v /etc/exports .
cp -v /etc/rc.local .
cp -rv /etc/scripts .
cp -rv /etc/libvirt/qemu .
cp -rv /etc/libvirt/storage .
cp -v /etc/samba/smb.conf .
mkdir -pv keys/users/emperor
mkdir -v keys/users/root
cp -v /home/emperor/.ssh/authorized_keys keys/users/emperor
cp -v /root/.ssh/authorized_keys keys/users/root
cp -v /etc/hosts .
cp -rv /var/spool/cron/crontabs .
cp -rv /home/emperor/Temp .
cd ../
tar -cvzf confbkp-`date +%F`.tar.gz confbkp > /dev/null 2>&1
rm -v /mnt/Local/Pool-A/Backup/SRV01/Container-A/confbkp-`date +%F`.tar.gz
cp -v confbkp-`date +%F`.tar.gz /mnt/Local/Pool-A/Backup/SRV01/Container-A
rm -r confbkp
rm -v confbkp-`date +%F`.tar.gz
find /mnt/Local/Pool-A/Backup/SRV01/Container-A -name "*.gz" -type f -mtime +15 -delete
sleep 30
# Virtual machines
find /var/log/virsh -name "*.log" -type f -mtime +7 -delete
cd /mnt/Local/Pool-A/Backup/SRV01/Container-A/Virt
find -name "*.bak" -type f -mtime +7 -delete
# VM01
for f in VM01.qcow2.bak
do
    mv -n "$f" "$(date -r "$f" +"VM01-%Y%m%d_%H%M%S").qcow2.bak"
done
sleep 5
virsh backup-begin --domain VM01 --backupxml /etc/scripts/scheduled/virsh/VM01.xml
sleep 300
virsh domjobinfo VM01 --completed > /var/log/virsh/VM01-`date +%F_%T`.log' > /etc/scripts/scheduled/sync.sh
chmod +x /etc/scripts/scheduled/sync.sh
cp -v VM.xml /etc/scripts/scheduled


rm -v /etc/network/interfaces
cp -v interfaces /etc/network
rm -v /etc/samba/smb.conf
cp -v smb.conf /etc/samba
rm -v /etc/ssh/sshd_config
cp -v sshd_config /etc/ssh
rm -v /etc/motd
cp -v useful /home/emperor/.useful
touch /etc/motd
chmod 700 /home/emperor/.ssh
su - emperor -c "echo |touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
#su - emperor -c "echo |ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.isolation
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
echo "1 - Adjust network nics according to the environment
2 - Add zabbix server ip address in /etc/zabbix/zabbix_agentd.conf 
3 - Manually configure samba users and their respective passwords"
su - emperor
#

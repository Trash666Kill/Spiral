#!/bin/bash
{(
    read -p "**SET A HOSTNAME**: " hostname
    rm -v /etc/hostname
    echo "$hostname" > /etc/hostname
    rm -v /etc/hosts
    echo "127.0.0.1       localhost
127.0.1.1       $hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters" > /etc/hosts
)}
sleep 10
cd $PWD/Repo
echo "**ADDING NON-FREE REPOSITORIES**"
rm -v /etc/apt/sources.list && cp -v sources.list /etc/apt
#Update and Upgrade
echo "**UPDATING AND UPGRADING**"
apt update && apt upgrade -y
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo cryptsetup smartmontools vim sshfs systemd-timesyncd unzip xz-utils bzip2 uuid pigz sshpass python3-apt screen -y
echo "2"
apt install lm-sensors htop stress hdparm x11-xkb-utils bc tree cpulimit locales -y
echo "3"
apt install curl wget samba net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh socat -y
echo "4"
apt install btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server -y
#Hypervisor
echo "**INSTALLING HYPERVISOR**"
apt install qemu-kvm libvirt0 bridge-utils libvirt-daemon-system -y
gpasswd libvirt -a emperor
systemctl disable --now libvirtd
virsh net-autostart default
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled/virsh
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
systemctl disable --now wpa_supplicant
systemctl disable --now smbd
systemctl disable --now nfs-kernel-server
systemctl disable --now systemd-networkd-wait-online
systemctl disable --now rpi-set-sysconf
systemctl disable --now ssh.socket
{(
    printf '#!/bin/sh
/etc/scripts/startup.sh' > /etc/rc.local
)}
chmod 755 /etc/rc.local
cp -v startup.sh /etc/scripts && chmod +x /etc/scripts/startup.sh
export TZ='America/Sao_Paulo'
rm -v /etc/localtime
cp -v /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
timedatectl set-timezone "America/Sao_Paulo"
rm -v /etc/systemd/timesyncd.conf
{(
    printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces.d/*
rm -v /etc/network/interfaces && cp -v interfaces /etc/network
rm -v /etc/ssh/sshd_config && cp -v sshd_config /etc/ssh
chmod 644 /etc/ssh/sshd_config
rm -v /etc/motd && touch /etc/motd
{(
    printf '#/mnt/Local/Container-A 10.0.0.1(rw,sync,crossmnt,no_subtree_check,no_root_squash)' > /etc/exports
)}
cp -v avscan.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/sync.sh
cp -v VM.xml /etc/scripts/scheduled/virsh
cp -v useful /etc
ln -s /etc/useful /home/emperor/useful
ln -s /etc/useful /root/useful
chmod 700 /home/emperor/.ssh
su - emperor -c "echo | touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
#su - emperor -c "echo | ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.isolation
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
#ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
echo "**SET A ROOT PASSWORD**"
passwd root
/sbin/usermod -aG sudo emperor
#
#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
echo "End"
su - emperor
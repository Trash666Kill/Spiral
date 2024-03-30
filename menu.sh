#!/bin/bash
cd $PWD/Repo
# Packages
common="sudo vim sshfs nfs-common systemd-timesyncd unzip xz-utils sshpass bzip2 python3-apt screen htop stress hdparm tree curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh socat"

workstation="cryptsetup smartmontools uuid pigz passwd lm-sensors hdparm x11-xkb-utils bc fwupd tree pm-utils acpid cpulimit btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server"

server="samba"

graphics="nvidia-driver firmware-amd-graphics"

firmware="firmware-misc-nonfree firmware-realtek firmware-atheros"

hypervisor="qemu-kvm libvirt0 bridge-utils libvirt-daemon-system"

de="xorg xserver-xorg-input-libinput xserver-xorg-input-evdev brightnessctl xserver-xorg-input-mouse xserver-xorg-input-synaptics lightdm openbox obconf lxterminal lxpanel lxhotkey-gtk lxtask lxsession-logout lxappearance lxrandr progress arc-theme nitrogen ffmpegthumbnailer gpicview evince galculator gnome-screenshot l3afpad alacarte gpick compton pcmanfm firefox-esr engrampa gparted gnome-disk-utility baobab virt-manager ssh-askpass"

minide="xorg openbox"
# Environment Setting

while true; do
clear
echo '================================================
Welcome to the post installation script for Debian minimal. Choose the type of installation you want:

1) Workstation

2) Server

3) Virtual machine

4) Raspberry Pi

5) Exit

================================================'

read -p "Enter the desired installation type and start it by pressing the Enter key: " x
echo "($x)
================================================"

case "$x" in
1)
echo '**INSTALLING PACKAGES**'
apt install -qq $common $workstation $de $hypervisor
{
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
echo '**CREATING DIRECTORIES**'
mkdir -pv /etc/scripts/scheduled/virsh
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/virsh
mkdir -v /var/log/rc.local
chown $user:$user -R /var/log/rc.local
mkdir -v /var/log/rsync
chown $user:$user -R /var/log/rsync
mkdir -v /root/Temp
mkdir -v /root/.isolation
mkdir -v /root/.crypt
mkdir -v /mnt/Temp
mkdir -pv /mnt/Local/USB/A
mkdir -v /mnt/Local/USB/B
mkdir -v /mnt/Local/Container-A
mkdir -v /mnt/Local/Container-B
mkdir -pv /mnt/Remote/Servers
chown $user:$user -R /mnt
mkdir -v /home/$user/Temp
mkdir -v /home/$user/.ssh
mkdir -v /root/.ssh
chown $user:$user -R /home/$user
#Conf Base
echo '**SETTING UP BASE**'
/sbin/usermod -aG sudo emperor
systemctl disable --now nfs-kernel-server
{(
    printf '#!/bin/sh
/etc/scripts/startup.sh' > /etc/rc.local
)}
chmod 755 /etc/rc.local
cp -v startup.sh /etc/scripts && chmod +x /etc/scripts/startup.sh
rm -v /etc/systemd/timesyncd.conf
{(
    printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces && cp -v interfaces /etc/network
rm -v /etc/ssh/sshd_config && cp -v sshd_config /etc/ssh
chmod 644 /etc/ssh/sshd_config
rm -v /etc/motd && touch /etc/motd
{(
    printf '#/mnt/Local/Container-A 10.0.0.1(rw,sync,crossmnt,no_subtree_check,no_root_squash)' > /etc/exports
)}
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
cp -v avscan.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/sync.sh
cp -v useful /etc
ln -s /etc/useful /home/$user/.useful
ln -s /etc/useful /root/.useful
chmod 700 /home/$user/.ssh
su - $user -c "echo | touch /home/$user/.ssh/authorized_keys"
chmod 600 /home/$user/.ssh/authorized_keys
su - $user -c "echo | ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.isolation
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
}
{
echo "**SETTING UP HYPERVISOR**"
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
while true; do
clear
gpasswd libvirt -a $user
touch /etc/modprobe.d/kvm.conf
virsh net-autostart default
cpu=$(lscpu | grep 'Vendor ID' | cut -f 2 -d ":" | awk '{$1=$1}1')
echo "$cpu"
case "$cpu" in
GenuineIntel)
#Nested Intel processors
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_intel
/sbin/modprobe kvm_intel
;;
AuthenticAMD)
echo 'options kvm_amd nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_amd
/sbin/modprobe kvm_amd nested=1
sleep 5
;;
esac
done
}
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
echo '**SETTING UP THE DESKTOP ENVIRONMENT**'
rm -v /etc/lightdm/lightdm-gtk-greeter.conf && cp -v lightdm-gtk-greeter.conf /etc/lightdm
cp -v default.jpg /usr/share/wallpapers
tar -xvf 01-Qogir.tar.xz -C /usr/share/icons > /dev/null 2>&1
tar -xvf Arc-Dark.tar.xz -C /usr/share/themes > /dev/null 2>&1
cp -v debian-swirl.png /usr/share/icons/default
mkdir -pv /etc/X11/xorg.conf.d && cp -v 40-libinput.conf /etc/X11/xorg.conf.d
echo "$user"
rm -r /home/$user/.config && cp -r config /home/$user/.config
cp -v gtkrc-2.0 /home/$user/.gtkrc-2.0
chown $user:$user -R /home/$user
chown $user:$user /usr/share/wallpapers/default.jpg
sleep 5s
echo 'Finished
================================================'
exit 0
;;
2)
echo '**INSTALLING PACKAGES**'
apt install -qq $common $workstation $server
{
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
echo '**CREATING DIRECTORIES**'
mkdir -pv /etc/scripts/scheduled/virsh
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/virsh
mkdir -v /var/log/rc.local
chown $user:$user -R /var/log/rc.local
mkdir -v /var/log/rsync
chown $user:$user -R /var/log/rsync
mkdir -v /root/Temp
mkdir -v /root/.isolation
mkdir -v /root/.crypt
mkdir -v /mnt/Temp
mkdir -pv /mnt/Local/USB/A
mkdir -v /mnt/Local/USB/B
mkdir -v /mnt/Local/Container-A
mkdir -v /mnt/Local/Container-B
mkdir -pv /mnt/Remote/Servers
chown $user:$user -R /mnt
mkdir -v /home/$user/Temp
mkdir -v /home/$user/.ssh
mkdir -v /root/.ssh
chown $user:$user -R /home/$user
#Conf Base
echo '**SETTING UP BASE**'
/sbin/usermod -aG sudo emperor
systemctl disable --now nfs-kernel-server
{(
    printf '#!/bin/sh
/etc/scripts/startup.sh' > /etc/rc.local
)}
chmod 755 /etc/rc.local
cp -v startup.sh /etc/scripts && chmod +x /etc/scripts/startup.sh
rm -v /etc/systemd/timesyncd.conf
{(
    printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces && cp -v interfaces /etc/network
rm -v /etc/ssh/sshd_config && cp -v sshd_config /etc/ssh
chmod 644 /etc/ssh/sshd_config
rm -v /etc/motd && touch /etc/motd
{(
    printf '#/mnt/Local/Container-A 10.0.0.1(rw,sync,crossmnt,no_subtree_check,no_root_squash)' > /etc/exports
)}
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
cp -v avscan.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/sync.sh
cp -v useful /etc
ln -s /etc/useful /home/$user/.useful
ln -s /etc/useful /root/.useful
chmod 700 /home/$user/.ssh
su - $user -c "echo | touch /home/$user/.ssh/authorized_keys"
chmod 600 /home/$user/.ssh/authorized_keys
su - $user -c "echo | ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.isolation
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
}
sleep 3s
{
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
while true; do
clear
read -p "Do you want to install graphical interface? [y/n]" x
echo "================================================"
case "$x" in
y)
echo '**INSTALLING DESKTOP ENVIRONMENT PACKAGES**'
apt install -qq $de
echo '**SETTING UP THE DESKTOP ENVIRONMENT**'
rm -v /etc/lightdm/lightdm-gtk-greeter.conf && cp -v lightdm-gtk-greeter.conf /etc/lightdm
cp -v default.jpg /usr/share/wallpapers
tar -xvf 01-Qogir.tar.xz -C /usr/share/icons > /dev/null 2>&1
tar -xvf Arc-Dark.tar.xz -C /usr/share/themes > /dev/null 2>&1
cp -v debian-swirl.png /usr/share/icons/default
mkdir -pv /etc/X11/xorg.conf.d && cp -v 40-libinput.conf /etc/X11/xorg.conf.d
echo "$user"
rm -r /home/$user/.config && cp -r config /home/$user/.config
cp -v gtkrc-2.0 /home/$user/.gtkrc-2.0
chown $user:$user -R /home/$user
chown $user:$user /usr/share/wallpapers/default.jpg
echo "Finished
================================================"
sleep 5s
exit 0
;;
n)
echo "Finished
================================================"
sleep 5s
exit 0
;;
*) echo "Invalid option!"
esac
done
}
;;
3)
echo '**ADDING NON-FREE REPOSITORIES**'
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
apt update && apt upgrade -y
echo "**INSTALLING BASE PACKAGES**"
apt install -qq $common
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
rm -v /etc/motd && touch /etc/motd
chmod 700 /home/emperor/.ssh
su - emperor -c "echo | touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
/sbin/usermod -aG sudo emperor
#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
{
echo "**SETTING UP HYPERVISOR**"
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
while true; do
clear
gpasswd libvirt -a $user
touch /etc/modprobe.d/kvm.conf
virsh net-autostart default
cpu=$(lscpu | grep 'Vendor ID' | cut -f 2 -d ":" | awk '{$1=$1}1')
echo "$cpu"
case "$cpu" in
GenuineIntel)
#Nested Intel processors
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_intel
/sbin/modprobe kvm_intel
;;
AuthenticAMD)
echo 'options kvm_amd nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_amd
/sbin/modprobe kvm_amd nested=1
sleep 5
;;
esac
done
}
sleep 3
{
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
while true; do
clear
read -p "Do you want to install graphical interface? [y/n]" x
echo "================================================"
case "$x" in
y)
echo '**INSTALLING DESKTOP ENVIRONMENT PACKAGES**'
apt install -qq $minide
echo '**SETTING UP THE MINIMAL DESKTOP ENVIRONMENT**'
mkdir -v /etc/systemd/system/getty@tty1.service.d
cp -v autologin.conf /etc/systemd/system/getty@tty1.service.d
rm -v /home/$user/.profile
cp -v profile /home/$user/.profile
chown $user:$user /home/$user/.profile
su - $user -c "mkdir -pv /home/$user/.config/openbox"
cp -v autostart.sh /home/$user/.config/openbox
chmod +x /home/$user/.config/openbox/autostart.sh
chown $user:$user /home/$user/.config/openbox/autostart.sh
echo "Finished
================================================"
sleep 5s
exit 0
;;
n)
echo "Finished
================================================"
sleep 5s
exit 0
;;
*) echo "Invalid option!"
esac
done
}
sleep 5s
echo "Finished
================================================"
exit 0
;;
4)
sensors
sleep 5s
echo "Finished
================================================"
exit 0
;;
5)
echo "Leaving...
================================================"
sleep 5s
clear
exit 0
;;
*) echo "Invalid option!"
esac
done
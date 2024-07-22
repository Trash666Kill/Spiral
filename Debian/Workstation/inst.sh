#!/bin/bash
cd $PWD/Repo
# SO Repositore
repo(){
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
apt update
)}
}
# Packages
common="sudo vim sshfs nfs-common systemd-timesyncd unzip xz-utils sshpass bzip2 python3-apt screen htop sysstat stress hdparm tree curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh socat"
workstation="cryptsetup smartmontools uuid pigz passwd lm-sensors hdparm x11-xkb-utils bc fwupd tree pm-utils acpi acpid cpulimit btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server"
server="samba"
graphics="nvidia-driver firmware-amd-graphics"
firmware="firmware-misc-nonfree firmware-realtek firmware-atheros"
hypervisor="lxc qemu-kvm libvirt0 bridge-utils libvirt-daemon-system dnsmasq"
de="xorg xserver-xorg-input-libinput xserver-xorg-input-evdev brightnessctl xserver-xorg-input-mouse xserver-xorg-input-synaptics xscreensaver dbus-x11 lightdm openbox obconf lxterminal lxpanel lxhotkey-gtk lxtask lxsession-logout lxappearance lxrandr numlockx progress arc-theme nitrogen ffmpegthumbnailer gpicview evince galculator gnome-screenshot l3afpad alacarte gpick compton pcmanfm firefox-esr engrampa gparted gnome-disk-utility baobab virt-manager ssh-askpass caffeine"
# Environment Setting
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
directories(){
echo '**CREATING DIRECTORIES**'
mkdir -pv /etc/scripts/scheduled/virsh
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/virsh
mkdir -v /var/log/lxc
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
}
base(){
echo '**SETTING UP BASE**'
/sbin/usermod -aG sudo $user
systemctl disable --now dnsmasq
systemctl disable --now libvirtd
systemctl disable --now lxc
systemctl mask lxc-net
systemctl disable --now nfs-kernel-server
systemctl disable --now smbd
{(
    printf '#!/bin/sh
#/etc/scripts/startup.sh' > /etc/rc.local
)}
chmod 755 /etc/rc.local
cp -v startup.sh /etc/scripts; chmod +x /etc/scripts/startup.sh
rm -v /etc/systemd/timesyncd.conf
{(
    printf '[Time]
NTP=a.st1.ntp.br' > /etc/systemd/timesyncd.conf
)}
rm -v /etc/network/interfaces; cp -v interfaces /etc/network
rm -v /etc/resolv.conf
{(
    printf 'nameserver 127.0.0.1
nameserver 9.9.9.9
nameserver 208.67.222.222' > /etc/resolv.conf
)}
chattr +i /etc/resolv.conf
rm -v /etc/dnsmasq.conf
{(
    printf 'interface=vsw0
port=53
dhcp-range=10.0.0.51,10.0.0.61,12h
#no-dhcp-interface=vsw0
domain=vsw0
local=/vsw0/
domain-needed
bogus-priv
conf-file=/usr/share/dnsmasq-base/trust-anchors.conf
dnssec
cache-size=1024' > /etc/dnsmasq.d/vsw0.conf
)}
{(
    printf 'interface=vsw1
dhcp-range=10.0.1.51,10.0.1.61,12h' > /etc/dnsmasq.d/vsw1.conf
)}
rm -v /etc/ssh/sshd_config; cp -v sshd_config /etc/ssh
chmod 644 /etc/ssh/sshd_config
rm -v /etc/motd && touch /etc/motd
{(
    printf '#/mnt/Local/Container-A 10.0.0.1(rw,sync,crossmnt,no_subtree_check,no_root_squash)' > /etc/exports
)}
rm -v /etc/default/lxc-net
rm -v /etc/lxc/default.conf
{(
    printf 'lxc.net.0.type = veth
lxc.net.0.link = vsw1
lxc.net.0.flags = up

lxc.apparmor.profile = generated
lxc.apparmor.allow_nesting = 1' > /etc/lxc/default.conf
)}
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
cp -v avscan.sh /etc/scripts/scheduled; chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled; chmod +x /etc/scripts/scheduled/sync.sh
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
de(){
echo '**SETTING UP THE DESKTOP ENVIRONMENT**'
rm -v /etc/lightdm/lightdm-gtk-greeter.conf; cp -v lightdm-gtk-greeter.conf /etc/lightdm
cp -v default.jpg /usr/share/wallpapers
tar -xvf 01-Qogir.tar.xz -C /usr/share/icons > /dev/null 2>&1
tar -xvf Arc-Dark.tar.xz -C /usr/share/themes > /dev/null 2>&1
cp -v debian-swirl.png /usr/share/icons/default
mkdir -pv /etc/X11/xorg.conf.d; cp -v 40-libinput.conf /etc/X11/xorg.conf.d
echo "$user"
rm -r /home/$user/.config; cp -r config /home/$user/.config
cp -v gtkrc-2.0 /home/$user/.gtkrc-2.0
mkdir -pv /home/$user/Pictures/Wallpapers
mkdir -v /home/$user/Pictures/Screenshots
mkdir -v /home/$user/Music
mkdir -v /home/$user/Documents
mkdir -v /home/$user/Videos
mkdir -v /home/$user/.virt
chown $user:$user -R /home/$user
chown $user:$user /usr/share/wallpapers/default.jpg
}
optde(){
while true; do
clear
read -p "Do you want to install graphical interface? [y/n]" x
echo "================================================"
case "$x" in
y)
apt install -qq $de
de
echo "Finished
================================================"
sleep 3s
exit 0
;;
n)
echo "Finished
================================================"
sleep 3s
exit 0
;;
*) echo "Invalid option!"
esac
done
}
chassis(){
htype=$(hostnamectl chassis)
while true; do
clear
echo "**$htype**"
case "$htype" in
laptop)
printf 'Section "InputClass"
        Identifier "libinput touchpad catchall"
        MatchIsTouchpad "on"
        MatchDevicePath "/dev/input/event*"
        Driver "libinput"
        Option "Tapping" "on"
EndSection' > /etc/X11/xorg.conf.d/40-libinput.conf
printf '[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/lib/notification-daemon/notification-daemon' > /usr/share/dbus-1/services/org.freedesktop.Notifications.service
sleep 3
echo 'Finished
================================================'
sleep 3
;;
desktop)
sleep 3
echo 'Finished
================================================'
sleep 3
esac
done
}
# Menu
while true; do
clear
echo '================================================
Welcome to the post installation script for Debian minimal. Choose the type of installation you want:

1) Workstation

2) Server

3) Exit

================================================'

read -p "Enter the desired installation type and start it by pressing the Enter key: " x
echo "($x)
================================================"
case "$x" in
1)
echo '**INSTALLING PACKAGES**'
repo
apt install -qq $common $workstation $de $hypervisor $firmware
directories
base
{
echo '**SETTING UP HYPERVISOR**'
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
cpu=$(lscpu | grep 'Vendor ID' | cut -f 2 -d ":" | sed -n 1p | awk '{$1=$1}1')
gpasswd libvirt -a $user
touch /etc/modprobe.d/kvm.conf
while true; do
clear
echo "**$cpu**"
case "$cpu" in
GenuineIntel)
#Nested Intel processors
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_intel
/sbin/modprobe kvm_intel
sleep 3
de
chassis
echo 'Finished
================================================'
sleep 3
exit 0
;;
AuthenticAMD)
#Nested AMD processors
echo 'options kvm_amd nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_amd
/sbin/modprobe kvm_amd nested=1
sleep 3
de
chassis
echo 'Finished
================================================'
sleep 3
exit 0
;;
*) echo "Unknown or unsupported CPU architecture"
sleep 3
de
echo "Finished
================================================"
exit 0
esac
done
}
;;
2)
echo '**INSTALLING PACKAGES**'
repo
apt install -qq $common $workstation $hypervisor $firmware $server
directories
base
{
echo '**SETTING UP HYPERVISOR**'
user=$(grep 1000 /etc/passwd | cut -f 1 -d ":")
cpu=$(lscpu | grep 'Vendor ID' | cut -f 2 -d ":" | sed -n 1p | awk '{$1=$1}1')
gpasswd libvirt -a $user
touch /etc/modprobe.d/kvm.conf
while true; do
clear
echo "**$cpu**"
case "$cpu" in
GenuineIntel)
#Nested Intel processors
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_intel
/sbin/modprobe kvm_intel
sleep 3
optde
;;
AuthenticAMD)
#Nested AMD processors
echo 'options kvm_amd nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_amd
/sbin/modprobe kvm_amd nested=1
sleep 3
optde
;;
*) echo "Unknown or unsupported CPU architecture"
sleep 3
optde
esac
done
}
;;
3)
echo "Leaving...
================================================"
sleep 3
clear
exit 0
;;
*) echo "Invalid option!"
esac
done

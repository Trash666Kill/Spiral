#!/bin/bash
cd $PWD
# Packages
common="sudo vim sshfs nfs-common systemd-timesyncd unzip xz-utils sshpass bzip2 python3-apt screen htop stress hdparm tree curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh socat"

workstation="cryptsetup smartmontools uuid pigz passwd lm-sensors hdparm x11-xkb-utils bc fwupd tree pm-utils acpid cpulimit btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server"

server="samba"

graphics="nvidia-driver firmware-amd-graphics"

firmware="firmware-misc-nonfree firmware-realtek firmware-atheros"

hypervisor="qemu-kvm libvirt0 bridge-utils libvirt-daemon-system"

de="xorg xserver-xorg-input-libinput xserver-xorg-input-evdev brightnessctl xserver-xorg-input-mouse xserver-xorg-input-synaptics lightdm openbox obconf lxterminal lxpanel lxhotkey-gtk lxtask lxsession-logout lxappearance lxrandr progress arc-theme nitrogen ffmpegthumbnailer gpicview evince galculator gnome-screenshot l3afpad alacarte gpick compton pcmanfm unrar firefox-esr engrampa gparted gnome-disk-utility baobab virt-manager ssh-askpass"

minide="xorg openbox"

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
apt install -qq $common $workstation $de
sleep 5s
echo "Finished
================================================"
exit 0
;;
2)
apt install -qq $common $workstation $server
sleep 5s
{
while true; do
clear
read -p "Deseja instalar interface gráfica? [y/n]" x
echo "================================================"
case "$x" in
y)
echo "**SETTING UP THE DESKTOP ENVIRONMENT**"
rm -v /etc/lightdm/lightdm-gtk-greeter.conf && cp -v lightdm-gtk-greeter.conf /etc/lightdm
cp -v default.jpg /usr/share/wallpapers
tar -xvf 01-Qogir.tar.xz -C /usr/share/icons > /dev/null 2>&1
tar -xvf Arc-Dark.tar.xz -C /usr/share/themes > /dev/null 2>&1
cp -v debian-swirl.png /usr/share/icons/default
mkdir -pv /etc/X11/xorg.conf.d && cp -v 40-libinput.conf /etc/X11/xorg.conf.d
#Emperor
rm -r /home/emperor/.config && cp -r config /home/emperor/.config
cp -v gtkrc-2.0 /home/emperor/.gtkrc-2.0
chown emperor:emperor -R /home/emperor
chown emperor:emperor /usr/share/wallpapers/default.jpg
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
apt install -qq $common
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
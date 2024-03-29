#!/bin/bash
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
apt install sudo cryptsetup smartmontools vim sshfs systemd-timesyncd unzip xz-utils bzip2 uuid pigz sshpass python3-apt screen passwd -y
echo "2"
apt install lm-sensors htop stress hdparm x11-xkb-utils bc fwupd tree -y
echo "3"
apt install pm-utils acpid cpulimit -y
echo "4"
apt install curl wget net-tools tcpdump traceroute iperf ethtool geoip-bin speedtest-cli nload autossh socat -y
echo "5"
apt install btrfs-progs ntfs-3g dosfstools rsync nfs-kernel-server -y
#echo "6"
#apt install nvidia-driver firmware-amd-graphics -y
echo "7"
apt install firmware-misc-nonfree firmware-realtek firmware-atheros -y
#Hypervisor
echo "**INSTALLING HYPERVISOR**"
apt install qemu-kvm libvirt0 bridge-utils libvirt-daemon-system -y
gpasswd libvirt -a emperor
touch /etc/modprobe.d/kvm.conf
virsh net-autostart default
#Nested Intel processors
#echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
#/sbin/modprobe -r kvm_intel
#/sbin/modprobe kvm_intel
#Nested AMD processors
#echo 'options kvm_amd nested=1' >> /etc/modprobe.d/kvm.conf
#/sbin/modprobe -r kvm_amd
#/sbin/modprobe kvm_amd nested=1
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
cp -v avscan.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled && chmod +x /etc/scripts/scheduled/sync.sh
cp -v useful /etc
ln -s /etc/useful /home/emperor/.useful
ln -s /etc/useful /root/.useful
chmod 700 /home/emperor/.ssh
su - emperor -c "echo | touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
su - emperor -c "echo | ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 600 /root/.isolation
chmod 600 /root/.crypt
chmod 600 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
#DE
echo "**INSTALLING THE DESKTOP ENVIRONMENT**"
echo "1"
apt install xorg xserver-xorg-input-libinput xserver-xorg-input-evdev brightnessctl -y
echo "2"
apt install xserver-xorg-input-mouse xserver-xorg-input-synaptics -y
echo "3"
apt install lightdm openbox obconf lxterminal lxpanel lxhotkey-gtk -y
echo "4"
apt install lxtask lxsession-logout lxappearance lxrandr progress -y
echo "5"
apt install arc-theme nitrogen ffmpegthumbnailer -y
echo "6"
apt install gpicview evince galculator gnome-screenshot l3afpad alacarte gpick -y
echo "7"
apt install connman connman-ui connman-gtk compton pcmanfm unrar -y
echo "8"
apt install firefox-esr engrampa gparted gnome-disk-utility baobab -y
echo "9"
apt install virt-manager ssh-askpass -y
#Conf DE
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
/sbin/usermod -aG sudo emperor
#
#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
echo "End"
su - emperor
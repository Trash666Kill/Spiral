#!/bin/bash
#
#Non-free repo
cd /Spiral/Repository/
echo "**ADDING NON-FREE REPOSITORIES**"
rm -v /etc/apt/sources.list
cp -v sources.list /etc/apt/
#Update and Upgrade
echo "**UPDATING AND UPGRADING**"
apt update && apt upgrade -y
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo cryptsetup smartmontools vim sshfs systemd-timesyncd unzip xz-utils bzip2 uuid pigz sshpass python3-apt screen -y
echo "2"
apt install lm-sensors htop stress hdparm x11-xkb-utils bc fwupd tree zabbix-agent -y
echo "3"
apt install pm-utils acpid cpulimit -y
echo "4"
apt install curl wget samba net-tools tcpdump traceroute nmap telnet iperf ethtool geoip-bin speedtest-cli nload autossh -y
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
systemctl disable libvirtd
systemctl stop libvirtd
touch /etc/modprobe.d/kvm.conf
echo 'options kvm_intel nested=1' >> /etc/modprobe.d/kvm.conf
/sbin/modprobe -r kvm_intel
/sbin/modprobe kvm_intel
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/scheduled
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /var/log/rsync
chown emperor:emperor -R /var/log/rsync
mkdir -v /root/.isolation
mkdir -v /root/.crypt/
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
systemctl disable smbd
systemctl disable zabbix-agent
cp -v startup.sh /etc/scripts
chmod +x /etc/scripts/startup.sh
cp -v avscan.sh /etc/scripts/scheduled
chmod +x /etc/scripts/scheduled/avscan.sh
cp -v sync.sh /etc/scripts/scheduled
chmod +x /etc/scripts/scheduled/sync.sh
cp -v rc.local /etc
chmod 755 /etc/rc.local
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
#DE
echo "**INSTALLING THE DESKTOP ENVIRONMENT**"
echo "1"
apt install xorg xserver-xorg-input-libinput xserver-xorg-input-evdev -y
echo "2"
apt install xserver-xorg-input-mouse xserver-xorg-input-synaptics -y
echo "3"
apt install lightdm openbox obconf lxterminal lxpanel xscreensaver lxhotkey-gtk -y
echo "4"
apt install lxtask lxsession-logout lxappearance lxrandr xfce4-power-manager progress -y
echo "5"
apt install arc-theme nitrogen x2goserver ffmpegthumbnailer -y
echo "6"
apt install gpicview evince galculator gnome-screenshot pluma alacarte -y
echo "7"
apt install connman connman-ui connman-gtk compton caja unrar-free -y
echo "8"
apt install firefox-esr caffeine engrampa gparted gnome-disk-utility baobab -y
echo "9"
apt install virt-manager ssh-askpass -y
#Conf DE
echo "**SETTING UP THE DESKTOP ENVIRONMENT**"
rm -v /etc/lightdm/lightdm-gtk-greeter.conf
tar -xvf Spiral.tar.xz -C /usr/share/wallpapers/ > /dev/null 2>&1
tar -xvf 01-Qogir.tar.xz -C /usr/share/icons > /dev/null 2>&1
tar -xvf Arc-Dark.tar.xz -C /usr/share/themes > /dev/null 2>&1
cp -v lightdm-gtk-greeter.conf /etc/lightdm/
cp -v explorer.desktop /usr/share/applications/
cp -v debian-swirl.png /usr/share/icons/default/
mkdir -pv /etc/X11/xorg.conf.d
# cp -v 40-libinput.conf /etc/X11/xorg.conf.d/
#Emperor
rm -rv /home/emperor/.config
tar -xvf home.tar.xz -C /home/emperor/ > /dev/null 2>&1
chown emperor:emperor -R /home/emperor/
chown emperor:emperor -R /usr/share/wallpapers/Spiral/
#systemctl set-default multi-user.target
systemctl disable x2goserver

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

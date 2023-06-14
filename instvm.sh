#!/bin/bash
#
#Non-free repo
cd /Spiral-bookworm/Repository/
echo "**ADDING NON-FREE REPOSITORIES**"
rm -v /etc/apt/sources.list
cp -v sources.list /etc/apt/
#Update and Upgrade
echo "**UPDATING AND UPGRADING**"
apt update && apt upgrade -y
#Base packages*
echo "**INSTALLING BASE PACKAGES**"
echo "1"
apt install sudo cryptsetup vim sshfs systemd-timesyncd xz-utils python3-apt screen -y
echo "2"
apt install htop iotop stress hdparm tree zabbix-agent -y
echo "3"
apt install curl wget net-tools tcpdump traceroute nmap telnet iperf ethtool geoip-bin speedtest-cli nload autossh -y
#Directories
echo "**CREATING DIRECTORIES**"
mkdir -pv /etc/scripts/interfaces
mkdir -v /etc/scripts/mount
mkdir -v /etc/scripts/tunnels
mkdir -v /etc/scripts/routes
mkdir -v /etc/scripts/others
mkdir -pv /var/log/clamav/daily
mkdir -v /var/log/rc.local
chown emperor:emperor -R /var/log/rc.local
mkdir -v /root/.isolation
mkdir -v /root/.crypt/
mkdir -v /mnt/Temp
mkdir -pv /mnt/Local/USB/A
mkdir -v /mnt/Local/USB/B
mkdir -v /mnt/Local/Container-A
mkdir -v /mnt/Local/Container-B
mkdir -v /mnt/Local/Essentials
mkdir -pv /mnt/Remote/Servers
chown emperor:emperor -R /mnt
mkdir -v /home/emperor/Temp
mkdir -v /home/emperor/.ssh
mkdir -v /root/.ssh
chown emperor:emperor -R /home/emperor
#Conf Base
echo "**SETTING UP BASE**"
systemctl disable zabbix-agent
cp -v mount.sh /etc/scripts/mount
chmod +x /etc/scripts/mount/mount.sh
cp -v zombie0.sh /etc/scripts/interfaces
chmod +x /etc/scripts/interfaces/zombie0.sh
cp -v strychnine.sh /etc/scripts/tunnels
chmod +x /etc/scripts/tunnels/strychnine.sh
cp -v enp1s0.sh /etc/scripts/routes
chmod +x /etc/scripts/routes/enp1s0.sh
cp -v rc.local /etc
chmod 755 /etc/rc.local
rm -v /etc/network/interfaces
cp -v interfaces /etc/network
rm -v /etc/ssh/sshd_config
cp -v sshd_config /etc/ssh
rm -v /etc/motd
cp -v useful /home/emperor/.useful
touch /etc/motd
chmod 700 /home/emperor/.ssh
su - emperor -c "echo |touch /home/emperor/.ssh/authorized_keys"
chmod 600 /home/emperor/.ssh/authorized_keys
#su - emperor -c "echo |ssh-keygen -t rsa -b 4096 -N '' <<<$'\n'" > /dev/null 2>&1
chmod 700 /root/.isolation
chmod 700 /root/.crypt
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
#ssh-keygen -t rsa -b 4096 -N '' <<<$'\n' > /dev/null 2>&1
/sbin/usermod -aG sudo emperor

#Cleaning up
echo "**CLEANING UP**"
apt autoremove -y
rm -v /home/emperor/.bash_history
rm -v /root/.bash_history

#End
echo "**END**"
#Manual settings
echo "1 - Adjust network nics according to the environment
2 - Add zabbix server ip address in /etc/zabbix/zabbix_agentd.conf 
3 - Manually configure samba users and their respective passwords"
su - emperor
#

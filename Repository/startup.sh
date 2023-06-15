#!/bin/bash
{(
set -e
# Mount
cryptsetup luksOpen /dev/disk/by-uuid/898221be-388d-4b20-bfdc-74759afb8dce Container-A_crypt --key-file /root/.crypt/Container-A.key
mount /dev/mapper/Container-A_crypt /mnt/Local/Container-A
sshfs -p 26 emperor@SRV02:/mnt/Local/Container-A/Virt/Images /mnt/Remote/Servers/SRV02/Container-A/Virt/Images/ -o allow_other -o compression=no -o StrictHostKeyChecking=false
# Interfaces
modprobe dummy
ip link add zombie0 type dummy
ip link set zombie0 address 00:00:00:11:11:22
#ip addr add 0.0.0.0/24 dev zombie0
#ip link set dev zombie0 up
#ETHTOOL_OPTS="speed 1000 duplex full autoneg off"
# Routes
#route del default enp7s0
#ip route add default via 10.0.1.1 dev enp1s0
# Services 
systemctl restart libvirtd
systemctl restart smbd
systemctl restart zabbix-agent
# Virtual Machines
#sleep 60
virsh start VM00
)}
# Tunnels
autossh -M 0 -N -R 2222:localhost:26 -p 4634 emperor@strychnine.duckdns.org -o StrictHostKeyChecking=false &
#

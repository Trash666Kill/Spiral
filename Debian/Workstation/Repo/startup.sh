#!/bin/bash
# Mount
mount -U 8217fdfc-41db-4ed1-af8a-580e69e49bf6 /mnt/Local/Container-A
cryptsetup luksOpen /dev/disk/by-uuid/6382e4a3-5a30-4c02-bc05-354121e03dd7 USB-A_crypt --key-file /root/.crypt/6382e4a3-5a30-4c02-bc05-354121e03dd7.key
mount /dev/mapper/USB-A_crypt /mnt/Local/USB/A
sleep 5
# Swap
sysctl vm.swappiness=22 #=405,24MiB
swapon /mnt/Local/Container-A/.swapfile
# Interfaces
modprobe dummy
ip link add zombie0 type dummy
ip link set zombie0 address 52:54:00:e6:21:4c
# Firewall
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.0.62/26 -o nic0 -j MASQUERADE
# Services
systemctl restart smbd
# Virtual Machines
virsh start VM01
# Tunnels
sleep 60
socat TCP-LISTEN:4533,fork TCP:10.0.0.1:4533 &
sleep 15
(
ssh -f -N -T -R 2222:localhost:26 -p 4634 emperor@strychnine.duckdns.org -o StrictHostKeyChecking=false &
)
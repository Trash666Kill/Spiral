#!/bin/bash
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
#)
# Red power LED - 1 = ON, 0 = OFF
echo 0 | sudo tee /sys/class/leds/PWR/brightness
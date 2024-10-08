#!/bin/bash
# Mount
#mount -U 8217fdfc-41db-4ed1-af8a-580e69e49bf6 /mnt/Local/Container-A
#cryptsetup luksOpen /dev/disk/by-uuid/6382e4a3-5a30-4c02-bc05-354121e03dd7 USB-A_crypt --key-file /root/.crypt/6382e4a3-5a30-4c02-bc05-354121e03dd7.key
#mount /dev/mapper/USB-A_crypt /mnt/Local/USB/A
#sleep 5
# Swap
#sysctl vm.swappiness=22 #=405,24MiB
#swapon /mnt/Local/Container-A/.swapfile
# Interfaces
#kvm_vsw0_tap0
ip tuntap add tap0 mode tap
brctl addbr kvm_vsw0_tap0
brctl addif kvm_vsw0_tap0 tap0
ifconfig kvm_vsw0_tap0 up
ifconfig kvm_vsw0_tap0 10.0.10.254 netmask 255.255.255.0 up
#lxc_vsw0_tap1
ip tuntap add tap1 mode tap
brctl addbr lxc_vsw0_tap1
brctl addif lxc_vsw0_tap1 tap1
ifconfig lxc_vsw0_tap1 up
ifconfig lxc_vsw0_tap1 10.0.20.254 netmask 255.255.255.0 up
# Firewall
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.10.254/24 -o enp1s0 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 10.0.20.254/24 -o enp1s0 -j MASQUERADE
# Services
systemctl restart dnsmasq
systemctl restart lxc
systemctl restart libvirtd
#systemctl restart smbd
#systemctl restart nfs-kernel-server
#sleep 10
# Virtual machines
#virsh start VM01
# Containers
#lxc-start --name CT01
# Tunnels
#sleep 60
#socat TCP-LISTEN:4533,fork TCP:10.0.0.1:4533 &
#sleep 15
#(
#ssh -f -N -T -R 2222:localhost:26 -p 4634 emperor@strychnine.duckdns.org -o StrictHostKeyChecking=false &
#)
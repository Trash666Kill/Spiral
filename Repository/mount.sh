#!/bin/bash
#
# Container-A
cryptsetup luksOpen /dev/disk/by-uuid/898221be-388d-4b20-bfdc-74759afb8dce Container-A_crypt --key-file /root/.crypt/Container-A.key
mount /dev/mapper/Container-A_crypt /mnt/Local/Container-A
#
# SRV02
sshfs -p 26 emperor@172.16.2.11:/mnt/Local/Container-A/Virt/Images /mnt/Remote/Servers/SRV02/Container-A/Virt/Images/ -o allow_other -o compression=no -o StrictHostKeyChecking=false
#
# Hypervisor
systemctl restart libvirtd
# Samba
systemctl restart smbd
# Zabbix
systemctl restart zabbix-agent
#
# Virtual machines
# VM02
sleep 60
virsh start VM02
#

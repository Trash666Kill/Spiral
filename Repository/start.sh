#!/bin/bash
# Mount
cryptsetup luksOpen /dev/disk/by-uuid/898221be-388d-4b20-bfdc-74759afb8dce Container-A_crypt --key-file /root/.crypt/Container-A.key
mount /dev/mapper/Container-A_crypt /mnt/Local/Container-A
sshfs -p 26 emperor@SRV02:/mnt/Local/Container-A/Virt/Images /mnt/Remote/Servers/SRV02/Container-A/Virt/Images/ -o allow_other -o compression=no -o StrictHostKeyChecking=false
systemctl restart libvirtd
systemctl restart smbd
systemctl restart zabbix-agent
#sleep 60
virsh start VM00
# Interfaces
# Routes
# Tunnels

#!/bin/bash
# Local
#echo "##Assembling local units##"
#echo "#"
#echo "**Container-A**"
cryptsetup luksOpen /dev/disk/by-uuid/898221be-388d-4b20-bfdc-74759afb8dce Container-A_crypt --key-file /root/.crypt/Container-A.key
mount /dev/mapper/Container-A_crypt /mnt/Local/Container-A
#echo "**Container-B**"
cryptsetup luksOpen /dev/disk/by-uuid/af7887bc-850c-476e-8729-adb217b95fbe Container-B_crypt --key-file /root/.crypt/Container-B.key
mount /dev/mapper/Container-B_crypt /mnt/Local/Container-B
#echo "**Container-C**"
cryptsetup luksOpen /dev/disk/by-uuid/e24ce6c8-77bd-4da2-860d-e2a49e7aa15b Container-C_crypt --key-file /root/.crypt/Container-C.key
mount /dev/mapper/Container-C_crypt /mnt/Local/Container-C
#echo "#"
# Remote
#echo "##Assembling remote units##"
#echo "##SRV02##"
#echo "**SRV02**"
#sshfs -p 26 emperor@172.16.2.11:/mnt/Local/Container-A/Virt/Images /mnt/Remote/Servers/SRV02/Container-A/Virt/Images/ -o allow_other -o compression=no -o StrictHostKeyChecking=false
#echo "#"
#echo "##Starting services##"
#echo "**Hypervisor**"
systemctl restart libvirtd
#echo "**Samba**"
systemctl restart smbd
#echo "**Zabbix**"
systemctl restart zabbix-agent
#echo "#"
#echo "##Starting virtual machines##"
#echo "VM02"
#virsh start VM02
#echo "VM03"
virsh start VM03
#echo "#"
#df -hT /dev/mapper/Container-A_crypt
#df -hT /dev/mapper/Container-B_crypt
#df -hT /dev/mapper/Container-C_crypt
#df -hT /mnt/Remote/Servers/SRV02/Container-A/Virt/Images

#!/bin/bash
#
#echo "##STANDBY MODE STARTED##"
#
#echo "##Shutting down virtual machines##"
for i in $(virsh list | grep running | awk '{print $2}'); do virsh shutdown $i; done
sleep 60
virsh list --all
#
#echo "##Stopping services##"
#echo "**Samba**"
systemctl stop smbd
#echo "**Zabbix**"
systemctl stop zabbix-agent
#echo "**libvirt**"
systemctl stop libvirtd
sleep 04
#
#echo "##Putting Storage Drives in Standby Mode##"
#echo "**Dismantling**"
umount /mnt/Local/Container-A
umount /mnt/Local/Container-B
umount /mnt/Local/Container-C
#echo "**Closing LUKS units**"
/usr/sbin/cryptsetup close Container-A_crypt
/usr/sbin/cryptsetup close Container-B_crypt
/usr/sbin/cryptsetup close Container-C_crypt
#echo "**Ejecting units**"
/usr/sbin/hdparm -Y /dev/sdb
#/usr/bin/udisksctl power-off -b /dev/sdb

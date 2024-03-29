#!/bin/bash
while true; do
clear
echo '================================================
Welcome to the post installation script for Debian minimal. Choose the type of installation you want:

1) Workstation

2) Server

3) Raspberry Pi

4) Exit

================================================'

read -p "Enter the desired installation type and start it by pressing the Enter key: " x
echo "($x)
================================================"

case "$x" in
1)
free -m
sleep 5s
echo "Finished
================================================"
exit 0
;;
2)
df -hT
sleep 5s
echo "Finished
================================================"
exit 0
;;
3)
sensors
sleep 5s
echo "Finished
================================================"
exit 0
;;
4)
echo "Leaving...
================================================"
sleep 5s
clear
exit 0
;;
*) echo "Invalid option!"
esac
done
#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   	echo "This script must be run as sudo"
   	exit 1
else
# swapfile
btrfs subvolume create /swap
btrfs filesystem mkswapfile --size $1 --uuid clear /swap/swapfile
swapon /swap/swapfile

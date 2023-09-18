btrfs subvolume create /swap
btrfs filesystem mkswapfile --size 8g --uuid clear /swap/swapfile
swapon /swap/swapfile

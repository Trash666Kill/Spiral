modprobe dummy
ip link add zombie0 type dummy
ip link set zombie0 address 00:00:00:11:11:22
#ip addr add 0.0.0.0/24 dev zombie0
#ip link set dev zombie0 up
#ETHTOOL_OPTS="speed 1000 duplex full autoneg off"

#!/bin/sh
usage() {
        echo "$0 /path/to/vm/description/file"
        exit 1
}
if [ $(id -u) -eq 0 ]
then
        echo "This script shouldn't be run as root. Aborting." >&2
        exit 1
fi
sudo -nl > /dev/null 2>&1
if [ $? -eq 1 ]
then
        echo "You need the sudo rights to run the script. Aborting." >&2
        exit 1
fi
if [ $# -ne 1 ]
then
        usage
fi
if [ ! -f $1 ]
then
        echo "Error: $1 is not a file. Aborting." >&2
fi
file=$(readlink -f $1)
vm="$(grep ^\s*name $file | cut -d= -f2 | tr -d "'\"")"
ipv6host="$(grep ^\s*ipv6host $file | cut -d= -f2 | tr -d "'\"")"
ipv6vm="$(grep ^\s*ipv6vm $file | cut -d= -f2 | tr -d "'\"")"
if [ $(sudo xl list-vm | grep $vm | wc -l) -ne 1 ]
then
        echo "The vm $1 is not running. Aborting." >&2
        exit 1
fi
vmvif=$(sudo xl network-list $vm | rev | cut -d\  -f1 | cut -d/ -f2 | rev)
vmvif=vif$(echo $vmvif | tr -d ' ').0
sudo ip link set $vmvif up
sudo ip address add $ipv6host dev $vmvif
sudo ip route delete $ipv6host dev $vmvif
sudo ip route add $ipv6host dev $vmvif
sudo ip route add $ipv6vm dev $vmvif

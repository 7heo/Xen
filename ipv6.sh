#!/bin/sh

usage() {
        echo "$0 <vm-name> <IPv6 address on host side> <IPv6 address on vm side>"
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

if [ $# -ne 3 ]
then
        usage
fi

if [ $(sudo xl list-vm | grep $1 | wc -l) -ne 1 ]
then
        echo "The vm $1 is not running. Aborting." >&2
        exit 1
fi

vmvif=$(sudo xl network-list dev | rev | cut -d\  -f1 | cut -d/ -f2 | rev)
vmvif=vif$(echo $vmvif | tr -d ' ').0

sudo ip link set $vmvif up
sudo ip address add $2 dev $vmvif
sudo ip route delete $2 dev $vmvif
sudo ip route add $2 dev $vmvif
sudo ip route add $3 dev $vmvif

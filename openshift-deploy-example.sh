#!/usr/bin/env bash

# How to use the script: copy it and adjust what you have to adjust!
#   For example: ip adresses ;-)

set -euo pipefail
set -x

export GOVC_URL='vcenter-ip'
export GOVC_USERNAME='administrator@vsphere.local'
export GOVC_PASSWORD='xxxxxx'
export GOVC_INSECURE=1
export GOVC_DATACENTER="DC"

basedomain="example.com"
clustername="openshift4"

nodes=(
    "bootstrap.${clustername}.${basedomain}"
    "control-plane-0.${clustername}.${basedomain}"
    "control-plane-1.${clustername}.${basedomain}"
    "control-plane-2.${clustername}.${basedomain}"
    "worker-1.${clustername}.${basedomain}"
    "worker-2.${clustername}.${basedomain}"
    "worker-3.${clustername}.${basedomain}"
)

ignitions=(
    'bootstrap.ign'
    'master.ign'
    'master.ign'
    'master.ign'
    'worker.ign'
    'worker.ign'
    'worker.ign'
);

# By default not needed.
# mac_adresses=(
#     '00:50:56:23:F7:21'
#     '00:50:56:1E:A5:6A'
#     '00:50:56:1E:33:25'
#     '00:50:56:0C:F8:E0'
#     '00:50:56:1E:2C:5D'
#     '00:50:56:24:CD:19'
#     '00:50:56:24:CD:20'
# )

ips=(
    '192.168.10.101'
    '192.168.10.102'
    '192.168.10.103'
    '192.168.10.104'
    '192.168.10.105'
    '192.168.10.106'
    '192.168.10.107'
)

# function govc {
#     echo "Dummy function"
# }

# Setup vm's
for (( i=0; i< ${#nodes[@]} ; i++ )) ; do
    node=${nodes[$i]}
    ip=${ips[$i]}
    ignition=${ignitions[$i]}
    
    echo "Setup $node -> $ip";

    # If you want to setup mac adress
    # mac_adresse=${mac_adresses[$i]}
    # -net.address ${mac_adresse} \
    govc vm.clone -vm "/${GOVC_DATACENTER}/vm/${clustername}/rhcos-4.3.8-ipxe"  \
        -annotation=$ignition \
        -c=4 \
        -m=16384 \
        -net ocp4-segment1 \
        -on=false \
        -folder=${clustername} \
        -ds='LUN 3TB' \
        $node

    # iPXE settings
    govc vm.change \
        -e="guestinfo.ipxe.hostname=$node" \
        -e="guestinfo.ipxe.ignition=$ignition" \
        -e="guestinfo.ipxe.net0.ip=$ip" \
        -e="guestinfo.ipxe.net0.netmask=255.255.255.0" \
        -e="guestinfo.ipxe.net0.gateway=192.168.10.97" \
        -e="guestinfo.ipxe.fileserver=http://192.168.10.100:8080" \
        -e="guestinfo.ipxe.dns=10.10.1.4" \
        -e="guestinfo.ipxe.kernel-installer=rhcos-4.3.8-x86_64-installer-kernel-x86_64" \
        -e="guestinfo.ipxe.initrd-installer=rhcos-4.3.8-x86_64-installer-initramfs.x86_64.img" \
        -e="guestinfo.ipxe.rhcos-image=rhcos-4.3.8-x86_64-metal.x86_64.raw.gz" \
        -e="guestinfo.ipxe.disk=sda" \
        -e="guestinfo.ipxe.net_interface=ens192" \
        -vm="/${GOVC_DATACENTER}/vm/${clustername}/$node"

done;

# Start vm's
for node in ${nodes[@]} ; do
    echo "# Start $node";
    govc vm.power -on=true $node
done;


PS: This method works just with BIOS

#Install packages#
sudo yum install git xz-devel -y
sudo yum groupinstall "Development tools" -y

#Download ipxe
git clone https://github.com/ipxe/ipxe/
cd ipxe/src

sed -i '/VMWARE_SETTINGS/s/\/\///g' config/settings.h

cat > vmware.ipxe << 'EOF'
#!ipxe
ifopen net0
kernel  ${fileserver}/${kernel-installer} ip=${net0/ip}::${net0/gateway}:${net0/netmask}:${hostname}:${net_interface}:none nameserver=${dns} rd.neednet=1 initrd=${fileserver}/${initrd-installer} console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=${disk} coreos.inst.image_url=${fileserver}/${rhcos-image} coreos.inst.ignition_url=${fileserver}/${ignition}
initrd ${fileserver}/${initrd-installer}
boot
EOF

make bin/ipxe.iso EMBED=vmware.ipxe 

VMWARE with static IPs without DHCP availability 

Vmware GOVC Installation

curl -L https://github.com/vmware/govmomi/releases/download/v0.22.1/govc_linux_amd64.gz | gunzip > /usr/local/bin/govc && chmod +x /usr/local/bin/govc

Basic Connectivity
Export a set of environment variables so the CLI knows how to connect to vCenter:

export GOVC_URL='vsphere.server.local
export GOVC_USERNAME='admin@vsphere.local'
export GOVC_PASSWORD='password
export GOVC_INSECURE=1
export GOVC_NETWORK='VM Network'
export GOVC_DATASTORE='datastore1'

Upload the ipxe.iso to datastore

govc datastore.mkdir OCP4
govc datastore.upload bin/ipxe.iso OCP4/ipxe-rhcos.iso
govc datastore.ls images

Create Demo Virtual Machine using Vmware GUI or use ansible to automate it :)


Set Vmware guest.info parameters:

  guestinfo.ipxe.hostname = "bootstrap"
  guestinfo.ipxe.ignition = "bootstrap.ign"
  guestinfo.ipxe.net0.ip = "192.168.122.15"
  guestinfo.ipxe.net0.netmask = "255.255.255.0"
  guestinfo.ipxe.net0.gateway = "192.168.122.1"
  guestinfo.ipxe.fileserver = "http://192.168.122.1:8080"
  guestinfo.ipxe.dns = "192.168.122.1"
  guestinfo.ipxe.kernel-installer = "rhcos-4.2.0-x86_64-installer-kernel"
  guestinfo.ipxe.initrd-installer = "rhcos-4.2.0-x86_64-installer-initramfs.img"
  guestinfo.ipxe.rhcos-image = "rhcos-4.2.0-x86_64-metal-bios.raw.gz"
  guestinfo.ipxe.disk = sda
  guestinfo.ipxe.net_interface = ens192
  
Using govc

govc vm.change -e="guestinfo.ipxe.hostname=bootstrap" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.ignition=bootstrap.ign" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.net0.ip=192.168.122.15" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.net0.netmask=255.255.255.0" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.net0.gateway=192.168.122.1" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.fileserver=http://192.168.122.1:8080" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.dns=192.168.122.1" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.kernel-installer=rhcos-4.2.0-x86_64-installer-kernel" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.initrd-installer=rhcos-4.2.0-x86_64-installer-initramfs.img" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.rhcos-image=rhcos-4.2.0-x86_64-metal-bios.raw.gz" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.disk=sda" -vm=ipxe-demo
govc vm.change -e="guestinfo.ipxe.net_interface=ens192" -vm=ipxe-demo


Power UP the VM and have fun :)

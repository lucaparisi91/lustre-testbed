
# Setting up a lustre cluster on a VM

Create 3 VMs running Rocky 9.5, one for the mgs/mds server, one for the oss and one for the client.
Each VM has 15GB disk space.

## Setting up networking

The network should be configured as static network. For instance on the mgs one would use.

```bash
nmcli con add type ethernet autoconnect yes con-name lustre_network  ifname enp0s1 ip4 192.168.64.17 gw4 192.168.64.1 ipv4.dns 192.168.64.1
```

ip | hostname
-- | ---
192.168.64.17 |  mgs/mdt
192.168.64.18 |  oss
192.168.64.19 |  client

Set up passwordless ssh connections between the the VMS and and host.
## Build ZFS on the servers

```bash
dnf groupinstall -y "Development Tools"
dnf config-manager -y --set-enabled crb
dnf install -y epel-release-9 gcc make autoconf automake libtool rpm-build kernel-rpm-macros libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel-$(uname -r) kernel-abi-stablelists-$(uname -r | sed 's/\.[^.]\+$//') python3 python3-devel python3-setuptools python3-cffi libffi-devel
dnf install -y  --skip-broken python3-packaging dkms

wget https://github.com/openzfs/zfs/releases/download/zfs-2.2.6/zfs-2.2.6.tar.gz
tar -zxvf zfs-2.2.6.tar.gz 
cd zfs-2.2.6
./autogen.sh
./configure
make -j1 rpm-utils rpm-kmod
dnf install -y *.$(uname -p).rpm *.noarch.rpm
```

## Install Lustre on the servers

Under the root user, install the latest lustre release from github.

```bash
dnf groupinstall -y "Development Tools" 
dnf config-manager -y --set-enabled crb
dnf install -y keyutils keyutils-libs-devel libmount \
                        libmount-devel libnl3-devel libnl3 libnl3-cli \
                        libyaml libyaml-devel kernel-abi-stablelists kernel-rpm-macros \
                        dkms expect python python-devel git
git clone git://git.whamcloud.com/fs/lustre-release.git
cd lustre-release
./autogen.sh
sed -i '/^SELINUX=/s/.*/SELINUX=disabled/' /etc/selinux/config 
./configure --disable-ldiskfs
make rpms
dnf --skip-broken install -y *.$(uname -p).rpm
```

# Setting up Lustre

Create a combined mgt/mdt disk.

On the mgs/mds server:

```bash
mkfs.lustre --reformat --backfstype=zfs --fsname=lustre --mgs --mdt mgt_mgs/lustre  /dev/vdb
mount -t lustre mgt_mgs/lustre /lustre/mgt_mgs
systemctl stop firewalld
```

On the oss server

```bash
systemctl stop firewalld
mkfs.lustre --reformat --backfstype=zfs --fsname=lustre --ost ost/lustre --mgsnode=192.168.64.17@tpc0 --index=0  /dev/vdb
mount -t lustre ost/lustre /lustre/ost
```

## Install Lustre on the clients

```bash
dnf update -y
dnf groupinstall -y "Development Tools" 
dnf config-manager -y --set-enabled crb
dnf install -y keyutils keyutils-libs-devel libmount \
                        libmount-devel libnl3-devel libnl3 libnl3-cli \
                        libyaml libyaml-devel kernel-abi-stablelists kernel-rpm-macros \
                        dkms expect python python-devel git
git clone git://git.whamcloud.com/fs/lustre-release.git
cd lustre-release
./autogen.sh
sed -i '/^SELINUX=/s/.*/SELINUX=disabled/' /etc/selinux/config 
./configure --disable-server --enable-client
make rpms
dnf --skip-broken install -y *.$(uname -p).rpm
```

## Setup the client

Mount the MGS server on the client

```bash
mkdir -p /lustre
mount -t lustre 192.168.64.17@tcp0:/lustre /lustre
```
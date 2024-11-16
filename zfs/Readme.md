# Building ZFS on ARM

```bash
sudo dnf install --skip-broken epel-release gcc make autoconf automake libtool rpm-build kernel-rpm-macros libtirpc-devel libblkid-devel libuuid-devel libudev-devel openssl-devel zlib-devel libaio-devel libattr-devel elfutils-libelf-devel kernel-devel-$(uname -r) kernel-abi-stablelists-$(uname -r | sed 's/\.[^.]\+$//') python3 python3-devel python3-setuptools python3-cffi libffi-devel
sudo dnf install --skip-broken --enablerepo=epel python3-packaging dkms

wget https://github.com/openzfs/zfs/releases/download/zfs-2.2.6/zfs-2.2.6.tar.gz
tar -zxvf zfs-2.2.6.tar.gz 
cd zfs-2.2.6
./autogen.sh
./configure
make -j1 rpm-utils rpm-kmod
sudo dnf install *.$(uname -p).rpm *.noarch.rpm
```
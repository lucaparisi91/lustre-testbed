

# Setting up a lustre cluster on a VM

## Disk

A 30GB disk is used for the server and an additional 30GB is used for the client.
The filesystem is mounted on `/vms/server` and `/vms/client`.

```bash
yum install autofs nfs-utils
```


```bash
 usermod -aG wheel lparisi

 ```

 At at the end of /etc/sudoers file add using visudo

 ```bash
 lparisi  ALL=(ALL) NOPASSWD:ALL
```

## Setting up networking

The network should be configured as static network
I used nmtui to setup the connection and set it to automount on each of the virtual machines.

Each vm as a 20GB disk and an additional 5GB disk to use with lustre.

ip | hostname | 
-- | --- |
192.168.122.83 |  lmgs


## Building lustre

```bash
#sudo dnf config-manager  --add-repo https://uk.linaro.cloud/repo/lustre/master/el9/aarch64/
sudo dnf groupinstall "Development Tools"
sudo dnf config-manager --set-enabled crb
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf install keyutils keyutils-libs-devel libmount \
                        libmount-devel libnl3-devel libnl3 libnl3-cli \
                        libyaml libyaml-devel kernel-abi-stablelists kernel-rpm-macros \
                        dkms expect python python-devel git

git clone git://git.whamcloud.com/fs/lustre-release.git
cd lustre-release
./autogen.sh
./configure
make rpms
sudo rpm -ivh ./kmod-lustre-client-2.16.0_RC3-1.el9.aarch64.rpm
sudo rpm -ivh ./lustre-client-dkms-2.16.0_RC3-1.el9.noarch.rpm
```

## Install on the servers

## Insall on the clients

```bash
sudo rpm -ivh ./kmod-lustre-client-2.16.0_RC3-1.el9.aarch64.rpm
sudo rpm -ivh ./lustre-client-dkms-2.16.0_RC3-1.el9.noarch.rpm
```
sudo virt-install \
    --name lustre_mng_server --memory 2048 \
    --vcpus 1 --disk /vms/server/server_vol.qcow2  \
    --location /opt/'CentOS-Stream-9-latest-aarch64-dvd1 (1).iso' \
    --initrd-inject /home/lparisi/instructions/lustre_kickstart/ks.cfg --extra-args="inst.ks=file:/ks.cfg"
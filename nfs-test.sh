#!/bin/bash

# Usage: ./check-nfs-from-node.sh <node-name> <nfs-server-ip> <nfs-path>
# Example: ./check-nfs-from-node.sh adc-node01 10.179.16.234 /nfs-cber-cer-m

NODE_NAME=$1
NFS_SERVER=$2
NFS_PATH=$3
MOUNT_DIR="/tmp/nfs-test-mount"

if [[ -z "$NODE_NAME" || -z "$NFS_SERVER" || -z "$NFS_PATH" ]]; then
  echo "Usage: $0 <node-name> <nfs-server-ip> <nfs-export-path>"
  exit 1
fi

echo "[INFO] Launching debug pod on node $NODE_NAME..."
oc debug node/$NODE_NAME -- bash -c "
  echo '[INFO] Entering chroot on node filesystem';
  chroot /host bash -c \"
    mkdir -p $MOUNT_DIR;
    echo '[INFO] Attempting to mount NFS share...';
    mount -t nfs -o soft,retry=3,nfsvers=4.1 $NFS_SERVER:$NFS_PATH $MOUNT_DIR && echo '[SUCCESS] Mounted NFS share.' || echo '[ERROR] Mount failed';

    echo '[INFO] Listing contents:';
    ls -l \$MOUNT_DIR;

    echo '[INFO] Cleaning up...';
    umount -f \$MOUNT_DIR 2>/dev/null;
    rmdir \$MOUNT_DIR 2>/dev/null;
  \"
"


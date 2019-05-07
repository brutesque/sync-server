#!/usr/bin/env bash

sudo mkdir -p /mnt/storage
NEW_LINE="/dev/vdb1 /mnt/storage xfs defaults 0 0"
EXISTING_LINE=$(cat /etc/fstab |grep "$NEW_LINE")
if [[ -z "$EXISTING_LINE" ]]; then
    echo "$NEW_LINE" | sudo tee -a /etc/fstab
    sudo mount /mnt/storage
fi
df -h |grep storage
sudo touch /mnt/storage/testfile && sudo rm /mnt/storage/testfile

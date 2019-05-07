#!/usr/bin/env bash

sudo rm -Rf /mnt/storage/sync/config
sudo rm /mnt/storage/sync/sync.conf
sudo rm -Rf /mnt/storage/sync/folders/*/.sync/

ls -la /mnt/storage/sync /mnt/storage/sync/folders

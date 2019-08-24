# sync-server
Docker Compose for a private remote backup service using Resilio Sync, Nginx and Let's Encrypt.

## Requirements
- Fresh Ubuntu install on a private server
- DNS Record pointing to your server
- Copy your ssh public key to the server 


## Prepare server

Install Ubuntu on a VPS. Login into the shell and type:
```bash
$ cd sync-server
```


Configure the host
```bash
$ bash scripts/install-docker.sh
```
This will do the following:
- Configures SSH server to only use public key authentication, turn of password authentication and other adjustments 
for hardening.
- Configures firewall to block all incoming traffic, except for ssh, webgui and sync
- Install fail2ban


Configure the backup disk. Make sure the disk is mounted as /mnt/storage.

When using [BigStorage at transip.nl](https://www.transip.nl/vps/big-storage/) you can use the following script:
```bash
$ bash scripts/mount-transip-bigstorage.sh
```


Make sure the following path exists after mounting:
```bash
$ mkdir -p /mnt/storage/sync
```
This will be resilio sync backup and cache folder.


Install Docker
```bash
$ bash scripts/install-docker.sh
```


## Deploy

Run the deploy script
```bash
$ bash deploy.sh [staging | production] <domain1 domain2 ...>
```

Let's Encrypt certificates will be generated during this process, so make sure to use the 'staging' parameter during testing.
Certificates will be generated for all the supplied domains.

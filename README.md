# A Guide to Installation

This meant to document the installation of my media server stack. Based off of : . Underlying infrastructure is Ubuntu with MergeFS and SnapRaid providing a single mount point for storage and periodic snapshot of data. Applications are then ran in docker via docker-compose on top of this data store. 

This was built on top of a clean Ubuntu install with Docker, Docker-Compose and Samba already installed (via apt). Any configuration type files are included in this repository along with instructions. For any backups/reinstallations a manual copy of files in opt and var locations would be needed. 

## Installation

### OS & Hard Drive

1. Install Unbuntu, Docker, Docker-Compose via usual means. 
2. Download and install mergeFS from github
    
    ```bash
    export release_type=jammy_amd64
    wget $(curl -s https://api.github.com/repos/trapexit/mergerfs/releases/latest | jq -r ".assets[] | select(.name | test(\"${release_type}\")) | .browser_download_url")
    sudo dpkg -i mergerfs_*$release_type.deb
    ```
    
3. Current Hard drives are identified in <link>  
    1. If new hard drives are added, they need to be identified
        
        ```bash
        ls /dev/disk/by-id
        ls -la /dev/disk/by-id/DISK_ID_FROM_ABOVE
        ```
        
    2. Use gdisk to setup data partitions on hard drive
        
        ```bash
        gdisk /dev/sdX #X replaced with disk ID
        * o - creates a new **EMPTY** GPT partition table (GPT is good for large drives over 3TB)
            * Proceed? (Y/N) - **`Y`**
        * n - creates a new partition
            * Partition number (1-128, default 1): **`1`**
            * First sector (34-15628053134, default = 2048) or {+-}size{KMGTP}: **`leave blank`**
            * Last sector (2048-15628053134, default = 15628053134) or {+-}size{KMGTP}: **`leave blank`**
            * Hex code or GUID (L to show codes, Enter = 8300): **`8300`**
        * p - (optional) validate 1 large partition to be created
            * Model: HGST HDN728080AL
            * Number  Start (sector)    End (sector)  Size       Code  Name
            * 1       2048              15628053134   7.3 TiB    8300  Linux filesystem
        * w - writes the changes made thus far
            * Until this point, gdisk has been non-destructive
            * Confirm that making these changes is OK and the changes queued so far will be executed
        ```
        
    3. Create ext4 filesystem 
        
        ```bash
        mkfs.ext4 /dev/sdX1 #X replaced with disk ID
        ```
        
4. Create mountpoints in /mnt directory, labelled disk1…x for each storage disk and parity1…x for each parity disk 
    
    ```bash
    mkdir /mnt/disk{1,2,3,4}
    mkdir /mnt/parity1 # adjust this command based on your parity setup
    mkdir /mnt/storage # this will be the main mergerfs mountpoint
    ```
    
5. Replace `/etc/fstab` with fstab from github
    1. Add any additional drives following pattern from <link>
    2. MergeFS setup at bottom of fstab
6. Mount and validate fstab
    
    ```bash
    mount -a
    df -h
    ```
    

### SnapRaid

1. Install SnapRaid - [Dockerized version from IronicBadger](https://github.com/IronicBadger/docker-snapraid)
    
    ```bash
    # these steps assume a valid, working docker installation
    apt update && apt install git -y
    mkdir ~/tmp && cd ~/tmp
    git clone https://github.com/IronicBadger/docker-snapraid
    cd docker-snapraid
    chmod +x build.sh
    ./build.sh
    sudo dpkg -i build/snapraid-from-source.deb
    
    #validate installation
    snapraid --version
    ```
    
2. Install Snapraid Runner
    
    ```bash
    git clone https://github.com/Chronial/snapraid-runner.git /opt/snapraid-runner
    ```
    
3. Load configuration file at `/opt/snapraid-runner/snapraid-runner.conf`
4. Create cronjob in crontab `sudo crontab -e`
    1. Cronjob includes ping to [healthchecks.io](http://healthchecks.io) for automated monitoring

### Samba

1. Install samba via apt
2. Load samba config to `etc/samba/smb.conf`
3. Set user password (can be new or existing) `smbpasswd -a user`
    1. Existing Users can be listed via `pdbedit -L -v`
4. Restart Samba `systemctl restart smbd`

### Application Setup

1. Load docker-compose file
    1. Containers follow the general logic of config/installation files on boot drive (/var)
    2. MergeFS storage point is loaded, generally the media folder for any media applications
    3. Ports are passed through without changes
    4. Applications are ran as default user
2. Plex Configuration
    1. Additional line is added for passing through graphics card for hardware acceleration
    2. RAMdisk is passed through for transcoding (plex defaults to created a /transcode directory in default install location unless specified)

## Questions?

- Why not ZFS?
    - I haven’t saved up enough money to having matching hard drives, moving to ZFS is the end goal
- Why not UnRaid?
    - It costs money! I also enjoy tinkering with my server (as can probably be seen), so it may be slightly less seemless then unraid but it’s free and fun
- Why were hard drive assigned in certain ways or why is SnapRaid running a certain way?
    - Vibes
- Why do you use a RAMdisk for plex transcoding
    - Because I can! By default linux allocates up to half the available RAM to a RAMdisk, meaning I have 16GB available. My densest media files is 50GB for a 2 hour movie, or ~.5 GB/minute and I have plex set to transcode up to 1 minute in advance before transcoding. Realistically I assume it’s not purging perfectly etc, but even assuming each transcode takes up 1 GB, I can still handle 16 simultaneously. My system generally uses about 1GB of RAM at rest (I have 32 in prep for ZFS) so since I have all the extra, why not use it? It also saves a lot of wear and tear on the NVME SSD.

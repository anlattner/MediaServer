# A Guide to Media Server Installation

This meant to document the installation of my media server stack. Based off of : . Underlying infrastructure is Ubuntu with MergeFS and SnapRaid providing a single mount point for storage and periodic snapshot of data. Applications are then ran in docker via docker-compose on top of this data store. 

This was built on top of a clean Ubuntu install with Docker, Docker-Compose and Samba already installed (via apt). Any configuration type files are included in this repository along with instructions. For any backups/reinstallations a manual copy of files in opt and var locations would be needed. 

## Installation

### OS & Hard Drive

1. Install Unbuntu, Docker, Docker-Compose via usual means. 
2. Download and install mergeFS from github. 
3. Current Hard drives are identified in <link>  
    1. If new hard drives are added, they can be identified using <code> if disks are new and need to be added to hard drive list. 
    2. Use gdisk to setup data partitions on hard drive
    3. Create ext4 filesystem 
4. Create mountpoints in /mnt directory, labelled disk1…x for each storage disk and parity1…x for each parity disk 
5. Replace /etc/fstab with fstab from github
    1. Add any additional drives following pattern
    2. MergeFS setup at bottom of 
6. Mount fstab
    1. Validate with df -h

### SnapRaid

1. Install SnapRaid
2. Install Snapraid Runner
3. Load configuration file at /opt/snapraid-runner/snapraid-runner.conf
4. Create cronjob
    1. Cronjob includes ping to [healthchecks.io](http://healthchecks.io) for automated monitoring

### Samba

1. Install samba
2. Load samba config to 
3. Set user password (can be new or existing)
    1. Existing Users:
4. Restart Samba

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

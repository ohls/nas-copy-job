# Synology NAS Copy Job with rsync

## Goal
Create a copy of recent photos in a target folder on the NAS.
The target folder shall only contains photos of the last few months.  
This ways the target folder can be synced using Synology Drive to
get a local copy of recent photos on each personal computer.

## Steps the script executes
### Clean data on the NAS
1. creates a copy of recent photos in the home folder of certain users to allow a Synology Drive sync offline to PC
1. deletes photos in the home folder of the user to keep only the recent photos as local copy

# Credits
Thanks to teh people of [rsync](https://rsync.samba.org/). I love it!
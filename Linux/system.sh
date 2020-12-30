#!/bin/bash

#Print the amount of free memory on the system and saves it to ~/backups/freemem/free_mem.txt
free -h > ~/backups/freemem/free_mem.txt
#Print disk usage and saves it to ~/backups/diskuse/disk_usage.txt
du -h > ~/backups/diskuse/disk_use.txt
#List all open files and saves it to ~/backups/openlist/open_list.txt
lsof > ~/backups/openlist/open_list.txt
#Print file system disk space statistics and saves it to ~/backups/freedisk/free_disk.txt
df -h > ~/backups/freedisk/free_disk.txt


#For the free memory, disk usage, and free disk commands, make sure you use the -h option to make the output human-readable

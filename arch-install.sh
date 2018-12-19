#!/bin/bash

####****************************************#####
####     INDEEDIONS ARCH-INSTALL SCRIPT     #####
####****************************************#####


#set keyboard layout
exec loadkeys sv-latin1

# skipping boot mode verification here

#Verify internet connection -- TODO

#Update system clock
exec timedatectl set-ntp true &
exec timedatectl set-timezone Europe/Stockholm &
exec timedatectl status &

#Partition disks -- TODO

#Format partitions
exec mkfs-ext4 /dev/sda1 &
exec mkswap /dev/sda2 &

#Mount filesystems
exec mount /dev/sda1 /mnt/ &

#Install base packages
exec pacstrap /mnt base &

#Configure the system
exec genfstab -U /mnt >> /mnt/etc/fstab &
exec arch-chroot /mnt &

#move script focus to chrooted environment -- TODO

#Configure time settings for new environment
exec ln -sf /usr/share/zoneinfo/Europe/Stockholm /etc/localtime &  # set timezone
exec hwclock --systohc & # not sure what this does, something with harware clock and UTC

#Open /etc/locale.gen and uncomment needed locals
#en_US.UTF-8, och den svenska.. -- TODO
#add code here
exec locale-gen & #generates the locals

#
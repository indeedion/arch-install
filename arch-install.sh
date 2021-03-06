#!/bin/bash

##########################################################
#  +++++++++ Indeedion Arch Installer V.0 ++++++++++     #
#                                                        #
#  Author: Magnus Jansson                                #
#  Email: mengus00@gmail.com				 #
#  Source: https://github.com/indeedion/arch-install     #
#                                                        #
##########################################################

clear
echo "Welcome to the arch installer!! Press any key to continue.."
read key

#Set up log file
declare -r LOG=$(pwd)"/install.log"
echo "" > $LOG

#Set up script home
declare -r SCRIPT_HOME=$(pwd)

#Set up defaults
declare -r DEF_KEYMAP="sv-latin1"
declare -r DEF_TIMEZONE="Europe/Stockholm"

#Verify bootmode is legacy
if ls /sys/firmware/efi/efivars > /dev/null 2>&1; then
    echo "[-] Error: EFI bootmode enabled, installer only works in legacy mode" | tee -a $LOG
    exit 1
fi
echo "[+] no EFI bootmode detected, asuming legacy boot" | tee -a $LOG

#Verify internet connection
if ! ping 8.8.8.8 -c 2 2>&1 >/dev/null; then
    echo "[-] Error: no internet connection, terminating script" | tee -a $LOG
    exit 1
fi
echo "[+] Connection sucessfull" | tee -a $LOG

#Update system clock
echo "Updating system clock"
if ! timedatectl set-ntp true 2>&1 >/dev/null; then
    echo "[!] Failed to enable NTP client" | tee -a $LOG
else
    echo "[+] NTP client enabled" | tee -a $LOG
fi

#Partition disks
clear
echo "DISK PARTITIONING"
echo "press any key to continue.."
read key
cfdisk

#Format partitions
clear
echo "PARTITION FORMATING"

lsblk | grep part > /tmp/partsFull1234
cat /tmp/partsFull1234 | cut -d " " -f 1 | cut -c 7- > /tmp/partsCut1234

mapfile -t partsCutArray < /tmp/partsCut1234
mapfile -t partsFullArray < /tmp/partsFull1234

echo "your partition table: "
echo ""
lsblk 
echo ""
echo "Choose partition formats, valid options are [ext4, swap, fat32] default is ext4:"
counter=0
for i in "${partsFullArray[@]}"; do
    read -p "$i FORMAT: " format_inp
    case $format_inp in
	ext4)
	    mkfs.ext4 /dev/${partsCutArray[$counter]} > /dev/null
	    (( counter++ ))
	    ;;
	swap)
	    mkswap /dev/${partsCutArray[$counter]} > /dev/null
	    (( counter++ ))
	    ;;
	fat32)
	    mkfs.vfat /dev/${partsCutArray[$counter]} > /dev/null
	    (( counter++ ))
	    ;;
	*)
	    mkfs.ext4 /dev/${partsCutArray[$counter]} > /dev/null
	    (( counter++ ))
    esac
done

#Mount filesystems
clear
echo "MOUNTING FILESYSTEMS"
counter=0
echo "Enter mountpoint for each partition. Just press enter to skip current partition. Ex: /boot "
for i in "${partsFullArray[@]}"; do
    read -p "$i MOUNTPOINT: " mpoint_inp
    if [ ${#mpoint_inp} -gt 0 ]; then
	mkdir -p "/mnt$mpoint_inp"
	mount /dev/${partsCutArray[$counter]} "/mnt/$mpoint_inp"
	(( counter++ ))
    fi
done

#Install base packages
clear
echo "INSTALLING BASE PACKAGES"
if ! pacstrap /mnt base; then
    echo "[-] Failed to install base packages" | tee -a $LOG
    exit 1
else
    echo "[+] Base packages installed successfully" | tee -a $LOG
fi

#Create fstab
clear
echo "GENERATING FSTAB"
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo "[-] Failed to generate fstab" | tee -a $LOG
    exit 1
else
    echo "[+] fstab generated successfully" | tee -a $LOG
fi

#Chroot into new system
clear
echo "CHROOTING INTO NEW SYSTEM"
cp $SCRIPT_HOME/chroot-conf.sh /mnt/ &&
arch-chroot /mnt ./chroot-conf.sh &&

#End message
clear
echo "END MESSAGE"
echo "[+] Arch has been successfully installed!, please reboot your system.." | tee -a $LOG



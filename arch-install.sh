#!/bin/bash

##########################################################
#  +++++++++ Indeedion Arch Installer V.0 ++++++++++     #
#                                                        #
#  Author: Magnus Jansson                                #
#  Email: mengus00@gmail.com				 #
#  Source: https://github.com/indeedion/arch-install     #
#                                                        #
##########################################################

#Set up log file
declare -r LOG=$(pwd)"/install.log"

#Set up script home
declare -r SCRIPT_HOME=$(pwd)

#Load keymap
read -p "Choose keymap file, example sv-latin1: " kmap
if ! loadkeys $kmap; then
    echo "[!] keymap file not found or not running as root, using default keymap" | tee -a $LOG
fi

#Verify bootmode is legacy
echo "Checking bootmode.."
if ls /sys/firmware/efi/efivars 2>&1 >/dev/null; then
    echo "[-] Error: EFI bootmode enabled, this script only works for legacy mode and MBR" | tee -a $LOG
    exit 1
fi
echo "[+] EFI bootmode not detected, asuming legacy boot" | tee -a $LOG

#Verify internet connection
echo "Verifying internet connection.."
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

read -p "Choose timezone: " tzone
if ! timedatectl set-timezone $tzone; then
    echo "[!] Timezone not found, using default" | tee -a $LOG
else
    echo "[+] Timezone set to $tzone" | tee -a $LOG
fi

#Partition disk
read -p "Choose size for /boot partiion(MiB): " BOOT_SIZE
read -p "Choose size for Swap partition(GiB): " SWAP_SIZE
read -p "Choose size for / partition(GiB): " ROOT_SIZE
if ! sfdisk /dev/sda <<EOF
,${BOOT_SIZE}MiB,83,*
,${SWAP_SIZE}GiB,82
,${ROOT_SIZE}GiB,83
,,83
EOF
then
    echo "[-] Partitioning failed" | tee -a $LOG
    exit 1
else
    echo "[+] Partitioning succeeded" | tee -a $LOG
    fdisk -l | tee -a $LOG
fi

#Format partitions
echo "Formatting partitions.."
if ! mkfs.ext4 /dev/sda1; then
    echo "[-] mkfs failed to format sda1 to ext4" | tee -a $LOG
else
    echo "[+] sda1 formatted to ext4" | tee -a $LOG
fi

if ! mkswap /dev/sda2; then
    echo "[!] mkswap formatting failed on sda2" | tee -a $LOG
else
    echo "[+] sda2 formatted to swap" | tee -a $LOG
fi

if ! mkfs.ext4 /dev/sda3; then
    echo "[-] mkfs failed to format sda3 to ext4" | tee -a $LOG
else
    echo "[+] sda3 formatted to ext4" | tee -a $LOG
fi

if ! mkfs.ext4 /dev/sda4; then
    echo "[-] mkfs failed to format sda4 to ext4" | tee -a $LOG
else
    echo "[+] sda4 formatted to ext4" | tee -a $LOG
fi

#Mount filesystems
echo "Mounting filesystems.."
mkdir -p /mnt/boot &&
echo "[+] Created /mnt/boot successfully" | tee -a $LOG
mkdir -p /mnt/home &&
echo "[+] Created /mnt/home successfully" | tee -a $LOG

exit 1

if ! mount /dev/sda1 /mnt/boot; then
    echo "[!] Failed to mount sda1 /mnt/boot" | tee -a $LOG
    exit 1
else
    echo "[+] sda1 mounted to /mnt/boot" | tee -a $LOG
fi

if ! mount /dev/sda3 /mnt; then
    echo "[-] Failed to mount sda3 to /mnt/" | tee -a $LOG
    exit 1
else
    echo "[+] sda3 mounted to /mnt/" | tee -a $LOG
fi

if ! mount /dev/sda4 /mnt/home; then
    echo "[-] Failed to mount sda4 to /mnt/home" | tee -a $LOG
    exit 1
else
    echo "[+] sda4 mounted to /mnt/home" | tee -a $LOG
fi

#Install base packages
if ! pacstrap /mnt base; then
    echo "[-] Failed to install base packages" | tee -a $LOG
    exit 1
else
    echo "[+] Base packages installed successfully" | tee -a $LOG
fi

#Create fstab
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo "[-] Failed to generate fstab" | tee -a $LOG
    exit 1
else
    echo "[+] fstab generated successfully" | tee -a $LOG
fi

#Chroot into new system
echo "Chrooting into new system.." | tee -a $LOG
cp $SCRIPT_HOME/chroot-conf.sh /mnt/ &&
arch-chroot /mnt ./chroot-conf.sh &&

#End message
echo "[+] Arch has been successfully installed!, please reboot your system.." | tee -a $LOG



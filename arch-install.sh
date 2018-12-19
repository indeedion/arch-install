#!/bin/bash

##########################################################
#  +++++++++ Indeedion Arch Installer V.0 ++++++++++     #
#                                                        #
#  Author: Magnus Jansson                                #
#  Email: mengus00@gmail.com				 #
#  Source: https://github.com/indeedion/arch-install     #
#                                                        #
##########################################################

#Load keymap
read -p "Choose keymap file: " kmap
if ! loadkeys $kmap; then
    echo "[!] keymap file not found or not running as root, using default keymap"
fi

#Verify bootmode is legacy
echo "Checking bootmode.."
if ls /sys/firmware/efi/efivars 2>&1 >/dev/null; then
    echo "[-] Error: EFI bootmode enabled, this script only works for legacy mode and MBR"
    exit 1
fi
echo "[+] EFI bootmode not detected, asuming legacy boot"

#Verify internet connection
echo "Verifying internet connection.."
if ! ping 8.8.8.8 -c 2 2>&1 >/dev/null; then
    echo "[-] Error: no internet connection, terminating script"
    exit 1
fi
echo "[+] Connection sucessfull"

#Update system clock
echo "Updating system clock"
if ! timedatectl set-ntp true 2>&1 >/dev/null; then
    echo "[!] Failed to enable NTP client"
else
    echo "[+] NTP client enabled"
fi

read -p "Choose timezone: " tzone
if ! timedatectl set-timezone $tzone; then
    echo "[!] Timezone not found, using default"
else
    echo "[+] Timezone set to $tzone"
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
    echo "[-] Partitioning failed"
    exit 1
else
    echo "[+] Partitioning succeeded"
    fdisk -l
fi


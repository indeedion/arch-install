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

#Format partitions
echo "Formatting partitions.."
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
echo "Done"

#Mount filesystems
echo "Mounting filesystems.."
mkdir -p /mnt/boot
mkdir -p /mnt/home
if ! mount /dev/sda1 /mnt/boot/; then
    echo "[!] Failed to mount sda1 /boot"
else
    echo "[+] sda1 mounted to /boot"
fi

if ! mount /dev/sda3 /mnt/; then
    echo "[-] Failed to mount sda3 to /"
    exit 1
else
    echo "[+] sda3 mounted to /"
fi

if ! mount /dev/sda4 /mnt/home/; then
    echo "[!] Failed to mount sda4 to /home"
else
    echo "[+] sda4 mounted to /home"
fi

#Install base packages
if ! pacstrap /mnt base; then
    echo "[-] Failed to install base packages"
else
    echo "[+] Base packages installed successfully"
fi

#Create fstab
if ! genfstab -U /mnt >> /mnt/etc/fstab; then
    echo "[!] Failed to generate fstab"
else
    echo "[+] fstab generated successfully"
fi

#Chroot into new system
echo "Chrooting into new system.."
arch-chroot /mnt

#Configure new system
if ! ln -sf /usr/share/zoneinfo/europe/Stockholm /etc/localtime; then
    echo "[!] Failed to set localtime"
else
    echo "[+] Local time set successfully"
fi

if ! hwclock --systohc; then
    echo "[!] Failed to set hardware clock"
else
    echo "[+] Hardware clock set successfully"
fi

#Uncomment needed locals
if ! sed -i '/^#.* en_US.UTF-8 /s/^#//' /etc/locale.gen; then
    echo "[!] Failed to uncomment locale in /etc/locale.gen"
else
    echo "[+] Uncommented line en_us.UTF-8 in /etc/locale.gen"
fi

if ! sed -i '/^#.* en_US ISO-8859-1 /s/^#//' /etc/locale.gen; then
    echo "[!] Failed to uncomment line en_US ISO-8859-1 in /etc/locale.gen"
else
    echo "[+] Uncommented line en_US ISO-8859-1 in /etc/locale.gen"
fi

#Generate locals
if ! locale-gen; then
    echo "[!] Failed to generate locals"
else
    echo "[+] Locals generated successfully"
fi

#Set language
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "[+] Language locale set successfully in /etc/locale.conf"

#Set keymap
read -p "Choose keymap for new system: " nkeymap
echo "KEYMAP=$nkeymap" >> /etc/vconsole.conf
echo "[+] Keymap $nkeymap set successfully in /etc/vconsole.conf"

#Network configuration
read -p "Choose hostname: " hname 
echo "$hname" >> /etc/hostname
echo "[+] hostname set successfully"
echo "127.0.0.1	    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.1.1	    $hname.localdomain $hname" >> /etc/hosts
echo "[+] Hostname set to $hname"
echo "[+] Localhost set to defaults in /etc/hosts"

#Set root password
passwd

#Install grub
echo "Installing grub.."
pacman -S grub

#Configure grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub.cfg
echo "[+] grub installed successfully"

#Exit chroot environment
echo "Exiting chroot environment.."
echo -e "exit"
cd

#End message
echo "[+] Arch has been successfully installed!, please reboot your system.."



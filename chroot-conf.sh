#!/bin/bash

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
    echo "[+] Uncommented line en_US.UTF-8 in /etc/locale.gen"
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



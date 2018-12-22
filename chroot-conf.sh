#!/bin/bash

#Set up log file
declare -r LOG="/arch-install.log"

#Configure new system
if ! ln -sf /usr/share/zoneinfo/europe/Stockholm /etc/localtime; then
    echo "[!] Failed to set localtime" | tee -a $LOG
else
    echo "[+] Local time set successfully" | tee -a $LOG
fi

if ! hwclock --systohc; then
    echo "[!] Failed to set hardware clock" | tee -a $LOG
else
    echo "[+] Hardware clock set successfully" | tee -a $LOG
fi

#Uncomment needed locals
if ! sed -i '/^#.* en_US.UTF-8 /s/^#//' /etc/locale.gen; then
    echo "[!] Failed to uncomment locale in /etc/locale.gen" | tee -a $LOG
else
    echo "[+] Uncommented line en_US.UTF-8 in /etc/locale.gen" | tee -a $LOG
fi

if ! sed -i '/^#.* en_US ISO-8859-1 /s/^#//' /etc/locale.gen; then
    echo "[!] Failed to uncomment line en_US ISO-8859-1 in /etc/locale.gen" | tee -a $LOG
else
    echo "[+] Uncommented line en_US ISO-8859-1 in /etc/locale.gen" | tee -a $LOG
fi

#Generate locals
if ! locale-gen; then
    echo "[!] Failed to generate locals" | tee -a $LOG
else
    echo "[+] Locals generated successfully" | tee -a $LOG
fi

#Set language
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "[+] Language locale set successfully in /etc/locale.conf" | tee -a $LOG

#Set keymap
read -p "Choose keymap for new system: " nkeymap
echo "KEYMAP=$nkeymap" >> /etc/vconsole.conf
echo "[+] Keymap $nkeymap set successfully in /etc/vconsole.conf" | tee -a $LOG

#Network configuration
read -p "Choose hostname: " hname 
echo "$hname" >> /etc/hostname
echo "[+] hostname set successfully" | tee -a $LOG
echo "127.0.0.1	    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.1.1	    $hname.localdomain $hname" >> /etc/hosts
echo "[+] Hostname set to $hname" | tee -a $LOG
echo "[+] Localhost set to defaults in /etc/hosts" | tee -a $LOG

#Set root password
echo "Choose root password: "
$(passwd) | tee -a $LOG

#Install grub
echo "Installing grub.."
pacman -S grub

#Configure grub
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
echo "[+] grub installed successfully" | tee -a $LOG

#Exit chroot environment
echo "Exiting chroot environment.." | tee -a $LOG
echo -e "exit"



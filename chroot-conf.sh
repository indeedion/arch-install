#!/bin/bash

#Set up log file
declare -r LOG="/arch-install.log"

#Set up defaults
declare -r DEF_LOCALTIME="America/New_York"
declare -r DEF_LOCALE="en_US.UTF-8 UTF-8"
declare -r DEF_KEYMAP="us"

#Configure new system
clear
echo "CHOOSE YOUR LOCALTIME"
echo "Choose localtime by entering a number from the list"
echo "Default is $DEF_LOCALTIME"
echo "1.Europe/Stockholm"
echo "2.Europe/Dublin"
echo "3.Europe/Amsterdam"

read -p "> " time_inp
case $time_inp in
    1)
	loctime="Europe/Stockholm"
	;;
    2)
	loctime="Europe/Dublin"
	;;
    3)
	loctime="Europe/Amsterdam"
	;;
    *)
	loctime="$DEF_LOCALTIME"
	;;
esac

if ! ln -sf /usr/share/zoneinfo/$loctime /etc/localtime; then
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
clear
echo "CHOOSE LOCALE"
echo "Choose as many locales as you want by entering a number from the list"
echo "Default is $DEF_LOCALE, just press enter to choose this"
loop_run=true
while [ "$loop_run" = true ]; do
    echo "1.Enter a locale"
    echo "2.Done entering locales"
    echo "3.List available locales"
    read -p "> " locale_menu_inp

    locale_array=()
    case $locale_menu_inp in
	1)
	    read -p "Locale: " locale_inp
	    sed -i "/^#.* $locale_inp /s/^#//" /etc/locale.gen
	    ;;
	2)
	    loop_run=false
	    ;;
	3)
	    less /etc/locale.gen
	    ;;
	*)
	    sed -i "/^#.* $DEF_LOCALE /s/^#//" /etc/locale.gen
	    loop_run=false
	    ;;
    esac
done

#Generate locals
clear
echo "GENERATING LOCALES"
if ! locale-gen; then
    echo "[!] Failed to generate locals" | tee -a $LOG
else
    echo "[+] Locals generated successfully" | tee -a $LOG
fi

#Set language
clear
localectl list-locales > /tmp/localesdef1234
mapfile -t locales_avail < /tmp/localesdef1234
echo "CHOOSE YOUR LANGUAGE"
echo "Choose from available language locales below"
counter=1
for i in "${locales_avail[@]}"; do
    echo "$counter.$i"
    (( counter++ ))
done
read -p "> " lang_inp
localectl set-locale "LANG=$lang_inp"

#Set keymap
clear
echo "CHOOSE KEYMAP"
echo "Choose option to enter keymap, or list available keymaps to choose from, default(Enter) is \"us\""
loop_run=true
while [ "$loop_run" = true ]; do
    echo "1.Enter keymap"
    echo "2.List keymaps"

    read -p "> " keymap_menu_inp
    case $keymap_menu_inp in
	1)
	    read -p "Keymap: " keymap_inp
	    loadkeys $keymap_inp 
	    echo "KEYMAP=$keymap_inp" >> /etc/vconsole.conf
	    loop_run=false
	    ;;
	2)
	    localectl list-keymaps
	    ;;
	*)
	    loadkeys $DEF_KEYMAP
	    echo "KEYMAP=$DEF_KEYMAP" >> /etc/vconsole.conf
	    loop_run=false
	    ;;
    esac
done

#Network configuration
clear
echo "CHOOSE HOSTNAME"
echo ""
read -p "Choose hostname: " hname 
echo "$hname" >> /etc/hostname
echo "[+] hostname set successfully" | tee -a $LOG
echo "127.0.0.1	    localhost" >> /etc/hosts
echo "::1    localhost" >> /etc/hosts
echo "127.0.1.1	    $hname.localdomain $hname" >> /etc/hosts
echo "[+] Hostname set to $hname" | tee -a $LOG
echo "[+] Localhost set to defaults in /etc/hosts" | tee -a $LOG

#Set root password
echo "Choose root password!! "
$(passwd) | tee -a $LOG


function inst_grub(){

    #Install grub
    echo "Installing grub.."
    pacman -S grub

    #Configure grub
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
    echo "[+] grub installed successfully" | tee -a $LOG
}

function inst_syslinux(){
    #install syslinux
    echo "Installing syslinux.."
    if ! pacman -S syslinux; then
	echo "[-] Syslinux not found in repository!" | tee -a $LOG
	exit 1
    else
	if ! syslinux-install_update -iam; then
	    echo "[-] Syslinux update failed!" | tee -a $LOG
	    exit 1
	fi
	echo "[+] syslinux installed correctly" | tee -a $LOG
	echo "[+] syslinux updated correctly" | tee -a $LOG
    fi
}

function query_bootloader(){
    #choose bootloader
    clear
    echo "CHOOSE BOOLOADER"
    echo "Choose prefered bootloader from the list below"
    echo "1.Grub"
    echo "2.Syslinux"
    read -p "> " btload
	
    case $btload in
    	1)
    	    inst_grub  ;;
    	2)
    	    inst_syslinux ;;
    	*)
    	    inst_grub ;;
    esac
}

query_bootloader

#Exit chroot environment
clear
echo "Exiting chroot environment.." | tee -a $LOG
echo -e "exit"


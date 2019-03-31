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
echo "" > $LOG

#Set up script home
declare -r SCRIPT_HOME=$(pwd)

#Set up defaults
declare -r DEF_KEYMAP="sv-latin1"
declare -r DEF_TIMEZONE="Europe/Stockholm"

#dialog globals
BACK_TITLE="BDOGZ ARCH INSTALLER"

#dialog functions
function errbox() {
    TITLE="ERROR!"
    HEIGHT=15
    WIDTH=40
    ERROR="$1"

    dialog --clear \
	   --backtitle "$BACK_TITLE" \
	   --title "$TITLE" \
	   --msgbox "$ERROR" \
           $HEIGHT $WIDTH
    
   echo "$ERROR" >> $LOG
}

function msgbox() {
    TITLE="MESSAGE!"
    HEIGHT=15
    WIDTH=40
    MESSAGE=$1

    dialog --clear \
	   --backtitle "$BACK_TITLE" \
	   --title "$TITLE" \
	   --msgbox "$MESSAGE" \
	   $HEIGHT $WIDTH
}

#Load keymap
INPUT=/tmp/lang.sh.$$
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
TITLE="Keyboard Layout"
MENU="Choose your keyboard layout:"

OPTIONS=(1 "Swedish - QWERTY"
         2 "USA! USA! - QWERTY")

dialog --clear \
       --backtitle "$BACK_TITLE" \
       --title "$TITLE" \
       --menu "$MENU" \
       $HEIGHT $WIDTH $CHOICE_HEIGHT \
       "${OPTIONS[@]}" \
       2>"${INPUT}"

res=$(cat /tmp/lang.sh.$$)

case $res in
    1)
        loadkeys sv-latin1
        echo "sv-latin1" > /etc/vconsole.conf 
        ;;
    2)
        loadkeys us
        echo "us" > /etc/vconsole.conf
        ;;
    *)
        loadkeys $DEFAULT_LANG
        echo "$DEF_KEYMAP" > /etc/vconsole.conf
        ;;
esac

#Verify bootmode is legacy
if ls /sys/firmware/efi/efivars 2>&1 >/dev/null; then
    err="[-] Error: EFI bootmode enabled, installer only works in legacy mode"
    errbox "$err"
    exit 1
fi
echo "[+] EFI bootmode not detected, asuming legacy boot" >> $LOG

#Verify internet connection
if ! ping 8.8.8.8 -c 2 2>&1 >/dev/null; then
    err="[-] Error: no internet connection, terminating script"
    errbox "$err"
    exit 1
fi
echo "[+] Connection sucessfull" >> $LOG

#Update system clock
echo "Updating system clock"
if ! timedatectl set-ntp true 2>&1 >/dev/null; then
    errbox "[!] Failed to enable NTP client"
else
    echo "[+] NTP client enabled" >> $LOG
fi

#Choose timezone
INPUT=/tmp/timez.sh.$$
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
TITLE="TIMEZONE"
MENU="Choose your timezone:"

OPTIONS=(1 "Europe/Stockholm"
	 2 "Europe/Berlin")

dialog --clear \
       --backtitle "$BACK_TITLE" \
       --title "$TITLE" \
       --menu "$MENU" \
       $HEIGHT $WIDTH $CHOICE_HEIGHT \
       "${OPTIONS[@]}" \
       2>"${INPUT}"

res=$(cat $INPUT)

case $res in
    1)
	timedatectl set-timezone "Europe/Stockholm"
	;;
    2)
	timedatectl set-timezone "Europe/Berlin"
	;;
    *)
	timedatectl set-timezone "Europe/Stockholm"
	;;
esac 


#Partition disks
msgbox "Lets partition some stuff, press OK to continue"
cfdisk

#Format partitions
#Might not be neccesary

#Mount filesystems



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



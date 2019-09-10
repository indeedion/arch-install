
import curses
import time
from enum import IntEnum
from ascii_draw import AsciiDraw
from menu import Menu
from inputs import Inputs
from welcome_screen import WelcomeScreen
from screen import Screen
from arch_install import ArchInstall
#res = ''
#with Sultan.load() as s:
#    res = s.ls().pipe().grep("arch").run()

class Choice(IntEnum):
    ARCH = 0
    BROWN_ARCH = 1

def main(stdscr):
    # Create screen manager
    screen = Screen.getInstance()
    screen.init_screen_manager(stdscr)

    # Create and run welcome screen
    welcome_screen = WelcomeScreen()
    choice = welcome_screen.run()

    # If user chooses to install only arch
    if choice == Choice.ARCH:
        a_install = ArchInstall()
        a_install.run()
    # If user chooses to install brownarch
    elif choice == Choice.BROWN_ARCH:
        pass
        
curses.wrapper(main)

#Set up log file

#Set up script home

#Set up defaults

#Verify bootmode is legacy

#Verify internet connection

#Update system clock

#Partition disks

#Format partitions

#Mount filesystems

#Install base packages

#Create fstab

#Chroot into new system, and run chroot script

#End message





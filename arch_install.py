import curses
import os
import subprocess
from screen import Screen
from menu import Menu
import time
from urllib.request import urlopen

screen = Screen.getInstance()

class Rect():
    def __init__(self, y, x, h, w):
        self.y = y
        self.x = x
        self.h = h
        self.w = w

class ArchInstall():

    #Set up defaults
    DEF_KEYMAP="sv-latin1"
    DEF_TIMEZONE="Europe/Stockholm"
    LOG_FILE = "arch_install_log.txt"

    def __init__(self):
        self.area_a = Rect(
            0,
            0,
            screen.h,
            int(screen.w * 0.3)
        )
        self.area_b = Rect(
            0,
            screen.w * 0.3 + 1,
            screen.h,
            screen.w - screen.w * 0.3 + 1
        )

        self.steps = [
            "Verify Bootmode",
            "Verify Internet",
            "Partition Disks",
            "Format Partitions",
            "Mount Filesystems",
            "Install Base Packages"
        ]

        self.left_menu = Menu(screen.stdscr, self.steps)

        self.right_screen_msgs = []
    
    def draw_left_screen(self):
        a = self.area_a
        b = self.area_b

        for i in range(a.h):
            for j in range(a.w):
                screen.stdscr.addstr(i, j, "█")

        screen.stdscr.attron(curses.color_pair(2))
        self.left_menu.print_menu(a.y + 3, a.x + 1)
        screen.stdscr.attron(curses.color_pair(1))

    def draw_right_screen(self):
        b = self.area_b
        y = int(b.y + 3)
        x = int(b.x + 1)

        for i, msg in enumerate(self.right_screen_msgs):
            screen.stdscr.attron(curses.color_pair(1))
            screen.stdscr.addstr(y + i, x, msg)

    def log(self, msg):
        f = open(LOG_FILE, 'a')
        f.write(str(msg))
        f.close()

    def verify_bootmode(self):
        s_row = self.left_menu.selected_row
        # check for efi folder
        if os.path.exists("/sys/firmware/efi"):
            self.right_screen_msgs.append("""It appears the computer is booted with EFI, 
                we dont support EFI""")
            self.update_screen()
            return False
        else:
            self.right_screen_msgs.append("Legacy boot mode verified")
            self.left_menu.selected_row += 1
            self.update_screen()
            return True

    def verify_internet(self):
        try:
            response = urlopen('https://www.google.com/', timeout=10)
            self.right_screen_msgs.append("Internet connection verified")
            self.left_menu.selected_row += 1
            self.update_screen()
            return True
        except:
            self.right_screen_msgs.append("Internet connection failed")
            self.update_screen()
            return False
        
    def add_to_right_screen(self, msg):
        s_row = self.left_menu.selected_row
        screen.stdscr.addstr(
                int(self.area_b.y + s_row + 3), 
                int(self.area_b.x + 3), 
                msg)

    def update_screen(self):
        screen.stdscr.clear()
        self.draw_left_screen()
        self.draw_right_screen()
        screen.stdscr.refresh()

    def failure_screen(self, msg):
         screen.stdscr.clear()
         y = screen.cy
         x = screen.cx
         screen.stdscr.addstr(
             y, x, msg
         )
         screen.stdscr.refresh()

    def run(self):

        # Clear and update screen
        screen.stdscr.clear()
        self.update_screen()

        # Verify Bootmode is legacy
        time.sleep(1)
        res = self.verify_bootmode()
        if not res:
            pass
            
        # Verify internet connection
        res = self.verify_internet()
        if not res:
           pass

        # Update system clock
        res = os.popen('timedatectl set-ntp true 2>&1 >/dev/null').read()

        # Partition disks
        subprocess.call('cfdisk', shell=False)
        screen.stdscr.clear()
        self.update_screen()

        time.sleep(5)




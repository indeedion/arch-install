import curses
import os
import subprocess
from screen import Screen
from menu import Menu
import time
from urllib.request import urlopen
from inputs import Inputs
from enum import Enum

screen = Screen.getInstance()
inputs = Inputs.getInstance()

class FileFormats(Enum):
    EXT3  = 0
    EXT4  = 1
    SWAP  = 2
    FAT32 = 3
    NTFS  = 4

class MountPoints(Enum):
    BOOT = 0
    HOME = 1
    ROOT = 2
    USR  = 3
    TMP  = 4
    VAR  = 5
    NONE = 6

class FormatAttrs():
    def __init__(self, part, f_format, m_point):
        self.part = part
        self.format = f_format
        self.m_point = m_point

class ArchInstall():
    #Set up defaults
    DEF_KEYMAP="sv-latin1"
    DEF_TIMEZONE="Europe/Stockholm"
    LOG_FILE = "arch_install_log.txt"

    def __init__(self):
        self.steps = [
            "Verify Bootmode",
            "Verify Internet",
            "Partition Disks",
            "Format Partitions",
            "Mount Filesystems",
            "Install Base Packages"
        ]

        self.success = []
        self.left_menu = Menu(screen.screen_l, self.steps)

        self.p_formats = (
            "ext3",
            "ext4",
            "swap",
            "fat32",
            "ntfs"
        )

        self.m_points = (
            "/boot",
            "/home",
            "/",
            "/usr",
            "/tmp",
            "/var",
            "none"
        )
    
    def draw_right_screen(self):
        b = screen.area_b
        screen.screen_r.attron(curses.color_pair(2))
        for i in range(int(b.h)):
            for j in range(int(b.w) -1):
                screen.screen_r.addstr(i, j, "█")
        #screen.screen_r.attron(curses.color_pair(1))

    def draw_left_screen(self):

        a = screen.area_a
        screen.screen_l.attron(curses.color_pair(1))
        for i in range(a.h):
            for j in range(a.w -1):
                screen.screen_l.addstr(i, j, "█")

        self.draw_headline(
            screen.screen_l,
            "INSTALLING ARCH LINUX:",
            2
        )

        self.left_menu.print_menu(a.y + 3, a.x + 1)
        #screen.screen_l.attron(curses.color_pair(2))

    def draw_success(self):
        y = screen.area_a.y + 3
        x = screen.area_a.w - 4
        for i, step in enumerate(self.success):
            screen.screen_l.attron(curses.color_pair(2))
            screen.screen_l.addstr(
                int(y + i), 
                int(x), 
                step)
            screen.screen_l.attron(curses.color_pair(1))

    def log(self, msg):
        f = open(LOG_FILE, 'a')
        f.write(str(msg))
        f.close()

    def verify_bootmode(self):
        s_row = self.left_menu.selected_row
        # check for efi folder
        if os.path.exists("/sys/firmware/efi"):
            self.success.append('!')
            self.update_screen_l()
            return False
        else:
            self.success.append('ok')
            self.left_menu.selected_row += 1
            self.update_screen_l()
            return True

    def verify_internet(self):
        try:
            response = urlopen('https://www.google.com/', timeout=10)
            self.left_menu.selected_row += 1
            self.success.append('ok')
            self.update_screen_l()
            return True
        except:
            self.success.append('!')
            self.update_screen_l()
            return False

    def partition_disks(self):
        subprocess.call('cfdisk', shell=False)
        self.success.append('ok')
        self.left_menu.selected_row += 1
        screen.screen_l.clear()
        self.update_screen()

    def draw_headline(self, screen, head_msg, color=1):
        h, w = screen.getmaxyx()
        screen.attron(curses.color_pair(color))
        screen.addstr(
            1, 
            w//2 - len(head_msg)//2, 
            head_msg
        )

    def partition_menu(self, partitions):
        parts = partitions
        h, w = screen.screen_r.getmaxyx()
        p_menu = Menu(screen.screen_r, parts)
        exit_items = [
            "Format",
            "Reset"
        ]
        exit_menu = Menu(screen.screen_r, exit_items, active=False)
        active_menu = 0

        screen.screen_r.addstr(3, 3, "partition")
        #screen.screen_r.addstr(4, 3, "---------------")

        while True:
            p_menu.print_menu(5, 3, 2, 1)
            exit_menu.print_horizontal_menu(h - 2, 3, 2, 1)
            screen.screen_r.refresh()

            key = screen.screen.getch()
            inputs.update(key)

            selected_row = p_menu.selected_row
            if key == curses.KEY_DOWN and selected_row == p_menu.menu_len -1:
                active_menu = 1
            elif key == curses.KEY_UP and active_menu == 1:
                active_menu = 0
                exit_menu.set_active(False)

            if active_menu == 0:
                choice = p_menu.update()
                if choice != None:
                    return choice, 0
            elif active_menu == 1:
                exit_menu.set_active(True)
                choice = exit_menu.update()
                if choice != None:
                    return choice, 1

    def format_menu(self):
        f_menu = Menu(screen.screen_r, self.p_formats)
        h, w = screen.screen_r.getmaxyx()

        screen.screen_r.addstr(3, w//3 * 2 -10, "format")
        while True:
            f_menu.print_menu(5, w//3 * 2 -10, 2, 1)
            screen.screen_r.refresh()

            key = screen.screen.getch()
            inputs.update(key)
            choice = f_menu.update()

            if choice != None:
                return choice

    def mount_point_menu(self):
        m_menu = Menu(screen.screen_r, self.m_points)
        h, w = screen.screen_r.getmaxyx()

        screen.screen_r.addstr(3, w//3 * 3 -14, "mount point")

        while True:
            m_menu.print_menu(5, w//3 * 3 -14, 2, 1)
            screen.screen_r.refresh()

            key = screen.screen.getch()
            inputs.update(key)
            choice = m_menu.update()

            if choice != None:
                return choice 

    def do_format(self, choices):
        # format commands
        f_ext3 = 'mkfs.ext3'
        f_ext4 = 'mkfs.ext4'
        f_swap = 'mkswap'
        on_swap = 'swapon -a'
        f_fat32 = 'mkfs.vfat -F 32'
        f_ntfs = 'mkfs.ntfs'

        # loop through choices and format
        for choice in choices:
            part = choice.part
            form = choice.format
            mp = choice.m_point
            path = '/dev/' + part
            
            if form == FileFormats.EXT3:
                os.popen(f_ext3 + ' ' + path)
                os.popen('mkdir -p ' + mp)
                os.popen('mount ' + path + ' ' + mp)
            elif form == FileFormats.EXT4:
                os.popen(f_ext4 + ' ' + path)
                os.popen('mkdir -p ' + mp)
                os.popen('mount ' + path + ' ' + mp)
            elif form == FileFormats.SWAP:
                os.popen(f_swap + ' ' + path)
                os.popen(on_swap + ' ' + path)
            elif form == FileFormats.FAT32:
                os.popen(f_fat32 + ' ' + path)
                os.popen('mkdir -p ' + mp)
                os.popen('mount ' + path + ' ' + mp)
            elif form == FileFormats.NTFS:
                os.popen(f_ntfs + ' ' + path)
                os.popen('mkdir -p ' + mp)
                os.popen('mount ' + path + ' ' + mp)
         
    def format_partitions(self):
        parts = self.get_partitions()
        screen.screen_r.clear()
        h, w = screen.screen_r.getmaxyx()

        choices = []
        while True:
            screen.screen_r.clear()
            self.draw_headline(
            screen.screen_r, 
            "FORMAT PARTITIONS:", 
            1)

            screen.screen_r.addstr(14, 3, "current configuration")
            for i, choice_attr in enumerate(choices):
                part = parts[choice_attr.part]
                form = self.p_formats[choice_attr.format]
                mount = self.m_points[choice_attr.m_point]
                choice = part + ' ' + form + ' ' + mount
                screen.screen_r.addstr(
                    16 + i,
                    3,
                    choice
                )

            partition_choice, menu_active = self.partition_menu(parts)
            if menu_active == 0:
                #this is from the partition menu
                pass
            elif menu_active == 1:
                #this is from the exit menu
                if partition_choice == 0:
                    #user pressed format
                    self.do_format(choices)
                    break
                elif partition_choice == 1:
                    #user pressed reset
                    choices.clear()
                    continue
                    
            format_choice = self.format_menu()
            mount_point_choice = self.mount_point_menu()
            format_choice = FormatAttrs(
                partition_choice,
                format_choice,
                mount_point_choice
            )
            
            found = False
            idx = 0
            for i, choice in enumerate(choices):
                if choice.part == partition_choice:
                    found = True
                    idx = i

            if found:
                choices[idx] = format_choice
            else:
                choices.append(format_choice)
                
            screen.screen_r.refresh()

        self.success.append('ok')
        self.left_menu.selected_row += 1
        screen.screen_l.clear()
        self.update_screen()

    def update_screen_l(self):
        screen.screen_l.clear()
        self.draw_left_screen()
        self.draw_success()
        screen.screen_l.refresh()

    def update_screen_r(self):
        #screen.screen_r.clear()
        #self.draw_right_screen()
        screen.screen_r.refresh()

    def update_screen(self):
        self.update_screen_l()
        self.update_screen_r()

    def get_partitions(self):    
        res = os.popen('lsblk | grep ─').read()
        res = res.replace('─', '')
        res = res.replace('└', '')
        res = res.replace('├', '')
        res = res.replace('   ', ' ')
        res = res.replace('  ', ' ')
        res = res.replace('  ', ' ')
        
        parts = res.split('\n')

        for part in parts.copy():
            if part == '':
                parts.remove(part)

        for i, part in enumerate(parts):
            spl = part.split(' ')
            res = spl[0] + "{:>10s}".format(spl[3])
            parts[i] = res

        return parts

    def run(self):

        # Clear and update screen
        screen.screen_l.clear()
        screen.screen_r.clear()
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
        self.partition_disks()

        # Format partitions
        self.format_partitions()
        time.sleep(5)




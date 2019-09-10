import curses
import time
from ascii_draw import AsciiDraw
from menu import Menu
from inputs import Inputs
from screen import Screen

inputs = Inputs.getInstance()
screen = Screen.getInstance()

class WelcomeScreen():
    def __init__(self):
        self.stdscr = screen.stdscr
        self.welcome_msg = "Welcome to Brown-Arch Installer 1.0"
        
        # Create ascii-dog
        self.dog = AsciiDraw(self.stdscr, "ascii_logo")

        self.init_curses_attributes()

        # Define menu items
        self.menu = ["Install Arch", "Install Brown-Arch"]

        # Create first screen menu
        self.welcome_menu = Menu(self.stdscr, self.menu)

        # Get terminal height, width and center x,y
        self.h, self.w, self.cy, self.cx = screen.get_scr_attribs()

    def init_curses_attributes(self):
        # Init default text color
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        self.stdscr.attron(curses.color_pair(1))

        # Init default menu choice color
        curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_GREEN)

        # Hide cursor
        curses.curs_set(0)

    def print_welcome(self, stdscr, y, x, msg):
        stdscr.addstr(int(y), int(x), msg)

    def print_frame(self, stdscr, h, w):
        h = h - 2
        w = w - 2
        for i in range(h):
            stdscr.addstr(i + 1, 0, "#")
            stdscr.addstr(i + 1, w + 1, "#")

        for i in range(w):
            stdscr.addstr(0, i + 1, "#")
            stdscr.addstr(h + 1, i + 1, "#")

    def run(self):

        stdscr = self.stdscr
        w = self.w
        h = self.h
        cy = self.cy
        cx = self.cx
        welcome = self.welcome_msg
        welcome_menu = self.welcome_menu

        while True:
            key = self.stdscr.getch()

            if key in [27, 113]:
                break
            
            self.stdscr.clear()
            inputs.update(key)
            
            self.print_welcome(
                stdscr, cy / 4, cx - int(len(welcome)//2), welcome)
            self.dog.draw(welcome_menu.menu_len)
            self.print_frame(stdscr, h, w)
            choice = welcome_menu.update()
                
            welcome_menu.print_centered_menu()
            
            stdscr.refresh()

            if choice != None:
                return choice

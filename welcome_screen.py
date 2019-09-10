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
        self.welcome_msg = "Welcome to Brown-Arch Installer 1.0"
        
        # Create ascii-dog
        self.dog = AsciiDraw(screen.screen, "ascii_logo")

        self.init_curses_attributes()

        # Define menu items
        self.menu = ["Install Arch", "Install Brown-Arch"]

        # Create first screen menu
        self.welcome_menu = Menu(screen.screen, self.menu)

        # Get terminal height, width and center x,y
        self.h, self.w, self.cy, self.cx = screen.get_scr_attribs()

    def init_curses_attributes(self):
        # Init default text color
        curses.init_pair(1, curses.COLOR_GREEN, curses.COLOR_BLACK)
        screen.screen.attron(curses.color_pair(1))

        # Init default menu choice color
        curses.init_pair(2, curses.COLOR_BLACK, curses.COLOR_GREEN)

        # Hide cursor
        curses.curs_set(0)

    def print_welcome(self, y, x, msg):
        screen.screen.addstr(int(y), int(x), msg)

    def print_frame(self, h, w):
        h = h - 2
        w = w - 2
        for i in range(h):
            screen.screen.addstr(i + 1, 0, "#")
            screen.screen.addstr(i + 1, w + 1, "#")

        for i in range(w):
            screen.screen.addstr(0, i + 1, "#")
            screen.screen.addstr(h + 1, i + 1, "#")

    def run(self):
        
        w = self.w
        h = self.h
        cy = self.cy
        cx = self.cx
        welcome = self.welcome_msg
        welcome_menu = self.welcome_menu

        while True:
            
            screen.screen.clear()
            
            self.print_welcome(
                cy / 4, cx - int(len(welcome)//2), welcome)
            self.dog.draw(welcome_menu.menu_len)
            self.print_frame(h, w)
            choice = welcome_menu.update()
                
            welcome_menu.print_centered_menu()
            
            screen.screen.refresh()

            key = screen.screen.getch()

            if key in [27, 113]:
                break
            
            inputs.update(key)
            
            if choice != None:
                return choice

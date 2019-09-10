import curses
from inputs import Inputs

inputs = Inputs.getInstance()

class Menu():
    def __init__(self, stdscr,menu_items, y=0, x=0):
        self.menu_items = menu_items
        self.menu_len = len(menu_items)
        self.y = y
        self.x = x
        self.stdscr = stdscr
        self.scr_h, self.scr_w = stdscr.getmaxyx()
        self.selected_row = 0

    def update(self):
        #self.debug_out(self.stdscr, "inputs.up: " + str(inputs.up), self.scr_h)
        if inputs.up and self.selected_row > 0:
            self.selected_row -= 1
          #  self.debug_out(stdscr, "pressing up: " + str(selected_row), h)
        elif inputs.down and self.selected_row < self.menu_len -1:
            self.selected_row += 1
           # self.debug_out(stdscr, "pressing down: " + str(selected_row), h)
        elif inputs.enter:
            return self.selected_row
           # self.debug_out(stdscr, "pressing enter: " + str(selected_row), h)
        return None

    def print_menu(self, y, x):
        w = self.scr_w
        h = self.scr_h
        m_length = self.menu_len
        stdscr = self.stdscr
        selected_row = self.selected_row

        for i, row in enumerate(self.menu_items):
            if i == selected_row:
                stdscr.attron(curses.color_pair(1))
                stdscr.addstr(y + i, x, row)
            else:
                stdscr.attron(curses.color_pair(2))
                stdscr.addstr(y + i, x, row)
                stdscr.attroff(curses.color_pair(1))
            
    def print_centered_menu(self):
        
        w = self.scr_w
        h = self.scr_h
        m_length = self.menu_len
        stdscr = self.stdscr
        selected_row = self.selected_row

       # self.debug_out(stdscr, "s row: " + str(selected_row), h)

        for i, row in enumerate(self.menu_items):
            x = w//2 - len(row)//2
            y = h//2 - m_length//2 + i
            if i == selected_row:
                stdscr.attron(curses.color_pair(2))
                stdscr.addstr(y, x, row)
                stdscr.attroff(curses.color_pair(2))
            else:
                stdscr.attron(curses.color_pair(1))
                stdscr.addstr(y, x, row)

    def debug_out(self, stdscr, msg, h):
        stdscr.addstr(h - 2, 2, str(msg))
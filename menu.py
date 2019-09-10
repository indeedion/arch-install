import curses
from inputs import Inputs

inputs = Inputs.getInstance()

class Menu():
    def __init__(self, screen, menu_items, y=0, x=0, active=True):
        self.menu_items = menu_items
        self.menu_len = len(menu_items)
        self.y = y
        self.x = x
        self.screen = screen
        self.scr_h, self.scr_w = screen.getmaxyx()
        self.selected_row = 0
        self.is_active = active

    def update(self):
        if inputs.up and self.selected_row > 0:
            self.selected_row -= 1
        elif inputs.down and self.selected_row < self.menu_len -1:
            self.selected_row += 1
        elif inputs.right and self.selected_row < self.menu_len -1:
            self.selected_row += 1
        elif inputs.left and self.selected_row > 0:
            self.selected_row -= 1
        elif inputs.enter:
            return self.selected_row
        return None

    def set_active(self, is_active):
        self.is_active = is_active

    def print_menu(self, y, x, pair_1=1, pair_2=2):
        w = self.scr_w
        h = self.scr_h
        m_length = self.menu_len
        screen = self.screen
        selected_row = self.selected_row

        for i, row in enumerate(self.menu_items):
            if i == selected_row and self.is_active:
                screen.attron(curses.color_pair(pair_1))
                screen.addstr(y + i, x, row)
            else:
                screen.attron(curses.color_pair(pair_2))
                screen.addstr(y + i, x, row)
                screen.attroff(curses.color_pair(pair_1))

    def print_horizontal_menu(self, y, x, pair_1=1, pair_2=2):
        w = self.scr_w
        h = self.scr_h
        m_length = self.menu_len
        screen = self.screen
        selected_row = self.selected_row
        sum_row = 0

        for i, row in enumerate(self.menu_items):
            if i == selected_row and self.is_active:
                screen.attron(curses.color_pair(pair_1))
                screen.addstr(y, x + sum_row + 2, row)
                sum_row += len(row) + 2
            else:
                screen.attron(curses.color_pair(pair_2))
                screen.addstr(y, x + sum_row + 2, row)
                sum_row += len(row) + 2
                screen.attroff(curses.color_pair(pair_1))
            
    def print_centered_menu(self):
        
        w = self.scr_w
        h = self.scr_h
        m_length = self.menu_len
        screen = self.screen
        selected_row = self.selected_row

        for i, row in enumerate(self.menu_items):
            x = w//2 - len(row)//2
            y = h//2 - m_length//2 + i
            if i == selected_row:
                screen.attron(curses.color_pair(2))
                screen.addstr(y, x, row)
                screen.attroff(curses.color_pair(2))
            else:
                screen.attron(curses.color_pair(1))
                screen.addstr(y, x, row)

    def debug_out(self, screen, msg, h):
        screen.addstr(h - 2, 2, str(msg))
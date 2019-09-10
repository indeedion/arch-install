import curses

class Rect():
    def __init__(self, y, x, h, w):
        self.y = y
        self.x = x
        self.h = h
        self.w = w

class Screen():
    """ Handles asset locations"""
    __instance = None
    @staticmethod 
    def getInstance():
        """ Static access method. """
        if Screen.__instance == None:
            Screen()
        return Screen.__instance
    def __init__(self):
        """ Virtually private constructor. """
        if Screen.__instance != None:
            raise Exception("This is almost a Singleton!")
        else:
            Screen.__instance = self

    def init_screen_manager(self, screen):
        self.screen = screen
        # init attributes
        # Get terminal height, width and center x,y
        self.h, self.w = self.screen.getmaxyx()
        self.cx = self.w//2 
        self.cy = self.h//2

        self.area_a = Rect(
            0,
            0,
            self.h,
            int(self.w * 0.35)
        )
        self.area_b = Rect(
            0,
            self.w * 0.35,
            self.h,
            self.w - self.w * 0.35
        )

        self.screen_l = curses.newwin(
            int(self.area_a.h), 
            int(self.area_a.w), 
            int(self.area_a.y), 
            int(self.area_a.x)
        )

        self.screen_r = curses.newwin(
            int(self.area_b.h), 
            int(self.area_b.w + 1), 
            int(self.area_b.y), 
            int(self.area_b.x)
        )

    def get_scr_attribs(self):
        return self.h, self.w, self.cy, self.cx

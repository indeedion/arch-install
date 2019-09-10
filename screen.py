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

    def init_screen_manager(self, stdscr):
        self.stdscr = stdscr
        # init attributes
        # Get terminal height, width and center x,y
        self.h, self.w = self.stdscr.getmaxyx()
        self.cx = self.w//2 
        self.cy = self.h//2

    def get_scr_attribs(self):
        return self.h, self.w, self.cy, self.cx

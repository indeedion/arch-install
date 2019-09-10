import curses

class Inputs():
    """ Handles asset locations"""
    __instance = None
    @staticmethod 
    def getInstance():
        """ Static access method. """
        if Inputs.__instance == None:
            Inputs()
        return Inputs.__instance
    def __init__(self):
        """ Virtually private constructor. """
        if Inputs.__instance != None:
            raise Exception("This is almost a Singleton!")
        else:
            Inputs.__instance = self

            # init attributes
            self.up = False
            self.down = False
            self.enter = False 
            
    def update(self, key):
        self.up = False
        self.down = False
        self.enter = False

        if key == curses.KEY_UP:
            self.up = True
        elif key == curses.KEY_DOWN:
            self.down = True
        elif key == curses.KEY_ENTER or key in [10, 13]:
            self.enter = True

        
        

    
            
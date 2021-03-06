import curses

class AsciiDraw():
    def __init__(self, screen, filename):
        self.lines = self.load_image(filename)
        self.screen = screen
        self.width = self.getWidth()

    def getWidth(self):
        width = 0
        for line in self.lines:
            if len(line) > width:
                width = len(line)
        return width

    def load_image(self, filename):
        lines = []
        with open(filename, 'r') as file:
            for line in file:
                lines.append(line)
        return lines

    def draw(self, menu_len):
        h, w = self.screen.getmaxyx()
        x = w//2 - self.width//2 + 5
        y = h//2 - menu_len//2 - 10
        for line in self.lines:
            self.screen.addstr(y, x, line)
            y += 1



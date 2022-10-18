import sys
from PySide2.QtWidgets import *
from PySide2.QtGui import *

class StackedWidget(QStackedWidget):
    def __init__(self, parent=None):
        QStackedWidget.__init__(self, parent=parent)

    def paintEvent(self, event):
        painter = QPainter(self)
        painter.drawPixmap(self.rect(), QPixmap("image.png"))
        QStackedWidget.paintEvent(self, event)

class MainWindow(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent=parent)
        self.setCentralWidget(StackedWidget())

if __name__ == '__main__':

    app = QApplication(sys.argv)
    w = MainWindow()
    w.show()
    sys.exit(app.exec_())
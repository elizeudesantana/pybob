# from lib.shcmd import Sh as _
from PySide2.QtCore import *
from PySide2.QtWidgets import *
import sys
import os


class Radio():
    def liga_radio(self):
        # option - iniciar o radio como default
        # https://www.internet-radio.com/
        # _().radio('xxx')
        text = "fffff"
        self.FormRadio = FormRadio(text)
        # self.window.close()
        self.FormRadio.show()

        # os.system("mplayer http://88.198.69.145:8084/")



class FormRadio(QWidget):

    def __init__(self, text):
        QWidget.__init__(self)
        self.setWindowTitle('Window Two')
        self.setStyleSheet("QWidget {background-image: url(radio.jpg)}")

        geometry = qApp.desktop().availableGeometry(self)
        self.setFixedSize(geometry.width() * 0.4, geometry.height() * 0.3)
        
        #layout = QGridLayout()

        #self.label = QLabel(text)
        #l#ayout.addWidget(self.label)

        #self.button = QPushButton('Close')
        #self.button.clicked.connect(self.close)

        #layout.addWidget(self.button)

        #self.setLayout(layout)
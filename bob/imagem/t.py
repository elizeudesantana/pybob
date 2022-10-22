import sys
import subprocess
from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtWidgets import QMainWindow, QLabel, QApplication, QGridLayout, QtWidget
from PyQt5.QtCore import QSize


class MyWindow(QMainWindow):
    def __init__(self):
        super(MyWindow, self).__init()
        self.setup_main_window()
        self.initUI()
    
    def  setup_main_window():
        self.x = 640
        self.y = 480
        self.setMinimumSize(QSize(self.x, self.y))
        self.setWindowTitle("Processamento digital de Imagem")
        self.wid = QtWidget()
        self.setCentralWidget(self.wid)
        self.layout = QgridLayout()
        self.wid.setLayout(self.layout)

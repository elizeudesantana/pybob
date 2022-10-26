"""
pybob - ui_settings.py - script python ui principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.02     Script Inicial.

Extern Dependency :
                pyside2

Intern Dependency:
                toolbarinit

Description:
    Settings da janela principal.

by: Elizeu de Santana  In: 20/10/2022
"""
from PySide2.QtGui import QPixmap
from PySide2.QtWidgets import QLabel, QWidget
from .ui_model.toolbarinit import InitToolbar
from .ui_model.menu.menu_main import MenuMain


class SettingsMain():
    def settings(self, MainWindow):
        MainWindow.setObjectName(MainWindow)
        '''Maximizar a Unidade de Interface.'''
        self.showMaximized()

        # Carrega o titulo na janela.
        self.setWindowTitle('PyBob - EliSoftWare®')

        '''Inicializa os menus.'''
        InitToolbar.inittoolbar(self)
        MenuMain.monta_menu(self)

        # tiro o backgraound
        self.centralwidget = QWidget(MainWindow)
        self.centralwidget.setObjectName("centralwidget")

        self.photo = QLabel(self.centralwidget)
        self.photo.setGeometry(QtCore.QRect(0, 0, 841, 511))
        self.photo.setText("")
        self.photo.setPixmap(QtGui.QPixmap("bg2.jpg"))
        self.photo.setScaledContents(True)
        self.photo.setObjectName("photo")

        # pixmap = setPixmap(QPixmap("bg2.jpg"))
        # self.setStyleSheet('QWidget {background-image: url(pixmap)}')

        '''Atualiza previsao do tempo.'''
        # Clima.atualiza(self)

        '''Atualiza a barra de status.'''
        self.status = self.statusBar()
        self.status.showMessage('Seja bem vindo - PyBob - EliSoftWare®')

    # def togglebar(self):
        # state = self.formatbar.isVisible()
        # # Set the visibility to its inverse
        # self.formatbar.setVisible(not state)

    # def toggleformatbar(self):
        # state = self.formatbar.isVisible()
        # # Set the visibility to its inverse
        # self.formatbar.setVisible(not state)

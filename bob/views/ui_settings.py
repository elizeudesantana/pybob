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
from .ui_model.toolbarinit import InitToolbar
from .ui_model.menu.menu_main import MenuMain
from .ui_model.modelo_clima import Clima


class SettingsMain():
    def settings(self):
        self.ui_maximiza(self)
        self.ui_background()
        self.ui_title()
        self .ui_menus()
        self.ui_clima()
        self.ui_statusbar()

    def ui_maximiza(self):
        '''Maximizar a Unidade de Interface.'''
        self.showMaximized()

    def ui_background(self):
        '''Carrega image para o background.'''
        # mg = os.path.join(CURRENT_DIR, "imagem/bg2.jpg")
        # self.setCentralWidget(StackedWidget())
        ...

    def ui_title(self):
        self.setWindowTitle('PyBob - EliSoftWare®')

    def ui_menus(self):
        InitToolbar.inittoolbar(self)
        MenuMain.monta_menu(self)

    def ui_clima(self):
        '''Atualiza previsao do tempo'''
        Clima.atualiza(self)

    def ui_statusbar(self):
        self.status = self.statusBar()
        self.status.showMessage('Seja bem vindo - PyBob - EliSoftWare®')

    def togglebar(self):
        state = self.formatbar.isVisible()
        # Set the visibility to its inverse
        self.formatbar.setVisible(not state)

    def toggleformatbar(self):
        state = self.formatbar.isVisible()
        # Set the visibility to its inverse
        self.formatbar.setVisible(not state)

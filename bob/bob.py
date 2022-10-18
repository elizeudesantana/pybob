"""
pybob - bob.py - script python principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script inicial versao, implementa a chamada
                da unidade interface main; cria hooks.

Extern Dependency :
                pyside2

Intern Dependency:
                mainwindow

Description:
    Aplicação chamado apartir de agora pybob, programa de  dados  que
    proporciona ao usuario uma experiência de configuração do ambiente
    sistema operacional linux.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtWidgets import QApplication
from bob.views.ui_main import UiMain
import sys


if __name__ == '__main__':
    '''
        Qt Application arquivo inicial funciona como gancho, na
        necessidade de subir alguma app, antes de subir a ui
        principal.
    '''
    app = QApplication(sys.argv)
    win = UiMain()
    win.show()                   # Sobe a Unidade Interface principal
    sys.exit(app.exec_())

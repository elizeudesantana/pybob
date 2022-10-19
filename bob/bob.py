"""
pybob - bob.py - script python principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script inicial versao, implementa a chamada
                da unidade interface main; cria hooks.
    2022.05.01  em : 18/10/2022
                Inserido menus, versionado o GUI para o pyside6
                que gerou incompatibilidade:
                .   Virtualenv com python 3.10.8 instalado atraves do poetry
                    usando o artificil de setar em [depencies] do toml
                    a var pyside6 = {PySide6.2.4.whl} baixado de
                    https://download.qt.io/official_releases/QtForPython/pyside6/
                    e a dependencia shiboken6.
                    Que gerou conflito, com o sistema operacional ubuntu 18.04,
                    na libc [GLIB-2.27], era necessario [GLIBC-2.28], onde a 
                    unica solucao era o update para ubuntu 20.01 LTS.
                em : 19/10/2022
                Tentativa de solucionar o bug da GUI, utilizando pyenv instalado
                a versao python 3.9.12 criar uma nova virtualenv, e instalar o
                pyside6.0.0

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

"""
pybob - bob.py - script python principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script inicial versao, implementa a chamada
                da unidade interface main; cria hooks.
    2022.02     em : 18/10/2022
                Inserido menus, versionado o GUI para o pyside6
                que gerou incompatibilidade:
                .   Virtualenv com python 3.10.8 instalado atraves do poetry
                    usando o artificil de setar em [depencies] do toml
                    a var pyside6 = {PySide6.2.4.whl} baixado de
                    https://download.qt.io/official_releases/QtForPython/pyside6/
                    e a dependencia shiboken6.
                    Que gerou conflito, com o sistema operacional ubuntu 18.04,
                    na libc [GLIB-2.27], era necessario [GLIBC-2.28], onde a
                    unica solucao era o update para ubuntu 20.04 LTS.
                em : 19/10/2022
                .   Tentativa de solucionar o bug da GUI, utilizando pyenv
                instalado a versao python 3.9.12 criar uma nova virtualenv, e
                instalar o pyside6.2.0 e shibloken6.2.0 - FALHOU erro Glibc
                .   Instado package PySide2 - Qt5. (poetry)
                atualizado codigo para pyside2 - qt5.

                teste [erro] :

                Traceback (most recent call last):
                File "<string>", line 1, in <module>
                ImportError: /usr/lib/x86_64-linux-gnu/libgssapi_krb5.so.2:
                symbol krb5_ser_context_init version krb5_3_MIT not defined
                in file libkrb5.so.3 with link time reference

                solucao:

                https://web.mit.edu/kerberos/  - dowload
                tar xf krb5-1.18.2.tar.gz
                cd krb5-1.18.2/src
                ./configure --prefix=/opt/krb5/
                make && make install

                export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/krb5/lib
                python -c "import PySide2.QtCore"

                poetry remove pyside2

                https://github.com/PySide/pyside2/wiki/Dependencies
                instalar as dependências para buildins

                conda install pyside2
                poetry add pyside23
                utilizando o vscode

                . inumeras falhas e tentativas.
                . Atual em 24/10/2022
                considerando a capacidade de processamento do hardware em uso:
                SO Ubuntu bionic, Gerenciador de janelas i3, workspace pycharm,
                script python com pyside2 and shell sem curse, engendrando com
                qutebrowser as Qt5 and zsh com ohmyzsh, monitorando com
                monitorix e apache zbix






Extern Dependency :
                pyside2

Intern Dependency:
                MainWindow in ui_main

Description:
    Aplicação chamada a partir de agora pybob, programa de  dados  que
    proporciona ao usuário uma experiência de configuração do ambiente
    sistema operacional linux.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QApplication
from views.ui_main import UiMain
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

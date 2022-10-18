"""
pybob - mcriarbd.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu adicionar do menu contatos.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu adicionar do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuCriarbd():
    def sub_criarbd(self):
        """
        Criar Banco de Dados.
        """

        menu_c = QAction(
            "&Criar BD",
            self,
            statusTip="L"
        )
        menu_c.setShortcut("Ctrl+F")
        menu_c.triggered.connect(self.menu_criardb_contato)
        self.file_menu.addAction(menu_c)

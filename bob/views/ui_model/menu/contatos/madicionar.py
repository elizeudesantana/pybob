"""
pybob - madicionar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu adicionar do menu contatos.

Extern Dependency :
                pyside2

Intern Dependency:
                not necessary

Description:
    submenu adicionar do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuAdicionar():
    def sub_adicionar(self):
        """
            Adicionar.
        """

        menu_acontato = QAction(
            "&Adicionar",
            self,
            statusTip="L"
        )
        menu_acontato.setShortcut("Ctrl+F")
        menu_acontato.triggered.connect(self.menu_adiciona_contato)
        self.file_menu.addAction(menu_acontato)

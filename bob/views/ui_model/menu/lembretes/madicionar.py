"""
pybob - madicionar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu adicionar do menu lembrete.

Extern Dependency :
                pyside2

Intern Dependency:
                not necessary

Description:
    submenu adicionar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuAdicionar():
    def sub_adicionar(self):
        """
            Adicionar.
        """

        menu_al = QAction(
            "&Adicionar",
            self,
            statusTip="L"
        )
        menu_al.setShortcut("Ctrl+F")
        menu_al.triggered.connect(self.menu_adiciona_lembrete)
        self.file_menu.addAction(menu_al)

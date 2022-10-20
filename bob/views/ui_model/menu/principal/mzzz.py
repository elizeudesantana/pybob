"""
pybob - mzzz.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu zz do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu zz do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuZz():
    def sub_zz(self):
        """
            Funções zz.
        """

        menu_zz = QAction(
            "&Funções ZZ",
            self,
            statusTip="Funções zz, matematicas, verbos, etc."
        )
        menu_zz.setShortcut("Ctrl+F")
        menu_zz.triggered.connect(self.menu_zz)
        self.file_menu.addAction(menu_zz)

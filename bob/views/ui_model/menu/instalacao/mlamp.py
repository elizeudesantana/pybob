"""
pybob - mlamp.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu lamp do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu lamp do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuLamp():
    def sub_lamp(self):
        """
        LAMP.
        """

        menu_l = QAction(
            "LAMP",
            self,
            statusTip="L"
        )
        menu_l.setShortcut("Ctrl+C")
        menu_l.triggered.connect(self.menu_lamp)
        self.file_menu.addAction(menu_l)

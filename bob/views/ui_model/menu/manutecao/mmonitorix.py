"""
pybob - mmonitorix.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu monitorix do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu monitorix do menu manutecao.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuMonitorix():
    def sub_monitorix(self):
        """
        Monitorix.
        """

        menu_m = QAction(
            "Monitorix",
            self,
            statusTip="L"
        )
        menu_m.setShortcut("Ctrl+C")
        menu_m.triggered.connect(self.menu_monitorix)
        self.file_menu.addAction(menu_m)

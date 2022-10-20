"""
pybob - mservice.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu service do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu service do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuService():
    def sub_service(self):
        """
            Services do sistema.
        """

        menu_sc = QAction(
            "&Services",
            self,
            statusTip="Services do sistema [ubuntu] systemctrl, \
                status, start, stop."
        )
        menu_sc.setShortcut("Ctrl+S")
        menu_sc.triggered.connect(self.menu_services)
        self.file_menu.addAction(menu_sc)

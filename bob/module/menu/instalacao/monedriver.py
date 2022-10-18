"""
pybob - monedriver.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu onedriver do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu onedriver do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuOnedriver():
    def sub_onedriver(self):
        """
        One driver.
        """

        menu_o = QAction(
            "One driver",
            self,
            statusTip="L"
        )
        menu_o.setShortcut("Ctrl+C")
        menu_o.triggered.connect(self.menu_onedriver)
        self.file_menu.addAction(menu_o)

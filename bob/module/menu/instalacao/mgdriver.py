"""
pybob - mgdriver.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu gdriver do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu gdriver do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuGdriver():
    def sub_gdriver(self):
        """
        Google driver.
        """

        menu_g = QAction(
            "Gdriver",
            self,
            statusTip="L"
        )
        menu_g.setShortcut("Ctrl+C")
        menu_g.triggered.connect(self.menu_griver)
        self.file_menu.addAction(menu_g)

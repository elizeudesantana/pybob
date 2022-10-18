"""
pybob - mfontes.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu fontes do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu fontes do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuFontes():
    def sub_fontes(self):
        """
        Shell_Fonts.
        """

        menu_sf = QAction(
            "Fontes",
            self,
            statusTip="L"
        )
        menu_sf.setShortcut("Ctrl+C")
        menu_sf.triggered.connect(self.menu_shellfonts)
        self.file_menu.addAction(menu_sf)

"""
pybob - mdjango.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu django do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu django do menu principal.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuDjango():
    def sub_django(self):
        """
            Framework Django cria App
        """

        menu_dg = QAction(
            "Djan&go",
            self,
            statusTip="Monta um aplicativo web, com configurações básicas."
        )
        menu_dg.setShortcut("Ctrl+D")
        menu_dg.triggered.connect(self.menu_django)
        self.file_menu.addAction(menu_dg)

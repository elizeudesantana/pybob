"""
pybob - mprotela.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu protecao de tela do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu pretecao de tela do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuProtela():
    def sub_protela(self):
        """
            Proteção de tela.
        """

        menu_tl = QAction(
            "&Proteção de tela",
            self,
            statusTip="Aquarium, php proteção de tela."
        )
        menu_tl.setShortcut("Ctrl+F")
        menu_tl.triggered.connect(self.menu_tela)
        self.file_menu.addAction(menu_tl)

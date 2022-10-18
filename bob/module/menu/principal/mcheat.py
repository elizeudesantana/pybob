"""
pybob - mdjango.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu cheat do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu cheat do menu principal.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuCheat():
    def sub_cheat(self):
        """
            https://cheat.sh/.
        """

        tmp = "The only cheat sheet you need "
        tmp1 = "unified access to the best "
        tmp2 = "community driven documentation "
        tmp3 = "repositories of the world."
        menu_cht = QAction(
            "ch&t.sh - community",
            self,
            statusTip=tmp+tmp1+tmp2+tmp3
        )
        menu_cht.setShortcut("Ctrl+t")
        menu_cht.triggered.connect(self.menu_cht)
        self.file_menu.addAction(menu_cht)

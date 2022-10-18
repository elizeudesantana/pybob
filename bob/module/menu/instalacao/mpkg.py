"""
pybob - mpkg.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu pkg do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu pkg do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuPkg():
    def sub_pkg(self):
        """
        Apt, snap, aptitude.
        """

        menu_p = QAction(
            "Pacotes",
            self,
            statusTip="L"
        )
        menu_p.setShortcut("Ctrl+C")
        menu_p.triggered.connect(self.menu_pkg)
        self.file_menu.addAction(menu_p)

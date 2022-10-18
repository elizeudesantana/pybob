"""
pybob - mevolucao.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu evolucao do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu evolucao do menu principal.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuEvo():
    def sub_evo(self):
        """
            Evolução do repósitorio no git.
        """

        menu_eg = QAction(
            "&Git evolution",
            self,
            statusTip="Gauger mostra a evolução no repositório github."
        )
        menu_eg.setShortcut("Ctrl+G")
        menu_eg.triggered.connect(self.menu_evogit)
        self.file_menu.addAction(menu_eg)

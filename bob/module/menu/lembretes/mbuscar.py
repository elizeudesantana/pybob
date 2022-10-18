"""
pybob - mbuscar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu buscar do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu buscar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuBuscar():
    def sub_buscar(self):
        """
        Buscar.
        """

        menu_bl = QAction(
            "&Buscar",
            self,
            statusTip="L"
        )
        menu_bl.setShortcut("Ctrl+F")
        menu_bl.triggered.connect(self.menu_busca_lembrete)
        self.file_menu.addAction(menu_bl)

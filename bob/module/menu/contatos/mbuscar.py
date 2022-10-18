"""
pybob - mbiscar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu buscar do menu contatos.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu buscar do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuBuscar():
    def sub_buscar(self):
        """
        Buscar.
        """

        menu_bc = QAction(
            "&Buscar",
            self,
            statusTip="L"
        )
        menu_bc.setShortcut("Ctrl+F")
        menu_bc.triggered.connect(self.menu_busca_contato)
        self.file_menu.addAction(menu_bc)

"""
pybob - mlistar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu listar do menu contatos.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu listar do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuListar():
    def sub_listar(self):
        """Listar."""
        menu_lc = QAction(
            "&Listar",
            self,
            statusTip="L"
        )
        menu_lc.setShortcut("Ctrl+F")
        menu_lc.triggered.connect(self.menu_lista_contato)
        self.file_menu.addAction(menu_lc)

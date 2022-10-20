"""
pybob - mlistar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu listar do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu listar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuListar():
    def sub_listar(self):
        """
        Listar.
        """

        menu_ll = QAction(
            "&Listar",
            self,
            statusTip="L"
        )
        menu_ll.setShortcut("Ctrl+F")
        menu_ll.triggered.connect(self.menu_lista_lembrete)
        self.file_menu.addAction(menu_ll)

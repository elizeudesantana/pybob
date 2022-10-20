"""
pybob - mmemoreal.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu memoria real do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu memoria real do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuMemoriaReal():
    def sub_memoriareal(self):
        """
        Memoria Real.
        """

        menu_mr = QAction(
            "Memoria Real",
            self,
            statusTip="L"
        )
        menu_mr.setShortcut("Ctrl+C")
        menu_mr.triggered.connect(self.menu_memoriareal)
        self.file_menu.addAction(menu_mr)

"""
pybob - merros.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu erro do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu erro do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuErros():
    def sub_erros(self):
        """
        ERROS.
        """

        menu_e = QAction(
            "Erros",
            self,
            statusTip="L"
        )
        menu_e.setShortcut("Ctrl+C")
        menu_e.triggered.connect(self.menu_erros)
        self.file_menu.addAction(menu_e)

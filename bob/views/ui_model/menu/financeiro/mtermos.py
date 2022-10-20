"""
pybob - mtermos.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu termos do menu financas.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu termos do menu financas.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuTermos():
    def sub_termos(self):
        """
        Indice de termos Fianceiros.
        """

        menu_t = QAction(
            "Indice de termos financeiro",
            self,
            statusTip="L"
        )
        menu_t.setShortcut("Ctrl+C")
        menu_t.triggered.connect(self.menu_termos)
        self.file_menu.addAction(menu_t)

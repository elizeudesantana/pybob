"""
pybob - mcripto.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu cripto moedas do menu financas.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu cripto moedas do menu financas.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuCriptoMoedas():
    def sub_criptomoedas(self):
        """
        Cripto moedas analise.
        """

        menu_c = QAction(
            "Cripto moedas",
            self,
            statusTip="L"
        )
        menu_c.setShortcut("Ctrl+C")
        menu_c.triggered.connect(self.menu_cripto)
        self.file_menu.addAction(menu_c)

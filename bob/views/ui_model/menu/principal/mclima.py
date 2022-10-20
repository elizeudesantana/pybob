"""
pybob - mdjango.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu clima do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu clima do menu principal.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuClima():
    def sub_clima(self):
        """
            Configuração e consulta do clima.
        """

        menu_cm = QAction(
            "&Clima",
            self,
            statusTip="Configuração e consulta do clima http://wttr.in."
        )
        menu_cm.setShortcut("Ctrl+F")
        menu_cm.triggered.connect(self.menu_clima)
        self.file_menu.addAction(menu_cm)

"""
pybob - mradio.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu radio do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu radio do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuRadio():
    def sub_radio(self):
        """
            Servico de Radio web.
        """

        menu_rd = QAction(
            "&Rádio",
            self,
            statusTip="Ouvir rádio, um serviço web."
        )
        menu_rd.setShortcut("Ctrl+R")
        menu_rd.triggered.connect(self.menu_radio)
        self.file_menu.addAction(menu_rd)

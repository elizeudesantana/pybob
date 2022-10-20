"""
pybob - msair.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu sair do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu sair do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuSair():
    def sub_sair(self):
        """
            Termina o aplicativo.
        """

        exit_sr = QAction(
            "Sair",
            self,
            statusTip="Sair do aplicativo."
        )
        exit_sr.setShortcut("Ctrl+Q")
        exit_sr.triggered.connect(self.exit_sair)
        self.file_menu.addAction(exit_sr)

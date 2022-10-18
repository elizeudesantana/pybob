"""
pybob - mcriarbd.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu adicionar do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu adicionar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuCriarbd():
    def sub_criarbd(self):
        """
        Criar Banco de Dados.
        """

        menu_cl = QAction(
            "&Criar BD",
            self,
            statusTip="L"
        )
        menu_cl.setShortcut("Ctrl+F")
        menu_cl.triggered.connect(self.menu_criardb_lembrete)
        self.file_menu.addAction(menu_cl)

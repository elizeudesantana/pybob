"""
pybob - mdeletar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu deletar do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu deletar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuDeletar():
    def sub_deletar(self):
        """
        Deletar.
        """

        menu_dl = QAction(
            "&Deletar",
            self,
            statusTip="L"
        )
        menu_dl.setShortcut("Ctrl+F")
        menu_dl.triggered.connect(self.menu_deleta_lembrete)
        self.file_menu.addAction(menu_dl)

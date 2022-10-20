"""
pybob - mdeletartodos.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu deletartodos do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu deletartodos do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuDeletartodos():
    def sub_deletartodos(self):
        """
        Deletar all.
        """

        menu_dl = QAction(
            "&Deletar All",
            self,
            statusTip="L"
        )
        menu_dl.setShortcut("Ctrl+F")
        menu_dl.triggered.connect(self.menu_deleta_all_lembrete)
        self.file_menu.addAction(menu_dl)

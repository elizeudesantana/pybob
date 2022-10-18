"""
pybob - meddisco.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu monitora disco do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu monitora disco do menu manutecao.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuMonitoraDisco():
    def sub_monitoradisco(self):
        """
        Monitora_o_de_E_S_disco_e_TCP_dump.
        """

        menu_d = QAction(
            "Discos E/S",
            self,
            statusTip="L"
        )
        menu_d.setShortcut("Ctrl+C")
        menu_d.triggered.connect(self.menu_discoes)
        self.file_menu.addAction(menu_d)

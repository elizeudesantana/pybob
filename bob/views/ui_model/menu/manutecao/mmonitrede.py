"""
pybob - mmonitrede.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu monitora rede do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu monitora rede do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuMonitoraRede():
    def sub_monitorarede(self):
        """
        Monitora Network.
        """

        menu_m = QAction(
            "Memoria Real",
            self,
            statusTip="L"
        )
        menu_m.setShortcut("Ctrl+C")
        menu_m.triggered.connect(self.menu_monitnet)
        self.file_menu.addAction(menu_m)

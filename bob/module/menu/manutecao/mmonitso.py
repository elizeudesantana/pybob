"""
pybob - mmonitso.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu monitora so do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu monitora so do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuMonitoraSO():
    def sub_monitoraso(self):
        """
        Monitora_o_do_Sistema_Operacional.
        """

        menu_mso = QAction(
            "Sistema Operacional",
            self,
            statusTip="L"
        )
        menu_mso.setShortcut("Ctrl+C")
        menu_mso.triggered.connect(self.menu_monitso)
        self.file_menu.addAction(menu_mso)

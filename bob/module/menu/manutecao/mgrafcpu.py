"""
pybob - mgrafcpu.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu grafico cpu do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu grafico cpu do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuGrafCPU():
    def sub_graf(self):
        """
        Plotar Gráfico da CPU.
        """

        menu_g = QAction(
            "Gráfico &CPU",
            self,
            statusTip="L"
        )
        menu_g.setShortcut("Ctrl+C")
        menu_g.triggered.connect(self.menu_grafcpu)
        self.file_menu.addAction(menu_g)

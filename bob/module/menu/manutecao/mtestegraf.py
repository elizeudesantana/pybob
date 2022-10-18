"""
pybob - mtestgraf.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu testes graficos do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu testes graficos do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuTestGraf():
    def sub_testgraf(self):
        """
        Plotar Grafico e teste CPU.
        """

        menu_t = QAction(
            "CPU Testes Gráficos",
            self,
            statusTip="L"
        )
        menu_t.setShortcut("Ctrl+C")
        menu_t.triggered.connect(self.menu_testecpu)
        self.file_menu.addAction(menu_t)

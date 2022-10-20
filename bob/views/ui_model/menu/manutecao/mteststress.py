"""
pybob - mtestestress.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu testes stress do menu manutencao.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu testes stress do menu manutecao.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuTestStress():
    def sub_teststress(self):
        """
        Plotar Gráfico da CPU.
        """

        menu_ts = QAction(
            "CPU Testes Stress",
            self,
            statusTip="L"
        )
        menu_ts.setShortcut("Ctrl+C")
        menu_ts.triggered.connect(self.menu_testestress)
        self.file_menu.addAction(menu_ts)

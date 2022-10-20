"""
pybob - mdiversos.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu diversos do menu instalacoes.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu diversos do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuDiversos():
    def sub_diversos(self):
        """
        Programas_Diversos_NetWork_Midias_Desenvolvimento_e_Editores.
        """

        menu_d = QAction(
            "Diversos",
            self,
            statusTip="L"
        )
        menu_d.setShortcut("Ctrl+C")
        menu_d.triggered.connect(self.menu_diversos)
        self.file_menu.addAction(menu_d)

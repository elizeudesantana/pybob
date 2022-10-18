"""
pybob - meditar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu editar do menu lembrete.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu editar do menu lembrete.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide6.QtGui import QAction


class SubmenuEditar():
    def sub_editar(self):
        """
            Editar.
        """

        menu_el = QAction(
            "&Editar",
            self,
            statusTip="L"
        )
        menu_el.setShortcut("Ctrl+F")
        menu_el.triggered.connect(self.menu_edita_lembrete)
        self.file_menu.addAction(menu_el)

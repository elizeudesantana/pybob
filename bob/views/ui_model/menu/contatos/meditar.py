"""
pybob - meditar.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu editar do menu contatos.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu editar do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuEditar():
    def sub_editar(self):
        """
            Editar.
        """

        menu_ed = QAction(
            "&Editar",
            self, 
            statusTip="L"
        )
        menu_ed.setShortcut("Ctrl+F")
        menu_ed.triggered.connect(self.menu_edita_contato)
        self.file_menu.addAction(menu_ed)

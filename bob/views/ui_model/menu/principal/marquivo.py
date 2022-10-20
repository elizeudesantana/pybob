"""
pybob - mdjango.py - script python submenu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     submenu arquivo do menu principal.

Extern Dependency :
                pyside6

Intern Dependency:
                not necessary

Description:
    submenu arquivo do menu principal.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QAction


class SubmenuArquivo():
    def sub_arquivo(self):
        """
            Variaveis de ambiente, mover, renomear, localizar, dotfiles,
            backup, configuraçoes, etc.
        """

        tmp = "Variaveis de ambiente, mover, renomear, "
        tmp1 = "localizar, dotfiles, backup, configuraçoes, etc."
        menu_arv = QAction(
            "&Pastas e Arquivos",
            self,
            statusTip=tmp+tmp1
        )
        menu_arv.setShortcut("Ctrl+A")
        menu_arv.triggered.connect(self.menu_arquivo)
        self.file_menu.addAction(menu_arv)

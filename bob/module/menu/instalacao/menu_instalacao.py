"""
pybob - menu_instalacao.py - script python menu instalacoes
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                pyside6

Intern Dependency:
                mfontes
                mdiversos
                mlamp
                merros
                mgdriver
                monedriver
                mpkg

Description:
    Montagem do menu instalacoes.

by: Elizeu de Santana  In: 17/10/2022
"""
from mfontes import SubmenuFontes
from mdiversos import SubmenuDiversos
from mlamp import SubmenuLamp
from merros import SubmenuErros
from mgdriver import SubmenuGdriver
from monedriver import SubmenuOnedriver
from mpkg import SubmenuPkg


class MenuInstalacao():
    def menu_fonts(self):
        SubmenuFontes.sub_fontes()

    def menu_idiversos(self):
        SubmenuDiversos.sub_diversos()

    def menu_ilamp(self):
        SubmenuLamp.sub_lamp()

    def menu_ierros(self):
        SubmenuErros.sub_erros()

    def menu_igdriver(self):
        SubmenuGdriver.sub_gdriver()

    def menu_ionedriver(self):
        SubmenuOnedriver.sub_onedriver()

    def menu_ipkg(self):
        SubmenuPkg.sub_pkg()

    def menu_monta(self):
        lista_menu = [
            self.menu_fonts(),
            self.menu_idiversos(),
            self.menu_ilamp(),
            self.menu_ierros(),
            self.menu_igdriver(),
            self.menu_ionedriver(),
            self.menu_ipkg()]
        return lista_menu

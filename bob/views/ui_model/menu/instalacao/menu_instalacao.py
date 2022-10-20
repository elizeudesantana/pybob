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
from .mfontes import SubmenuFontes
from .mdiversos import SubmenuDiversos
from .mlamp import SubmenuLamp
from .merros import SubmenuErros
from .mgdriver import SubmenuGdriver
from .monedriver import SubmenuOnedriver
from .mpkg import SubmenuPkg


class MenuInstalacao():
    def menu_fonts(self):
        SubmenuFontes.sub_fontes(self)

    def menu_idiversos(self):
        SubmenuDiversos.sub_diversos(self)

    def menu_ilamp(self):
        SubmenuLamp.sub_lamp(self)

    def menu_ierros(self):
        SubmenuErros.sub_erros(self)

    def menu_igdriver(self):
        SubmenuGdriver.sub_gdriver(self)

    def menu_ionedriver(self):
        SubmenuOnedriver.sub_onedriver(self)

    def menu_ipkg(self):
        SubmenuPkg.sub_pkg(self)

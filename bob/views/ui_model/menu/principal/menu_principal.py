"""
pybob - menu_principal.py - script python menu principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                not necessary

Intern Dependency:
                mdjango
                SubmenuService
                SubmenuRadio
                marquivo
                mcheat
                mevolucao
                mzzz
                mprotela
                mclima
                msair

Description:
    Montagem do menu principal.

by: Elizeu de Santana  In: 18/10/2022
"""
from .mdjango import SubmenuDjango
from .mservice import SubmenuService
from .mradio import SubmenuRadio
from .marquivo import SubmenuArquivo
from .mcheat import SubmenuCheat
from .mevolucao import SubmenuEvo
from .mzzz import SubmenuZz
from .mprotela import SubmenuProtela
from .mclima import SubmenuClima
from .msair import SubmenuSair


class MenuPrincipal:
    def menu_django(self):
        SubmenuDjango.sub_django(self)

    def menu_service(self):
        SubmenuService.sub_service(self)

    def menu_radio(self):
        SubmenuRadio.sub_radio(self)

    def menu_arquivo(self):
        SubmenuArquivo.sub_arquivo(self)

    def menu_cheat(self):
        SubmenuCheat.sub_cheat(self)

    def menu_evolucao(self):
        SubmenuEvo.sub_evo(self)

    def menu_zzz(self):
        SubmenuZz.sub_zz(self)

    def menu_tela(self):
        SubmenuProtela.sub_protela(self)

    def menu_pclima(self):
        SubmenuClima.sub_clima(self)

    def menu_psair(self):
        SubmenuSair.sub_sair(self)

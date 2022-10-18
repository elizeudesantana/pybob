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
from mdjango import SubmenuDjango
from mservice import SubmenuService
from mradio import SubmenuRadio
from marquivo import SubmenuArquivo
from mcheat import SubmenuCheat
from mevolucao import SubmenuEvo
from mzzz import SubmenuZz
from mprotela import SubmenuProtela
from mclima import SubmenuClima
from msair import SubmenuSair


class MenuPrincipal:
    def menu_django(self):
        SubmenuDjango.sub_django()

    def menu_service(self):
        SubmenuService.sub_service()

    def menu_radio(self):
        SubmenuRadio.sub_radio()

    def menu_arquivo(self):
        SubmenuArquivo.sub_arquivo()

    def menu_cheat(self):
        SubmenuCheat.sub_cheat()

    def menu_evolucao(self):
        SubmenuEvo.sub_evo()

    def menu_zzz(self):
        SubmenuZz.sub_zz()

    def menu_tela(self):
        SubmenuProtela.sub_protela()

    def menu_pclima(self):
        SubmenuClima.sub_clima()

    def menu_psair(self):
        SubmenuSair.sub_sair()

    def menu_monta(self):
        lista_menu = [
            self.menu_django(),
            self.menu_service(),
            self.menu_radio(),
            self.menu_arquivo(),
            self.menu_cheat(),
            self.menu_evolucao(),
            self.menu_zzz(),
            self.menu_tela(),
            self.menu_pclima(),
            self.menu_psair(),
        ]
        return lista_menu

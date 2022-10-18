"""
pybob - menu_financas.py - script python menu financas
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                not necessary

Intern Dependency:
                mcripto
                mtermos

Description:
    Montagem do menu financas.

by: Elizeu de Santana  In: 17/10/2022
"""
from mcripto import SubmenuCriptoMoedas
from mtermos import SubmenuTermos


class MenuFinancas():
    def menu_cripto(self):
        SubmenuCriptoMoedas.sub_criptomoedas()

    def menu_termos(self):
        SubmenuTermos.sub_termos()

    def menu_monta(self):
        lista_menu = [
                self.menu_termos(),
                self.menu_cripto(self)]
        return lista_menu

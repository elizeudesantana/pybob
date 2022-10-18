"""
pybob - menu_lembrete.py - script python menu lembretes
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                pyside6

Intern Dependency:
                madicionar
                meditar
                mdeletar
                mlistar
                mbuscar
                mdeletartodos
                mcriarbd

Description:
    Montagem do menu lembretes.

by: Elizeu de Santana  In: 17/10/2022
"""
from madicionar import SubmenuAdicionar
from meditar import SubmenuEditar
from mdeletar import SubmenuDeletar
from mlistar import SubmenuListar
from mbuscar import SubmenuBuscar
from mdeletartodos import SubmenuDeletartodos
from mcriarbd import SubmenuCriarbd


class MenuLembretes:
    def menu_adicionar(self):
        SubmenuAdicionar.sub_adicionar()

    def menu_editar(self):
        SubmenuEditar.sub_editar()

    def menu_deletar(self):
        SubmenuDeletar.sub_deletar()

    def menu_listar(self):
        SubmenuListar.sub_listar()

    def menu_buscar(self):
        SubmenuBuscar.sub_buscar()

    def menu_deletartodos(self):
        SubmenuDeletartodos.sub_deletartodos()

    def menu_criarbd(self):
        SubmenuCriarbd.sub_criarbd()

    def menu_monta(self):
        lista_menu = [
                self.menu_adicionar(),
                self.menu_editar(),
                self.menu_deletar(),
                self.menu_listar(),
                self.menu_buscar(),
                self.menu_deletarall(),
                self.menu_criardb()]
        return lista_menu

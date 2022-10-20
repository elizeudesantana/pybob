"""
pybob - menu_contatos.py - script python menu contatos
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script montagem do menu.

Extern Dependency :
                not necessary

Intern Dependency:
                madicionar
                meditar
                mdeletar
                mlistar
                mbuscar
                mdeletartodos
                mcriarbd

Description:
    Montagem do menu contatos.

by: Elizeu de Santana  In: 17/10/2022
"""
from .madicionar import SubmenuAdicionar
from .meditar import SubmenuEditar
from .mdeletar import SubmenuDeletar
from .mlistar import SubmenuListar
from .mbuscar import SubmenuBuscar
from .mdeletartodos import SubmenuDeletartodos
from .mcriarbd import SubmenuCriarbd


class MenuContatos:
    def menu_adicionar(self):
        SubmenuAdicionar.sub_adicionar(self)

    def menu_editar(self):
        SubmenuEditar.sub_editar(self)

    def menu_deletar(self):
        SubmenuDeletar.sub_deletar(self)

    def menu_listar(self):
        SubmenuListar.sub_listar(self)

    def menu_buscar(self):
        SubmenuBuscar.sub_buscar(self)

    def menu_deletartodos(self):
        SubmenuDeletartodos.sub_deletartodos(self)

    def menu_criarbd(self):
        SubmenuCriarbd.sub_criarbd(self)

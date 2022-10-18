"""
pybob - menu_main.py - script python menu.
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     monta a barra de menu.

Extern Dependency :
                not necessary

Intern Dependency:
                menu_principal
                menu_contatos
                menu_lembrete
                menu_manutencao
                menu_financas
                menu_instalacao

Description:
    Monta barra de menu.

by: Elizeu de Santana  In: 18/10/2022
"""
from bob.module.menu.principal.menu_principal import MenuPrincipal
from bob.module.menu.contatos.menu_contatos import MenuContatos
from bob.module.menu.lembretes.menu_lembrete import MenuLembretes
from bob.module.menu.manutecao.menu_manutencao import MenuManutencao
from bob.module.menu.financeiro.menu_financas import MenuFinancas
from bob.module.menu.instalacao.menu_instalacao import MenuInstalacao


class MenuMain():
    def monta_menu(self):
        self.menu = self.menuBar()

        """Menu Principal"""
        self.file_menu = self.menu.addMenu("&Principal")

        submenu_principal = MenuPrincipal.menu_monta()
        for _ in range(len(submenu_principal)):
            submenu_principal[_]

        """Menu Contatos"""
        self.file_menu = self.menu.addMenu("&Contatos")

        submenu_contatos = MenuContatos.menu_monta()
        for _ in range(len(submenu_contatos)):
            submenu_contatos[_]

        """Menu Lembretes"""
        self.file_menu = self.menu.addMenu("&Lembretes")

        submenu_lembretes = MenuLembretes.menu_monta()
        for _ in range(len(submenu_lembretes)):
            submenu_lembretes[_]

        """Menu Manutencao"""
        self.file_menu = self.menu.addMenu("&Manutencao")

        submenu_manutecao = MenuManutencao.menu_monta()
        for _ in range(len(submenu_manutecao)):
            submenu_manutecao[_]

        """Menu Financeiro"""
        self.file_menu = self.menu.addMenu("&Financeiro")

        submenu_financas = MenuFinancas.menu_monta()
        for _ in range(len(submenu_financas)):
            submenu_financas[_]

        """Menu Instalacao"""
        self.file_menu = self.menu.addMenu("&Instalação")

        submenu_instalacao = MenuInstalacao.menu_monta()
        for _ in range(len(submenu_instalacao)):
            submenu_instalacao[_]

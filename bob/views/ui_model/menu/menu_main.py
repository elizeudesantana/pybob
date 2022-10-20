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
from .principal.menu_principal import MenuPrincipal
from .contatos.menu_contatos import MenuContatos
from .lembretes.menu_lembrete import MenuLembretes
from .manutecao.menu_manutencao import MenuManutencao
from .financeiro.menu_financas import MenuFinancas
from .instalacao.menu_instalacao import MenuInstalacao


class MenuMain():
    def monta_menu(self):
        self.menu = self.menuBar()

        """Menu Principal"""
        self.file_menu = self.menu.addMenu("&Principal")

        submenu_principal = [
            MenuPrincipal.menu_django(self),
            MenuPrincipal.menu_service(self),
            MenuPrincipal.menu_radio(self),
            MenuPrincipal.menu_arquivo(self),
            MenuPrincipal.menu_cheat(self),
            MenuPrincipal.menu_evolucao(self),
            MenuPrincipal.menu_zzz(self),
            MenuPrincipal.menu_tela(self),
            MenuPrincipal.menu_pclima(self),
            MenuPrincipal.menu_psair(self),
        ]
        for _ in range(len(submenu_principal)):
            submenu_principal[_]

        """Menu Contatos"""
        self.file_menu = self.menu.addMenu("&Contatos")

        submenu_contatos = [
                MenuContatos.menu_adicionar(self),
                MenuContatos.menu_editar(self),
                MenuContatos.menu_deletar(self),
                MenuContatos.menu_listar(self),
                MenuContatos.menu_buscar(self),
                MenuContatos.menu_deletartodos(self),
                MenuContatos.menu_criarbd(self)
        ]
        for _ in range(len(submenu_contatos)):
            submenu_contatos[_]

        """Menu Lembretes"""
        self.file_menu = self.menu.addMenu("&Lembretes")

        submenu_lembretes = [
                MenuLembretes.menu_adicionar(self),
                MenuLembretes.menu_editar(self),
                MenuLembretes.menu_deletar(self),
                MenuLembretes.menu_listar(self),
                MenuLembretes.menu_buscar(self),
                MenuLembretes.menu_deletartodos(self),
                MenuLembretes.menu_criarbd(self)
        ]
        for _ in range(len(submenu_lembretes)):
            submenu_lembretes[_]

        """Menu Manutencao"""
        self.file_menu = self.menu.addMenu("&Manutencao")

        submenu_manutecao = [
            MenuManutencao.menu_graficocpu(self),
            MenuManutencao.menu_monitorix(self),
            MenuManutencao.menu_testesgraf(self),
            MenuManutencao.menu_stressgraf(self),
            MenuManutencao.menu_memoriareal(self),
            MenuManutencao.menu_monitoranetwork(self),
            MenuManutencao.menu_so(self),
            MenuManutencao.menu_eddisco(self),
            MenuManutencao.menu_hardinstalado(self),
            MenuManutencao.menu_linuxdev(self),
            MenuManutencao.menu_discos(self),
            MenuManutencao.menu_sistemadiscos(self),
            MenuManutencao.menu_cdrom(self),
            MenuManutencao.menu_definedadpters(self),
            MenuManutencao.menu_netrouters(self),
            MenuManutencao.menu_netstatisticas(self),
            MenuManutencao.menu_impressoras(self),
            MenuManutencao.menu_processosativos(self),
            MenuManutencao.menu_drivervideo(self),
            MenuManutencao.menu_portas(self),
            MenuManutencao.menu_listaconf(self),
            MenuManutencao.menu_pkginstalados(self),
            MenuManutencao.menu_pkgquebrados(self),
            MenuManutencao.menu_logs(self),
            MenuManutencao.menu_latencia(self)
        ]
        for _ in range(len(submenu_manutecao)):
            submenu_manutecao[_]

        """Menu Financeiro"""
        self.file_menu = self.menu.addMenu("&Financeiro")

        submenu_financas = [
                MenuFinancas.menu_termos(self),
                MenuFinancas.menu_cripto(self)
        ]
        for _ in range(len(submenu_financas)):
            submenu_financas[_]

        """Menu Instalacao"""
        self.file_menu = self.menu.addMenu("&Instalação")

        submenu_instalacao = [
            MenuInstalacao.menu_fonts(self),
            MenuInstalacao.menu_idiversos(self),
            MenuInstalacao.menu_ilamp(self),
            MenuInstalacao.menu_ierros(self),
            MenuInstalacao.menu_igdriver(self),
            MenuInstalacao.menu_ionedriver(self),
            MenuInstalacao.menu_ipkg(self)
        ]
        for _ in range(len(submenu_instalacao)):
            submenu_instalacao[_]

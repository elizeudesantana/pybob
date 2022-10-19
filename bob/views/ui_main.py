"""
pybob - ui_main.py - script python ui principal
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script Inicial.
    2022.02     em : 19/10/2022
                Trocado pyside6 para pyside2 - Qt

Extern Dependency :
                pyside2

Intern Dependency:
                mainwindow
                modelo_clima
                modelo_radio
                toolbarinit

Description:
    Aplicação  unidae de interface.

by: Elizeu de Santana  In: 17/10/2022
"""
from PySide2.QtWidgets import QMainWindow, QMessageBox, QPlainTextEdit
from PySide2.QtGui import QIcon, QAction
from PySide2.QtCore import Slot


from bob.module.menu.menu_main import MenuMain
from bob.module.modelo_clima import Clima
from bob.module.modelo_radio import Radio
from bob.module.toolbarinit import InitToolbar
import sys
import os


CURRENT_DIR = os.path.dirname(os.path.realpath(__file__))


class UiMain(QMainWindow):
    def __init__(self, parent=None):
        QMainWindow.__init__(self, parent)
        self.settings()
        MenuMain.monta_menu(self)

    def settings(self):
        # maximiza a ui
        self.showMaximized()

        # carrega image para o background
        # mg = os.path.join(CURRENT_DIR, "imagem/bg2.jpg")
        # self.setCentralWidget(StackedWidget())

        self.setWindowTitle('PyBob - EliSoftWare®')
        InitToolbar.inittoolbar(self)

        # Clima.atualiza(self)

        self.status = self.statusBar()
        self.status.showMessage('Seja bem vindo - PyBob - EliSoftWare®')

    def togglebar(self):
        state = self.formatbar.isVisible()
        # Set the visibility to its inverse
        self.formatbar.setVisible(not state)

    def toggleformatbar(self):
        state = self.formatbar.isVisible()
        # Set the visibility to its inverse
        self.formatbar.setVisible(not state)

    # Qaction do Menu Principal.
    @Slot()
    def menu_django(self, checked):
        if checked:
            self.msg_construcao()

    @Slot()
    def menu_services(self, checked):
        # tiro o backgraound
        self.setStyleSheet('QWidget {background-image: url()}')

        # coloco botao no bartools
        self.terAction = QAction(QIcon('icons/terminar.png'), 'Scraping', self)
        self.terAction.setShortcut('Ctrl+T')
        self.terAction.setStatusTip('Terminar a leitura do log de arquivos.')
        self.terAction.triggered.connect(self.terminar)
        self.toolbar.addAction(self.terAction)

        # trabalho o edit e os dados.
        plainText = QPlainTextEdit()
        plainText.setStyleSheet(
            """QPlainTextEdit {background-color: #333;
            color: #00FF00;
            font-family: Courier;}"""
        )
        # text-decoration: underline;
        # text = str(os.popen('cat /var/log/dpkg.log').read())
        # text = str(os.popen('cat /var/log/apache2.log').read())
        text = str(os.popen('cat /var/log/syslog').read())

        self.setCentralWidget(plainText)
        plainText.textChanged.connect(
            lambda: plainText.document().toPlainText()
        )
        plainText.document().setPlainText(text)

        # informo no status bar
        self.status.showMessage('Lendo logs do sistema de arquivo.')

        # systemctl list-dependencies --type service
        # systemctl list-units --type service --all
        # systemctl list-units --type service
        # service --status-all;
        # Mostra_diretorio "/etc/init.d";
        # #Dependencias lnav;
        # # e_arrow -l "As escolhas disponiveis sao: (l)nav, (d)pkg log,
        # # (a)pache2 log, -(r) old logs, -(t) timestamps e -a re(c)ent : "

    def terminar(self):
        self.toolbar.clear()
        self.settings()

    @Slot()
    def menu_radio(self, checked):
        Radio.liga_radio(self)

    @Slot()
    def menu_arquivo(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_cht(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_evogit(self, checked):
        import os

        os.system('cd ~/w_space/git_repository/bob/bob')
        #  --background-image $HOME/projetos/bob/doc/sky.jpg")
        os.system('gource')   # diretorio clonado git

    @Slot()
    def menu_zz(self, checked):
        """
        Script bash, com varias funcoes.
        """

        # limpar esta mensagem, colocar um input para escolha e
        # apresentar a saida
        msg = str(os.popen('bash lib/zzfuncao.sh zzzz').read())
        popup = QMessageBox(self)
        popup.setIcon(QMessageBox.Warning)
        popup.setText(msg)
        popup.setStandardButtons(QMessageBox.Cancel)
        answer = popup.exec_()
        if answer == QMessageBox.Cancel:
            popup.close()

    @Slot()
    def menu_tela(self, checked):
        """
        Protecao de tela em PHP, tipo ascii um aquario  com peixes
        simulando pescaria.

        Requerimentos para instalacao:

        sudo apt install libcurses-perl
        wget http://search.cpan.org/CPAN/authors/id/K/KB/\
            KBAUCOM/Term-Animation-2.6.tar.gz
        tar -zxvf Term-Animation-2.6.tar.gz
        cd Term-Animation-2.6
        perl Makefile.PL &&  make &&   make test
        sudo make install
        wget --no-check-certificate http://www.robobunny.com/\
            projects/asciiquarium/asciiquarium.tar.gz
        tar -zxvf asciiquarium.tar.gz
        cd asciiquarium_1.1
        sudo cp asciiquarium /usr/local/bin/
        sudo chmod 0755 /usr/local/bin/asciiquarium
        ./asciiquarium
        """
        os.system('./lib/asciiquarium')

    @Slot()
    def menu_clima(self, checked):
        """
        Atualiza label canto direito, com mensagem
        download clima de http://wttr.in
        """
        Clima.atualiza(self)

    @Slot()
    def exit_sair(self, checked):
        sys.exit()

    """Menu Contatos."""
    @Slot()
    def menu_adiciona_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_edita_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_deleta_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_lista_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_busca_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_deleta_all_contato(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_criardb_contato(self, checked):
        self.msg_construcao()

    """Menu Lembretes."""
    @Slot()
    def menu_adiciona_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_edita_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_deleta_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_lista_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_busca_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_deleta_all_lembrete(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_criardb_lembrete(self, checked):
        self.msg_construcao()

    """Menu Manutencao."""
    @Slot()
    def menu_grafcpu(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_monitorix(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_testecpu(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_testestress(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_memoriareal(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_monitnet(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_monitso(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_discoes(self, checked):
        self.msg_construcao()

    """Menu Finaceiro."""
    @Slot()
    def menu_cripto(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_termos(self, checked):
        self.msg_construcao()

    """Menu Instalacao."""
    @Slot()
    def menu_shellfonts(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_diversos(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_lamp(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_erros(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_griver(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_onedriver(self, checked):
        self.msg_construcao()

    @Slot()
    def menu_pkg(self, checked):
        self.msg_construcao()

    """Aviso temporario."""
    def msg_construcao(self):
        popup = QMessageBox(self)
        popup.setIcon(QMessageBox.Warning)
        popup.setText('Este programa esta em construcao')
        popup.setInformativeText('Agradeco a pacietncia.')
        popup.setStandardButtons(QMessageBox.Cancel)
        popup.setDefaultButton(QMessageBox.Cancel)
        answer = popup.exec_()
        if answer == QMessageBox.Cancel:
            popup.close()

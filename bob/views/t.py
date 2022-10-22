from PySide2.QtWidgets import (
    QApplication,
    QMainWindow,
    QDialog,
    QTableWidget,
    QToolBar,
    QAction,
    QDialogButtonBox,
    QStatusBar,
    QTableWidgetItem,
    QPushButton,
    QVBoxLayout,
    QLineEdit,
    QMessageBox,
    QLabel,
    QComboBox,
)
from PySide2.QtGui import QIcon, QPixmap, QIntValidator
# from PySide2.QtCore import *
# from PySide2.QtPrintSupport import *
from pathlib import Path
import sqlite3
import sys

# import time
# import os


class DeleteDialog(QDialog):
    def __init__(self, *args, **kwargs):
        super(DeleteDialog, self).__init__(*args, **kwargs)

        self.QBtn = QPushButton()
        self.QBtn.setText('Delete : ')

        self.setWindowTitle('Deletar Alunos')
        self.setFixedWidth(300)
        self.setFixedHeight(100)

        self.QBtn.clicked.connect(self.deletestudent)

        layout = QVBoxLayout()

        self.deleteinput = QLineEdit()
        self.onlyInt = QIntValidator()
        self.deleteinput.setValidator(self.onlyInt)
        self.deleteinput.setPlaceholderText('Inscrição No')
        layout.addWidget(self.deleteinput)

        layout.addWidget(self.QBtn)
        self.setLayout(layout)

    def deletestudent(self):
        delrol = ''
        delrol = self.deleteinput.text()

        try:
            self.conn = sqlite3.connect('database.db')
            self.c = self.conn.cursor()
            result = self.c.execute(
                'DELETE FROM students WHERE roll =' + str(delrol)
            )
            result.fetchone()
            self.conn.commit()
            self.c.close()
            self.conn.close()

            QMessageBox.information(QMessageBox(), 'Sucesso', 'Deletado')
            self.close()
        except Exception:
            QMessageBox.warning(QMessageBox(), 'Erro!', 'erro')


class SearchDialog(QDialog):
    def __init__(self, *args, **kwargs):  # Construtor
        super(SearchDialog, self).__init__(*args, **kwargs)

        self.QBtn = QPushButton()
        self.QBtn.setText('Pesquisar : ')

        self.setWindowTitle('Pesquisar por Alunos')
        self.setFixedWidth(300)
        self.setFixedHeight(100)

        self.QBtn.clicked.connect(self.searchstudent)

        layout = QVBoxLayout()

        self.searchinput = QLineEdit()
        self.onlyInt = QIntValidator()
        self.searchinput.setValidator(self.onlyInt)
        self.searchinput.setPlaceholderText('Inscrição No')
        layout.addWidget(self.searchinput)

        layout.addWidget(self.QBtn)
        self.setLayout(layout)

    def searchstudent(self):
        searchrol = ''
        searchrol = self.searchinput.text()

        try:

            self.conn = sqlite3.connect('database.db')
            self.c = self.conn.cursor()
            result = self.c.execute(
                'SELECT * FROM students WHERE roll =' + str(searchrol)
            )
            row = result.fetchone()
            searchresult = (
                'Inscrição No: '
                + str(row[0])
                + '\n'
                + 'Nome: '
                + str(row[1])
                + '\n'
                + 'Filial: '
                + str(row[2])
                + '\n'
                + 'Semestre: '
                + str(row[3])
                + '\n'
                + 'Telefone'
                + str(row[4])
                + '\n'
                + 'Endereço: '
                + str(row[5])
            )
            QMessageBox.information(QMessageBox(), 'Sucesso', searchresult)
            self.conn.commit()
            self.c.close()
            self.conn.close()

        except Exception:

            QMessageBox.warning(QMessageBox(), 'Erro!', 'erro')


class InsertDialog(QDialog):
    def __init__(self, *args, **kwargs):  # Construtor
        super(InsertDialog, self).__init__(*args, **kwargs)

        self.QBtn = QPushButton()
        self.QBtn.setText('Registrar : ')

        self.setWindowTitle('Dados do Aluno')
        self.setFixedWidth(300)
        self.setFixedHeight(300)

        self.QBtn.clicked.connect(self.addstudent)

        layout = QVBoxLayout()

        self.nameinput = QLineEdit()
        self.nameinput.setPlaceholderText('Nome')
        layout.addWidget(self.nameinput)

        self.branchinput = QComboBox()
        self.branchinput.addItem('Eng. Química')
        self.branchinput.addItem('Eng. Cívil')
        self.branchinput.addItem('Elétrica')
        self.branchinput.addItem('Eletrônica')
        self.branchinput.addItem('Automação')
        self.branchinput.addItem('Elettrônica e Comunicaço')
        self.branchinput.addItem('Eletrônica e Computação')
        self.branchinput.addItem('Tecnologia da Informação')
        layout.addWidget(self.branchinput)

        self.seminput = QComboBox()
        self.seminput.addItem('1')
        self.seminput.addItem('2')
        self.seminput.addItem('3')
        self.seminput.addItem('4')
        self.seminput.addItem('5')
        self.seminput.addItem('6')
        self.seminput.addItem('7')
        self.seminput.addItem('8')
        layout.addWidget(self.seminput)

        self.mobileinput = QLineEdit()
        self.mobileinput.setPlaceholderText('Celular No')
        layout.addWidget(self.mobileinput)

        self.addressinput = QLineEdit()
        self.addressinput.setPlaceholderText('Endereço')
        layout.addWidget(self.addressinput)

        layout.addWidget(self.QBtn)
        self.setLayout(layout)

    def addstudent(self):
        name = ''
        branch = ''
        sem = -1
        mobile = ''
        address = ''

        name = self.nameinput.text()
        branch = self.branchinput.itemText(self.branchinput.currentIndex())
        sem = self.seminput.itemText(self.seminput.currentIndex())
        mobile = self.mobileinput.text()
        address = self.addressinput.text()

        try:
            # inserindo dados na tabela
            self.conn = sqlite3.connect('database.db')
            self.c = self.conn.cursor()
            self.c.execute(
                'INSERT INTO students(name, branch, sem, mobile, address) \
                VALUES (?,?,?,?,?)',
                (name, branch, sem, mobile, address),
            )
            self.conn.commit()
            self.c.close()
            self.conn.close()
            QMessageBox.information(
                QMessageBox(), 'Sucesso!', 'Cadastro com sucesso'
            )
            window.loaddata()
            self.close()
        except Exception:
            QMessageBox.information(QMessageBox(), 'Erro!', 'erro')


class AboutDialog(QDialog):
    def __init__(self, *args, **kwargs):
        super(AboutDialog, self).__init__(*args, **kwargs)

        self.setFixedWidth(500)
        self.setFixedHeight(500)

        qbtn = QDialogButtonBox.Ok
        self.buttonBox = QDialogButtonBox(qbtn)
        self.buttonBox.accepted.connect(self.accept)
        self.buttonBox.rejected.connect(self.reject)

        layout = QVBoxLayout()

        self.setWindowTitle('Sobre')
        title = QLabel('Cadastro de Alunos')
        font = title.font()
        font.setPointSize(20)
        title.setFont(font)

        labelpic = QLabel()
        home = Path.home()
        print(home)
        # addr = Path(home, 'Documentos', 'pybob', 'bob', 'views', 'static', 'work.png')  # absolute addrs
        addr = Path('static', 'work.png')
        print(addr)
        pixmap = QPixmap(addr)
        pixmap = pixmap.scaledToWidth(275)
        labelpic.setPixmap(pixmap)
        labelpic.setFixedHeight(150)

        layout.addWidget(title)
        layout.addWidget(QLabel('V1.0'))
        layout.addWidget(QLabel('Copyright EliSoftWare 2019'))
        layout.addWidget(labelpic)
        layout.addWidget(self.buttonBox)
        self.setLayout(layout)


class MainWindow(QMainWindow):
    def __init__(self, *args, **kwargs):   # Construtor
        super(MainWindow, self).__init__(*args, **kwargs)  # Polimorfismo

        """[ Banco de dados ]"""
        self.conn = sqlite3.connect('database.db')
        self.c = self.conn.cursor()
        self.c.execute(
            'CREATE TABLE IF NOT EXISTS students(roll INTEGER PRIMARY KEY \
            AUTOINCREMENT, name TEXT, branch TEXT, sem INTEGER, mobile \
            INTEGER, address TEXT)'
        )
        self.c.close()

        """[ Configurações gráficas ]"""
        self.setWindowTitle('Cadastro de Alunos')  # Define o título da janela
        self.setWindowIcon(QIcon('static/software.png'))  # Fica para depois

        """[ Dimensionamento ]"""
        self.resize(1200, 800)  # Redefinir o tamanho da janela
        self.setMinimumSize(800, 600)  # Dimensão Mínima

        """[ Fluxo do programa (Menu) ]"""
        file_menu = self.menuBar().addMenu('&Arquivo')  # Menu Arquivo

        adduser_action = QAction(
            QIcon('static/data.png'), 'Adicionar Aluno', self
        )
        adduser_action.triggered.connect(self.insert)
        file_menu.addAction(adduser_action)

        refresh_action = QAction(
            QIcon('/static/checklist.png'), 'Atualizar dados dos alunos', self
        )
        file_menu.addAction(refresh_action)

        search_action = QAction(
            QIcon('/static/web.png'), 'Pesquisar Alunos', self
        )
        search_action.triggered.connect(self.search)
        file_menu.addAction(search_action)

        delete_action = QAction(
            QIcon('/static/work.png'), 'Deletar Alunos', self
        )
        delete_action.triggered.connect(self.delete)
        file_menu.addAction(delete_action)

        # Menu Ajuda
        help_menu = self.menuBar().addMenu('&Ajuda')

        """[ Barra de Ferramenta ]"""
        # Inicializa a barra de ferramenta
        toolbar = QToolBar()
        toolbar.setMovable(False)  # Fixar
        self.addToolBar(toolbar)  # Adicionar

        btn_ac_adduser = QAction(
            QIcon('/static/data.png'), 'Adicionar Aluno', self
        )
        btn_ac_adduser.triggered.connect(self.insert)
        btn_ac_adduser.setStatusTip('add Aluno')
        toolbar.addAction(btn_ac_adduser)

        btn_ac_refresh = QAction(
            QIcon('/static/checklist.png'), 'Atualizar dados dos alunos', self
        )
        btn_ac_refresh.triggered.connect(self.loaddata)
        btn_ac_refresh.setStatusTip('Atualizar Dados')
        toolbar.addAction(btn_ac_refresh)

        btn_ac_search = QAction(
            QIcon('/static/web.png'), 'Pesquisar Alunos', self
        )
        btn_ac_search.triggered.connect(self.search)
        btn_ac_search.setStatusTip('Pesquisar')
        toolbar.addAction(btn_ac_search)

        btn_ac_delete = QAction(
            QIcon('/static/work.png'), 'Deletar Alunos', self
        )
        btn_ac_delete.triggered.connect(self.delete)
        btn_ac_delete.setStatusTip('Deletar')
        toolbar.addAction(btn_ac_delete)

        about_action = QAction(
            QIcon('/static/chip.png'), 'Desenvolvedor', self
        )
        about_action.triggered.connect(self.about)
        help_menu.addAction(about_action)

        """[ Status bar ]"""
        statusbar = QStatusBar()
        self.setStatusBar(statusbar)

        """[Tabela dos dados cadastrais (body)]"""
        # Criar table
        self.tableWidget = QTableWidget()
        # Centralizar Table
        self.setCentralWidget(self.tableWidget)
        # Alternar cores da linhas
        self.tableWidget.setAlternatingRowColors(True)
        # Números de colunas
        self.tableWidget.setColumnCount(6)
        # Arrumar colunas
        self.tableWidget.horizontalHeader().setCascadingSectionResizes(False)
        # Ordenação
        self.tableWidget.horizontalHeader().setSortIndicatorShown(False)
        # Preenche horizontal
        self.tableWidget.horizontalHeader().setStretchLastSection(True)
        # Mostrar
        self.tableWidget.verticalHeader().setVisible(False)
        # Arrumar linhas
        self.tableWidget.verticalHeader().setCascadingSectionResizes(False)
        # preenche vertical
        self.tableWidget.verticalHeader().setStretchLastSection(True)
        # Caption das colunas
        self.tableWidget.setHorizontalHeaderLabels(
            (
                'Inscrição no',
                'Nome',
                'Filial',
                'Semestre',
                'Telefone',
                'Endereço',
            )
        )

    def loaddata(self):
        self.connection = sqlite3.connect('database.db')
        query = 'SELECT * FROM students'
        result = self.connection.execute(query)
        self.tableWidget.setRowCount(0)
        for row_number, row_data in enumerate(result):
            self.tableWidget.insertRow(row_number)
            for column_number, data in enumerate(row_data):
                self.tableWidget.setItem(
                    row_number, column_number, QTableWidgetItem(str(data))
                )
            # self.connection.close()

    def insert(self):
        dlg = InsertDialog()
        dlg.exec_()

    def delete(self):
        dlg = DeleteDialog()
        dlg.exec_()

    def search(self):
        dlg = SearchDialog()
        dlg.exec_()

    def about(self):
        dlg = AboutDialog()
        dlg.exec_()


# Instância Qwidgets (janelas gráficas) e trata eventos
# QGuiApplication tbm pode ser usada qdo XML,
# QCoreApplication qdo for shell
app = QApplication()
window = MainWindow()
window.show()
window.loaddata()

sys.exit(app.exec_())  # Loop forever [while True]

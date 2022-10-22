from PyQt5 import QtWidgets, QtCore, QtGui
from PyQt5.QtWidgets import (
    QMainWindow,
    QLabel,
    QApplication,
    QGridLayout,
    QWidget
)
from PyQt5.QtCore import QSize
import subprocess
import sys


class MyWindow(QMainWindow):
    def __init__(self):
        super(MyWindow, self).__init__()
        self.setup_main_window()
        self.initui()

    def setup_main_window(self):
        self.x = 640
        self.y = 480
        self.setMinimumSize(QSize(self.x, self.y))
        self.setWindowTitle("Processamento digital de Imagem")
        self.wid = QWidget()
        self.setCentralWidget(self.wid)
        self.layout = QGridLayout()
        self.wid.setLayout(self.layout)

    def initui(self):
        '''
        Criar os widgetes (Label, text, Button, Image)
        '''

        # Criando o Qlabel para o texto
        self.texto = QLabel("Aplicativo from PyQt5,self", self)
        self.texto.adjustSize()
        self.largura = self.texto.frameGeometry().width()
        self.altura = self.texto.frameGeometry().height()
        self.texto.setAlignment(QtCore.Qt.AlignCenter)  # Alignment

        # Criando um botao
        self.b1 = QtWidgets.QPushButton(self)
        self.b1.setText("Open")
        self.b1.clicked.connect(self.open_file)
        self.b2 = QtWidgets.QPushButton(self)
        self.b2.setText("transform")
        self.b2.clicked.connect(self.transform)

        # Criando as Imagens
        self.imagem1 = QLabel()
        self.endereco1 = 'bg1.png'
        self.pixmap1 = QtGui.QPixmap(self.endereco1)
        self.pixmap1 = self.pixmap1.scaled(250, 250, QtCore.Qt.KeepAspectRatio)
        self.imagem1.setPixmap(self.pixmap1)
        self.imagem1.setAlignment(QtCore.Qt.AlignCenter)

        self.imagem2 = QLabel()
        self.endereco2 = 'bg1.png'
        self.pixmap2 = QtGui.QPixmap(self.endereco2)
        self.pixmap2 = self.pixmap2.scaled(250, 250, QtCore.Qt.KeepAspectRatio)
        self.imagem2.setPixmap(self.pixmap2)
        self.imagem2.setAlignment(QtCore.Qt.AlignCenter)

        # Organizando os widgets dentro do gridLayout
        self.layout.addWidget(self.texto, 0, 0, 1, 2)
        self.layout.addWidget(self.b1, 2, 0)
        self.layout.addWidget(self.b2, 2, 1)
        self.layout.addWidget(self.imagem1, 1, 0)
        self.layout.addWidget(self.imagem2, 1, 1)
        self.layout.setRowStretch(0, 0)
        self.layout.setRowStretch(1, 1)
        self.layout.setRowStretch(2, 0)

    # Metodo para acao do botao
    def open_file(self):
        filename, _ = QtWidgets.QFileDialog.getOpenFileName(
            self, caption='open_image', directory=QtCore.QDir.currentPath(),
            filter='All files(*.*);;Images PPM(*.ppm; *.pgm; *.pbm);; \
            Images JPG(*.jpg; *.png)',
            initialFilter='Images JPG(*.jpg; *.png)'
        )

        print(filename)
        if filename != '':
            self.endereco1 = filename
            self.pixmap1 = QtGui.QPixmap(self.endereco1)
            self.pixmap1 = self.pixmap1.scaled(
                250, 250, QtCore.Qt.KeepAspectRatio
            )
            self.imagem1.setPixmap(self.pixmap1)

    def transform(self):
        self.entrada = self.endereco1
        self.saida = 'arquivo_novo.pgm'
        self.script = 'ppm_to_pgm.py'
        self.program = 'python' + self.script + ' \"' + \
            self.entrada + '\" ' + self.saida
        print(self.program)
        subprocess.run(self.program, shell=True)
        self.endereco2 = self.saida
        self.pixmap2 = QtGui.QPixmap(self.endereco2)
        self.pixmap2 = self.pixmap2.scaled(
            250, 250, QtCore.Qt.KeepAspectRatio
        )
        self.image2.setPixmap(self.pixmap2)

    def button_clicked(self):
        self.texto.setText('Botao clicado')
        self.texto.adjustSize()
        self.novoendereco = QtGui.QPixmap('bg1.pbm')
        self.imagem1.setPixmap(self.novoendereco)


def window():
    app = QApplication(sys.argv)
    win = MyWindow()
    win.show()
    sys.exit(app.exec())


window()

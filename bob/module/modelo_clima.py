from lib.modelo_texto import LerArquivoTexto
from PySide6.QtWidgets import QLabel
from PySide6.QtCore import Qt
from lib.shcmd import Sh as _


class Clima():
    def atualiza(self):
        """
            acrescentar geolocalização : Guaratiba
            solicitar ao usario a localização, populacionar dropdaw
            com locais posssiveis.
            salvar ela em um config
            adicionar um timer para atualizar a cada 30 min.
            mostrar previsão para os demais dias.
        """
        _().curl("'wttr.in/{Guaratiba}?format=%l:%c+%t+%h+%M+%w+%p+%P+%m' \
            > doc/clima.txt")
        self.label = QLabel(LerArquivoTexto('doc/clima.txt').ler_arquivo())
        self.label.setAlignment(Qt.AlignRight)
        self.setCentralWidget(self.label)

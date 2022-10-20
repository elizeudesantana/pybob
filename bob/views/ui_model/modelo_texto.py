"""
    Bobpy manfile script python
    version="2020.01"
    scriptFileVersion="1.0.0"

    History:
        20201.01    Script first version, template method file
                    LerArquivoTexto, EscreverArquivoTexto.

    Dependency:
        pathlib, manfile

    by: Elizeu de Santana  In: 02/02/2020
"""
from . modelo import LerArquivo, EscreverArquivo
from pathlib import Path


class LerArquivoTexto(LerArquivo):
    def __init__(self, arquivo):
        self.arquivo = Path(arquivo)
        self.resultado = None

    def ler_conteudo(self):
        self.resultado = self.arquivo.read_text()

    def depois_de_ler(self):
        """Limpar dados."""   # import pdb; pdb.set_trace()
        self.resultado = self.resultado.replace('\n', '')

    def antes_de_ler(self):
        """Retornar validação"""
        pass


class EscreverArquivoTexto(EscreverArquivo):
    def __init__(self, arquivo, conteudo):
        self.arquivo = Path(arquivo)
        self.conteudo = conteudo

    def escrever_conteudo(self):
        self.arquivo.write_text(self.conteudo)

    def depois_de_escrever(self):
        pass

    def antes_de_escrever(self):
        pass

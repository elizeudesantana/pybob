"""
    Bobpy manfile script python
    version="2020.01"
    scriptFileVersion="1.0.0"

    History:
        20201.01    Script first version, template method file
                    RenomeiaArquivo.

    Dependency:
        pathlib, manfile

    by: Elizeu de Santana  In: 02/02/2020
"""
from . modelo import RenomearArquivo
from pathlib import Path


class RenomeiaArquivo(RenomearArquivo):
    def __init__(self, arquivo, novo_nome_arquivo):
        self.arquivo = Path(arquivo)
        self.novo_nome_arquivo = Path(novo_nome_arquivo)

    def renomeia_arquivo(self):
        try:
            if self.arquivo.rename(self.novo_nome_arquivo) is not None:
                print("Sucess: Arquivo renomeado!")
            else:
                print("Erro: Arquivo não renomeado!")
        except FileNotFoundError:
            print("Erro: Não encontrado arquivo solicitado!")

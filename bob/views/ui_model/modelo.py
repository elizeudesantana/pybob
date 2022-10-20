"""
    Bobpy manfile script python
    version="2020.01"
    scriptFileVersion="1.0.0"

    History:
        20201.01    Script first version, template method file
                    LerArquivo, EscreverArquivo, RenomearArquivo.

    Dependency:
        pathlib, abc

    by: Elizeu de Santana  In: 02/02/2020
"""
from abc import ABC, abstractmethod


class LerArquivo(ABC):
    def ler_arquivo(self):
        """Teplate Method."""
        self.antes_de_ler()
        self.ler_conteudo()
        self.depois_de_ler()
        return self.resultado

    @abstractmethod
    def ler_conteudo(self):
        pass

    def depois_de_ler(self):
        pass

    def antes_de_ler(self):
        pass


class EscreverArquivo(ABC):
    def escrever_arquivo(self):
        """Teplate Method."""
        self.antes_de_escrever()
        self.escrever_conteudo()
        self.depois_de_escrever()

    @abstractmethod
    def escrever_conteudo(self):
        pass

    def depois_de_escrever(self):
        pass

    def antes_de_escrever(self):
        pass


class RenomearArquivo(ABC):
    def renomear_arquivo(self):
        """Teplate Method."""
        self.renomeia_arquivo()

    @abstractmethod
    def renomeia_arquivo(self):
        pass
        
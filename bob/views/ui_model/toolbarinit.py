"""
pybob - toolbarinit.py - script python barra init
version="2022.01"
scriptFileVersion="0.1.0"

History:
    2022.01     Script inicializa a barra de menu.

Extern Dependency :
                pyside6

Intern Dependency:
                mainwindow

Description:
    Aplicação pybob, menu barra.

by: Elizeu de Santana  In: 18/10/2022
"""
from PySide2.QtGui import QIcon
from PySide2.QtWidgets import QAction


class InitToolbar():
    def inittoolbar(self):
        self.newAction = QAction(QIcon("icons/new.png"), "Scraping", self)
        self.newAction.setShortcut("Ctrl+N")
        self.newAction.setStatusTip("Create a new document from scratch.")
        self.newAction.triggered.connect(InitToolbar.scraping)

        self.openAction = QAction(QIcon("icons/open.png"), "NLTK", self)
        self.openAction.setStatusTip("Open existing document")
        self.openAction.setShortcut("Ctrl+O")
        self.openAction.triggered.connect(InitToolbar.nlp)

        # self.saveAction = QAction(QIcon("icons/save.png"),"Save",self)
        # self.saveAction.setStatusTip("Save document")
        # self.saveAction.setShortcut("Ctrl+S")
        # self.saveAction.triggered.connect(self.save)

        # self.printAction = QAction(QIcon("icons/print.png"),
        # "Print document",self)
        # self.printAction.setStatusTip("Print document")
        # self.printAction.setShortcut("Ctrl+P")
        # self.printAction.triggered.connect(self.printHandler)

        # self.previewAction = QAction(QIcon("icons/preview.png"),
        # "Page view",self)
        # self.previewAction.setStatusTip("Preview page before printing")
        # self.previewAction.setShortcut("Ctrl+Shift+P")
        # self.previewAction.triggered.connect(self.preview)

        # self.findAction = QAction(QIcon("icons/find.png"),
        # "Find and replace",self)
        # self.findAction.setStatusTip("Find and replace words in
        # your document")
        # self.findAction.setShortcut("Ctrl+F")
        # self.findAction.triggered.connect(find.Find(self).show)

        # self.cutAction = QAction(QIcon("icons/cut.png"),
        # "Cut to clipboard",self)
        # self.cutAction.setStatusTip("Delete and copy text to clipboard")
        # self.cutAction.setShortcut("Ctrl+X")
        # self.cutAction.triggered.connect(self.text.cut)
        #
        # self.copyAction = QAction(QIcon("icons/copy.png"),
        # "Copy to clipboard",self)
        # self.copyAction.setStatusTip("Copy text to clipboard")
        # self.copyAction.setShortcut("Ctrl+C")
        # self.copyAction.triggered.connect(self.text.copy)
        #
        # self.pasteAction = QAction(QIcon("icons/paste.png"),
        # "Paste from clipboard",self)
        # self.pasteAction.setStatusTip("Paste text from clipboard")
        # self.pasteAction.setShortcut("Ctrl+V")
        # self.pasteAction.triggered.connect(self.text.paste)
        #
        # self.undoAction = QAction(QIcon("icons/undo.png"),
        # "Undo last action",self)
        # self.undoAction.setStatusTip("Undo last action")
        # self.undoAction.setShortcut("Ctrl+Z")
        # self.undoAction.triggered.connect(self.text.undo)
        #
        # self.redoAction = QAction(QIcon("icons/redo.png"),
        # "Redo last undone thing",self)
        # self.redoAction.setStatusTip("Redo last undone thing")
        # self.redoAction.setShortcut("Ctrl+Y")
        # self.redoAction.triggered.connect(self.text.redo)

        # dateTimeAction = QAction(QIcon("icons/calender.png"),
        # "Insert current date/time",self)
        # dateTimeAction.setStatusTip("Insert current date/time")
        # dateTimeAction.setShortcut("Ctrl+D")
        # dateTimeAction.triggered.connect(datetime.DateTime(self).show)
        #
        # wordCountAction = QAction(QIcon("icons/count.png"),
        # "See word/symbol count",self)
        # wordCountAction.setStatusTip("See word/symbol count")
        # wordCountAction.setShortcut("Ctrl+W")
        # wordCountAction.triggered.connect(self.wordCount)
        #
        # tableAction = QAction(QIcon("icons/table.png"),"Insert table",self)
        # tableAction.setStatusTip("Insert table")
        # tableAction.setShortcut("Ctrl+T")
        # tableAction.triggered.connect(table.Table(self).show)
        #
        # imageAction = QAction(QIcon("icons/image.png"),"Insert image",self)
        # imageAction.setStatusTip("Insert image")
        # imageAction.setShortcut("Ctrl+Shift+I")
        # imageAction.triggered.connect(self.insertImage)
        #
        # bulletAction = QAction(QIcon("icons/bullet.png"),
        # "Insert bullet List",self)
        # bulletAction.setStatusTip("Insert bullet list")
        # bulletAction.setShortcut("Ctrl+Shift+B")
        # bulletAction.triggered.connect(self.bulletList)
        #
        # numberedAction = QAction(QIcon("icons/number.png"),
        # "Insert numbered List",self)
        # numberedAction.setStatusTip("Insert numbered list")
        # numberedAction.setShortcut("Ctrl+Shift+L")
        # numberedAction.triggered.connect(self.numberList)

        self.toolbar = self.addToolBar("Options")

        self.toolbar.addAction(self.newAction)
        self.toolbar.addAction(self.openAction)
        # self.toolbar.addAction(self.saveAction)
        #
        # self.toolbar.addSeparator()
        #
        # self.toolbar.addAction(self.printAction)
        # self.toolbar.addAction(self.previewAction)
        #
        # self.toolbar.addSeparator()
        #
        # self.toolbar.addAction(self.cutAction)
        # self.toolbar.addAction(self.copyAction)
        # self.toolbar.addAction(self.pasteAction)
        # self.toolbar.addAction(self.undoAction)
        # self.toolbar.addAction(self.redoAction)
        #
        # self.toolbar.addSeparator()
        #
        # self.toolbar.addAction(self.findAction)
        # self.toolbar.addAction(dateTimeAction)
        # self.toolbar.addAction(wordCountAction)
        # self.toolbar.addAction(tableAction)
        # self.toolbar.addAction(imageAction)
        #
        # self.toolbar.addSeparator()
        #
        # self.toolbar.addAction(bulletAction)
        # self.toolbar.addAction(numberedAction)

        self.addToolBarBreak()

    def scraping(self):
        print("dentro do scrpaing")

    def nlp(self):
        print("dentro de nlp")

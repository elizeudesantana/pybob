"""
    Bobpy vias script python
    version="2020.01"
    scriptFileVersion="1.0.0"

    History:
        20201.01    Script version inicial, configura diretórios e arquivos.

    Dependências:
        pathlib, abc

    by: Elizeu de Santana  Em: 02/02/2020
"""
from abc import ABC, abstractmethod


class ManipulaDiretorio(ABC):
    def obtem_diretorio(self):
        """Teplate Method. (@concreto)"""
        self.abrir_diretorio()

        self.antes_de_ler()  # hooks
        self.diretorio = self.ler_diretorio()
        self.depois_de_ler()  # hooks

        self.fechar_diretorio()

        return self.diretorio

    def list_diretorio(self):
        return Path.cwd()  # pwd
        # import os
        # entries = os.listdir('my_directory/')
        # print(entries)

    def tmp():
        # """Listing subdirectories:"""
        # p = Path('.')
        # print([x for x in p.iterdir() if x.is_dir()])
        # """Listing Python source files in this directory tree:"""
        # print(list(p.glob('**/*.py')))
        # """Navigating inside a directory tree:"""
        # p = Path('/etc')
        # q = p / 'init.d' / 'glances'
        # print(q)  # /etc/init.d/glances
        # print(q.resolve())  # /etc/init.d/glances
        # """Querying path properties:"""
        # print(q.exists())  # True
        # print(q.is_dir())  # False
        # """Opening a file:"""
        # with q.open() as f: f.readline()
        # print(f)
        # # <_io.TextIOWrapper name='/etc/init.d/glances' mode='r' encoding='UTF-8'>

        # """Pure paths"""
        # print(PurePath('requirements.txt'))      # setup.py  <- PurePosixPath
        # print(PurePath('foo', 'some/path', 'bar'))
        # # foo/some/path/bar <- PurePosixPath
        # print(PurePath(Path('foo'), Path('bar')))  # foo/bar <- PurePosixPath
        # print(PurePath())  # PurePosixPath('.') com print .
        # print(PurePath('/etc', '/usr', 'lib64'))  # PurePosixPath('/usr/lib64')
        # print(PurePath('foo//bar'))  # PurePosixPath('foo/bar')
        # print(PurePath('foo/./bar'))  # PurePosixPath('foo/bar')
        # print(PurePath('foo/../bar'))  # PurePosixPath('foo/../bar')
        # print(PurePosixPath('/etc'))  # PurePosixPath('/etc')

        # # General properties
        # print(PurePosixPath('foo') == PurePosixPath('FOO'))  # False
        # p = PurePath('/etc')
        # print(p)  # PurePosixPath('/etc')
        # print(p / 'init.d' / 'apache2')  # PurePosixPath('/etc/init.d/apache2')
        # q = PurePath('bin')
        # print('/usr' / q)  # PurePosixPath('/usr/bin')

        # # import os
        # p = PurePath('/etc')
        # print(os.fspath(p))  # '/etc'  <- equivalente ao print
        # p = PurePath('/etc')
        # print(str(p))  # '/etc'
        # print(bytes(p))  # b'/etc'
        # p = PurePath('/usr/bin/python3')
        # print(p.parts)  # ('/', 'usr', 'bin', 'python3')
        # print(PurePosixPath('/etc').drive)  
        # # '' UNC shares are also considered drives:
        # print(PurePosixPath('/etc').root)  # '/'

        # # PurePath.anchor
        # print(PurePosixPath('/etc').anchor)  # '/'

        # # PurePath.parents
        # p = PurePosixPath('/a/b/c/d')
        # print(p.parent)  # PurePosixPath('/a/b/c')
        # p = PurePosixPath('/')
        # print(p.parent)  # PurePosixPath('/')
        # p = PurePosixPath('.')
        # print(p.parent)  # PurePosixPath('.')
        # p = PurePosixPath('foo/..')
        # print(p.parent)  # PurePosixPath('foo')

        # # PurePath.name
        # print(PurePosixPath('my/library/setup.py').name)  # 'setup.py'

        # # PurePath.suffix
        # print(PurePosixPath('my/library/setup.py').suffix)  # '.py'
        # print(PurePosixPath('my/library.tar.gz').suffix)  # '.gz'
        # print(PurePosixPath('my/library').suffix)  # ''

        # # PurePath.suffixes
        # print(PurePosixPath('my/library.tar.gar').suffixes)  # ['.tar', '.gar']
        # print(PurePosixPath('my/library.tar.gz').suffixes)  # ['.tar', '.gz']
        # print(PurePosixPath('my/library').suffixes)  # []

        # # PurePath.stem
        # print(PurePosixPath('my/library.tar.gz').stem)  # 'library.tar'
        # print(PurePosixPath('my/library.tar').stem)  # 'library'
        # print(PurePosixPath('my/library').stem)  # 'library'

        # # PurePath.as_posix()
        # p = PurePosixPath('/etc/passwd')
        # print(p.as_uri())  # 'file:///etc/passwd'

        # # PurePath.is_absolute()
        # print(PurePosixPath('/a/b').is_absolute())  # True
        # print(PurePosixPath('a/b').is_absolute())  # False

        # # PurePath.is_reserved()
        # print(PurePosixPath('nul').is_reserved())  # False

        # # PurePath.joinpath(*other)
        # print(PurePosixPath('/etc').joinpath('passwd'))  
        # # PurePosixPath('/etc/passwd')
        # print(PurePosixPath('/etc').joinpath(PurePosixPath('passwd')))
        # # PurePosixPath('/etc/passwd')
        # print(PurePosixPath('/etc').joinpath('init.d', 'apache2'))
        # # PurePosixPath('/etc/init.d/apache2')

        # # PurePath.match(pattern)
        # print(PurePath('a/b.py').match('*.py'))  # True
        # print(PurePath('/a/b/c.py').match('b/*.py'))  # True
        # print(PurePath('/a/b/c.py').match('a/*.py'))  # False
        # print(PurePath('/a.py').match('/*.py'))  # True
        # print(PurePath('a/b.py').match('/*.py'))  # False

        # # PurePath.relative_to(*other)
        # p = PurePosixPath('/etc/passwd')
        # print(p.relative_to('/'))  # PurePosixPath('etc/passwd')
        # print(p.relative_to('/etc'))  # PurePosixPath('passwd')
        # # print(p.relative_to('/usr'))
        # # Traceback (most recent call last):
        # #   File "<stdin>", line 1, in <module>
        # #   File "pathlib.py", line 694, in relative_to
        # #     .format(str(self), str(formatted)))
        # # ValueError: '/etc/passwd' does not start with '/usr'

        # # Concrete paths
        # print(Path('setup.py'))  # PosixPath('setup.py')
        # print(PosixPath('/etc'))  # PosixPath('/etc')
        # # import os
        # print(os.name)  # 'posix'
        # print(Path('setup.py'))  # PosixPath('setup.py')
        # print(PosixPath('setup.py'))  # PosixPath('setup.py')

        # # Methods
        # # classmethod Path.cwd()
        # print(Path.cwd())  # PosixPath('/home/elizeu/w_space/git_repository/bobpy')

        # # classmethod Path.home()
        # print(Path.home())  # PosixPath('/home/elizeu')

        # # Path.stat()
        # p = Path('bob_py.py')
        # print(p.stat().st_size)  # 1000
        # print(p.stat().st_mtime)  # 1327883547.852554

        # # Path.chmod(mode)
        # p = Path('readme.md')
        # print(p.stat().st_mode)  # 33277
        # p.chmod(0o444)
        # print(p.stat().st_mode)  # 33060

        # # Path.exists()
        # print(Path('.').exists())  # True
        # print(Path('setup.py').exists())  # True
        # print(Path('/etc').exists())  # True
        # print(Path('nonexistentfile').exists())  # False

        # # Path.expanduser()
        # p = PosixPath('~/films/Monty Python')
        # print(p.expanduser())  # PosixPath('/home/eric/films/Monty Python')

        # # Path.glob(pattern)
        # print(sorted(Path('.').glob('*.py')))
        # # [PosixPath('pathlib.py'), PosixPath('setup.py'),
        # # PosixPath('test_pathlib.py')]
        # print(sorted(Path('.').glob('*/*.py')))
        # # [PosixPath('docs/conf.py')]
        # # The “**” pattern means “this directory and all subdirectories, recursively”
        # # In other words, it enables recursive globbing:
        # print(sorted(Path('.').glob('**/*.py')))
        # # Note Using the “**” pattern in large directory trees may
        # # consume an inordinate amount of time.

        # # Path.group()
        # # Path.is_dir()
        # # Path.is_file()
        # # Path.is_mount()
        # # Path.is_symlink()
        # # Path.is_socket()
        # # Path.is_fifo()
        # # Path.is_block_device()
        # # Path.is_char_device()

        # # Path.iterdir()
        # p = Path('.biblioteca')
        # for child in p.iterdir():
        #     print(child)

        # # Path.lchmod(mode)
        # # Path.lstat()
        # # Path.mkdir(mode=0o777, parents=False, exist_ok=False)

        # # Path.open(mode='r', buffering=-1, encoding=None, errors=None, newline=None)
        # p = Path('bob_py.py')
        # with p.open() as f:
        #     print(f.readline())

        # # Path.owner()
        # # Path.read_bytes()
        # p = Path('my_binary_file')
        # print(p.write_bytes(b'Binary file contents'))  # 20
        # print(p.read_bytes())  # b'Binary file contents'

        # # Path.read_text(encoding=None, errors=None)
        # p = Path('my_text_file')
        # print(p.write_text('Text file contents'))  # 18
        # print(p.read_text())  # 'Text file contents'
        # # The file is opened and then closed.

        # # Path.rename(target)
        # p = Path('foo')
        # print(p.open('w').write('some text'))  # 9
        # target = Path('bar')
        # print(p.rename(target))  # PosixPath('bar')
        # print(target.open().read())  # 'some text'
        # # Changed in version 3.8:
        # # Added return value, return the new Path instance.

        # # Path.replace(target)
        # # Path.resolve(strict=False)
        # p = Path()
        # print(p)  # PosixPath('.')
        # print(p.resolve())  # PosixPath('/home/antoine/pathlib')
        # # “..” components are also eliminated (this is the only method to do so):
        # p = Path('docs/../setup.py')
        # print(p.resolve())  # PosixPath('/home/antoine/pathlib/setup.py')

        # # Path.rglob(pattern)
        # print(sorted(Path().rglob("*.py")))

        # # Path.rmdir()
        # # Path.samefile(other_path)
        # p = Path('test')
        # q = Path('test')
        # print(p.samefile(q))  # True
        # print(p.samefile('test'))  # True

        # # Path.symlink_to(target, target_is_directory=False)
        # try:
        #     p = Path('mylink')
        #     p.symlink_to('bob_py.py')
        #     print(p.resolve())  # PosixPath('/home/antoine/pathlib/setup.py')
        #     print(p.stat().st_size)  # 956
        #     print(p.lstat().st_size)  # 8
        # except:
        #     pass

        # # Path.touch(mode=0o666, exist_ok=True)
        # # Path.unlink(missing_ok=False)
        # # Path.link_to(target)
        # # Path.write_bytes(data)
        # p = Path('my_binary_file')
        # print(p.write_bytes(b'Binary file contents'))  # 20
        # print(p.read_bytes())  # b'Binary file contents'

        # # Path.write_text(data, encoding=None, errors=None)
        # p = Path('my_text_file')
        # print(p.write_text('Text file contents'))  # 18
        # print(p.read_text())  # 'Text file contents'
        pass


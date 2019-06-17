from . import pip


main = pip.package(__name__.rsplit('.')[-1], 'Python language server')

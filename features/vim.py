from . import Feature, system


main = system.package(__name__.rsplit('.')[-1], 'vim')

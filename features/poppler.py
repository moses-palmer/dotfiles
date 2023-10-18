from . import system


main = system.package(
    'libpoppler-glib-dev', description='PDF rendering library')
cairo = system.package(
    'python3-gi-cairo', description='Python 3 Cairo bindings')

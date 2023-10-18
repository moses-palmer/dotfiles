import os

from . import Feature, curl, feature


#: The version to use.
VERSION = '1.28.0'

#: The date of release.
DATE = '202309281329'

#: The URL of the i202309281329ckagenstallation script.
URL = 'https://www.eclipse.org/downloads/download.php?' \
    'file=/jdtls/milestones/{0}/jdt-language-server-{0}-{1}.tar.gz'.format(
        VERSION, DATE)

#: The target path.
TARGET = os.path.expanduser('~/.local/lib/jdtls')


@feature('Eclipse JDT Language Server', {curl})
def main(env: Feature):
    with curl.get(env, URL) as archive:
        env.run('rm', '-rf', TARGET)
        os.makedirs(TARGET)
        env.run('tar', '--extract', '--file', archive, '--directory', TARGET)


@main.checker
def is_installed(env: Feature):
    return os.path.exists(os.path.join(
        TARGET,
        'plugins',
        'org.eclipse.jdt.ls.core_{}.{}.jar'.format(VERSION, DATE)))

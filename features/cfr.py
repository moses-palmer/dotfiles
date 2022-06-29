import os
import shutil

from . import Feature, curl, feature


#: The version of CFR to install.
VERSION = '0.152'

#: The name of the JAR file.
JAR_FILE = 'cfr-{}.jar'.format(VERSION)

#: The directory containing the library file.
TARGET_DIR = os.path.expanduser('~/.local/lib/cfr')

#: The source URL for the library.
SOURCE = 'https://github.com/leibnitz27/cfr/releases/download/{}/{}'.format(
    VERSION, JAR_FILE)

#: The library file.
TARGET = os.path.join(TARGET_DIR, JAR_FILE)


@feature('A Java classfile decompiler', {curl})
def main(env: Feature):
    with curl.get(env, SOURCE) as jar:
        os.makedirs(TARGET_DIR, exist_ok=True)
        shutil.copy(jar, TARGET)


@main.checker
def is_installed(env: Feature):
    return os.path.isfile(TARGET)


@main.completer
def complete(env: Feature):
    for jar in os.listdir(TARGET_DIR):
        if jar != JAR_FILE:
            os.unlink(os.path.join(TARGET_DIR, jar))

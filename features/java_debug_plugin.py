import os
import shutil

from . import Feature, curl, feature, jdtls


#: The version to use.
VERSION = '0.49.0'


#: The base name of the plugin JAR.
BASE_NAME = 'com.microsoft.java.debug.plugin-{0}.jar'.format(VERSION)


#: The URL of the i202309281329ckagenstallation script.
URL = 'https://repo1.maven.org/maven2/com/microsoft/java/' \
    'com.microsoft.java.debug.plugin/{0}/' + BASE_NAME

#: The target path.
TARGET = os.path.join(
    os.path.expanduser('~/.local/lib/jdtls/plugins'),
    BASE_NAME)


@feature('Microsoft Java Debugger', {curl, jdtls})
def main(env: Feature):
    with curl.get(env, URL) as archive:
        shutil.copy(archive, TARGET)


@main.checker
def is_installed(env: Feature):
    return os.path.exists(TARGET)

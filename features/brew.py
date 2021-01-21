import os
import stat

from . import FEATURES, Feature, curl, feature, system


#: The Rust compiler.
BIN = 'brew'

#: The URL of the installation script.
URL = 'https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh'


@feature('The Missing Package Manager for macOS', {curl})
def main(env: Feature):
    with curl.get(env, URL) as script:
        os.chmod(script, stat.S_IRWXU)
        env.run('bash', '-c', script)


@main.preparer
def prioritize(env: Feature):
    FEATURES.remove(env)
    FEATURES.insert(0, env)


@main.checker
def is_installed(env: Feature):
    return system.present(env, BIN)

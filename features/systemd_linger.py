import re
import os
import pwd

from . import Feature, feature


#: The name of the current user.
USER = pwd.getpwuid(os.getuid()).pw_name


@feature('Lingering user sessions')
def main(env: Feature):
    env.run('sudo', 'loginctl', 'enable-linger', USER)


@main.checker
def is_installed(env: Feature):
    regex = re.compile(r'^\s*Linger\s*=\s*yes\s*$')
    return any(
        regex.match(line)
        for line in env.run(
            'loginctl', 'show-user', USER,
            capture=True,
            interactive=False).splitlines())

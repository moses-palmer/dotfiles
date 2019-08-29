import subprocess

from . import Distribution, Version


def information():
    subprocess.check_call(['which', 'termux-info'])
    return (Distribution('Termux', 'termux'), Version('1.0'))

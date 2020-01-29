import subprocess

from . import Distribution, Version


def information():
    subprocess.check_call(
        ['which', 'termux-info'],
        stderr=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL)
    return (Distribution('Termux', 'termux'), Version('1.0'))

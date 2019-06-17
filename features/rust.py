import re
import os
import types

from typing import Optional, Union

from . import Feature, curl, feature, system


#: The Rust compiler.
BIN_RUSTC = 'rustc'

#: The rustup binary.
BIN_RUSTUP = 'rustup'

#: The cargo binary.
BIN_CARGO = 'cargo'


@feature('The Rust programming language', {curl})
def main(env: Feature):
    if env.configuration['env']['distribution'] == 'termux':
        system.install_package(env, 'rust')
    else:
        with curl.get(env, 'https://sh.rustup.rs') as script:
            env.run('sh', script, '-y', '--no-modify-path')

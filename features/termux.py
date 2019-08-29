import os

from . import Feature, feature


#: The runtime directory used by tmux for IPC
RUNTIME_DIR = os.path.join(
    os.getenv('PREFIX', '/'),
    'var/run')

#: The bash profile used to auto-launch tmux
BASH_PROFILE_FILE = os.path.join(
    os.getenv('HOME'),
    '.bash_profile')

#: The bash script used to auto-launch tmux
BASH_PROFILE_DATA = '''# Launch tmux
if [ -z "$TMUX" ]; then
    tmux
fi
'''

#: The file used to load comletions for bash
COMPLETIONS_FILE = os.path.join(
    os.getenv('HOME'),
    '.config/bash/completions')

#: The bash script used to load the completion data
COMPLETIONS_DATA = '''# Load completions
for completion_file in "$PREFIX/etc/bash_completion.d/"*; do
    source "$completion_file"
done
'''


@feature('Termux')
def main(env: Feature):
    # This directory is expected by tmux
    os.makedirs(RUNTIME_DIR, exist_ok=True)
    with open(BASH_PROFILE_FILE, 'w', encoding='utf-8') as f:
        f.write(BASH_PROFILE_DATA)
    with open(COMPLETIONS_FILE, 'w', encoding='utf-8') as f:
        f.write(COMPLETIONS_DATA)


@main.checker
def is_installed(env):
    return (True
        and os.path.isdir(RUNTIME_DIR)
        and os.path.isfile(BASH_PROFILE_FILE)
        and os.path.isfile(COMPLETIONS_FILE))

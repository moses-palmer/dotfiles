import re

from . import Feature, dconf, feature


#: The path to custom key bindings.
PATH = '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'

#: The regular expression matching custom bindings.
CUSTOM_BINDING_RE = re.compile(r'custom([0-9]+)')

#: The values to write.
VALUES = {
    'name': '\'Toggle Terminal Overlay\'',
    'binding': '\'<Primary>section\'',
    'command': '\'dbus-send '
        '--session '
        '--dest=com.newrainsoftware.TerminalOverlay '
        '--type=method_call '
        '/com/newrainsoftware/TerminalOverlay '
        'com.newrainsoftware.TerminalOverlay.Toggle\''}


@feature('Key bindings for Terminal Overlay', {dconf})
def main(env: Feature):
    base = '{}/custom{}'.format(PATH, max(
        (
            int(CUSTOM_BINDING_RE.match(binding).group(1))
            for binding in dconf.list(env, '{}/'.format(PATH))
            if CUSTOM_BINDING_RE.match(binding)),
        default=0) + 1)
    for name, value in VALUES.items():
        dconf.write(env, '{}/{}'.format(base, name), value)


@main.checker
def is_installed(env: Feature):
    return any(
        any(
            dconf.read(env, '{}/{}{}'.format(PATH, binding, name)) == value
            for name, value in VALUES.items())
        for binding in dconf.list(env, '{}/'.format(PATH)))

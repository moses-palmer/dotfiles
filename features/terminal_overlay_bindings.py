import re

from . import Feature, dconf, feature


#: The path to custom key bindings.
PATH = '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings'

#: The regular expression matching custom bindings.
CUSTOM_BINDING_RE = re.compile(r'custom([0-9]+)')

#: The bindings.
BINDINGS = [
    {
        'name': '\'Toggle Terminal Overlay\'',
        'binding': '\'<Primary>section\'',
        'command': '\'dbus-send '
            '--session '
            '--dest=com.newrainsoftware.TerminalOverlay '
            '--type=method_call '
            '/com/newrainsoftware/TerminalOverlay '
            'com.newrainsoftware.TerminalOverlay.Toggle\''},
    {
        'name': '\'Cycle Terminal Overlay Monitor\'',
        'binding': '\'<Primary>Tab\'',
        'command': '\'dbus-send '
            '--session '
            '--dest=com.newrainsoftware.TerminalOverlay '
            '--type=method_call '
            '/com/newrainsoftware/TerminalOverlay '
            'com.newrainsoftware.TerminalOverlay.CycleDisplay\''}]


@feature('Key bindings for Terminal Overlay', {dconf})
def main(env: Feature):
    next_index = max(
        (
            int(CUSTOM_BINDING_RE.match(binding).group(1))
            for binding in dconf.list(env, '{}/'.format(PATH))
            if CUSTOM_BINDING_RE.match(binding)),
        default=0) + 1
    for binding in list_missing(env):
        base = '{}/custom{}'.format(PATH, next_index)
        for name, value in binding.items():
            dconf.write(env, '{}/{}'.format(base, name), value)
        next_index += 1


@main.checker
def is_installed(env: Feature):
    return len(list_missing(env)) == 0


def list_missing(env: Feature) -> [dict]:
    """Lists missing key bindings.
    """
    current_names = [
        dconf.read(env, '{}/{}name'.format(PATH, binding))
        for binding in dconf.list(env, '{}/'.format(PATH))]
    return [
        binding
        for binding in BINDINGS
        if binding['name'] not in current_names]


def _is_installed(env: Feature, name: str) -> bool:
    """Determines whether a single key binding is installed.

    :param name: The name of the key binding.
    """
    return any(
        dconf.read(env, '{}/{}{}'.format(PATH, binding, name)) == value
        for name, value in value.items())

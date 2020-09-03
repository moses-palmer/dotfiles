from . import FEATURES, rust, system


if any(f.name == 'rust' for f in FEATURES if not f.blacklisted):
    rust.binary('rg', 'ripgrep', 'ripgrep')
else:
    system.package('rg', 'ripgrep')

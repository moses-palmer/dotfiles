from . import FEATURES, rust, system


if any(f.name == 'rust' for f in FEATURES if not f.blacklisted):
    main = rust.binary('rg', 'ripgrep')
else:
    main = system.package('ripgrep', 'rg')

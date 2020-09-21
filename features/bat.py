from . import FEATURES, rust, system


if any(f.name == 'rust' for f in FEATURES if not f.blacklisted):
    rust.binary('bat', 'bat', 'bat')
else:
    system.package('bat', 'bat')

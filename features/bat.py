from . import FEATURES, rust, system


if any(f.name == 'rust' for f in FEATURES if not f.blacklisted):
    main = rust.binary('bat', 'bat', 'bat')
else:
    main = system.package('bat', 'bat')

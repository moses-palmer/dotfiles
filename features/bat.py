from . import FEATURES, rust, system

DESCRIPTION = 'A cat(1) clone with wings'


if any(f.name == 'rust' for f in FEATURES if not f.blacklisted):
    main = rust.binary('bat', 'bat', DESCRIPTION)
else:
    main = system.package('bat', 'bat', DESCRIPTION)

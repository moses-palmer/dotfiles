import contextlib
import os
import tempfile

from . import Feature, system


main = system.package(__name__.rsplit('.')[-1])


@contextlib.contextmanager
def get(env: Feature, url: str) -> str:
    """Fetches a resource, writes it to a temporary file and returns the path.

    This function works as a context manager: once the context is exited, the
    temporary file is removed.

    :param env: The feature environment.

    :param url: The source URL.

    :return: the path to a temporary file
    """
    target = tempfile.mktemp()
    try:
        env.run(
            'curl',
            '--output', target,
            '--location',
            url,
            check=True,
            interactive=False,
            silent=True)
        yield target
    finally:
        os.unlink(target)

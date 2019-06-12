import difflib
import enum
import errno
import os
import shutil

from typing import Union


#: The header to show before showing the next item.
__HEADER = None


class CopyMethod(enum.Enum):
    """The methods used when installing dotfiles.
    """
    #: Create symlinks.
    LINK = 'link'

    #: Copy files.
    COPY = 'copy'

    def changed(self, source: str, target: str, filename: str) -> bool:
        """Determines whether a file has been changed.

        :param source: The source directory.

        :param target: The target directory.

        :param filename: The file name, relative to the source directory.

        :return: whether the file has changed
        """
        source = os.path.abspath(os.path.join(source, filename))
        target = os.path.abspath(os.path.join(target, filename))

        if not os.path.exists(target):
            return True

        elif self == CopyMethod.LINK:
            # The target file must be a symlink pointing to the source file
            try:
                return os.readlink(target) != source
            except OSError:
                return True

        elif self == CopyMethod.COPY:
            # The target file must be a non-link with the same content as the
            # source file
            if os.stat(source).st_size != os.stat(target).st_size:
                return True
            elif os.path.islink(target):
                return True
            else:
                with open(source, 'rb') as s:
                    with open(target, 'rb') as t:
                        return s.read() != t.read()

        else:
            raise ValueError(self)

    def copy(self, source: str, target: str, filename: str):
        """Copies a single file.

        This function is interactive if a conflict resolution by the user is
        required.

        :param source: The source directory.

        :param target: The target directory.

        :param filename: The file name, relative to the source directory.
        """
        source = os.path.abspath(os.path.join(source, filename))
        target = os.path.abspath(os.path.join(target, filename))

        # Make sure the target directory exists
        try:
            os.makedirs(os.path.dirname(target))
        except OSError as e:
            if e.errno == errno.EEXIST:
                pass
            else:
                raise

        while os.path.exists(target) or os.path.islink(target):
            r = query(
                '{} already exists. Overwrite? '.format(filename),
                 'yes', 'no', 'diff')
            if r == 'yes':
                os.unlink(target)
                break
            elif r == 'no':
                return
            elif r == 'diff':
                with open(source, encoding='utf-8') as f:
                    sdata = f.readlines()
                try:
                    with open(target, encoding='utf-8') as f:
                        tdata = f.readlines()
                except FileNotFoundError:
                    # The target file may be an invalid link
                    tdata = ''
                for line in difflib.unified_diff(
                        sdata, tdata, fromfile=source, tofile=target):
                    if line[0] == '+':
                        print('\033[0;32m{}\033[0m'.format(line.rstrip()))
                    elif line[0] == '-':
                        print('\033[0;31m{}\033[0m'.format(line.rstrip()))
                    else:
                        print(line.rstrip())

        if self == CopyMethod.LINK:
            os.symlink(source, target)
        elif self == CopyMethod.COPY:
            shutil.copy2(source, target)
        else:
            raise ValueError(self)


def query(prompt: str, *args) -> Union[str, None]:
    """Queries the user for a string.

    :param prompt: The prompt. The options lowercased will be appended.

    :param args: The options. One of these will be returned.

    :return: one of the options, or ``None`` if ``stdin`` is not a tty.
    """
    if not os.isatty(0):
        return None
    else:
        options = [arg.lower() for arg in args]
        prompt = '{} [{}] '.format(prompt, '/'.join(options))
        while True:
            r = input(prompt).lower()
            if r:
                alternatives = [o for o in options if o.startswith(r)]
                if len(alternatives) == 1:
                    return alternatives[0]
                else:
                    print('Please select one of {}'.format(', '.join(options)))


def header(s: str):
    """Prints a header message.

    :param s: The message.
    """
    global __HEADER
    __HEADER = s


def disabled(s: str):
    """Prints a message about a file or feature being disabled.

    :param s: The message.
    """
    _item('\033[0;90m{}\033[0m'.format(s))


def ignoring(s: str):
    """Prints a message about a file or feature being ignored.

    :param s: The message.
    """
    _item('\033[0;94m{}\033[0m'.format(s))


def installing(s: str):
    """Prints a message about a file or feature being installed.

    :param s: The message.
    """
    _item('\033[0;32m{}\033[0m'.format(s))


def removing(s: str):
    """Prints a message about a file or feature being removed.

    :param s: The message.
    """
    _item('\033[0;31m{}\033[0m'.format(s))


def _item(s: str):
    """Displays an item.

    If a header has been queued, it will be shown first.

    :param s: The item to display.
    """
    global __HEADER
    if __HEADER is not None:
        print('\033[1m{}\033[0m'.format(__HEADER))
        __HEADER = None
    print('• {}'.format(s))

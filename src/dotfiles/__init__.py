import difflib
import enum
import errno
import os
import shutil


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
            r = input('{} already exists. Overwrite? [yes/no/diff] '.format(
                filename)).lower()
            if not r:
                pass
            elif r in ('y', 'yes'):
                os.unlink(target)
                break
            elif r in ('n', 'no'):
                return
            elif r in ('d', 'diff'):
                with open(source, encoding='utf-8') as f:
                    sdata = f.readlines()
                with open(target, encoding='utf-8') as f:
                    tdata = f.readlines()
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


def header(s):
    """Prints a header message.

    :param str s: The message.
    """
    print('\033[1m{}\033[0m'.format(s))


def disabled(s):
    """Prints a message about a file or feature being disabled.

    :param str s: The message.
    """
    print('• \033[0;90m{}\033[0m'.format(s))


def ignoring(s):
    """Prints a message about a file or feature being ignored.

    :param str s: The message.
    """
    print('• \033[0;94m{}\033[0m'.format(s))


def installing(s):
    """Prints a message about a file or feature being installed.

    :param str s: The message.
    """
    print('• \033[0;32m{}\033[0m'.format(s))


def removing(s):
    """Prints a message about a file or feature being removed.

    :param str s: The message.
    """
    print('• \033[0;31m{}\033[0m'.format(s))

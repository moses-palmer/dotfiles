import re
import subprocess

from . import Distribution, Version

#: The regular expression used to extract values from lines in the information
#: file.
LINE_RE = re.compile(r'^([a-zA-Z][a-zA-Z0-9_]*)\s*:\s*(.*?)\s*$')


def information():
    values = {
        m.group(1): m.group(2)
        for m in (
            LINE_RE.match(line)
            for line in subprocess.check_output(['sw_vers'])
                .decode('utf-8')
                .splitlines()
            if LINE_RE.match(line))}

    return (
        Distribution(values['ProductName'], 'macos'),
        Version(values['ProductVersion']))

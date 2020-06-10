# adapted from https://github.com/lxml/lxml/blob/master/versioninfo.py

import io
import os
import re
import sys

__PYXPDF_VERSION = None


def version():
    global __PYXPDF_VERSION
    if __PYXPDF_VERSION is None:
        with open(os.path.join(get_base_dir(), 'src', 'pyxpdf', '__init__.py')) as f:
            __PYXPDF_VERSION = re.search(r'__version__\s*=\s*"([^"]+)"', f.read(250)).group(1)
            assert __PYXPDF_VERSION
    return __PYXPDF_VERSION


def branch_version():
    return version()[:3]


def is_pre_release():
    version_string = version()
    return "a" in version_string or "b" in version_string


def dev_status():
    _version = version()
    if 'a' in _version:
        return 'Development Status :: 3 - Alpha'
    elif 'b' in _version or 'c' in _version:
        return 'Development Status :: 4 - Beta'
    else:
        return 'Development Status :: 5 - Production/Stable'


def get_base_dir():
    return os.path.abspath(os.path.dirname(sys.argv[0]))


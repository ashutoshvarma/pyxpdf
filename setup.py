#!/usr/bin/env python3


import sys
import os
import shutil
from pathlib import Path

from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
from Cython.Build import cythonize

MODULE_NAME = "pyxpdf"



# Cleaning
# for root, dirs, files in os.walk(".", topdown=False):
#     if not ("venv" in root or "venv" in dirs):
#         for name in files:
#             if (name.startswith(MODULE_NAME) and not(name.endswith(".pyx") or name.endswith(".pxd"))):
#                 os.remove(os.path.join(root, name))
#         for name in dirs:
#             if (name == "build"):
#                 shutil.rmtree(name)


# Building
setup(
    cmdclass={'build_ext': build_ext},
    ext_modules=cythonize([
        Extension(MODULE_NAME,
                  sources=["src/pyxpdf/xpdf.pyx"],
                  libraries=["xpdf",],
                  language="c++",
                  extra_compile_args=["-Ilibxpdf/include", "-Isrc/pyxpdf/includes"],
                  extra_link_args=["-Llibxpdf/lib", ]
                  )
    ]
    )
)

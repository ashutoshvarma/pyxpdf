# distutils: language=c++
# cython: language_level=2
# cython: profile=True
import cython

__all__ = [
    "pdftotext_raw", "XPDFDoc", "XPage", "Config", "TextControl",
    "RawImageOutput", "PDFError", 'XPDFError', "PDFSyntaxError",
    "XPDFConfigError", "PDFIOError", "PDFPermissionError",
    "XPDFInternalError","XPDFNotInplementedError"
]

from libc cimport math as cmath
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libcpp.vector cimport vector
from libcpp.utility cimport move

cimport cython
from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as inc, predecrement as dec

from pyxpdf.includes.xpdf_types cimport GString, GBool, gTrue, gFalse, Guchar



#######################################################
# load optional dependencies
#######################################################
cdef tuple optional_deps = ('pyxpdf_data', 'PIL.Image')
cdef dict available_deps = dict()

cdef int load_deps() except -1:
    global available_deps
    global optional_deps

    cdef object importlib
    import importlib.util

    cdef object sys
    import sys

    cdef:
        int i
    for dep in optional_deps:
        if dep in sys.modules:
            available_deps.append(dep)
        else:
            # load deps starting from parent package
            # to child.
            dep_packages = dep.split('.')
            for i in range(len(dep_packages)):
                d = '.'.join(dep_packages[:i+1])
                spec = importlib.util.find_spec(d)
                if spec is not None:
                    # import it
                    module = importlib.util.module_from_spec(spec)
                    sys.modules[d] = module
                    spec.loader.exec_module(module)
                    available_deps[d] = module
                else:
                    break
    return 0

load_deps()


# Helper functions (like conversions from str to chars)
include "helper.pxi"

include "pdferror.pxi"

# Manage xpdf globalParams
include "globalconfig.pxi"

# pdftotext
include "pdftotext.pxi"


# Python Objects based on TextOutputDev.pxd
include "textoutput.pxi"

# Python Objects based on SplashOutputDev.pxd
include "imageoutput.pxi"

# Pythonn Objects based on PDFDoc.pxd ,Page.pxd
include "document.pxi"


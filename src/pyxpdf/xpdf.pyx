# distutils: language=c++
# cython: language_level=2
# cython: profile=True
import cython

__all__ = [
    "pdftotext_raw", "XPDFDoc", "XPage", "Config", "TextControl",
    "PDFError", 'XPDFError', "PDFSyntaxError", "XPDFConfigError",
    "PDFIOError", "PDFPermissionError", "XPDFInternalError",
    "XPDFNotInplementedError"
]

from libc cimport math as cmath
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libcpp.vector cimport vector
from libcpp.utility cimport move

cimport cython
from cython.operator cimport dereference as deref
from cython.operator cimport preincrement as inc, predecrement as dec

from pyxpdf.includes.xpdf_types cimport GString, GBool, gTrue, gFalse

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


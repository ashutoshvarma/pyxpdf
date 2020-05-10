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

# Helper functions (like conversions from str to chars)
include "helper.pxi"

include "pdferror.pxi"

# Manage xpdf globalParams
include "globalconfig.pxi"

# pdftotext
include "pdftotext.pxi"


# Python Objects based on TextOutputDev.pxd
include "textoutput.pxi"

# Pythonn Objects based on PDFDoc.pxd ,Page.pxd
include "document.pxi"


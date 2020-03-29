# distutils: language=c++
# cython: language_level=2

__all__ = [
"Document, PDFError"
]

from pyxpdf.includes.xpdf_error cimport ErrorCategory, setErrorCallback


cdef bytes pytext_to_bytes(pystr):
    return pystr.encode('UTF-8')

cdef object bytes_to_string(cstr):
    return cstr.decode('UTF-8')

# Dummy callback to silence errors for now.
cdef void dummpy_error_callback(void *data, ErrorCategory category, int pos, char *msg):
    return
    
setErrorCallback(&dummpy_error_callback, NULL)

# PDF Errors
include "pdferror.pxi"

# include Document Class which wrap PDFDoc c++ class
include "Document.pxi"


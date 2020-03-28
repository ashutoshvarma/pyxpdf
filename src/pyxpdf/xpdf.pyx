#cython: language_level=3
from pyxpdf.includes.xpdf_error cimport ErrorCategory, setErrorCallback


cdef bytes pytext_to_bytes(pystr):
    return pystr.encode('UTF-8')

cdef object bytes_to_string(cstr):
    return cstr.decode('UTF-8')

cdef void dummpy_error_callback(void *data, ErrorCategory category, int pos, char *msg):
    # Dummy callback to silence errors for now.
    return
    
setErrorCallback(&dummpy_error_callback, NULL)


# PDF Errors
include "pdferror.pxi"


# include Document Class which wrap PDFDoc c++ class
include "Document.pxi"


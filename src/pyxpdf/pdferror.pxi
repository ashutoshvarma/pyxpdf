
cdef class PDFError(Exception):
    """Main exception base class for pyxpdf.  All other exceptions inherit from
    this one.
    """
    def __init__(self, message):
        super().__init__(message)
        

cdef class XPDFError(PDFError):
    pass

cdef class PDFSyntaxError(XPDFError):
    pass

cdef class XPDFConfigError(XPDFError):
    pass

cdef class PDFIOError(XPDFError):
    pass

cdef class PDFPermissionError(XPDFError):
    pass

cdef class XPDFInternalError(XPDFError):
    pass

cdef class XPDFNotInplementedError(XPDFError):
    pass
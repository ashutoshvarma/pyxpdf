
cdef class PDFError(Exception):
    """Main exception base class for pyxpdf.  All other exceptions inherit from
    this one.
    """
    def __init__(self, message):
        super().__init__(message)
        

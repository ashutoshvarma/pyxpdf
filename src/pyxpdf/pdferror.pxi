from pyxpdf.includes.xpdf_error cimport ErrorCategory, setErrorCallback, ErrorCallback, errNone, errOpenFile, errBadCatalog, errDamaged, errEncrypted, errHighlightFile, errBadPrinter, errPrinting, errPermission, errBadPageNum, errFileIO

ErrorCodesDict = {
    errNone : "Error None",
    errOpenFile : "Error Opening file.",
    errBadCatalog : "Error Parsing PDF Catalog",
    errDamaged : "Error Parsing PDF File. File might be damaged",
    errEncrypted : "Error decrypting PDF File",
    # No idea what errhighlightfile is?
    errHighlightFile : "Error File Highlight",
    errBadPrinter : "Error Bad Printer",
    errPrinting : "Error Printing",
    errPermission : "Error PDF Permissions",
    errBadPageNum : "Error Bad PDF Page Number",
    errFileIO : "Error while r/w File"
}


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
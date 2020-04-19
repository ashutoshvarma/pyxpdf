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

ErrorCodeMapping = {
    errNone : XPDFError,
    errHighlightFile : XPDFError,
    errBadPrinter : XPDFError,
    errPrinting : XPDFError,
    errOpenFile : PDFIOError,
    errBadPageNum : XPDFError,
    errBadCatalog : PDFSyntaxError,
    errDamaged : PDFSyntaxError,
    errEncrypted : PDFPermissionError,
    errPermission : PDFPermissionError,
    errFileIO : PDFIOError
}


cdef class PDFError(Exception):
    """Main exception base class for pyxpdf.  All other exceptions inherit from
    this one.
    """
    def __init__(self, message):
        super().__init__(message)
        

cdef class XPDFError(PDFError):
    def __init__(self, message = None):
        if message:
            super().__init__(message)
        else:
            default_msg = "Uncaught error in xpdf library."
            for code, err in ErrorCodeMapping.items():
                if err == type(self):
                    default_msg = ErrorCodesDict[code]
            super().__init__(default_msg)

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



# cdef int xpdf_error_callback(void *data, ErrorCategory category, int pos, char *msg) except -1 with gil:
#     message = msg.decode('UTF-8') 
#     if pos != -1:
#         message += " , at internal position {pos}".format(pos=pos)

#     if category == ErrorCategory.errSyntaxError:
#         raise PDFSyntaxError(message)
#     elif category == ErrorCategory.errConfig:
#         raise XPDFConfigError(message)
#     elif category == ErrorCategory.errIO:
#         raise PDFIOError(message)
#     elif category == ErrorCategory.errNotAllowed:
#         raise PDFPermissionError(message)
#     elif category == ErrorCategory.errUnimplemented:
#         raise XPDFNotInplementedError(message)
#     elif category == ErrorCategory.errInternal:
#         raise XPDFInternalError(message)
#     elif category == ErrorCategory.errSyntaxWarning:
#         #TODO: Handle warnings
#         pass
#     else:
#         raise XPDFError("Unkown Error Occured")


# setErrorCallback(<ErrorCallback>&xpdf_error_callback, NULL)
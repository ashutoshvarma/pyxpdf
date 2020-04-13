# distutils: language=c++
# cython: language_level=2
# cython: profile=True
import cython

__all__ = [
"pdftotext_raw, PDFError", "XPDFDoc", "XPage", "Config", "TextControl" 
]

# Helper functions (like conversions from str to chars)
include "helper.pxi"

include "pdferror.pxi"

from pyxpdf.includes.xpdf_error cimport ErrorCategory, setErrorCallback, ErrorCallback
# Dummy callback to silence errors for now.
cdef int xpdf_error_callback(void *data, ErrorCategory category, int pos, char *msg) except -1:
    message = msg.decode('UTF-8') 
    if pos != -1:
        message += " , at internal position {pos}".format(pos=pos)

    if category == ErrorCategory.errSyntaxError:
        raise PDFSyntaxError(message)
    elif category == ErrorCategory.errConfig:
        raise XPDFConfigError(message)
    elif category == ErrorCategory.errIO:
        raise PDFIOError(message)
    elif category == ErrorCategory.errNotAllowed:
        raise PDFPermissionError(message)
    elif category == ErrorCategory.errUnimplemented:
        raise XPDFNotInplementedError(message)
    elif category == ErrorCategory.errInternal:
        raise XPDFInternalError(message)
    elif category == ErrorCategory.errSyntaxWarning:
        #TODO: Handle warnings
        pass
    else:
        raise XPDFError("Unkown Error Occured")


setErrorCallback(<ErrorCallback>&dummpy_error_callback, NULL)


from os import linesep

from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libc.stdio cimport printf

from pyxpdf.includes.xpdf_types cimport GString, gFalse, gTrue
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams
from pyxpdf.includes.TextOutputDev cimport TextOutputDev, TextOutputMode, TextOutputControl


cdef void _text_out_func(void *stream, const char *text, int length):
    (<string*>stream)[0] += string(text, length)

cpdef pdftotext_raw(pdf_file, int start = 0, int end = 0, layout="reading", ownerpass=None, userpass=None, cfg_file=""):
    cdef string ext_text
    cdef int err_code
    cdef unique_ptr[GString] ownerpassG  
    cdef unique_ptr[GString] userpassG 
    cdef unique_ptr[PDFDoc] doc
    cdef unique_ptr[TextOutputDev] text_dev
    cdef unique_ptr[TextOutputControl] control 

    if cfg_file:
        Config.load_file(cfg_file)
    Config.text_encoding = "UTF-8"

    if ownerpass:
        ownerpassG = make_unique[GString](_chars(ownerpass))
    if userpass:
        userpassG = make_unique[GString](_chars(userpass))

    doc = make_unique[PDFDoc](_chars(pdf_file), ownerpassG.get(), userpassG.get())
    if deref(doc).isOk() == gFalse:
        err_code = deref(doc).getErrorCode()
        raise PDFError(f"Cannot open pdf file. ErrorCode-{err_code}")

    if deref(doc).okToCopy(ignoreOwnerPW=gFalse) == gFalse:
        raise PDFError("Copying of text from this document is not allowed.")

    if start < 1:
        start = 1
    if end < 1 or end > deref(doc).getNumPages():
        end = deref(doc).getNumPages()

    control = make_unique[TextOutputControl]()
    if layout == "table":
        deref(control).mode = TextOutputMode.textOutTableLayout
    elif layout == "physical":
        deref(control).mode = TextOutputMode.textOutPhysLayout
    elif layout == "simple":
        deref(control).mode = TextOutputMode.textOutSimpleLayout
    elif layout == "lineprinter":
        deref(control).mode = TextOutputMode.textOutLinePrinter
    elif layout == "raw":
        deref(control).mode = TextOutputMode.textOutRawOrder
    elif layout == "reading":
        deref(control).mode = TextOutputMode.textOutReadingOrder
    else:
        raise ValueError(f"Unknown layout - {layout}")

    text_dev = make_unique[TextOutputDev](&_text_out_func, &ext_text, control.get())
    if deref(text_dev).isOk() == gFalse:
        raise PDFError("Error in pdf options")

    deref(doc).displayPages(text_dev.get(), start, end, 72, 72, 0, gFalse, gTrue, gFalse)
    return ext_text



## Internal Xpdf Objects

# Manage xpdf globalParams
include "globalconfig.pxi"

# Python Objects based on TextOutputDev.pxd
include "textoutput.pxi"

# Pythonn Objects based on PDFDoc.pxd ,Page.pxd
include "document.pxi"


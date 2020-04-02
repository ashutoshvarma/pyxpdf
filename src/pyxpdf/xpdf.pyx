# distutils: language=c++
# cython: language_level=2

__all__ = [
"pdftotext, PDFError"
]



cdef char *pytext_to_char(pystr):
    return pystr.encode('UTF-8')

cdef object cstr_to_pytext(cstr, l = None):
    if l:
        return cstr[:l].decode('UTF-8', errors="ignore")
    else:
        return cstr.decode('UTF-8', errors="ignore")



from pyxpdf.includes.xpdf_error cimport ErrorCategory, setErrorCallback
# Dummy callback to silence errors for now.
cdef void dummpy_error_callback(void *data, ErrorCategory category, int pos, char *msg):
    return
    
#setErrorCallback(&dummpy_error_callback, NULL)


include "pdferror.pxi"


from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libc.stdio cimport printf

from pyxpdf.includes.xpdf_types cimport GString, gFalse, gTrue
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams
from pyxpdf.includes.TextOutputDev cimport TextOutputDev, TextOutputMode, TextOutputControl

globalParams = new GlobalParams(b"")

cdef void _text_out_func(void *stream, const char *text, int length):
    cdef string *stream_str = <string*>stream
    stream_str[0] += string(text, length)

cdef _pdftotext(str pdf_file, int start = 0, int end = 0, layout=None, ownerpass=None, userpass=None, cfg_file=""):
    cdef string ext_text
    cdef int err_code
    cdef GString *ownerpassG = NULL 
    cdef GString *userpassG = NULL 
    cdef PDFDoc* doc
    cdef TextOutputDev* text_dev = NULL
    cdef TextOutputControl *control =  NULL

    globalParams = new GlobalParams(pytext_to_char(cfg_file))

    if ownerpass:
        ownerpassG = new GString(pytext_to_char(ownerpass))
    if userpass:
        userpassG = new GString(pytext_to_char(userpass))

    doc = new PDFDoc(pytext_to_char(pdf_file), ownerpassG, userpassG)
    if doc.isOk() == gFalse:
        err_code = doc.getErrorCode()
        if ownerpassG is not NULL:
            del ownerpassG
        if userpassG is not NULL:
            del userpassG
        del doc
        raise PDFError(f"Cannot open pdf file. ErrorCode-{err_code}")

    if doc.okToCopy() == gFalse:
        if ownerpassG is not NULL:
            del ownerpassG
        if userpassG is not NULL:
            del userpassG
        del doc
        raise PDFError("Copying of text from this document is not allowed.")

    if start < 1:
        start = 1
    if end < 1 or end > doc.getNumPages():
        end = doc.getNumPages()

    control = new TextOutputControl()
    if layout == "table":
        control.mode = TextOutputMode.textOutTableLayout
    elif layout == "physical":
        control.mode = TextOutputMode.textOutPhysLayout
    elif layout == "simple":
        control.mode = TextOutputMode.textOutSimpleLayout
    elif layout == "lineprinter":
        control.mode = TextOutputMode.textOutLinePrinter
    elif layout == "raw":
        control.mode = TextOutputMode.textOutRawOrder
    elif layout == "reading":
        control.mode = TextOutputMode.textOutReadingOrder
    else:
        if ownerpassG is not NULL:
            del ownerpassG
        if userpassG is not NULL:
            del userpassG
        del doc
        del control
        raise ValueError(f"Unknown layout - {layout}")

    text_dev = new TextOutputDev(&_text_out_func, &ext_text, control)
    if text_dev.isOk() == gFalse:
        if ownerpassG is not NULL:
            del ownerpassG
        if userpassG is not NULL:
            del userpassG
        del doc
        del control
        del text_dev
        raise PDFError("Error in pdf options")

    doc.displayPages(text_dev, start, end, 72, 72, 0, gFalse, gTrue, gFalse)
    return cstr_to_pytext(ext_text)

def pdftotext(pdf_file, start=1, end=0, layout="table", ownerpass=None, userpass=None, cfg_file=""):
    return _pdftotext(pdf_file, start, end, layout, ownerpass, userpass, cfg_file)
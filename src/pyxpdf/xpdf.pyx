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

from os import linesep

from cython.operator cimport dereference as deref
from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libc.stdio cimport printf

from pyxpdf.includes.xpdf_types cimport GString, gFalse, gTrue
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams
from pyxpdf.includes.TextOutputDev cimport (
    TextOutputDev, TextOutputMode, TextOutputControl
)

cdef void _text_out_func(void *stream, const char *text, int length):
    (<string*>stream)[0] += string(text, length)

cpdef pdftotext_raw(pdf_file, int start = 0, int end = 0, ownerpass=None, 
                    userpass=None, layout = "reading", double fixed_pitch=0,
                    double fixed_line_spacing=0, clip_text=False, discard_diagonal=False, 
                    insert_bom=False, double margin_left=0, double margin_right=0, 
                    double margin_top=0, double margin_bottom=0):
    cdef string ext_text
    cdef int err_code
    cdef unique_ptr[GString] ownerpassG  
    cdef unique_ptr[GString] userpassG 
    cdef unique_ptr[PDFDoc] doc
    cdef unique_ptr[TextOutputDev] text_dev
    cdef unique_ptr[TextOutputControl] control 

    if ownerpass:
        ownerpassG = make_unique[GString](_chars(ownerpass))
    if userpass:
        userpassG = make_unique[GString](_chars(userpass))

    doc = make_unique[PDFDoc](_chars(pdf_file), ownerpassG.get(), userpassG.get())
    if deref(doc).isOk() == gFalse:
        err_code = deref(doc).getErrorCode()
        raise ErrorCodeMapping[err_code]

    if deref(doc).okToCopy(ignoreOwnerPW=gFalse) == gFalse:
        raise PDFPermissionError("Copying of text from this document is not allowed.")

    if start < 1:
        start = 1
    if end < 1 or end > deref(doc).getNumPages():
        end = deref(doc).getNumPages()

    control = make_unique[TextOutputControl]()

    deref(control).fixedPitch = fixed_pitch
    deref(control).fixedLineSpacing = fixed_line_spacing

    deref(control).clipText = to_GBool(clip_text)
    deref(control).discardDiagonalText = to_GBool(discard_diagonal)
    deref(control).insertBOM = to_GBool(insert_bom)

    deref(control).marginRight = margin_right
    deref(control).marginLeft = margin_left
    deref(control).marginTop = margin_top
    deref(control).marginBottom = margin_bottom

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
        raise ValueError(f"Unknown layout - {layout}.")

    text_dev = make_unique[TextOutputDev](&_text_out_func, &ext_text, control.get())
    if deref(text_dev).isOk() == gFalse:
        raise XPDFConfigError("Failed to create TextOutputDev with given options")

    deref(doc).displayPages(text_dev.get(), start, end, 72, 72, 0, gFalse, gTrue, gFalse)
    return ext_text



# Python Objects based on TextOutputDev.pxd
include "textoutput.pxi"

# Pythonn Objects based on PDFDoc.pxd ,Page.pxd
include "document.pxi"


from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.TextOutputDev cimport (
    TextOutputDev, TextOutputMode, TextOutputControl
)


cpdef pdftotext_raw(pdf_file, int start = 0, int end = 0, ownerpass=None,
                    userpass=None, layout = "reading", double fixed_pitch=0,
                    double fixed_line_spacing=0, discard_clipped=False, discard_diagonal=False,
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

    deref(control).discardClippedText = to_GBool(discard_clipped)
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

    text_dev = make_unique[TextOutputDev](&append_to_cpp_string, &ext_text, control.get())
    if deref(text_dev).isOk() == gFalse:
        raise XPDFConfigError("Failed to create TextOutputDev with given options")

    deref(doc).displayPages(text_dev.get(), start, end, 72, 72, 0, gFalse, gTrue, gFalse)
    return ext_text

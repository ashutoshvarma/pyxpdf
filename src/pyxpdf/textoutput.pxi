from pyxpdf.includes.xpdf_types cimport GBool
from pyxpdf.includes.TextOutputDev cimport TextOutputMode, TextOutputControl

TextPhysicalLayout = TextOutputMode.textOutPhysLayout
TextSimpleLayout = TextOutputMode.textOutSimpleLayout
TextTableLayout = TextOutputMode.textOutTableLayout
TextLinePrinter = TextOutputMode.textOutLinePrinter
TextRawOrder = TextOutputMode.textOutRawOrder
TextReadingOrder = TextOutputMode.textOutReadingOrder


cdef class TextControl:
    cdef TextOutputControl control

    def __cinit__(self, TextOutputMode mode = TextReadingOrder, double fixed_pitch = 0, double fixed_line_spacing=0, enable_html=False,
                clip_text=False, discard_diagonal=False, discard_invisible=False, discard_clipped=False,
                insert_bom=False, double margin_left=0, double margin_right=0, double margin_top=0, double margin_bottom=0):
    
        self.control.fixedPitch = fixed_pitch
        self.control.fixedLineSpacing = fixed_line_spacing

        self.control.html = to_GBool(enable_html)
        self.control.clipText = to_GBool(clip_text)
        self.control.discardDiagonalText = to_GBool(discard_diagonal)
        self.control.discardInvisibleText = to_GBool(discard_invisible)
        self.control.discardClippedText = to_GBool(discard_clipped)
        self.control.insertBOM = to_GBool(insert_bom)

        self.control.marginRight = margin_right
        self.control.marginLeft = margin_left
        self.control.marginTop = margin_top
        self.control.marginBottom = margin_bottom



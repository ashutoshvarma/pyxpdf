from pyxpdf.includes.xpdf_types cimport GString, GBool, gTrue
from pyxpdf.includes.Page cimport PDFRectangle

cdef inline char* _chars(object s):
    if isinstance(s, unicode):
        # encode to the specific encoding used inside of the module
        s = (<unicode>s).encode('UTF-8')
    return s

cdef inline bytes _utf8_bytes(object s):
    if isinstance(s, unicode):
        # encode to the specific encoding used inside of the module
        s = (<unicode>s).encode('UTF-8')
    return s

cdef inline bytes _utf32_bytes(object s):
    if isinstance(s, unicode):
        # encode to the specific encoding used inside of the module
        s = (<unicode>s).encode('UTF-32')
    return s

cdef inline GString* to_GString(object s):
    return new GString(_chars(s))

cdef inline object GString_to_unicode(GString *gstr):
    return gstr.getCString()[:gstr.getLength()].decode("UTF-8")

cdef inline GBool_to_bool(GBool b):
    return True if b == gTrue else False

cdef inline GBool to_GBool(pyb):
    return gTrue if pyb else gFalse


cdef inline PDFRectangle_to_tuple(PDFRectangle *rect):
    cdef tuple rect_tp 
    rect_tp = (rect.x1, rect.y1, rect.x2, rect.y2)
    return rect_tp
from libcpp.vector cimport vector

from cython.operator cimport dereference as deref
from cpython cimport bool as PyBool

from pyxpdf.includes.xpdf_types cimport GString, GBool, gTrue, gFalse
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Page cimport PDFRectangle
from pyxpdf.includes.TextString cimport TextString

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
    if gstr is not NULL:
        return gstr.getCString()[:gstr.getLength()].decode("UTF-8")
    else:
        return ""

cdef inline GBool_to_bool(GBool b):
    return True if b == gTrue else False

cdef inline GBool to_GBool(pyb):
    return gTrue if pyb else gFalse


cdef inline PDFRectangle_to_tuple(PDFRectangle *rect):
    cdef tuple rect_tp 
    rect_tp = (rect.x1, rect.y1, rect.x2, rect.y2)
    return rect_tp

cdef void utf32_to_Unicode_vector(text, vector[Unicode]& vec):
    cdef bytes by = _utf32_bytes(text)
    cdef char* ch = by

    cdef size_t l_bytes = len(by)
    cdef size_t l_utf32 = (l_bytes/4) - 1

    vec.resize(l_utf32)  # Not including BOM

    # print(f"{l_bytes}")
    # print(f"Loop - {list(range(4, l_bytes, 4))}")
    cdef int i 
    for i in range(4, l_bytes, 4):
        vec[(i/4) - 1] = deref(<Unicode*>(&ch[i]))
        # print(f"{(i/4) - 1} - {vec[(i/4) - 1]}")


cdef dict Dict_to_pydict(Dict* xdict, dict pydict = {}):
    cdef Object obj
    cdef const char* key 
    if xdict != NULL:
        for i in range(xdict.getLength()):
            key = xdict.getKey(i)
            if xdict.lookup(key, &obj).isString() == gTrue:
                pydict[key.decode('UTF-8')] = GString_to_unicode(obj.getString())
            elif xdict.lookup(key, &obj).isNum() == gTrue:
                pydict[key.decode('UTF-8')] = obj.getNum()
        obj.free()
    return pydict

cdef object TextString_to_unicode(TextString* text_str):
    return GString_to_unicode(text_str.toPDFTextString())

cdef TextString* to_TextString(tstr):
    cdef TextString* text_string
    text_string = new TextString(to_GString(tstr))
    return text_string

cdef void append_to_cpp_string(void *stream, const char *text, int length):
    (<string*>stream)[0] += string(text, length)
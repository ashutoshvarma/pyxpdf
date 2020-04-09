from pyxpdf.includes.xpdf_types cimport GString, GBool, gTrue


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

cdef inline GString* to_GString(object s):
    return new GString(_chars(s))

cdef inline object GString_to_unicode(GString *gstr):
    return gstr.getCString()[:gstr.getLength()].decode("UTF-8")

cdef inline bint GBool_to_bool(GBool b):
    return True if b == gTrue else False
from pyxpdf.includes.xpdf_types cimport GString


cdef inline char* _chars(object s):
    if isinstance(s, unicode):
        # encode to the specific encoding used inside of the module
        s = (<unicode>s).encode('UTF-8')
    return s

cdef inline GString* to_GString(object s):
    return new GString(_chars(s))


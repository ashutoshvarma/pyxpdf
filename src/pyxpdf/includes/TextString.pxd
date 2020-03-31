from pyxpdf.includes.xpdf_types cimport GBool, GString
from pyxpdf.includes.CharTypes cimport Unicode


cdef extern from "TextString.h" nogil:
    cdef cppclass TextString:
        # Create an empty TextString.
        TextString()

        # Create a TextString from a PDF text string.
        TextString(GString *s)

        # Copy a TextString.
        TextString(TextString *s)

        # Append a Unicode character or PDF text string to this TextString.
        TextString *append(Unicode c)
        TextString *append(GString *s)

        # Insert a Unicode character, sequence of Unicode characters, or
        # PDF text string in this TextString.
        TextString *insert(int idx, Unicode c)
        TextString *insert(int idx, Unicode *u2, int n)
        TextString *insert(int idx, GString *s)

        # Get the Unicode characters in the TextString.
        int getLength() #
        Unicode *getUnicode() #

        # Create a PDF text string from a TextString.
        GString *toPDFTextString()
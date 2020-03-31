from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.CharTypes cimport Unicode, CharCode



cdef extern from "CharCodeToUnicode.h" nogil:
    ctypedef struct CharCodeToUnicodeString

    cdef cppclass CharCodeToUnicode:
        # Create an identity mapping (Unicode = CharCode).
        CharCodeToUnicode *makeIdentityMapping()

        # Read the CID-to-Unicode mapping for <collection> from the file
        # specified by <fileName>.  Sets the initial reference count to 1.
        # Returns NULL on failure.
        CharCodeToUnicode *parseCIDToUnicode(GString *fileName,
                                GString *collection)

        # Create a Unicode-to-Unicode mapping from the file specified by
        # <fileName>.  Sets the initial reference count to 1.  Returns NULL
        # on failure.
        CharCodeToUnicode *parseUnicodeToUnicode(GString *fileName)

        # Create the CharCode-to-Unicode mapping for an 8-bit font.
        # <toUnicode> is an array of 256 Unicode indexes.  Sets the initial
        # reference count to 1.
        CharCodeToUnicode *make8BitToUnicode(Unicode *toUnicode)

        # Parse a ToUnicode CMap for an 8- or 16-bit font.
        CharCodeToUnicode *parseCMap(GString *buf, int nBits)

        # Parse a ToUnicode CMap for an 8- or 16-bit font, merging it into
        # <this>.
        void mergeCMap(GString *buf, int nBits)

        void incRefCnt()
        void decRefCnt()

        # Return true if this mapping matches the specified <tagA>.
        GBool match(GString *tagA)

        # Set the mapping for <c>.
        void setMapping(CharCode c, Unicode *u, int len)

        # Map a CharCode to Unicode.
        int mapToUnicode(CharCode c, Unicode *u, int size)

        # Return the mapping's length, i.e., one more than the max char
        # code supported by the mapping.
        CharCode getLength() 

        GBool isIdentity() 


    cdef cppclass CharCodeToUnicodeCache:
        CharCodeToUnicodeCache(int sizeA)

        # Get the CharCodeToUnicode object for <tag>.  Increments its
        # reference count there will be one reference for the cache plus
        # one for the caller of this function.  Returns NULL on failure.
        CharCodeToUnicode *getCharCodeToUnicode(GString *tag)

        # Insert <ctu> into the cache, in the most-recently-used position.
        void add(CharCodeToUnicode *ctu)

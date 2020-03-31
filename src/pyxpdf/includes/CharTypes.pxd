cdef extern from "CharTypes.h" nogil:
    # Unicode character.
    ctypedef unsigned int Unicode

    # Character ID for CID character collections.
    ctypedef unsigned int CID

    # This is large enough to hold any of the following:
    # - 8-bit char code
    # - 16-bit CID
    # - Unicode
    ctypedef unsigned int CharCode
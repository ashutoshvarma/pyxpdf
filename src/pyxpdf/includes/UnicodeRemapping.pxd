from pyxpdf.includes.xpdf_types cimport GString
from pyxpdf.includes.CharTypes cimport Unicode



cdef extern from "UnicodeRemapping.h" nogil:
    cdef cppclass UnicodeRemapping:
        # Create an empty (i.e., identity) remapping.
        UnicodeRemapping()

        # Add a remapping for <in>.
        void addRemapping(Unicode _in, Unicode *out, int len)

        # Add entries from the specified file to this UnicodeRemapping.
        void parseFile(GString *fileName)

        # Map <in> to zero or more (up to <size>) output characters in
        # <out>.  Returns the number of output characters.
        int map(Unicode _in, Unicode *out, int size)
cdef extern from "gtypes.h" nogil:
    ctypedef int GBool
    ctypedef unsigned char Guchar
    ctypedef unsigned short Gushort
    ctypedef unsigned int Guint
    ctypedef unsigned long Gulong
    cdef int gTrue 
    cdef int gFalse 

cdef extern from "gfile.h" nogil:
    ctypedef long long GFileOffset

cdef extern from "GString.h" nogil:
    cdef cppclass GString:
        # Create an empty string.
        GString() 

        # Create a string from a C string.
        GString(const char *sA) 

        # Create a string from <lengthA> chars at <sA>.  This string
        # can contain null characters.
        GString(const char *sA, int lengthA)

        # Create a string from <lengthA> chars at <idx> in <str>.
        GString(GString *str, int idx, int lengthA)

        # Copy a string.
        GString(GString *str)




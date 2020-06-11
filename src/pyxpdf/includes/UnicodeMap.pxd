cdef extern from "UnicodeMap.h" nogil:
    cdef cppclass UnicodeMap:
        void incRefCnt()
        void decRefCnt()

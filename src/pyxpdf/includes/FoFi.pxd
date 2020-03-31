cdef extern from "FoFiBase.h" nogil:
    cdef cppclass FoFiBase:
        pass


cdef extern from "FoFiTrueType.h" nogil:
    cdef cppclass FoFiTrueType(FoFiBase):
        pass


cdef extern from "FoFiType1C.h" nogil:
    cdef cppclass FoFiType1C(FoFiBase):
        pass
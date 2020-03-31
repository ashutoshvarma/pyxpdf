

cdef extern from "DisplayState.h" nogil:
    ctypedef enum DisplayMode:
        displaySingle
        displayContinuous
        displaySideBySideSingle
        displaySideBySideContinuous
        displayHorizontalContinuous

    cdef cppclass DisplayState:
        pass
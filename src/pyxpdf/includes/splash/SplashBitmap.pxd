from pyxpdf.includes.splash.SplashTypes cimport (
    SplashColorPtr
)

cdef extern from "SplashBitmap.h" nogil:
    ctypedef long long SplashBitmapRowSize

    cdef cppclass SplashBitmap:
        int getWidth()
        int getHeight()
        SplashBitmapRowSize getRowSize()
        SplashColorPtr getDataPtr()
        SplashColorPtr takeData()


from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector

from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.splash.SplashBitmap cimport SplashBitmap
from pyxpdf.includes.splash.SplashTypes cimport SplashColorMode


cdef extern from "BitmapOutputDev.h" nogil:
    ctypedef struct PDFImage:
        int pageNum
        unique_ptr[SplashBitmap] bitmap
        SplashColorMode mode
        double hDPI
        double vDPI
        int bpc

    cdef cppclass BitmapOutputDev(OutputDev):
        BitmapOutputDev(vector[PDFImage] &image_listA)


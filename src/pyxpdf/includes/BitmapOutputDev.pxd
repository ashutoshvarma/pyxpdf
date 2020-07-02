from libcpp cimport bool as bool_t
from libcpp.memory cimport unique_ptr
from libcpp.vector cimport vector

from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.Stream cimport StreamKind
from pyxpdf.includes.splash.SplashBitmap cimport SplashBitmap
from pyxpdf.includes.splash.SplashTypes cimport SplashColorMode
from pyxpdf.includes.GfxState cimport GfxColorSpaceMode


cdef extern from "BitmapOutputDev.h" nogil:
    ctypedef enum ImageType:
        imgImage
        imgStencil
        imgMask
        imgSmask

    ctypedef struct PDFBitmapImage:
        int pageNum
        unique_ptr[SplashBitmap] bitmap
        ImageType imgType
        StreamKind compression
        bool_t interpolate
        bool_t inlineImg
        SplashColorMode bitmapColorMode
        GfxColorSpaceMode colorspace
        int components
        int bpc
        double hDPI
        double vDPI
        double x1
        double y1
        double x2
        double y2


    cdef cppclass BitmapOutputDev(OutputDev):
        BitmapOutputDev(vector[PDFBitmapImage] &image_listA)


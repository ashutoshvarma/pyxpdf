from pyxpdf.includes.xpdf_types cimport GBool, gTrue
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.splash.SplashBitmap cimport SplashBitmap
from pyxpdf.includes.splash.SplashTypes cimport (
    SplashColorMode, SplashColorPtr
)

cdef extern from "SplashOutputDev.h" nogil:
    cdef cppclass SplashOutputDev(OutputDev):
        # Constructor.
        SplashOutputDev(SplashColorMode colorModeA, int bitmapRowPadA,
                        GBool reverseVideoA, SplashColorPtr paperColorA,
                        GBool bitmapTopDownA = gTrue,
                        GBool allowAntialiasA = gTrue)

        # Get the bitmap and its size.
        SplashBitmap *getBitmap()

        # Returns the last rasterized bitmap, transferring ownership to 
        # the caller.
        SplashBitmap *takeBitmap()


        # Called to indicate that a new PDF document has been loaded.
        void startDoc(XRef *xrefA)

        # Setting this to true disables the final composite (with the
        # opaque paper color), resulting in transparent output.
        void setNoComposite(GBool f) 


from pyxpdf.includes.xpdf_types cimport Guchar

cdef extern from "SplashTypes.h" nogil:
    ctypedef enum SplashColorMode:
        splashModeMono1		# 1 bit per component, 8 pixels per byte,
				            # MSbit is on the left
        splashModeMono8 	# 1 byte per component, 1 byte per pixel
        splashModeRGB8 		# 1 byte per component, 3 bytes per pixel:
                            # RGBRGB...
        splashModeBGR8		# 1 byte per component, 3 bytes per pixel:
                            # BGRBGR...

    cdef int splashMaxColorComps
    ctypedef Guchar SplashColor[4]
    ctypedef Guchar *SplashColorPtr

    # RGB8
    cdef   Guchar splashRGB8R(SplashColorPtr rgb8)
    cdef   Guchar splashRGB8G(SplashColorPtr rgb8)
    cdef   Guchar splashRGB8B(SplashColorPtr rgb8)

    # BGR8
    cdef   Guchar splashBGR8R(SplashColorPtr bgr8)
    cdef   Guchar splashBGR8G(SplashColorPtr bgr8)
    cdef   Guchar splashBGR8B(SplashColorPtr bgr8)

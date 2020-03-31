from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.Gfx cimport Gfx
from pyxpdf.includes.GfxState cimport GfxState, GfxImageColorMap
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport Stream
from pyxpdf.includes.OutputDev cimport OutputDev


cdef extern from "ImageOutputDev.h" nogil:
    cdef cppclass ImageOutputDev(OutputDev):
        # Create an OutputDev which will write images to files named
        # <fileRoot>-NNN.<type>.  Normally, all images are written as PBM
        # (.pbm) or PPM (.ppm) files.  If <dumpJPEG> is set, JPEG images
        # are written as JPEG (.jpg) files.  If <dumpRaw> is set, all
        # images are written in PDF-native formats.  If <list> is set, a
        # one-line summary will be written to stdout for each image.
        ImageOutputDev(char *fileRootA, GBool dumpJPEGA, GBool dumpRawA,
                GBool listA)

        # Check if file was successfully created.
        GBool isOk() 

        # Does this device use tilingPatternFill()?  If this returns false,
        # tiling pattern fills will be reduced to a series of other drawing
        # operations.
        GBool useTilingPatternFill() 

        # Does this device use beginType3Char/endType3Char?  Otherwise,
        # text in Type 3 fonts will be drawn with drawChar/drawString.
        GBool interpretType3Chars() 

        # Does this device need non-text content?
        GBool needNonText() 

        #---- get info about output device

        # Does this device use upside-down coordinates?
        # (Upside-down means (0,0) is the top left corner of the page.)
        GBool upsideDown() 

        # Does this device use drawChar() or drawString()?
        GBool useDrawChar() 

        #----- initialization and control
        void startPage(int pageNum, GfxState *state)

        #----- path painting
        void tilingPatternFill(GfxState *state, Gfx *gfx, Object *strRef,
                        int paintType, int tilingType, Dict *resDict,
                        double *mat, double *bbox,
                        int x0, int y0, int x1, int y1,
                        double xStep, double yStep)

        #----- image drawing
        void drawImageMask(GfxState *state, Object *ref, Stream *str,
                        int width, int height, GBool invert,
                        GBool inlineImg, GBool interpolate)
        void drawImage(GfxState *state, Object *ref, Stream *str,
                    int width, int height, GfxImageColorMap *colorMap,
                    int *maskColors, GBool inlineImg, GBool interpolate)
        void drawMaskedImage(GfxState *state, Object *ref, Stream *str,
                        int width, int height,
                        GfxImageColorMap *colorMap,
                        Stream *maskStr, int maskWidth, int maskHeight,
                        GBool maskInvert, GBool interpolate)
        void drawSoftMaskedImage(GfxState *state, Object *ref, Stream *str,
                        int width, int height,
                        GfxImageColorMap *colorMap,
                        Stream *maskStr,
                        int maskWidth, int maskHeight,
                        GfxImageColorMap *maskColorMap,
                        double *matte, GBool interpolate)

from pyxpdf.includes.xpdf_types cimport Guchar, Guint, Gushort, GBool, GString
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Array cimport Array
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport Stream
from pyxpdf.includes.Page cimport PDFRectangle
from pyxpdf.includes.Function cimport Function
from pyxpdf.includes.GfxFont cimport GfxFont


cdef extern from "GfxState.h" nogil:
    ctypedef enum GfxBlendMode: 
        gfxBlendNormal
        gfxBlendMultiply
        gfxBlendScreen
        gfxBlendOverlay
        gfxBlendDarken
        gfxBlendLighten
        gfxBlendColorDodge
        gfxBlendColorBurn
        gfxBlendHardLight
        gfxBlendSoftLight
        gfxBlendDifference
        gfxBlendExclusion
        gfxBlendHue
        gfxBlendSaturation
        gfxBlendColor
        gfxBlendLuminosity


    ctypedef enum GfxRenderingIntent:
        gfxRenderingIntentAbsoluteColorimetric
        gfxRenderingIntentRelativeColorimetric
        gfxRenderingIntentSaturation
        gfxRenderingIntentPerceptual


    cdef int gfxNumRenderingIntents


    #------------------------------------------------------------------------
    # GfxColorComp
    #------------------------------------------------------------------------

    # 16.16 fixed point color component
    ctypedef int GfxColorComp

    cdef int gfxColorComp1 

    @staticmethod
    GfxColorComp dblToCol(double x)

    @staticmethod
    double colToDbl(GfxColorComp x) 

    @staticmethod
    GfxColorComp byteToCol(Guchar x)
    # (x / 255) << 16  =  (0.0000000100000001... * x) << 16
    #                  =  ((x << 8) + (x) + (x >> 8) + ...)
    #                  =  (x << 8) + (x) + (x >> 7)
    #                                      [for rounding]

    @staticmethod
    GfxColorComp wordToCol(Gushort x)
    # (x / 65535) << 16  =  (0.0000000000000001... * x) << 16
    #                    =  x + (x >> 15)
    #                           [for rounding]

    @staticmethod
    Guchar colToByte(GfxColorComp x)
    # 255 * x + 0.5  =  256 * x - x + 0.5
    #                =  [256 * (x << 16) - (x << 16) + (1 << 15)] >> 16

    @staticmethod
    Gushort colToWord(GfxColorComp x)
    # 65535 * x + 0.5  =  65536 * x - x + 0.5
    #                  =  [65536 * (x << 16) - (x << 16) + (1 << 15)] >> 16



    #------------------------------------------------------------------------
    # GfxColor
    #------------------------------------------------------------------------

    #define GfxColorMaxComps funcMaxOutputs  = 32
    cdef int gfxColorMaxComps 

    DEF GfxColorMaxComps = 32
    ctypedef struct GfxColor:
        GfxColorComp c[GfxColorMaxComps]
    

    #------------------------------------------------------------------------
    # GfxGray
    #------------------------------------------------------------------------

    ctypedef GfxColorComp GfxGray



    #------------------------------------------------------------------------
    # GfxRGB
    #------------------------------------------------------------------------

    ctypedef struct GfxRGB:
        GfxColorComp r, g, b


    #------------------------------------------------------------------------
    # GfxCMYK
    #------------------------------------------------------------------------

    ctypedef struct GfxCMYK:
        GfxColorComp c, m, y, k


    #------------------------------------------------------------------------
    # GfxColorSpace
    #------------------------------------------------------------------------

    # NB: The nGfxColorSpaceModes constant and the gfxColorSpaceModeNames
    # array defined in GfxState.cc must match this enum.
    ctypedef enum GfxColorSpaceMode:
        csDeviceGray
        csCalGray
        csDeviceRGB
        csCalRGB
        csDeviceCMYK
        csLab
        csICCBased
        csIndexed
        csSeparation
        csDeviceN
        csPattern
        


    cdef cppclass GfxColorSpace:
        GfxColorSpace()
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode()

        # Construct a color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Object *csObj,
                        int recursion = 0)

        # Construct a simple color space.  The <mode> argument can be
        # csDeviceGray, csDeviceRGB, or csDeviceCMYK.
        @staticmethod
        GfxColorSpace *create(GfxColorSpaceMode mode)


        # Convert to gray, RGB, or CMYK.
        void getGray(GfxColor *color, GfxGray *gray,
                    GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb,
                    GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk,
                    GfxRenderingIntent ri)

        # Return the number of color components.
        int getNComps()

        # Get this color space's default color.
        void getDefaultColor(GfxColor *color)

        # Return the default ranges for each component, assuming an image
        # with a max pixel value of <maxImgPixel>.
        void getDefaultRanges(double *decodeLow, double *decodeRange,
                        int maxImgPixel)

        # Returns true if painting operations in this color space never
        # mark the page (e.g., the "None" colorant).
        GBool isNonMarking() 


        # Return the color space's overprint mask.
        Guint getOverprintMask() 

        # Return the number of color space modes
        @staticmethod
        int getNumColorSpaceModes()

        # Return the name of the <idx>th color space mode.
        @staticmethod
        const char *getColorSpaceModeName(int idx)

        

    #------------------------------------------------------------------------
    # GfxDeviceGrayColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxDeviceGrayColorSpace(GfxColorSpace): 

        GfxDeviceGrayColorSpace()
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)


    #------------------------------------------------------------------------
    # GfxCalGrayColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxCalGrayColorSpace(GfxColorSpace):
        GfxCalGrayColorSpace()
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a CalGray color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        # CalGray-specific access.
        double getWhiteX() 
        double getWhiteY() 
        double getWhiteZ() 
        double getBlackX() 
        double getBlackY() 
        double getBlackZ() 
        double getGamma() 


    #------------------------------------------------------------------------
    # GfxDeviceRGBColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxDeviceRGBColorSpace(GfxColorSpace):

        GfxDeviceRGBColorSpace()
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)


    #------------------------------------------------------------------------
    # GfxCalRGBColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxCalRGBColorSpace(GfxColorSpace):
    
        GfxCalRGBColorSpace()
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a CalRGB color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        # CalRGB-specific access.
        double getWhiteX() 
        double getWhiteY() 
        double getWhiteZ() 
        double getBlackX() 
        double getBlackY() 
        double getBlackZ() 
        double getGammaR() 
        double getGammaG() 
        double getGammaB() 
        double *getMatrix() 


    #------------------------------------------------------------------------
    # GfxDeviceCMYKColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxDeviceCMYKColorSpace(GfxColorSpace):

        GfxDeviceCMYKColorSpace()
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)


    #------------------------------------------------------------------------
    # GfxLabColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxLabColorSpace(GfxColorSpace):

        GfxLabColorSpace()
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a Lab color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        void getDefaultRanges(double *decodeLow, double *decodeRange,
                        int maxImgPixel)

        # Lab-specific access.
        double getWhiteX() 
        double getWhiteY() 
        double getWhiteZ() 
        double getBlackX() 
        double getBlackY() 
        double getBlackZ() 
        double getAMin() 
        double getAMax() 
        double getBMin() 
        double getBMax() 


    #------------------------------------------------------------------------
    # GfxICCBasedColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxICCBasedColorSpace(GfxColorSpace):

        GfxICCBasedColorSpace(int nCompsA, GfxColorSpace *altA,
                    Ref *iccProfileStreamA)
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct an ICCBased color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        void getDefaultRanges(double *decodeLow, double *decodeRange,
                        int maxImgPixel)


        # ICCBased-specific access.
        GfxColorSpace *getAlt() 
        Ref getICCProfileStreamRef() 


    #------------------------------------------------------------------------
    # GfxIndexedColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxIndexedColorSpace(GfxColorSpace):

        GfxIndexedColorSpace(GfxColorSpace *baseA, int indexHighA)
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct an Indexed color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        void getDefaultRanges(double *decodeLow, double *decodeRange,
                        int maxImgPixel)

        # Indexed-specific access.
        GfxColorSpace *getBase() 
        int getIndexHigh() 
        Guchar *getLookup() 
        GfxColor *mapColorToBase(GfxColor *color, GfxColor *baseColor)


    #------------------------------------------------------------------------
    # GfxSeparationColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxSeparationColorSpace(GfxColorSpace):

        GfxSeparationColorSpace(GString *nameA, GfxColorSpace *altA,
                    Function *funcA)
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a Separation color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        GBool isNonMarking() 

        # Separation-specific access.
        GString *getName() 
        GfxColorSpace *getAlt() 
        Function *getFunc() 


    #------------------------------------------------------------------------
    # GfxDeviceNColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxDeviceNColorSpace(GfxColorSpace):

        GfxDeviceNColorSpace(int nCompsA, GString **namesA,
                    GfxColorSpace *alt, Function *func,
                    Object *attrsA)
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a DeviceN color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        GBool isNonMarking() 

        # DeviceN-specific access.
        GString *getColorantName(int i) 
        GfxColorSpace *getAlt() 
        Function *getTintTransformFunc() 
        Object *getAttrs() 


    #------------------------------------------------------------------------
    # GfxPatternColorSpace
    #------------------------------------------------------------------------

    cdef cppclass GfxPatternColorSpace(GfxColorSpace):

        GfxPatternColorSpace(GfxColorSpace *underA)
        
        GfxColorSpace *copy()
        GfxColorSpaceMode getMode() 

        # Construct a Pattern color space.  Returns NULL if unsuccessful.
        @staticmethod
        GfxColorSpace *parse(Array *arr, int recursion)

        void getGray(GfxColor *color, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(GfxColor *color, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(GfxColor *color, GfxCMYK *cmyk, GfxRenderingIntent ri)

        int getNComps() 
        void getDefaultColor(GfxColor *color)

        # Pattern-specific access.
        GfxColorSpace *getUnder() 


    #------------------------------------------------------------------------
    # GfxPattern
    #------------------------------------------------------------------------

    cdef cppclass GfxPattern:

        GfxPattern(int typeA)
        
        @staticmethod
        GfxPattern *parse(Object *objRef, Object *obj)

        GfxPattern *copy()

        int getType() 


    #------------------------------------------------------------------------
    # GfxTilingPattern
    #------------------------------------------------------------------------

    cdef cppclass GfxTilingPattern(GfxPattern):
        @staticmethod
        GfxTilingPattern *parse(Object *patObjRef, Object *patObj)
        

        GfxPattern *copy()

        int getPaintType() 
        int getTilingType() 
        double *getBBox() 
        double getXStep() 
        double getYStep() 
        Dict *getResDict()
            
        double *getMatrix() 
        Object *getContentStreamRef() 


    #------------------------------------------------------------------------
    # GfxShadingPattern
    #------------------------------------------------------------------------

    cdef cppclass GfxShadingPattern(GfxPattern):
        @staticmethod
        GfxShadingPattern *parse(Object *patObj)
        

        GfxPattern *copy()

        GfxShading *getShading() 
        double *getMatrix() 


    #------------------------------------------------------------------------
    # GfxShading
    #------------------------------------------------------------------------

    cdef cppclass GfxShading:

        GfxShading(int typeA)
        GfxShading(GfxShading *shading)
        
        @staticmethod
        GfxShading *parse(Object *obj)

        GfxShading *copy()

        int getType() 
        GfxColorSpace *getColorSpace() 
        GfxColor *getBackground() 
        GBool getHasBackground() 
        void getBBox(double *xMinA, double *yMinA, double *xMaxA, double *yMaxA)
            
        GBool getHasBBox() 


    #------------------------------------------------------------------------
    # GfxFunctionShading
    #------------------------------------------------------------------------

    cdef cppclass GfxFunctionShading(GfxShading):

        GfxFunctionShading(double x0A, double y0A,
                    double x1A, double y1A,
                    double *matrixA,
                    Function **funcsA, int nFuncsA)
        GfxFunctionShading(GfxFunctionShading *shading)
        
        @staticmethod
        GfxFunctionShading *parse(Dict *dict)

        GfxShading *copy()

        void getDomain(double *x0A, double *y0A, double *x1A, double *y1A)
            
        double *getMatrix() 
        int getNFuncs() 
        Function *getFunc(int i) 
        void getColor(double x, double y, GfxColor *color)


    #------------------------------------------------------------------------
    # GfxAxialShading
    #------------------------------------------------------------------------

    cdef cppclass GfxAxialShading(GfxShading):

        GfxAxialShading(double x0A, double y0A,
                double x1A, double y1A,
                double t0A, double t1A,
                Function **funcsA, int nFuncsA,
                GBool extend0A, GBool extend1A)
        GfxAxialShading(GfxAxialShading *shading)
        
        @staticmethod       
        GfxAxialShading *parse(Dict *dict)

        GfxShading *copy()

        void getCoords(double *x0A, double *y0A, double *x1A, double *y1A)
            
        double getDomain0() 
        double getDomain1() 
        GBool getExtend0() 
        GBool getExtend1() 
        int getNFuncs() 
        Function *getFunc(int i) 
        void getColor(double t, GfxColor *color)


    #------------------------------------------------------------------------
    # GfxRadialShading
    #------------------------------------------------------------------------

    cdef cppclass GfxRadialShading(GfxShading):

        GfxRadialShading(double x0A, double y0A, double r0A,
                double x1A, double y1A, double r1A,
                double t0A, double t1A,
                Function **funcsA, int nFuncsA,
                GBool extend0A, GBool extend1A)
        GfxRadialShading(GfxRadialShading *shading)
        
        @staticmethod
        GfxRadialShading *parse(Dict *dict)

        GfxShading *copy()

        void getCoords(double *x0A, double *y0A, double *r0A,
                double *x1A, double *y1A, double *r1A)
            
        double getDomain0() 
        double getDomain1() 
        GBool getExtend0() 
        GBool getExtend1() 
        int getNFuncs() 
        Function *getFunc(int i) 
        void getColor(double t, GfxColor *color)


    #------------------------------------------------------------------------
    # GfxGouraudTriangleShading
    #------------------------------------------------------------------------

    ctypedef struct GfxGouraudVertex:
        double x, y
        double color[GfxColorMaxComps]
        

    cdef cppclass GfxGouraudTriangleShading(GfxShading):

        GfxGouraudTriangleShading(int typeA,
                        GfxGouraudVertex *verticesA, int nVerticesA,
                        int (*trianglesA)[3], int nTrianglesA,
                        int nCompsA, Function **funcsA, int nFuncsA)
        GfxGouraudTriangleShading(GfxGouraudTriangleShading *shading)
        
        @staticmethod
        GfxGouraudTriangleShading *parse(int typeA, Dict *dict, Stream *str)

        GfxShading *copy()

        int getNComps() 
        int getNTriangles() 
        void getTriangle(int i, double *x0, double *y0, double *color0,
                double *x1, double *y1, double *color1,
                double *x2, double *y2, double *color2)
        void getColor(double *_in, GfxColor *out)


    #------------------------------------------------------------------------
    # GfxPatchMeshShading
    #------------------------------------------------------------------------

    ctypedef struct GfxPatch:
        double x[4][4]
        double y[4][4]
        double color[2][2][GfxColorMaxComps]
    

    cdef cppclass GfxPatchMeshShading(GfxShading):

        GfxPatchMeshShading(int typeA, GfxPatch *patchesA, int nPatchesA,
                    int nCompsA, Function **funcsA, int nFuncsA)
        GfxPatchMeshShading(GfxPatchMeshShading *shading)
        
        @staticmethod
        GfxPatchMeshShading *parse(int typeA, Dict *dict, Stream *str)

        GfxShading *copy()

        int getNComps() 
        int getNPatches() 
        GfxPatch *getPatch(int i) 
        void getColor(double *_in, GfxColor *out)


    #------------------------------------------------------------------------
    # GfxImageColorMap
    #------------------------------------------------------------------------

    cdef cppclass GfxImageColorMap:

        # Constructor.
        GfxImageColorMap(int bitsA, Object *decode, GfxColorSpace *colorSpaceA,
                int maxAllowedBits = 8)

        
        

        # Return a copy of this color map.
        GfxImageColorMap *copy() 

        # Is color map valid?
        GBool isOk() 

        # Get the color space.
        GfxColorSpace *getColorSpace() 

        # Get stream decoding info.
        int getNumPixelComps() 
        int getBits() 

        # Get decode table.
        double getDecodeLow(int i) 
        double getDecodeHigh(int i) 

        # Convert an image pixel to a color.
        void getGray(Guchar *x, GfxGray *gray, GfxRenderingIntent ri)
        void getRGB(Guchar *x, GfxRGB *rgb, GfxRenderingIntent ri)
        void getCMYK(Guchar *x, GfxCMYK *cmyk, GfxRenderingIntent ri)
        void getColor(Guchar *x, GfxColor *color)

        # Convert a line of <n> pixels to 8-bit colors.
        void getGrayByteLine(Guchar *_in, Guchar *out, int n, GfxRenderingIntent ri)
        void getRGBByteLine(Guchar *_in, Guchar *out, int n, GfxRenderingIntent ri)
        void getCMYKByteLine(Guchar *_in, Guchar *out, int n, GfxRenderingIntent ri)


    #------------------------------------------------------------------------
    # GfxSubpath and GfxPath
    #------------------------------------------------------------------------

    cdef cppclass GfxSubpath:

        # Constructor.
        GfxSubpath(double x1, double y1)

        # Copy.
        GfxSubpath *copy() 

        # Get points.
        int getNumPoints() 
        double getX(int i) 
        double getY(int i) 
        GBool getCurve(int i) 

        # Get last point.
        double getLastX() 
        double getLastY() 

        # Add a line segment.
        void lineTo(double x1, double y1)

        # Add a Bezier curve.
        void curveTo(double x1, double y1, double x2, double y2,
                double x3, double y3)

        # Close the subpath.
        void close()
        GBool isClosed() 

        # Add (<dx>, <dy>) to each point in the subpath.
        void offset(double dx, double dy)


    cdef cppclass GfxPath:

        # Constructor.
        GfxPath()

        # Copy.
        GfxPath *copy()
            

        # Is there a current point?
        GBool isCurPt() 

        # Is the path non-empty, i.e., is there at least one segment?
        GBool isPath() 

        # Get subpaths.
        int getNumSubpaths() 
        GfxSubpath *getSubpath(int i) 

        # Get last point on last subpath.
        double getLastX() 
        double getLastY() 

        # Move the current point.
        void moveTo(double x, double y)

        # Add a segment to the last subpath.
        void lineTo(double x, double y)

        # Add a Bezier curve to the last subpath
        void curveTo(double x1, double y1, double x2, double y2,
                double x3, double y3)

        # Close the last subpath.
        void close()

        # Append <path> to <this>.
        void append(GfxPath *path)

        # Add (<dx>, <dy>) to each point in the path.
        void offset(double dx, double dy)


    #------------------------------------------------------------------------
    # GfxState
    #------------------------------------------------------------------------

    cdef cppclass GfxState:

        # Construct a default GfxState, for a device with resolution <hDPI>
        # x <vDPI>, page box <pageBox>, page rotation <rotateA>, and
        # coordinate system specified by <upsideDown>.
        GfxState(double hDPIA, double vDPIA, PDFRectangle *pageBox,
            int rotateA, GBool upsideDown
            )


        # Copy.
        GfxState *copy(GBool copyPath = gFalse)
            

        # Accessors.
        double getHDPI() 
        double getVDPI() 
        double *getCTM() 
        double getX1() 
        double getY1() 
        double getX2() 
        double getY2() 
        double getPageWidth() 
        double getPageHeight() 
        int getRotate() 
        GfxColor *getFillColor() 
        GfxColor *getStrokeColor() 
        void getFillGray(GfxGray *gray)
            
        void getStrokeGray(GfxGray *gray)
            
        void getFillRGB(GfxRGB *rgb)
            
        void getStrokeRGB(GfxRGB *rgb)
            
        void getFillCMYK(GfxCMYK *cmyk)
            
        void getStrokeCMYK(GfxCMYK *cmyk)
            
        GfxColorSpace *getFillColorSpace() 
        GfxColorSpace *getStrokeColorSpace() 
        GfxPattern *getFillPattern() 
        GfxPattern *getStrokePattern() 
        GfxBlendMode getBlendMode() 
        double getFillOpacity() 
        double getStrokeOpacity() 
        GBool getFillOverprint() 
        GBool getStrokeOverprint() 
        int getOverprintMode() 
        GfxRenderingIntent getRenderingIntent() 
        Function **getTransfer() 
        double getLineWidth() 
        void getLineDash(double **dash, int *length, double *start)
            
        double getFlatness() 
        int getLineJoin() 
        int getLineCap() 
        double getMiterLimit() 
        GBool getStrokeAdjust() 
        GfxFont *getFont() 
        double getFontSize() 
        double *getTextMat() 
        double getCharSpace() 
        double getWordSpace() 
        double getHorizScaling() 
        double getLeading() 
        double getRise() 
        int getRender() 
        GfxPath *getPath() 
        void setPath(GfxPath *pathA)
        double getCurX() 
        double getCurY() 
        void getClipBBox(double *xMin, double *yMin, double *xMax, double *yMax)
            
        void getUserClipBBox(double *xMin, double *yMin, double *xMax, double *yMax)
        double getLineX() 
        double getLineY() 
        GBool getIgnoreColorOps() 

        # Is there a current point/path?
        GBool isCurPt() 
        GBool isPath() 

        # Transforms.
        void transform(double x1, double y1, double *x2, double *y2)
           
        void transformDelta(double x1, double y1, double *x2, double *y2)
        void textTransform(double x1, double y1, double *x2, double *y2)
        void textTransformDelta(double x1, double y1, double *x2, double *y2)
        double transformWidth(double w)
        double getTransformedLineWidth()
            
        double getTransformedFontSize()
        void getFontTransMat(double *m11, double *m12, double *m21, double *m22)

        # Change state parameters.
        void setCTM(double a, double b, double c,
                double d, double e, double f)
        void concatCTM(double a, double b, double c,
                double d, double e, double f)
        void shiftCTM(double tx, double ty)
        void setFillColorSpace(GfxColorSpace *colorSpace)
        void setStrokeColorSpace(GfxColorSpace *colorSpace)
        void setFillColor(GfxColor *color) 
        void setStrokeColor(GfxColor *color) 
        void setFillPattern(GfxPattern *pattern)
        void setStrokePattern(GfxPattern *pattern)
        void setBlendMode(GfxBlendMode mode) 
        void setFillOpacity(double opac) 
        void setStrokeOpacity(double opac) 
        void setFillOverprint(GBool op) 
        void setStrokeOverprint(GBool op) 
        void setOverprintMode(int opm) 
        void setRenderingIntent(GfxRenderingIntent ri) 
        void setTransfer(Function **funcs)
        void setLineWidth(double width) 
        void setLineDash(double *dash, int length, double start)
        void setFlatness(double flatness1) 
        void setLineJoin(int lineJoin1) 
        void setLineCap(int lineCap1) 
        void setMiterLimit(double limit) 
        void setStrokeAdjust(GBool sa) 
        void setFont(GfxFont *fontA, double fontSizeA)
            
        void setTextMat(double a, double b, double c,
                double d, double e, double f)
        void setCharSpace(double space)
            
        void setWordSpace(double space)
            
        void setHorizScaling(double scale)
            
        void setLeading(double leadingA)
            
        void setRise(double riseA)
            
        void setRender(int renderA)
            

        # Add to path.
        void moveTo(double x, double y)
            
        void lineTo(double x, double y)
            
        void curveTo(double x1, double y1, double x2, double y2,
                double x3, double y3)
            
        void closePath()
            
        void clearPath()

        # Update clip region.
        void clip()
        void clipToStrokePath()
        void clipToRect(double xMin, double yMin, double xMax, double yMax)
        void resetDevClipRect(double xMin, double yMin, double xMax, double yMax)
            

        # Text position.
        void textSetPos(double tx, double ty) 
        void textMoveTo(double tx, double ty)
            
        void textShift(double tx, double ty)
        void shift(double dx, double dy)
        
        # Ignore color operators (in cached/uncolored Type 3 chars, and
        # uncolored tiling patterns).  Cached Type 3 char status.
        void setIgnoreColorOps(GBool ignore) 

        # Push/pop GfxState on/off stack.
        GfxState *save()
        GfxState *restore()
        GBool hasSaves() 

        # Misc
        GBool parseBlendMode(Object *obj, GfxBlendMode *mode)







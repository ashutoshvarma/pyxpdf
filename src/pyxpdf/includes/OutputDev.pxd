from pyxpdf.includes.xpdf_types cimport GBool, GString
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport Stream
from pyxpdf.includes.Function cimport Function
from pyxpdf.includes.Link cimport Link
from pyxpdf.includes.Gfx cimport Gfx
from pyxpdf.includes.GfxState cimport GfxState, GfxFunctionShading, GfxAxialShading, GfxRadialShading, GfxImageColorMap, GfxColor, GfxColorSpace
from pyxpdf.includes.Page cimport Page
from pyxpdf.includes.CharTypes cimport Unicode, CharCode


cdef extern from "OutputDev.h" nogil:
    cdef cppclass OutputDev:
        # Constructor.
        OutputDev() 

        #----- get info about output device

        # Does this device use upside-down coordinates?
        # (Upside-down means (0,0) is the top left corner of the page.)
        GBool upsideDown()

        # Does this device use drawChar() or drawString()?
        GBool useDrawChar()

        # Does this device use tilingPatternFill()?  If this returns false,
        # tiling pattern fills will be reduced to a series of other drawing
        # operations.
        GBool useTilingPatternFill() 

        # Does this device use functionShadedFill(), axialShadedFill(), and
        # radialShadedFill()?  If this returns false, these shaded fills
        # will be reduced to a series of other drawing operations.
        GBool useShadedFills() 

        # Does this device use drawForm()?  If this returns false,
        # form-type XObjects will be interpreted (i.e., unrolled).
        GBool useDrawForm() 

        # Does this device use beginType3Char/endType3Char?  Otherwise,
        # text in Type 3 fonts will be drawn with drawChar/drawString.
        GBool interpretType3Chars()

        # Does this device need non-text content?
        GBool needNonText() 

        # Does this device require incCharCount to be called for text on
        # non-shown layers?
        GBool needCharCount() 



        #----- initialization and control

        # Set default transform matrix.
        void setDefaultCTM(double *ctm)

        # Check to see if a page slice should be displayed.  If this
        # returns false, the page display is aborted.  Typically, an
        # OutputDev will use some alternate means to display the page
        # before returning false.
        GBool checkPageSlice(Page *page, double hDPI, double vDPI,
                        int rotate, GBool useMediaBox, GBool crop,
                        int sliceX, int sliceY, int sliceW, int sliceH,
                        GBool printing,
                        GBool (*abortCheckCbk)(void *data) = NULL,
                        void *abortCheckCbkData = NULL)
            

        # Start a page.
        void startPage(int pageNum, GfxState *state) 

        # End a page.
        void endPage() 

        #----- coordinate conversion

        # Convert between device and user coordinates.
        void cvtDevToUser(double dx, double dy, double *ux, double *uy)
        void cvtUserToDev(double ux, double uy, double *dx, double *dy)
        void cvtUserToDev(double ux, double uy, int *dx, int *dy)

        double *getDefCTM() 
        double *getDefICTM() 

        #----- save/restore graphics state
        void saveState(GfxState *state) 
        void restoreState(GfxState *state) 

        #----- update graphics state
        void updateAll(GfxState *state)
        void updateCTM(GfxState *state, double m11, double m12,
                    double m21, double m22, double m31, double m32) 
        void updateLineDash(GfxState *state) 
        void updateFlatness(GfxState *state) 
        void updateLineJoin(GfxState *state) 
        void updateLineCap(GfxState *state) 
        void updateMiterLimit(GfxState *state) 
        void updateLineWidth(GfxState *state) 
        void updateStrokeAdjust(GfxState *state) 
        void updateFillColorSpace(GfxState *state) 
        void updateStrokeColorSpace(GfxState *state) 
        void updateFillColor(GfxState *state) 
        void updateStrokeColor(GfxState *state) 
        void updateBlendMode(GfxState *state) 
        void updateFillOpacity(GfxState *state) 
        void updateStrokeOpacity(GfxState *state) 
        void updateFillOverprint(GfxState *state) 
        void updateStrokeOverprint(GfxState *state) 
        void updateOverprintMode(GfxState *state) 
        void updateRenderingIntent(GfxState *state) 
        void updateTransfer(GfxState *state) 

        #----- update text state
        void updateFont(GfxState *state) 
        void updateTextMat(GfxState *state) 
        void updateCharSpace(GfxState *state) 
        void updateRender(GfxState *state) 
        void updateRise(GfxState *state) 
        void updateWordSpace(GfxState *state) 
        void updateHorizScaling(GfxState *state) 
        void updateTextPos(GfxState *state) 
        void updateTextShift(GfxState *state, double shift) 
        void saveTextPos(GfxState *state) 
        void restoreTextPos(GfxState *state) 

        #----- path painting
        void stroke(GfxState *state) 
        void fill(GfxState *state) 
        void eoFill(GfxState *state) 
        void tilingPatternFill(GfxState *state, Gfx *gfx, Object *strRef,
                        int paintType, int tilingType, Dict *resDict,
                        double *mat, double *bbox,
                        int x0, int y0, int x1, int y1,
                        double xStep, double yStep) 
        GBool functionShadedFill(GfxState *state,
                        GfxFunctionShading *shading)
            
        GBool axialShadedFill(GfxState *state, GfxAxialShading *shading)
            
        GBool radialShadedFill(GfxState *state, GfxRadialShading *shading)
            

        #----- path clipping
        void clip(GfxState *state) 
        void eoClip(GfxState *state) 
        void clipToStrokePath(GfxState *state) 

        #----- text drawing
        void beginStringOp(GfxState *state) 
        void endStringOp(GfxState *state) 
        void beginString(GfxState *state, GString *s) 
        void endString(GfxState *state) 
        void drawChar(GfxState *state, double x, double y,
                    double dx, double dy,
                    double originX, double originY,
                    CharCode code, int nBytes, Unicode *u, int uLen) 
        void drawString(GfxState *state, GString *s) 
        GBool beginType3Char(GfxState *state, double x, double y,
                        double dx, double dy,
                        CharCode code, Unicode *u, int uLen)
        void endType3Char(GfxState *state) 
        void endTextObject(GfxState *state) 
        void incCharCount(int nChars) 
        void beginActualText(GfxState *state, Unicode *u, int uLen) 
        void endActualText(GfxState *state) 

        #----- image drawing
        void drawImageMask(GfxState *state, Object *ref, Stream *str,
                        int width, int height, GBool invert,
                        GBool inlineImg, GBool interpolate)
        void setSoftMaskFromImageMask(GfxState *state,
                            Object *ref, Stream *str,
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

        #----- OPI functions
        void opiBegin(GfxState *state, Dict *opiDict)
        void opiEnd(GfxState *state, Dict *opiDict)

        #----- Type 3 font operators
        void type3D0(GfxState *state, double wx, double wy) 
        void type3D1(GfxState *state, double wx, double wy,
                    double llx, double lly, double urx, double ury) 

        #----- form XObjects
        void drawForm(Ref id) 

        #----- PostScript XObjects
        void psXObject(Stream *psStream, Stream *level1Stream) 

        #----- transparency groups and soft masks
        void beginTransparencyGroup(GfxState *state, double *bbox,
                            GfxColorSpace *blendingColorSpace,
                            GBool isolated, GBool knockout,
                            GBool forSoftMask) 
        void endTransparencyGroup(GfxState *state) 
        void paintTransparencyGroup(GfxState *state, double *bbox) 
        void setSoftMask(GfxState *state, double *bbox, GBool alpha,
                    Function *transferFunc, GfxColor *backdropColor) 
        void clearSoftMask(GfxState *state) 

        #----- links
        void processLink(Link *link) 

        void setInShading(GBool sh) 

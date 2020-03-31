from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.Page cimport Page, PDFRectangle
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.Annot cimport AnnotBorderStyle
from pyxpdf.includes.Function cimport Function
from pyxpdf.includes.GfxFont cimport GfxFont
from pyxpdf.includes.GfxState cimport GfxState, GfxPattern, GfxShading, GfxColorSpace, GfxColor



cdef extern from "Gfx.h" nogil:
    ctypedef enum GfxClipType:
        clipNone
        clipNormal
        clipEO


    ctypedef enum TchkType:
        tchkBool			# boolean
        tchkInt			    # integer
        tchkNum			    # number (integer or real)
        tchkString			# string
        tchkName			# name
        tchkArray			# array
        tchkProps			# properties (dictionary or name)
        tchkSCN			    # scn/SCN args (number of name)
        tchkNone			# used to avoid empty initializer lists

    #define maxArgs 33
    cdef int maxArgs 

    DEF MaxArgs = 33
    ctypedef struct Operator:
        char name[4]
        int numArgs
        TchkType tchk[MaxArgs]
        void (*func "Gfx::*func")(Object args[], int numArgs)


    cdef cppclass GfxResources: 
        GfxResources(XRef *xref, Dict *resDict, GfxResources *nextA)

        GfxFont *lookupFont(char *name)
        GfxFont *lookupFontByRef(Ref ref)
        GBool lookupXObject(const char *name, Object *obj)
        GBool lookupXObjectNF(const char *name, Object *obj)
        void lookupColorSpace(const char *name, Object *obj)
        GfxPattern *lookupPattern(const char *name)
        GfxShading *lookupShading(const char *name)
        GBool lookupGState(const char *name, Object *obj)
        GBool lookupPropertiesNF(const char *name, Object *obj)

        GfxResources *getNext() 


    ctypedef enum GfxMarkedContentKind:
        gfxMCOptionalContent
        gfxMCActualText
        gfxMCOther


    cdef cppclass GfxMarkedContent:
        GfxMarkedContent(GfxMarkedContentKind kindA, GBool ocStateA)

        GfxMarkedContentKind kind
        GBool ocState		# true if drawing is enabled, false if
                            #   disabled


    cdef cppclass Gfx:
        # Constructor for regular output.
        Gfx(PDFDoc *docA, OutputDev *outA, int pageNum, Dict *resDict,
            double hDPI, double vDPI, PDFRectangle *box,
            PDFRectangle *cropBox, int rotate,
            GBool (*abortCheckCbkA)(void *data) = NULL,
            void *abortCheckCbkDataA = NULL)

        # Constructor for a sub-page object.
        Gfx(PDFDoc *docA, OutputDev *outA, Dict *resDict,
            PDFRectangle *box, PDFRectangle *cropBox,
            GBool (*abortCheckCbkA)(void *data) = NULL,
            void *abortCheckCbkDataA = NULL)

        # Interpret a stream or array of streams.  <objRef> should be a
        # reference wherever possible (for loop-checking).
        void display(Object *objRef, GBool topLevel = gTrue)

        # Display an annotation, given its appearance (a Form XObject),
        # border style, and bounding box (in default user space).
        void drawAnnot(Object *strRef, AnnotBorderStyle *borderStyle,
                double xMin, double yMin, double xMax, double yMax)

        # Save graphics state.
        void saveState()

        # Restore graphics state.
        void restoreState()

        # Get the current graphics state object.
        GfxState *getState() 

        void drawForm(Object *strRef, Dict *resDict, double *matrix, double *bbox,
                GBool transpGroup = gFalse, GBool softMask = gFalse,
                GfxColorSpace *blendingColorSpace = NULL,
                GBool isolated = gFalse, GBool knockout = gFalse,
                GBool alpha = gFalse, Function *transferFunc = NULL,
                GfxColor *backdropColor = NULL)

        # Take all of the content stream stack entries from <oldGfx>.  This
        # is useful when creating a new Gfx object to handle a pattern,
        # etc., where it's useful to check for loops that span both Gfx
        # objects.  This function should be called immediately after the
        # Gfx constructor, i.e., before processing any content streams with
        # the new Gfx object.
        void takeContentStreamStack(Gfx *oldGfx)

        # Clear the state stack and the marked content stack.
        void endOfPage()
from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport Stream
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.Link cimport Links
from pyxpdf.includes.PDFDoc cimport PDFDoc


cdef extern from "Page.h" nogil:
    cdef cppclass PDFRectangle:
        double x1, y1, x2, y2

        PDFRectangle()
        PDFRectangle(double x1A, double y1A, double x2A, double y2A)
        GBool isValid() 
        void clipTo(PDFRectangle *rect)

    cdef cppclass PageAttrs:
        # Construct a new PageAttrs object by merging a dictionary
        # (of type Pages or Page) into another PageAttrs object.  If
        # <attrs> is NULL, uses defaults.
        PageAttrs(PageAttrs *attrs, Dict *dict)

        # Construct a new PageAttrs object for an empty page (only used
        # when there is an error in the page tree).
        PageAttrs()

        # Accessors.
        PDFRectangle *getMediaBox() 
        PDFRectangle *getCropBox() 
        GBool isCropped() 
        PDFRectangle *getBleedBox() 
        PDFRectangle *getTrimBox() 
        PDFRectangle *getArtBox() 
        int getRotate() 
        GString *getLastModified()
        Dict *getBoxColorInfo()
            
        Dict *getGroup()
            
        Stream *getMetadata()
            
        Dict *getPieceInfo()
            
        Dict *getSeparationInfo()
           
        double getUserUnit() 
        Dict *getResourceDict()
            

        # Clip all other boxes to the MediaBox.
        void clipBoxes()


    cdef cppclass Page:
        # Constructor.
        Page(PDFDoc *docA, int numA, Dict *pageDict, PageAttrs *attrsA)

        # Create an empty page (only used when there is an error in the
        # page tree).
        Page(PDFDoc *docA, int numA)

        # Is page valid?
        GBool isOk() 

        # Get page parameters.
        int getNum() 
        PDFRectangle *getMediaBox() 
        PDFRectangle *getCropBox() 
        GBool isCropped() 
        double getMediaWidth() 
            
        double getMediaHeight()
            
        double getCropWidth() 
            
        double getCropHeight()
            
        PDFRectangle *getBleedBox() 
        PDFRectangle *getTrimBox() 
        PDFRectangle *getArtBox() 
        int getRotate() 
        GString *getLastModified() 
        Dict *getBoxColorInfo() 
        Dict *getGroup() 
        Stream *getMetadata() 
        Dict *getPieceInfo() 
        Dict *getSeparationInfo() 
        double getUserUnit() 

        # Get resource dictionary.
        Dict *getResourceDict() 

        # Get annotations array.
        Object *getAnnots(Object *obj) 

        # Return a list of links.
        Links *getLinks()

        # Get contents.
        Object *getContents(Object *obj) 

        # Get the page's thumbnail image.
        Object *getThumbnail(Object *obj) 

        # Display a page.
        void display(OutputDev *out, double hDPI, double vDPI,
                int rotate, GBool useMediaBox, GBool crop,
                GBool printing,
                GBool (*abortCheckCbk)(void *data) = NULL,
                void *abortCheckCbkData = NULL)

        # Display part of a page.
        void displaySlice(OutputDev *out, double hDPI, double vDPI,
                    int rotate, GBool useMediaBox, GBool crop,
                    int sliceX, int sliceY, int sliceW, int sliceH,
                    GBool printing,
                    GBool (*abortCheckCbk)(void *data) = NULL,
                    void *abortCheckCbkData = NULL)

        void makeBox(double hDPI, double vDPI, int rotate,
                GBool useMediaBox, GBool upsideDown,
                double sliceX, double sliceY, double sliceW, double sliceH,
                PDFRectangle *box, GBool *crop)

        void processLinks(OutputDev *out)

        # Get the page's default CTM.
        void getDefaultCTM(double *ctm, double hDPI, double vDPI,
                    int rotate, GBool useMediaBox, GBool upsideDown)
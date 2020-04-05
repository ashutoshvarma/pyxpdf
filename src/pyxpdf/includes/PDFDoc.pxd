from pyxpdf.includes.xpdf_types cimport GString, GBool, gFalse
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.Catalog cimport Catalog
from pyxpdf.includes.Stream cimport BaseStream
from pyxpdf.includes.PDFCore cimport PDFCore
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Link cimport Links, LinkDest
from pyxpdf.includes.Outline cimport Outline, OutlineItem
from pyxpdf.includes.OptionalContent cimport OptionalContent




cdef extern from "PDFDoc.h" nogil:
    cdef cppclass PDFDoc:
        # This version takes a UTF-8 file name (which is only relevant on
        # Windows).
        PDFDoc(char *fileNameA, GString *ownerPassword, GString *userPassword, PDFCore *coreA = NULL)

        # BUG: Workaround as Cython assumes these two have same signature
        PDFDoc(GString *fileName, GString *ownerPassword, GString *userPassword)

        PDFDoc(BaseStream *strA, GString *owner, GString *user)
        
        GBool isOk()

        int getErrorCode()

        # Get the xref table.
        XRef *getXRef()

        # Get catalog.
        Catalog *getCatalog()

        # Get base stream.
        BaseStream *getBaseStream()

        # Get page parameters.
        double getPageMediaWidth(int page)
        double getPageMediaHeight(int page)
        double getPageCropWidth(int page)
        double getPageCropHeight(int page)
        int getPageRotate(int page)

        # Get number of pages.
        int getNumPages()

        # Return the contents of the metadata stream, or NULL if there is
        # no metadata.
        GString *readMetadata()

        # Return the structure tree root object.
        Object *getStructTreeRoot()

        # Display a page.
        void displayPage(OutputDev *out, int page, double hDPI, double vDPI, 
                        int rotate, GBool useMediaBox, GBool crop, GBool printing, 
                        GBool (*abortCheckCbk)(void *data) = NULL, void *abortCheckCbkData = NULL)

        # Display a range of pages.
        void displayPages(OutputDev *out, int firstPage, int lastPage, double hDPI, 
                        double vDPI, int rotate, GBool useMediaBox, GBool crop, 
                        GBool printing, GBool (*abortCheckCbk)(void *data) = NULL, 
                        void *abortCheckCbkData = NULL)

        # Display part of a page.
        void displayPageSlice(OutputDev *out, int page,
                        double hDPI, double vDPI, int rotate,
                        GBool useMediaBox, GBool crop, GBool printing,
                        int sliceX, int sliceY, int sliceW, int sliceH,
                        GBool (*abortCheckCbk)(void *data) = NULL,
                        void *abortCheckCbkData = NULL)

        # Find a page, given its object ID.  Returns page number, or 0 if
        # not found.
        int findPage(int num, int gen)

        # Returns the links for the current page, transferring ownership to
        # the caller.
        Links *getLinks(int page)

        # Find a named destination.  Returns the link destination, or
        # NULL if <name> is not a destination.
        LinkDest *findDest(GString *name)

        # Process the links for a page.
        void processLinks(OutputDev *out, int page)

        # Return the outline object.
        Outline *getOutline() 

        # Return the OptionalContent object.
        OptionalContent *getOptionalContent()

        # Is the file encrypted?
        GBool isEncrypted()

        # Return the target page number for an outline item.  Returns 0 if
        # the item doesn't target a page in this PDF file.
        int getOutlineTargetPage(OutlineItem *outlineItem)


        # Check various permissions.
        GBool okToPrint(GBool ignoreOwnerPW = gFalse)
        GBool okToChange(GBool ignoreOwnerPW = gFalse)
        GBool okToCopy(GBool ignoreOwnerPW = gFalse)
        GBool okToAddNotes(GBool ignoreOwnerPW = gFalse)

        # Is this document linearized?
        GBool isLinearized()

        # Return the document's Info dictionary (if any).
        Object *getDocInfo(Object *obj) 
        Object *getDocInfoNF(Object *obj) 

        # Return the PDF version specified by the file.
        double getPDFVersion() 

        # Save this file with another name.
        GBool saveAs(GString *name)

        # Return a pointer to the PDFCore object.
        PDFCore *getCore() 

        # Get the list of embedded files.
        int getNumEmbeddedFiles() 
        Unicode *getEmbeddedFileName(int idx)
        int getEmbeddedFileNameLength(int idx)
        GBool saveEmbeddedFile(int idx, const char *path)
        
        char *getEmbeddedFileMem(int idx, int *size)

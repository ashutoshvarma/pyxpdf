from pyxpdf.includes.xpdf_types cimport GBool, GList, GString
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Page cimport Page
from pyxpdf.includes.Link cimport LinkDest
from pyxpdf.includes.TextString cimport TextString
from pyxpdf.includes.PDFDoc cimport PDFDoc

# Lazy load Form to prevent crazy import errors
cdef extern from *:
    cdef cppclass Form:
        pass

cdef extern from "Catalog.h" nogil:
    cdef cppclass Catalog:
        # Constructor.
        Catalog(PDFDoc *docA)

        # Is catalog valid?
        GBool isOk() 

        # Get number of pages.
        int getNumPages() 

        # Get a page.
        Page *getPage(int i)

        # Get the reference for a page object.
        Ref *getPageRef(int i)

        # Remove a page from the catalog.  (It can be reloaded later by
        # calling getPage).
        void doneWithPage(int i)

        # Return base URI, or NULL if none.
        GString *getBaseURI() 

        # Return the contents of the metadata stream, or NULL if there is
        # no metadata.
        GString *readMetadata()

        # Return the structure tree root object.
        Object *getStructTreeRoot() 

        # Find a page, given its object ID.  Returns page number, or 0 if
        # not found.
        int findPage(int num, int gen)

        # Find a named destination.  Returns the link destination, or
        # NULL if <name> is not a destination.
        LinkDest *findDest(GString *name)

        Object *getDests() 

        Object *getNameTree() 

        Object *getOutline() 

        Object *getAcroForm() 

        GBool getNeedsRendering() 

        Object *getOCProperties() 

        # Return the DestOutputProfile stream, or NULL if there isn't one.
        Object *getDestOutputProfile(Object *destOutProf)

        # Get the list of embedded files.
        int getNumEmbeddedFiles()
        Unicode *getEmbeddedFileName(int idx)
        int getEmbeddedFileNameLength(int idx)
        Object *getEmbeddedFileStreamRef(int idx)
        Object *getEmbeddedFileStreamObj(int idx, Object *strObj)

        # Return true if the document has page labels.
        GBool hasPageLabels() 

        # Get the page label for page number [pageNum].  Returns NULL if
        # the PDF file doesn't have page labels.
        TextString *getPageLabel(int pageNum)

        # Returns the page number corresponding to [pageLabel].  Returns -1
        # if there is no matching page label, or if the document doesn't
        # have page labels.
        int getPageNumFromPageLabel(TextString *pageLabel)

        Object *getViewerPreferences() 

        Form *getForm() 
        

# Lazy import to prevent crazy compiler include errors
from pyxpdf.includes.Form cimport Form


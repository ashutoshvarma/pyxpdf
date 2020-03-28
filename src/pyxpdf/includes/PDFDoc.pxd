from pyxpdf.includes.defs cimport _WIN32
from pyxpdf.includes.xpdf_types cimport GString, GBool, gFalse
from pyxpdf.includes.PDFCore cimport PDFCore
from pyxpdf.includes.OutputDev cimport OutputDev



cdef extern from "PDFDoc.h" nogil:
    cdef cppclass PDFDoc:
        # This version takes a UTF-8 file name (which is only relevant on
        # Windows).
        PDFDoc(char *fileNameA, GString *ownerPassword = NULL, GString *userPassword = NULL, 
                PDFCore *coreA = NULL)
        PDFDoc(GString *fileNameA, GString *ownerPassword = NULL, GString *userPassword = NULL, 
                PDFCore *coreA = NULL)
        GBool isOk()
        int getErrorCode()
        int getNumPages()
        GBool okToCopy(GBool ignoreOwnerPW = gFalse)

        # Display a page.
        void displayPage(OutputDev *out, int page, double hDPI, double vDPI, 
                        int rotate, GBool useMediaBox, GBool crop, GBool printing, 
                        GBool (*abortCheckCbk)(void *data) = NULL, void *abortCheckCbkData = NULL)

        # Display a range of pages.
        void displayPages(OutputDev *out, int firstPage, int lastPage, double hDPI, 
                        double vDPI, int rotate, GBool useMediaBox, GBool crop, 
                        GBool printing, GBool (*abortCheckCbk)(void *data) = NULL, 
                        void *abortCheckCbkData = NULL)
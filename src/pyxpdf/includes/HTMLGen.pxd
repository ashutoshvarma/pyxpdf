from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.PDFDoc cimport PDFDoc



cdef extern from "HTMLGen.h" nogil:
    cdef cppclass HTMLGen:
        HTMLGen(double backgroundResolutionA)

        GBool isOk() 

        double getBackgroundResolution() 
        void setBackgroundResolution(double backgroundResolutionA)
            

        double getZoom() 
        void setZoom(double zoomA) 

        GBool getDrawInvisibleText() 
        void setDrawInvisibleText(GBool drawInvisibleTextA)
            

        GBool getAllTextInvisible() 
        void setAllTextInvisible(GBool allTextInvisibleA)
            

        void setExtractFontFiles(GBool extractFontFilesA)
            

        void startDoc(PDFDoc *docA)
        int convertPage(int pg, const char *pngURL, const char *htmlDir,
                int (*writeHTML)(void *stream, const char *data, int size),
                void *htmlStream,
                int (*writePNG)(void *stream, const char *data, int size),
                void *pngStream)
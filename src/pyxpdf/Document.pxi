from libc.stdlib cimport free
from pyxpdf.includes.PDFDoc cimport PDFDoc 
from pyxpdf.includes.xpdf_types cimport gFalse

cdef class Document:
    cdef PDFDoc* pdfdoc

    def __cinit__(self, filename, owner_pass=None, user_pass=None):
        self.pdfdoc = new PDFDoc(pytext_to_bytes(filename))
        if self.pdfdoc.isOk() == 0:
            raise PDFError(f"Could'nt Open PDF file. ErrorCode - {self.pdfdoc.getErrorCode()}")

    def __dealloc__(self):
        if self.pdfdoc != NULL:
            free(self.pdfdoc)
    
    @property
    def num_pages(self):
        return self.pdfdoc.getNumPages()

    @property
    def ok_to_copy(self):
        if self.pdfdoc.okToCopy() == gFalse:
            return False
        else:
            return True

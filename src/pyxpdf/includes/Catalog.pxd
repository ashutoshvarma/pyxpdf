cdef extern from "Catalog.h" nogil:
    cdef cppclass Catalog:
        # Is catalog valid?
        GBool isOk()
        # Get number of pages.
        int getNumPages() 
        # Get a page.
        Page *getPage(int i)
        # Remove a page from the catalog.  (It can be reloaded later by
        # calling getPage).
        void doneWithPage(int i)

from pyxpdf.includes.xpdf_types cimport GString, GBool, GList
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Link cimport LinkAction
from pyxpdf.includes.TextString cimport TextString



cdef extern from "Outline.h" nogil:
    cdef cppclass Outline:
        Outline(Object *outlineObj, XRef *xref)
        GList *getItems()
    
    
    cdef cppclass OutlineItem:
        OutlineItem(Object *itemRefA, Dict *dict, OutlineItem *parentA, XRef *xrefA)

        @staticmethod
        GList *readItemList(Object *firstItemRef, Object *lastItemRef,
                        OutlineItem *parentA, XRef *xrefA)

        void open()
        void close()

        Unicode *getTitle()
        int getTitleLength()
        TextString *getTitleTextString() 
        LinkAction *getAction() 
        GBool isOpen() 
        GBool hasKids() 
        GList *getKids() 
        OutlineItem *getParent() 
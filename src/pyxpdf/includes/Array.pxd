from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef


cdef extern from "Array.h" nogil:
    cdef cppclass Array:
        # Constructor.
        Array(XRef *xrefA)

        # Reference counting.
        long incRef() 
        long decRef() 

        # Get number of elements.
        int getLength() 

        # Add an element.
        void add(Object *elem)

        # Accessors.
        Object *get(int i, Object *obj, int recursion = 0)
        Object *getNF(int i, Object *obj)
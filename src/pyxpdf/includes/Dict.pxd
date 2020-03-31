from pyxpdf.includes.xpdf_types cimport GString, GBool
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef



cdef extern from "Dict.h" nogil:
    ctypedef struct DictEntry:
        pass

    cdef cppclass Dict:
        # Constructor.
        Dict(XRef *xrefA)

        # Reference counting.
        long incRef() 
        long decRef() 

        # Get number of entries.
        int getLength() 

        # Add an entry.  NB: does not copy key.
        void add(char *key, Object *val)

        # Check if dictionary is of specified type.
        GBool is_type "is"(const char *type)

        # Look up an entry and return the value.  Returns a null object
        # if <key> is not in the dictionary.
        Object *lookup(const char *key, Object *obj, int recursion = 0)
        Object *lookupNF(const char *key, Object *obj)

        # Iterative accessors.
        char *getKey(int i)
        Object *getVal(int i, Object *obj)
        Object *getValNF(int i, Object *obj)

        # Set the xref pointer.  This is only used in one special case: the
        # trailer dictionary, which is read before the xref table is
        # parsed.
        void setXRef(XRef *xrefA) 


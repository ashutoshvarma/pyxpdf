from libc.stdio cimport FILE, stdout
from pyxpdf.includes.xpdf_types cimport GString, GBool, GFileOffset



cdef extern from "Object.h" nogil:
    ctypedef struct Ref:
        int num
        int gen

    ctypedef enum ObjType: 
        # simple objects
        objBool			# boolean
        objInt			# integer
        objReal			# real
        objString		# string
        objName			# name
        objNull			# null

        # complex objects
        objArray		# array
        objDict			# dictionary
        objStream		# stream
        objRef			# indirect reference

        # special objects
        objCmd			# command name
        objError		# error return from Lexer
        objEOF			# end of file return from Lexer
        objNone			# uninitialized object

    int numObjTypes


# Lazy import to prevent crazy compiler include errors
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Array cimport Array
from pyxpdf.includes.Stream cimport Stream
from pyxpdf.includes.XRef cimport XRef

cdef extern from "Object.h" nogil:
    cdef cppclass Object:
        # Default constructor.
        Object():type(objNone)

          # Initialize an object.
        Object *initBool(GBool boolnA)
        Object *initInt(int intgA)
        Object *initReal(double realA)
        Object *initString(GString *stringA)
        Object *initName(const char *nameA)
        Object *initNull()
        Object *initArray(XRef *xref)
        Object *initDict(XRef *xref)
        Object *initDict(Dict *dictA)
        Object *initStream(Stream *streamA)
        Object *initRef(int numA, int genA)
        Object *initCmd(char *cmdA)
        Object *initError()
        Object *initEOF()

        # Copy an object.
        Object *copy(Object *obj)

        # If object is a Ref, fetch and return the referenced object.
        # Otherwise, return a copy of the object.
        Object *fetch(XRef *xref, Object *obj, int recursion = 0)

        # Free object contents.
        void free()

        # Type checking.
        ObjType getType()
        GBool isBool() 
        GBool isInt() 
        GBool isReal() 
        GBool isNum() 
        GBool isString()
        GBool isName() 
        GBool isNull() 
        GBool isArray() 
        GBool isDict() 
        GBool isStream()
        GBool isRef() 
        GBool isCmd() 
        GBool isError() 
        GBool isEOF() 
        GBool isNone() 

        # Special type checking.
        GBool isName(const char *nameA)
        GBool isDict(const char *dictType)
        GBool isStream(char *dictType)
        GBool isCmd(const char *cmdA)

        # Accessors.  NB: these assume object is of correct type.
        GBool getBool() 
        int getInt() 
        double getReal() 
        double getNum() 
        GString *getString()
        char *getName() 
        Array *getArray() 
        Dict *getDict() 
        Stream *getStream()
        Ref getRef() 
        int getRefNum() 
        int getRefGen() 
        char *getCmd() 

        # Array accessors.
        int arrayGetLength()
        void arrayAdd(Object *elem)
        Object *arrayGet(int i, Object *obj, int recursion = 0)
        Object *arrayGetNF(int i, Object *obj)

        # Dict accessors.
        int dictGetLength()
        void dictAdd(char *key, Object *val)
        GBool dictIs(const char *dictType)
        Object *dictLookup(const char *key, Object *obj, int recursion = 0)
        Object *dictLookupNF(const char *key, Object *obj)
        char *dictGetKey(int i)
        Object *dictGetVal(int i, Object *obj)
        Object *dictGetValNF(int i, Object *obj)

        # Stream accessors.
        GBool streamIs(char *dictType)
        void streamReset()
        void streamClose()
        int streamGetChar()
        int streamLookChar()
        int streamGetBlock(char *blk, int size)
        char *streamGetLine(char *buf, int size)
        GFileOffset streamGetPos()
        void streamSetPos(GFileOffset pos, int dir = 0)
        Dict *streamGetDict()

        # Output.
        const char *getTypeName()
        # void print(FILE *f = stdout)

        # Memory testing.
        @staticmethod
        void memCheck(FILE *f)




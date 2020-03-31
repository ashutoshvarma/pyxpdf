from pyxpdf.includes.xpdf_types cimport GString, GBool, Guchar, GFileOffset
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.Stream cimport BaseStream, CryptAlgorithm

cdef extern from "XRef.h" nogil:
    ctypedef enum XRefEntryType:
        xrefEntryFree
        xrefEntryUncompressed
        xrefEntryCompressed

    ctypedef struct XRefEntry:
        GFileOffset offset
        int gen
        XRefEntryType type
        

    ctypedef struct XRefCacheEntry:
        int num
        int gen
        Object obj

    int xrefCacheSize 

    int objStrCacheSize 
    int objStrCacheTimeout 
        

cdef extern from "XRef.h" nogil:
    cdef cppclass XRef:
         # Constructor.  Read xref table from stream.
        XRef(BaseStream *strA, GBool repair)

        # Is xref table valid?
        GBool isOk() 

        # Get the error code (if isOk() returns false).
        int getErrorCode() 

        # Set the encryption parameters.
        void setEncryption(int permFlagsA, GBool ownerPasswordOkA,
                    Guchar *fileKeyA, int keyLengthA, int encVersionA,
                    CryptAlgorithm encAlgorithmA)

        # Is the file encrypted?
        GBool isEncrypted() 
        GBool getEncryption(int *permFlagsA, GBool *ownerPasswordOkA,
                    int *keyLengthA, int *encVersionA,
                    CryptAlgorithm *encAlgorithmA)

        # Check various permissions.
        GBool okToPrint(GBool ignoreOwnerPW = gFalse)
        GBool okToChange(GBool ignoreOwnerPW = gFalse)
        GBool okToCopy(GBool ignoreOwnerPW = gFalse)
        GBool okToAddNotes(GBool ignoreOwnerPW = gFalse)
        int getPermFlags() 

        # Get catalog object.
        Object *getCatalog(Object *obj) 

        # Fetch an indirect reference.
        Object *fetch(int num, int gen, Object *obj, int recursion = 0)

        # Return the document's Info dictionary (if any).
        Object *getDocInfo(Object *obj)
        Object *getDocInfoNF(Object *obj)

        # Return the number of objects in the xref table.
        int getNumObjects() 

        # Return the offset of the last xref table.
        GFileOffset getLastXRefPos() 

        # Return the offset of the 'startxref' at the end of the file.
        GFileOffset getLastStartxrefPos() 

        # Return the catalog object reference.
        int getRootNum() 
        int getRootGen() 

        # Get the xref table positions.
        int getNumXRefTables() 
        GFileOffset getXRefTablePos(int idx) 

        # Get end position for a stream in a damaged file.
        # Returns false if unknown or file is not damaged.
        GBool getStreamEnd(GFileOffset streamStart, GFileOffset *streamEnd)

        # Direct access.
        int getSize() 
        XRefEntry *getEntry(int i) 
        Object *getTrailerDict() 
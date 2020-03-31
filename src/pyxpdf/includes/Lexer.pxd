from pyxpdf.includes.xpdf_types cimport GBool, GFileOffset
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.Stream cimport Stream

cdef extern from "Lexer.h" nogil:
    cdef cppclass Lexer:
        # Construct a lexer for a single stream.  Deletes the stream when
        # lexer is deleted.
        Lexer(XRef *xref, Stream *str)

        # Construct a lexer for a stream or array of streams (assumes obj
        # is either a stream or array of streams).
        Lexer(XRef *xref, Object *obj)

        # Destructor.
        

        # Get the next object from the input stream.
        Object *getObj(Object *obj)

        # Skip to the beginning of the next line in the input stream.
        void skipToNextLine()

        # Skip to the end of the input stream.
        void skipToEOF()

        # Skip over one character.
        void skipChar() 

        # Get stream index (for arrays of streams).
        int getStreamIndex() 

        # Get stream.
        Stream *getStream()
            

        # Get current position in file.
        GFileOffset getPos()
            

        # Set position in file.
        void setPos(GFileOffset pos, int dir = 0)
            

        # Returns true if <c> is a whitespace character.
        @staticmethod
        GBool isSpace(int c)
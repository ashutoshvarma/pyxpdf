from pyxpdf.includes.xpdf_types import GBool
from pyxpdf.includes.UnicodeMap import UnicodeMap

cdef extern from "GlobalParams.h" nogil:
    cdef cppclass GlobalParams:
        # Initialize the global parameters by attempting to read a config
        # file.
        GlobalParams(const char *cfgFileName);

        void setTextEncoding(const char *encodingName)
        GBool setTextEOL(char *s)
        void setTextPageBreaks(GBool pageBreaks)
        void setErrQuiet(GBool errQuietA)

        UnicodeMap *getTextEncoding();
from pyxpdf.includes.xpdf_types cimport GFileOffset

cdef extern from "ErrorCodes.h" nogil:
    ctypedef enum:
        errNone
        errOpenFile
        errBadCatalog
        errDamaged
        errEncrypted
        errHighlightFile
        errBadPrinter
        errPrinting
        errPermission
        errBadPageNum
        errFileIO

cdef extern from "Error.h":
    ctypedef enum ErrorCategory: 
        errSyntaxWarning	#PDF syntax error which can be worked around;    output will probably be correct
        errSyntaxError	    # PDF syntax error which cannot be worked around;    output will probably be incorrect
        errConfig		    # error in Xpdf config info (xpdfrc file, etc.)
        errCommandLine	    # error in user-supplied parameters, action not allowed, etc. (only used by command-line tools)
        errIO		        #error in file I/O
        errNotAllowed       # action not allowed by PDF permission bits
        errUnimplemented	# unimplemented PDF feature - display will be incorrect
        errInternal		    # internal error - malfunction within the Xpdf code

    cdef const char *errorCategoryNames[]

    cdef void setErrorCallback(void (*cbk)(void *data, ErrorCategory category, int pos, char *msg), void *data)

    cdef void *getErrorCallbackData()

    cdef void error(ErrorCategory category, GFileOffset pos,
			const char *msg, ...)

# Make sure to keep it consistent with setErrorCallback
ctypedef void (*ErrorCallback)(void *data, ErrorCategory category, int pos, char *msg)
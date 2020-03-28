from pyxpdf.includes.xpdf_types cimport GBool
from pyxpdf.includes.OutputDev import OutputDev

ctypedef void (*TextOutputFunc)(void *stream, const char *text, int len)

cdef extern from "TextOutputDev.h" nogil:
    ctypedef enum TextOutputMode:
        textOutReadingOrder		# format into reading order
        textOutPhysLayout		# maintain original physical layout
        textOutSimpleLayout		# simple one-column physical layout
        textOutTableLayout		# similar to PhysLayout, but optimized for tables
        textOutLinePrinter	    # strict fixed-pitch/height layout
        textOutRawOrder		    # keep text in content stream order

cdef extern from "TextOutputDev.h" nogil:
    cdef cppclass TextOutputControl:
        TextOutputControl();

        TextOutputMode mode		    # formatting mode
        double fixedPitch		    # if this is non-zero, assume fixed-pitch   characters with this width (only relevant for PhysLayout, Table, and LinePrinter modes)
        double fixedLineSpacing	    # fixed line spacing (only relevant for LinePrinter mode)
        GBool html			        # enable extra processing for HTML
        GBool clipText		        # separate clipped text and add it back in after forming columns
        GBool discardDiagonalText	# discard all text that's not close to 0/90/180/270 degrees
        GBool discardInvisibleText	# discard all invisible characters
        GBool discardClippedText	# discard all clipped characters
        GBool insertBOM		        # insert a Unicode BOM at the start of the text output

        double marginLeft		    # characters outside the margins are discarded
        double marginRight		  
        double marginTop
        double marginBottom

cdef extern from "TextOutputDev.h" nogil:
    cdef cppclass TextOutputDev(OutputDev):
        GBool isOk()



from pyxpdf.includes.xpdf_types cimport GBool, GString, GList
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.Link cimport Link
from pyxpdf.includes.CharTypes cimport Unicode, CharCode
from pyxpdf.includes.GfxState cimport GfxState

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
        TextOutputControl()

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
    #------------------------------------------------------------------------
    # TextFontInfo
    #------------------------------------------------------------------------

    cdef cppclass TextFontInfo:

        TextFontInfo(GfxState *state)
        

        GBool matches(GfxState *state)

        # Get the font name (which may be NULL).
        GString *getFontName() 

        # Get font descriptor flags.
        GBool isFixedWidth() 
        GBool isSerif() 
        GBool isSymbolic() 
        GBool isItalic() 
        GBool isBold() 

        # Get the width of the 'm' character, if available.
        double getMWidth() 

        Ref getFontID() 


    #------------------------------------------------------------------------
    # TextWord
    #------------------------------------------------------------------------

    cdef cppclass TextWord:

        TextWord(GList *chars, int start, int lenA,
            int rotA, int dirA, GBool spaceAfterA)
        
        TextWord *copy() 

        # Get the TextFontInfo object associated with this word.
        TextFontInfo *getFontInfo() 

        int getLength() 
        Unicode getChar(int idx) 
        GString *getText()
        GString *getFontName() 
        void getColor(double *r, double *g, double *b)
            
        GBool isInvisible() 
        void getBBox(double *xMinA, double *yMinA, double *xMaxA, double *yMaxA)
            
        void getCharBBox(int charIdx, double *xMinA, double *yMinA,
                double *xMaxA, double *yMaxA)
        double getFontSize() 
        int getRotation() 
        int getCharPos() 
        int getCharLen() 
        int getDirection() 
        GBool getSpaceAfter() 
        double getBaseline()
        GBool isUnderlined() 
        GString *getLinkURI()


    #------------------------------------------------------------------------
    # TextLine
    #------------------------------------------------------------------------

    cdef cppclass TextLine:

        TextLine(GList *wordsA, double xMinA, double yMinA,
            double xMaxA, double yMaxA, double fontSizeA)
        

        double getXMin() 
        double getYMin() 
        double getXMax() 
        double getYMax() 
        double getBaseline()
        int getRotation() 
        GList *getWords() 
        int getLength() 
        double getEdge(int idx) 


    #------------------------------------------------------------------------
    # TextParagraph
    #------------------------------------------------------------------------

    cdef cppclass TextParagraph:

        TextParagraph(GList *linesA, GBool dropCapA)
        

        # Get the list of TextLine objects.
        GList *getLines() 

        GBool hasDropCap() 

        double getXMin() 
        double getYMin() 
        double getXMax() 
        double getYMax() 


    #------------------------------------------------------------------------
    # TextColumn
    #------------------------------------------------------------------------

    cdef cppclass TextColumn:

        TextColumn(GList *paragraphsA, double xMinA, double yMinA,
                double xMaxA, double yMaxA)
        

        # Get the list of TextParagraph objects.
        GList *getParagraphs() 

        double getXMin() 
        double getYMin() 
        double getXMax() 
        double getYMax() 

        int getRotation()


    #------------------------------------------------------------------------
    # TextWordList
    #------------------------------------------------------------------------

    cdef cppclass TextWordList:

        TextWordList(GList *wordsA, GBool primaryLRA)

        

        # Return the number of words on the list.
        int getLength()

        # Return the <idx>th word from the list.
        TextWord *get(int idx)

        # Returns true if primary direction is left-to-right, or false if
        # right-to-left.
        GBool getPrimaryLR() 


    #------------------------------------------------------------------------
    # TextPosition
    #------------------------------------------------------------------------

    # Position within a TextColumn tree.  The position is in column
    # [colIdx], paragraph [parIdx], line [lineIdx], before character
    # [charIdx].
    cdef cppclass TextPosition:

        TextPosition()
        TextPosition(int colIdxA, int parIdxA, int lineIdxA, int charIdxA)
        
        int operator==(TextPosition pos)
        int operator!=(TextPosition pos)
        int operator<(TextPosition pos)
        int operator>(TextPosition pos)

        int colIdx, parIdx, lineIdx, charIdx


    #------------------------------------------------------------------------
    # TextPage
    #------------------------------------------------------------------------

    cdef cppclass TextPage:

        TextPage(TextOutputControl *controlA)
        

        # Write contents of page to a stream.
        void write(void *outputStream, TextOutputFunc outputFunc)

        # Find a string.  If <startAtTop> is true, starts looking at the
        # top of the page else if <startAtLast> is true, starts looking
        # immediately after the last find result else starts looking at
        # <xMin>,<yMin>.  If <stopAtBottom> is true, stops looking at the
        # bottom of the page else if <stopAtLast> is true, stops looking
        # just before the last find result else stops looking at
        # <xMax>,<yMax>.
        GBool findText(Unicode *s, int len,
                GBool startAtTop, GBool stopAtBottom,
                GBool startAtLast, GBool stopAtLast,
                GBool caseSensitive, GBool backward,
                GBool wholeWord,
                double *xMin, double *yMin,
                double *xMax, double *yMax)

        # Get the text which is inside the specified rectangle.  Multi-line
        # text always includes end-of-line markers at the end of each line.
        # If <forceEOL> is true, an end-of-line marker will be appended to
        # single-line text as well.
        GString *getText(double xMin, double yMin,
                double xMax, double yMax,
                GBool forceEOL = gFalse)

        # Find a string by character position and length.  If found, sets
        # the text bounding rectangle and returns true otherwise returns
        # false.
        GBool findCharRange(int pos, int length,
                    double *xMin, double *yMin,
                    double *xMax, double *yMax)

        # Returns true if x,y falls inside a column.
        GBool checkPointInside(double x, double y)

        # Find a point inside a column.  Returns false if x,y fall outside
        # all columns.
        GBool findPointInside(double x, double y, TextPosition *pos)

        # Find a point in the nearest column.  Returns false only if there
        # are no columns.
        GBool findPointNear(double x, double y, TextPosition *pos)

        # Get the upper point of a TextPosition.
        void convertPosToPointUpper(TextPosition *pos, double *x, double *y)

        # Get the lower point of a TextPosition.
        void convertPosToPointLower(TextPosition *pos, double *x, double *y)

        # Get the upper left corner of the line containing a TextPosition.
        void convertPosToPointLeftEdge(TextPosition *pos, double *x, double *y)

        # Get the lower right corner of the line containing a TextPosition.
        void convertPosToPointRightEdge(TextPosition *pos, double *x, double *y)

        # Get the upper right corner of a column.
        void getColumnUpperRight(int colIdx, double *x, double *y)

        # Get the lower left corner of a column.
        void getColumnLowerLeft(int colIdx, double *x, double *y)

        # Create and return a list of TextColumn objects.
        GList *makeColumns()

        # Get the list of all TextFontInfo objects used on this page.
        GList *getFonts() 

        # Build a flat word list, in the specified ordering.
        TextWordList *makeWordList()

        # Build a word list containing only words inside the specified
        # rectangle.
        TextWordList *makeWordListForRect(double xMin, double yMin,
                            double xMax, double yMax)

        # Returns true if the primary character direction is left-to-right,
        # false if it is right-to-left.
        GBool primaryDirectionIsLR()

        # Returns true if any of the fonts used on this page are likely to
        # be problematic when converting text to Unicode.
        GBool problematicForUnicode() 


    #------------------------------------------------------------------------
    # TextOutputDev
    #------------------------------------------------------------------------

    cdef cppclass TextOutputDev(OutputDev):

        # Open a text output file.  If <fileName> is NULL, no file is
        # written (this is useful, e.g., for searching text).  If
        # <physLayoutA> is true, the original physical layout of the text
        # is maintained.  If <rawOrder> is true, the text is kept in
        # content stream order.
        TextOutputDev(char *fileName, TextOutputControl *controlA,
                GBool append)

        # Create a TextOutputDev which will write to a generic stream.  If
        # <physLayoutA> is true, the original physical layout of the text
        # is maintained.  If <rawOrder> is true, the text is kept in
        # content stream order.
        TextOutputDev(TextOutputFunc func, void *stream,
                TextOutputControl *controlA)

        # Destructor.
        

        # Check if file was successfully created.
        GBool isOk() 

        #---- get info about output device

        # Does this device use upside-down coordinates?
        # (Upside-down means (0,0) is the top left corner of the page.)
        GBool upsideDown() 

        # Does this device use drawChar() or drawString()?
        GBool useDrawChar() 

        # Does this device use beginType3Char/endType3Char?  Otherwise,
        # text in Type 3 fonts will be drawn with drawChar/drawString.
        GBool interpretType3Chars() 

        # Does this device need non-text content?
        GBool needNonText() 

        # Does this device require incCharCount to be called for text on
        # non-shown layers?
        GBool needCharCount() 

        #----- initialization and control

        # Start a page.
        void startPage(int pageNum, GfxState *state)

        # End a page.
        void endPage()

        #----- save/restore graphics state
        void restoreState(GfxState *state)

        #----- update text state
        void updateFont(GfxState *state)

        #----- text drawing
        void beginString(GfxState *state, GString *s)
        void endString(GfxState *state)
        void drawChar(GfxState *state, double x, double y,
                    double dx, double dy,
                    double originX, double originY,
                    CharCode c, int nBytes, Unicode *u, int uLen)
        void incCharCount(int nChars)
        void beginActualText(GfxState *state, Unicode *u, int uLen)
        void endActualText(GfxState *state)

        #----- path painting
        void stroke(GfxState *state)
        void fill(GfxState *state)
        void eoFill(GfxState *state)

        #----- link borders
        void processLink(Link *link)

        #----- special access

        # Find a string.  If <startAtTop> is true, starts looking at the
        # top of the page else if <startAtLast> is true, starts looking
        # immediately after the last find result else starts looking at
        # <xMin>,<yMin>.  If <stopAtBottom> is true, stops looking at the
        # bottom of the page else if <stopAtLast> is true, stops looking
        # just before the last find result else stops looking at
        # <xMax>,<yMax>.
        GBool findText(Unicode *s, int len,
                GBool startAtTop, GBool stopAtBottom,
                GBool startAtLast, GBool stopAtLast,
                GBool caseSensitive, GBool backward,
                GBool wholeWord,
                double *xMin, double *yMin,
                double *xMax, double *yMax)

        # Get the text which is inside the specified rectangle.
        GString *getText(double xMin, double yMin,
                double xMax, double yMax)

        # Find a string by character position and length.  If found, sets
        # the text bounding rectangle and returns true otherwise returns
        # false.
        GBool findCharRange(int pos, int length,
                    double *xMin, double *yMin,
                    double *xMax, double *yMax)

        # Build a flat word list, in content stream order (if
        # this->rawOrder is true), physical layout order (if
        # this->physLayout is true and this->rawOrder is false), or reading
        # order (if both flags are false).
        TextWordList *makeWordList()

        # Build a word list containing only words inside the specified
        # rectangle.
        TextWordList *makeWordListForRect(double xMin, double yMin,
                            double xMax, double yMax)

        # Returns the TextPage object for the last rasterized page,
        # transferring ownership to the caller.
        TextPage *takeText()

        # Turn extra processing for HTML conversion on or off.
        void enableHTMLExtras(GBool html) 





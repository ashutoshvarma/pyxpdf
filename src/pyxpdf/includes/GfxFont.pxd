from pyxpdf.includes.xpdf_types cimport GBool, GString, Guchar
from pyxpdf.includes.Object cimport Object, Ref
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.CharTypes cimport Unicode, CID, CharCode
from pyxpdf.includes.CharCodeToUnicode cimport CharCodeToUnicode
from pyxpdf.includes.FoFi cimport FoFiTrueType, FoFiType1C


cdef extern from "GfxFont.h" nogil:
    ctypedef enum GfxFontType:
        #----- Gfx8BitFont
        fontUnknownType
        fontType1
        fontType1C
        fontType1COT
        fontType3
        fontTrueType
        fontTrueTypeOT
        #----- GfxCIDFont
        fontCIDType0
        fontCIDType0C
        fontCIDType0COT
        fontCIDType2
        fontCIDType2OT


    #------------------------------------------------------------------------
    # GfxFontCIDWidths
    #------------------------------------------------------------------------

    ctypedef struct GfxFontCIDWidthExcep:
        CID first			# this record applies to
        CID last			#   CIDs <first>..<last>
        double width			# char width

    ctypedef struct GfxFontCIDWidthExcepV:
        CID first			# this record applies to
        CID last			#   CIDs <first>..<last>
        double height		# char height
        double vx, vy		# origin position

    ctypedef struct GfxFontCIDWidths:
        double defWidth		            # default char width
        double defHeight		        # default char height
        double defVY			        # default origin position
        GfxFontCIDWidthExcep *exceps	# exceptions
        int nExceps		            	# number of valid entries in exceps
        GfxFontCIDWidthExcepV *	excepsV # exceptions for vertical font
        int nExcepsV			        # number of valid entries in excepsV


    #------------------------------------------------------------------------
    # GfxFontLoc
    #------------------------------------------------------------------------

    ctypedef enum GfxFontLocType:
        gfxFontLocEmbedded  	# font embedded in PDF file
        gfxFontLocExternal		# external font file
        gfxFontLocResident		# font resident in PS printer
    

    cdef cppclass GfxFontLoc:
        GfxFontLoc()

        GfxFontLocType locType
        GfxFontType fontType
        Ref embFontID		# embedded stream obj ID
                            #   (if locType == gfxFontLocEmbedded)
        GString *path		# font file path
                            #   (if locType == gfxFontLocExternal)
                            # PS font name
                            #   (if locType == gfxFontLocResident)
        int fontNum		# for TrueType collections and Mac dfonts
                            #   (if locType == gfxFontLocExternal)
        double oblique		# sheer factor to oblique this font
                            #   (used when substituting a plain
                            #   font for an oblique font)
        GString *encoding  # PS font encoding, only for 16-bit fonts
                            #   (if locType == gfxFontLocResident)
        int wMode			# writing mode, only for 16-bit fonts
                            #   (if locType == gfxFontLocResident)
        int substIdx		# substitute font index
                            #   (if locType == gfxFontLocExternal,
                            #   and a Base-14 substitution was made)


    #------------------------------------------------------------------------
    # GfxFont
    #------------------------------------------------------------------------

    cdef int fontFixedWidth 
    cdef int fontSerif      
    cdef int fontSymbolic   
    cdef int fontItalic     
    cdef int fontBold     

    cdef cppclass GfxFont:

        # Build a GfxFont object.
        GfxFont *makeFont(XRef *xref, const char *tagA,
                    Ref idA, Dict *fontDict)

        GfxFont(const char *tagA, Ref idA, GString *nameA,
            GfxFontType typeA, Ref embFontIDA)

        

        GBool isOk() 

        # Get font tag.
        GString *getTag() 

        # Get font dictionary ID.
        Ref *getID() 

        # Does this font match the tag?
        GBool matches(char *tagA) 

        # Get the original font name (ignornig any munging that might have
        # been done to map to a canonical Base-14 font name).
        GString *getName() 

        # Get font type.
        GfxFontType getType() 
        GBool isCIDFont() 

        # Get embedded font ID, i.e., a ref for the font file stream.
        # Returns false if there is no embedded font.
        GBool getEmbeddedFontID(Ref *embID)
            

        # Get the PostScript font name for the embedded font.  Returns
        # NULL if there is no embedded font.
        GString *getEmbeddedFontName() 

        # Get font descriptor flags.
        int getFlags() 
        GBool isFixedWidth() 
        GBool isSerif() 
        GBool isSymbolic() 
        GBool isItalic() 
        GBool isBold() 

        # Return the font matrix.
        double *getFontMatrix() 

        # Return the font bounding box.
        double *getFontBBox() 

        # Return the ascent and descent values.
        double getAscent() 
        double getDescent() 

        # Return the writing mode (0=horizontal, 1=vertical).
        int getWMode() 

        # Locate the font file for this font.  If <ps> is true, includes PS
        # printer-resident fonts.  Returns NULL on failure.
        GfxFontLoc *locateFont(XRef *xref, GBool ps)

        # Locate a Base-14 font file for a specified font name.
        GfxFontLoc *locateBase14Font(GString *base14Name)

        # Read an embedded font file into a buffer.
        char *readEmbFontFile(XRef *xref, int *len)

        # Get the next char from a string <s> of <len> bytes, returning the
        # char <code>, its Unicode mapping <u>, its displacement vector
        # (<dx>, <dy>), and its origin offset vector (<ox>, <oy>).  <uSize>
        # is the number of entries available in <u>, and <uLen> is set to
        # the number actually used.  Returns the number of bytes used by
        # the char code.
        int getNextChar(char *s, int len, CharCode *code,
                    Unicode *u, int uSize, int *uLen,
                    double *dx, double *dy, double *ox, double *oy)

        # Returns true if this font is likely to be problematic when
        # converting text to Unicode.
        GBool problematicForUnicode()


    #------------------------------------------------------------------------
    # Gfx8BitFont
    #------------------------------------------------------------------------

    cdef cppclass Gfx8BitFont(GfxFont):

        Gfx8BitFont(XRef *xref, const char *tagA, Ref idA, GString *nameA,
                GfxFontType typeA, Ref embFontIDA, Dict *fontDict)

        

        int getNextChar(char *s, int len, CharCode *code,
                    Unicode *u, int uSize, int *uLen,
                    double *dx, double *dy, double *ox, double *oy)

        # Return the encoding.
        char **getEncoding() 

        # Return the Unicode map.
        CharCodeToUnicode *getToUnicode()

        # Return the character name associated with <code>.
        char *getCharName(int code) 

        # Returns true if the PDF font specified an encoding.
        GBool getHasEncoding() 

        # Returns true if the PDF font specified MacRomanEncoding.
        GBool getUsesMacRomanEnc() 

        # Get width of a character.
        double getWidth(Guchar c) 

        # Return a char code-to-GID mapping for the provided font file.
        # (This is only useful for TrueType fonts.)
        int *getCodeToGIDMap(FoFiTrueType *ff)

        # Return a char code-to-GID mapping for the provided font file.
        # (This is only useful for Type1C fonts.)
        int *getCodeToGIDMap(FoFiType1C *ff)

        # Return the Type 3 CharProc dictionary, or NULL if none.
        Dict *getCharProcs()

        # Return the Type 3 CharProc for the character associated with <code>.
        Object *getCharProc(int code, Object *proc)
        Object *getCharProcNF(int code, Object *proc)

        # Return the Type 3 Resources dictionary, or NULL if none.
        Dict *getResources()

        GBool problematicForUnicode()


    #------------------------------------------------------------------------
    # GfxCIDFont
    #------------------------------------------------------------------------

    cdef cppclass GfxCIDFont(GfxFont):

        GfxCIDFont(XRef *xref, const char *tagA, Ref idA, GString *nameA,
                GfxFontType typeA, Ref embFontIDA, Dict *fontDict)

        

        GBool isCIDFont() 

        int getNextChar(char *s, int len, CharCode *code,
                    Unicode *u, int uSize, int *uLen,
                    double *dx, double *dy, double *ox, double *oy)

        # Return the writing mode (0=horizontal, 1=vertical).
        int getWMode()

        # Return the Unicode map.
        CharCodeToUnicode *getToUnicode()

        # Get the collection name (<registry>-<ordering>).
        GString *getCollection()

        # Return the horizontal width for <cid>.
        double getWidth(CID cid)

        # Return the CID-to-GID mapping table.  These should only be called
        # if type is fontCIDType2.
        int *getCIDToGID() 
        int getCIDToGIDLen() 

        # Returns true if this font uses the Identity-H encoding (cmap),
        # and the Adobe-Identity character collection, and does not have a
        # CIDToGIDMap.  When this is true for a CID TrueType font, Adobe
        # appears to treat char codes as raw GIDs.
        GBool usesIdentityEncoding() 

        GBool problematicForUnicode()


    #------------------------------------------------------------------------
    # GfxFontDict
    #------------------------------------------------------------------------

    cdef cppclass GfxFontDict:
        # Build the font dictionary, given the PDF font dictionary.
        GfxFontDict(XRef *xref, Ref *fontDictRef, Dict *fontDict)

        # Get the specified font.
        GfxFont *lookup(char *tag)
        GfxFont *lookupByRef(Ref ref)

        # Iterative access.
        int getNumFonts()
        GfxFont *getFont(int i)
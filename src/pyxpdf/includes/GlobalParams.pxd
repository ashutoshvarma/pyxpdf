from libc.stdio cimport FILE

from pyxpdf.includes.xpdf_types cimport GBool, GString, GList
from pyxpdf.includes.UnicodeMap cimport UnicodeMap
from pyxpdf.includes.CharTypes cimport CharCode, Unicode
from pyxpdf.includes.UnicodeRemapping cimport UnicodeRemapping
from pyxpdf.includes.CharCodeToUnicode cimport CharCodeToUnicode
from pyxpdf.includes.CMap cimport CMap

cdef extern from "GlobalParams.h" nogil:

    ctypedef enum SysFontType:
        sysFontPFA
        sysFontPFB
        sysFontTTF
        sysFontTTC
        sysFontOTF



    cdef cppclass PSFontParam16:
        GString *name		    # PDF font name for psResidentFont16
                                # char collection name for psResidentFontCC
        int wMode			    # writing mode (0=horiz, 1=vert)
        GString *psFontName		# PostScript font name
        GString *encoding		# encoding

        PSFontParam16(GString *nameA, int wModeA,
                GString *psFontNameA, GString *encodingA)



    ctypedef enum PSLevel:
        psLevel1
        psLevel1Sep
        psLevel2
        psLevel2Gray
        psLevel2Sep
        psLevel3
        psLevel3Gray
        psLevel3Sep


    ctypedef enum EndOfLineKind:
        eolUnix			# LF
        eolDOS			# CR+LF
        eolMac			# CR


    cdef cppclass GlobalParams:
        # Initialize the global parameters by attempting to read a config
        # file.
        GlobalParams(const char *cfgFileName)

        void setBaseDir(const char *dir)
        void setupBaseFonts(const char *dir)

        void parseLine(char *buf, GString *fileName, int line)

        #----- accessors

        CharCode getMacRomanCharCode(char *charName)

        GString *getBaseDir()
        Unicode mapNameToUnicode(const char *charName)
        UnicodeMap *getResidentUnicodeMap(GString *encodingName)
        FILE *getUnicodeMapFile(GString *encodingName)
        FILE *findCMapFile(GString *collection, GString *cMapName)
        FILE *findToUnicodeFile(GString *name)
        UnicodeRemapping *getUnicodeRemapping()
        GString *findFontFile(GString *fontName)
        GString *findBase14FontFile(GString *fontName, int *fontNum,
                        double *oblique)
        GString *findSystemFontFile(GString *fontName, SysFontType *type,
                        int *fontNum)
        GString *findCCFontFile(GString *collection)
        int getPSPaperWidth()
        int getPSPaperHeight()
        void getPSImageableArea(int *llx, int *lly, int *urx, int *ury)
        GBool getPSDuplex()
        GBool getPSCrop()
        GBool getPSUseCropBoxAsPage()
        GBool getPSExpandSmaller()
        GBool getPSShrinkLarger()
        GBool getPSCenter()
        PSLevel getPSLevel()
        GString *getPSResidentFont(GString *fontName)
        GList *getPSResidentFonts()
        PSFontParam16 *getPSResidentFont16(GString *fontName, int wMode)
        PSFontParam16 *getPSResidentFontCC(GString *collection, int wMode)
        GBool getPSEmbedType1()
        GBool getPSEmbedTrueType()
        GBool getPSEmbedCIDPostScript()
        GBool getPSEmbedCIDTrueType()
        GBool getPSFontPassthrough()
        GBool getPSPreload()
        GBool getPSOPI()
        GBool getPSASCIIHex()
        GBool getPSLZW()
        GBool getPSUncompressPreloadedImages()
        double getPSMinLineWidth()
        double getPSRasterResolution()
        GBool getPSRasterMono()
        int getPSRasterSliceSize()
        GBool getPSAlwaysRasterize()
        GBool getPSNeverRasterize()
        GString *getTextEncodingName()
        EndOfLineKind getTextEOL()
        GBool getTextPageBreaks()
        GBool getTextKeepTinyChars()
        int getMaxTileWidth()
        int getMaxTileHeight()
        int getTileCacheSize()
        int getWorkerThreads()
        GBool getEnableFreeType()
        GBool getDisableFreeTypeHinting()
        GBool getAntialias()
        GBool getVectorAntialias()
        double getMinLineWidth()
        GBool getEnablePathSimplification()
        GBool getDrawAnnotations()
        GBool getDrawFormFields()
        GBool getOverprintPreview()
        GString *getPaperColor()
        GString *getMatteColor()
        GString *getFullScreenMatteColor()
        GBool getReverseVideoInvertImages()
        GString *getLaunchCommand()
        GString *getMovieCommand()
        GBool getMapNumericCharNames()
        GBool getMapUnknownCharNames()
        GBool getMapExtTrueTypeFontsViaUnicode()
        GBool isDroppedFont(const char *fontName)
        GBool getEnableXFA()
        GString *getTabStateFile()
        GBool getPrintCommands()
        GBool getErrQuiet()
        GString *getDebugLogFile()
        void debugLogPrintf(char *fmt, ...)

        CharCodeToUnicode *getCIDToUnicode(GString *collection)
        CharCodeToUnicode *getUnicodeToUnicode(GString *fontName)
        UnicodeMap *getUnicodeMap(GString *encodingName)
        CMap *getCMap(GString *collection, GString *cMapName)
        UnicodeMap *getTextEncoding()

        #----- functions to set parameters

        void addUnicodeRemapping(Unicode _in, Unicode *out, int len)
        void addFontFile(GString *fontName, GString *path)
        GBool setPSPaperSize(char *size)
        void setPSPaperWidth(int width)
        void setPSPaperHeight(int height)
        void setPSImageableArea(int llx, int lly, int urx, int ury)
        void setPSDuplex(GBool duplex)
        void setPSCrop(GBool crop)
        void setPSUseCropBoxAsPage(GBool crop)
        void setPSExpandSmaller(GBool expand)
        void setPSShrinkLarger(GBool shrink)
        void setPSCenter(GBool center)
        void setPSLevel(PSLevel level)
        void setPSEmbedType1(GBool embed)
        void setPSEmbedTrueType(GBool embed)
        void setPSEmbedCIDPostScript(GBool embed)
        void setPSEmbedCIDTrueType(GBool embed)
        void setPSFontPassthrough(GBool passthrough)
        void setPSPreload(GBool preload)
        void setPSOPI(GBool opi)
        void setPSASCIIHex(GBool hex)
        void setTextEncoding(const char *encodingName)
        GBool setTextEOL(char *s)
        void setTextPageBreaks(GBool pageBreaks)
        void setTextKeepTinyChars(GBool keep)
        void setInitialZoom(char *s)
        GBool setEnableFreeType(char *s)
        GBool setAntialias(char *s)
        GBool setVectorAntialias(char *s)
        void setScreenSize(int size)
        void setScreenDotRadius(int r)
        void setScreenGamma(double gamma)
        void setScreenBlackThreshold(double thresh)
        void setScreenWhiteThreshold(double thresh)
        void setDrawFormFields(GBool draw)
        void setOverprintPreview(GBool preview)
        void setMapNumericCharNames(GBool map)
        void setMapUnknownCharNames(GBool map)
        void setMapExtTrueTypeFontsViaUnicode(GBool map)
        void setEnableXFA(GBool enable)
        void setTabStateFile(char *tabStateFileA)
        void setPrintCommands(GBool printCommandsA)
        void setErrQuiet(GBool errQuietA)

        const char *defaultTextEncoding

    cdef GlobalParams *globalParams

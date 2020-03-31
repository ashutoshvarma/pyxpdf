from libc.stdio cimport FILE

from pyxpdf.includes.xpdf_types cimport GString, GBool, Guint, Guchar, Gushort, GFileOffset
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.XRef cimport XRef
from pyxpdf.includes.Dict cimport Dict



cdef extern from "Stream.h" nogil:
    ctypedef enum StreamKind:
        strFile
        strASCIIHex
        strASCII85
        strLZW
        strRunLength
        strCCITTFax
        strDCT
        strFlate
        strJBIG2
        strJPX
        strWeird			# internal-use stream types
        

    ctypedef enum StreamColorSpaceMode: 
        streamCSNone
        streamCSDeviceGray
        streamCSDeviceRGB
        streamCSDeviceCMYK
        

    ctypedef enum CryptAlgorithm: 
        cryptRC4
        cryptAES
        cryptAES256
        

cdef extern from "Stream.h" nogil:
    cdef cppclass Stream:
        # Constructor.
        Stream()

        # Destructor.
        

        Stream *copy()

        # Get kind of stream.
        StreamKind getKind()

        GBool isEmbedStream() 

        # Reset stream to beginning.
        void reset()

        # Close down the stream.
        void close()

        # Get next char from stream.
        int getChar()

        # Peek at next char in stream.
        int lookChar()

        # Get next char from stream without using the predictor.
        # This is only used by StreamPredictor.
        int getRawChar()

        # Get exactly <size> bytes from stream.  Returns the number of
        # bytes read -- the returned count will be less than <size> at EOF.
        int getBlock(char *blk, int size)

        # Get next line from stream.
        char *getLine(char *buf, int size)

        # Discard the next <n> bytes from stream.  Returns the number of
        # bytes discarded, which will be less than <n> only if EOF is
        # reached.
        Guint discardChars(Guint n)

        # Get current position in file.
        GFileOffset getPos()

        # Go to a position in the stream.  If <dir> is negative, the
        # position is from the end of the file otherwise the position is
        # from the start of the file.
        void setPos(GFileOffset pos, int dir = 0)

        # Get PostScript command for the filter(s).
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)

        # Does this stream type potentially contain non-printable chars?
        GBool isBinary(GBool last = gTrue)

        # Get the BaseStream of this stream.
        BaseStream *getBaseStream()

        # Get the stream after the last decoder (this may be a BaseStream
        # or a DecryptStream).
        Stream *getUndecodedStream()

        # Get the dictionary associated with this stream.
        Dict *getDict()

        # Is this an encoding filter?
        GBool isEncoder() 

        # Get image parameters which are defined by the stream contents.
        void getImageParams(int *bitsPerComponent,
                        StreamColorSpaceMode *csMode) 

        # Return the next stream in the "stack".
        Stream *getNextStream() 

        # Add filters to this stream according to the parameters in <dict>.
        # Returns the new stream.
        Stream *addFilters(Object *dict, int recursion = 0)
    

cdef extern from "Stream.h" nogil:
    cdef cppclass BaseStream(Stream):
        BaseStream(Object *dictA)
        Stream *makeSubStream(GFileOffset start, GBool limited,
                        GFileOffset length, Object *dict)
        void setPos(GFileOffset pos, int dir = 0)
        GBool isBinary(GBool last = gTrue) 
        BaseStream *getBaseStream() 
        Stream *getUndecodedStream() 
        Dict *getDict() 
        GString *getFileName() 

        # Get/set position of first byte of stream within the file.
        GFileOffset getStart()
        void moveStart(int delta)


cdef extern from "Stream.h" nogil:
    cdef cppclass FilterStream(Stream):
        FilterStream(Stream *strA)
        void close()
        GFileOffset getPos() 
        void setPos(GFileOffset pos, int dir = 0)
        BaseStream *getBaseStream() 
        Stream *getUndecodedStream() 
        Dict *getDict() 
        Stream *getNextStream() 


cdef extern from "Stream.h" nogil:
    cdef cppclass ImageStream:
        # Create an image stream object for an image with the specified
        # parameters.  Note that these are the actual image parameters,
        # which may be different from the predictor parameters.
        ImageStream(Stream *strA, int widthA, int nCompsA, int nBitsA)

        

        # Reset the stream.
        void reset()

        # Close down the stream.
        void close()

        # Gets the next pixel from the stream.  <pix> should be able to hold
        # at least nComps elements.  Returns false at end of file.
        GBool getPixel(Guchar *pix)

        # Returns a pointer to the next line of pixels.  Returns NULL at
        # end of file.
        Guchar *getLine()

        # Skip an entire line from the image.
        void skipLine()


cdef extern from "Stream.h" nogil:
    cdef cppclass StreamPredictor:
        # Create a predictor object.  Note that the parameters are for the
        # predictor, and may not match the actual image parameters.
        StreamPredictor(Stream *strA, int predictorA,
                int widthA, int nCompsA, int nBitsA)

        

        GBool isOk() 

        void reset()

        int lookChar()
        int getChar()
        int getBlock(char *blk, int size)

        int getPredictor() 
        int getWidth() 
        int getNComps() 
        int getNBits() 


cdef extern from "Stream.h" nogil:
    int fileStreamBufSize

    cdef cppclass FileStream(BaseStream):
        FileStream(FILE *fA, GFileOffset startA, GBool limitedA,
	                GFileOffset lengthA, Object *dictA)
        
        Stream *copy()
        Stream *makeSubStream(GFileOffset startA, GBool limitedA,
                        GFileOffset lengthA, Object *dictA)
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
            
        int getBlock(char *blk, int size)
        GFileOffset getPos() 
        void setPos(GFileOffset pos, int dir = 0)
        GFileOffset getStart() 
        void moveStart(int delta)


cdef extern from "Stream.h" nogil:
    cdef cppclass MemStream(BaseStream):
        MemStream(char *bufA, Guint startA, Guint lengthA, Object *dictA)
        
        Stream *copy()
        Stream *makeSubStream(GFileOffset start, GBool limited,
                        GFileOffset lengthA, Object *dictA)
        StreamKind getKind() 
        void reset()
        void close()
        int getChar()
            
        int lookChar()
            
        int getBlock(char *blk, int size)
        GFileOffset getPos() 
        void setPos(GFileOffset pos, int dir = 0)
        GFileOffset getStart() 
        void moveStart(int delta)


cdef extern from "Stream.h" nogil:
    #------------------------------------------------------------------------
    # EmbedStream
    #
    # This is a special stream type used for embedded streams (inline
    # images).  It reads directly from the base stream -- after the
    # EmbedStream is deleted, reads from the base stream will proceed where
    # the BaseStream left off.  Note that this is very different behavior
    # that creating a new FileStream (using makeSubStream).
    #------------------------------------------------------------------------
    cdef cppclass EmbedStream(BaseStream):
        EmbedStream(Stream *strA, Object *dictA, GBool limitedA, GFileOffset lengthA)
        Stream *copy()
        Stream *makeSubStream(GFileOffset start, GBool limitedA,
                        GFileOffset lengthA, Object *dictA)
        StreamKind getKind() 
        GBool isEmbedStream() 
        void reset() 
        int getChar()
        int lookChar()
        int getBlock(char *blk, int size)
        GFileOffset getPos() 
        void setPos(GFileOffset pos, int dir = 0)
        GFileOffset getStart()
        void moveStart(int delta)


cdef extern from "Stream.h" nogil:
    cdef cppclass ASCIIHexStream(FilterStream):
        ASCIIHexStream(Stream *strA)
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)


cdef extern from "Stream.h" nogil:
    cdef cppclass ASCII85Stream(FilterStream):
        ASCII85Stream(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)


    cdef cppclass LZWStream(FilterStream):
        LZWStream(Stream *strA, int predictor, int columns, int colors, int bits, int earlyA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        int getRawChar()
        int getBlock(char *blk, int size)
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)

    
    #------------------------------------------------------------------------
    # RunLengthStream
    #------------------------------------------------------------------------
    cdef cppclass RunLengthStream(FilterStream): 
        RunLengthStream(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
            
        int getBlock(char *blk, int size)
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)

    

    #------------------------------------------------------------------------
    # CCITTFaxStream
    #------------------------------------------------------------------------

    ctypedef struct CCITTCodeTable:
        pass

    cdef cppclass CCITTFaxStream(FilterStream): 
        CCITTFaxStream(Stream *strA, int encodingA, GBool endOfLineA,
                GBool byteAlignA, int columnsA, int rowsA,
                GBool endOfBlockA, GBool blackA)
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        int getBlock(char *blk, int size)
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)


        #------------------------------------------------------------------------
        # DCTStream
        #------------------------------------------------------------------------

        # DCT component info
    ctypedef struct DCTCompInfo: 
        int id			# component ID
        int hSample, vSample		# horiz/vert sampling resolutions
        int quantTable		# quantization table number
        int prevDC			# DC coefficient accumulator
        

    ctypedef struct DCTScanInfo:
        GBool comp[4]		# comp[i] is set if component i is
                        #   included in this scan
        int numComps			# number of components in the scan
        int dcHuffTable[4]		# DC Huffman table numbers
        int acHuffTable[4]		# AC Huffman table numbers
        int firstCoeff, lastCoeff	# first and last DCT coefficient
        int ah, al			# successive approximation parameters
        

        # DCT Huffman decoding table
    ctypedef struct DCTHuffTable: 
        Guchar firstSym[17]		# first symbol for this bit length
        Gushort firstCode[17]	# first code for this bit length
        Gushort numCodes[17]		# number of codes of this bit length
        Guchar sym[256]		# symbols
        


    cdef cppclass DCTStream(FilterStream): 
        DCTStream(Stream *strA, int colorXformA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        void close()
        int getChar()
        int lookChar()
        int getBlock(char *blk, int size)
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)
        Stream *getRawStream() 

       

    #------------------------------------------------------------------------
    # FlateStream
    #------------------------------------------------------------------------

    int flateWindow              # buffer size
    int flateMask          
    int flateMaxHuffman           # max Huffman code length
    int flateMaxCodeLenCodes        # max # code length codes
    int flateMaxLitCodes           # max # literal codes
    int flateMaxDistCodes           # max # distance codes

    # Huffman code table entry
    ctypedef struct FlateCode:
        Gushort len			# code length, in bits
        Gushort val			# value represented by this code
        

    ctypedef struct FlateHuffmanTab: 
        FlateCode *codes
        int maxLen
        

        # Decoding info for length and distance code words
    ctypedef struct FlateDecode: 
        int bits			# # extra bits
        int first			# first length/distance
        

    cdef cppclass FlateStream(FilterStream): 
        FlateStream(Stream *strA, int predictor, int columns,
                int colors, int bits)
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        int getRawChar()
        int getBlock(char *blk, int size)
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
        GBool isBinary(GBool last = gTrue)

        

    #------------------------------------------------------------------------
    # EOFStream
    #------------------------------------------------------------------------

    cdef cppclass EOFStream(FilterStream): 
        EOFStream(Stream *strA)
        Stream *copy()
        StreamKind getKind() 
        void reset() 
        int getChar() 
        int lookChar() 
        int getBlock(char *blk, int size) 
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue) 
        



    #------------------------------------------------------------------------
    # BufStream
    #------------------------------------------------------------------------

    cdef cppclass BufStream(FilterStream):

        BufStream(Stream *strA, int bufSizeA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue)

        int lookChar(int idx)

        

    #------------------------------------------------------------------------
    # FixedLengthEncoder
    #------------------------------------------------------------------------

    cdef cppclass FixedLengthEncoder(FilterStream):

        FixedLengthEncoder(Stream *strA, int lengthA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue)
        GBool isEncoder() 

    
    #------------------------------------------------------------------------
    # ASCIIHexEncoder
    #------------------------------------------------------------------------

    cdef cppclass ASCIIHexEncoder(FilterStream):
        ASCIIHexEncoder(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
            
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue) 
        GBool isEncoder() 

       

    #------------------------------------------------------------------------
    # ASCII85Encoder
    #------------------------------------------------------------------------

    cdef cppclass ASCII85Encoder(FilterStream):
        ASCII85Encoder(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
            
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue) 
        GBool isEncoder() 

    

    #------------------------------------------------------------------------
    # RunLengthEncoder
    #------------------------------------------------------------------------

    cdef cppclass RunLengthEncoder(FilterStream): 
        RunLengthEncoder(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
            
        int lookChar()
            
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue) 
        GBool isEncoder() 

       

    #------------------------------------------------------------------------
    # LZWEncoder
    #------------------------------------------------------------------------

    ctypedef struct LZWEncoderNode:
        int byte
        LZWEncoderNode *next		# next sibling
        LZWEncoderNode *children	# first child
        

    cdef cppclass LZWEncoder(FilterStream): 
        LZWEncoder(Stream *strA)
        
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        GString *getPSFilter(int psLevel, const char *indent,
                        GBool okToReadStream)
            
        GBool isBinary(GBool last = gTrue) 
        GBool isEncoder() 
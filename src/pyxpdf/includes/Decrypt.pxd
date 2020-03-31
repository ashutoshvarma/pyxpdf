from pyxpdf.includes.xpdf_types cimport GString, GBool, Guchar, Guint, Gulong
from pyxpdf.includes.Stream cimport Stream, FilterStream, CryptAlgorithm, StreamKind



cdef extern from "Decrypt.h" nogil:
    cdef cppclass Decrypt:
        # Generate a file key.  The <fileKey> buffer must have space for at
        # least 16 bytes.  Checks <ownerPassword> and then <userPassword>
        # and returns true if either is correct.  Sets <ownerPasswordOk> if
        # the owner password was correct.  Either or both of the passwords
        # may be NULL, which is treated as an empty string.
        GBool makeFileKey(int encVersion, int encRevision, int keyLength,
                    GString *ownerKey, GString *userKey,
                    GString *ownerEnc, GString *userEnc,
                    int permissions, GString *fileID,
                    GString *ownerPassword, GString *userPassword,
                    Guchar *fileKey, GBool encryptMetadata,
                    GBool *ownerPasswordOk)


    ctypedef struct DecryptRC4State:
        Guchar state[256]
        Guchar x, y
        int buf
        

    ctypedef struct DecryptAESState: 
        Guint w[44]
        Guchar state[16]
        Guchar cbc[16]
        Guchar buf[16]
        int bufIdx
        

    ctypedef struct DecryptAES256State: 
        Guint w[60]
        Guchar state[16]
        Guchar cbc[16]
        Guchar buf[16]
        int bufIdx


    cdef cppclass DecryptStream(FilterStream):
        DecryptStream(Stream *strA, Guchar *fileKeyA,
                        CryptAlgorithm algoA, int keyLengthA,
                        int objNumA, int objGenA)
        Stream *copy()
        StreamKind getKind() 
        void reset()
        int getChar()
        int lookChar()
        GBool isBinary(GBool last)
        Stream *getUndecodedStream() 


    ctypedef struct MD5State:
        Gulong a, b, c, d
        Guchar buf[64]
        int bufLen
        int msgLen
        Guchar digest[16]

    void rc4InitKey(Guchar *key, int keyLen, Guchar *state)
    Guchar rc4DecryptByte(Guchar *state, Guchar *x, Guchar *y, Guchar c)
    void md5Start(MD5State *state)
    void md5Append(MD5State *state, Guchar *data, int dataLen)
    void md5Finish(MD5State *state)
    void md5(Guchar *msg, int msgLen, Guchar *digest)
    void aesKeyExpansion(DecryptAESState *s,
                    Guchar *objKey, int objKeyLen,
                    GBool decrypt)
    void aesEncryptBlock(DecryptAESState *s, Guchar *in_)
    void aesDecryptBlock(DecryptAESState *s, Guchar *in_, GBool last)


        
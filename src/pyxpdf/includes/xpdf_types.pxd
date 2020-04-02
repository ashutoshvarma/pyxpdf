from pyxpdf.includes.native cimport va_list

cdef extern from "gtypes.h" nogil:
    ctypedef int GBool
    ctypedef unsigned char Guchar
    ctypedef unsigned short Gushort
    ctypedef unsigned int Guint
    ctypedef unsigned long Gulong
    cdef int gTrue 
    cdef int gFalse 

cdef extern from "gfile.h" nogil:
    ctypedef long long GFileOffset

cdef extern from "GString.h" nogil:
    cdef cppclass GString:
        # Create an empty string.
        GString()

        # Create a string from a C string.
        GString(const char *sA)

        # Create a string from <lengthA> chars at <sA>.  This string
        # can contain null characters.
        GString(const char *sA, int lengthA)

        # Create a string from <lengthA> chars at <idx> in <str>.
        GString(GString *str, int idx, int lengthA)

        # Copy a string.
        GString(GString *str)
        GString *copy() 

        # Concatenate two strings.
        GString(GString *str1, GString *str2)

        # Convert an integer to a string.
        @staticmethod
        GString *fromInt(int x)

        # Create a formatted string.  Similar to printf, but without the
        # string overflow issues.  Formatting elements consist of:
        #     
        # where:
        # - <arg> is the argument number (arg 0 is the first argument
        #   following the format string) -- NB: args must be first used in
        #   order they can be reused in any order
        # - <width> is the field width -- negative to reverse the alignment
        #   starting with a leading zero to zero-fill (for integers)
        # - <precision> is the number of digits to the right of the decimal
        #   point (for floating point numbers)
        # - <type> is one of:
        #     d, x, o, b -- int in decimal, hex, octal, binary
        #     ud, ux, uo, ub -- unsigned int
        #     ld, lx, lo, lb, uld, ulx, ulo, ulb -- long, unsigned long
        #     lld, llx, llo, llb, ulld, ullx, ullo, ullb
        #         -- long long, unsigned long long
        #     f, g -- double
        #     c -- char
        #     s -- string (char *)
        #     t -- GString *
        #     w -- blank space arg determines width
        # To get literal curly braces, use .
        @staticmethod
        GString *format(const char *fmt, ...)
        @staticmethod
        GString *formatv(const char *fmt, va_list argList)

        # Get length.
        int getLength() 

        # Get C string.
        char *getCString() 

        # Get <i>th character.
        char getChar(int i) 

        # Change <i>th character.
        void setChar(int i, char c) 

        # Clear string to zero length.
        GString *clear()

        # Append a character or string.
        GString *append(char c)
        GString *append(GString *str)
        GString *append(const char *str)
        GString *append(const char *str, int lengthA)

        # Append a formatted string.
        GString *appendf(const char *fmt, ...)
        GString *appendfv(const char *fmt, va_list argList)

        # Insert a character or string.
        GString *insert(int i, char c)
        GString *insert(int i, GString *str)
        GString *insert(int i, const char *str)
        GString *insert(int i, const char *str, int lengthA)

        # Delete a character or range of characters.
        GString *delete "*delete"(int i, int n = 1)

        # Convert string to all-upper/all-lower case.
        GString *upperCase()
        GString *lowerCase()

        # Compare two strings:  -1:<  0:=  +1:>
        int cmp(GString *str)
        int cmpN(GString *str, int n)
        int cmp(const char *sA)
        int cmpN(const char *sA, int n) 


cdef extern from "GList.h" nogil:
    cdef cppclass GList:
        # Create an empty list.
        GList()

        # Create an empty list with space for <size1> elements.
        GList(int sizeA)

        #----- general

        # Get the number of elements.
        int getLength() 

        # Returns a (shallow) copy of this list.
        GList *copy()

        #----- ordered list support

        # Return the <i>th element.
        # Assumes 0 <= i < length.
        void *get(int i) 

        # Replace the <i>th element.
        # Assumes 0 <= i < length.
        void put(int i, void *p) 

        # Append an element to the end of the list.
        void append(void *p)

        # Append another list to the end of this one.
        void append(GList *list)

        # Insert an element at index <i>.
        # Assumes 0 <= i <= length.
        void insert(int i, void *p)

        # Deletes and returns the element at index <i>.
        # Assumes 0 <= i < length.
        void *delete "*del"(int i)

        # Sort the list accoring to the given comparison function.
        # NB: this sorts an array of pointers, so the pointer args need to
        # be double-dereferenced.
        void sort(int (*cmp)(const void *ptr1, const void *ptr2))

        # Reverse the list.
        void reverse()

        #----- control

        # Set allocation increment to <inc>.  If inc > 0, that many
        # elements will be allocated every time the list is expanded.
        # If inc <= 0, the list will be doubled in size.
        void setAllocIncr(int incA) 

        
    cdef void deleteGList(GList list, T)
       





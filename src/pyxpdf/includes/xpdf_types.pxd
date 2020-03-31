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

        # Get C string.
        char *getCString() 


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
       







cdef extern from "Link.h" nogil:
    ctypedef enum LinkActionKind: 
        actionGoTo			# go to destination
        actionGoToR			# go to destination in new file
        actionLaunch			# launch app (or open document)
        actionURI			# URI
        actionNamed			# named action
        actionMovie			# movie action
        actionJavaScript		# run JavaScript
        actionSubmitForm		# submit form
        actionHide			# hide annotation
        actionUnknown			# anything else
        

    cdef cppclass LinkAction:
        pass

    ctypedef enum LinkDestKind:
        pass

    cdef cppclass LinkDest:
        pass

        
    cdef cppclass Link:
        pass
    cdef cppclass Links:
        pass


    

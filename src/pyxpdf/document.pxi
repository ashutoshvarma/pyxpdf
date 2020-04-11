from libcpp.string cimport string
from libcpp.memory cimport unique_ptr, make_unique
from libcpp.vector cimport vector

from cython.operator cimport dereference as deref

from pyxpdf.includes.xpdf_error cimport errEncrypted
from pyxpdf.includes.xpdf_types cimport GBool, GString, gFalse, gTrue
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.TextString cimport TextString
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport MemStream
from pyxpdf.includes.PDFDoc cimport PDFDoc
from pyxpdf.includes.Page cimport Page
from pyxpdf.includes.TextOutputDev cimport TextOutputDev, TextPage, TextOutputControl
from pyxpdf.includes.Catalog cimport Catalog


cdef class XPDFDoc:
    cdef PDFDoc *doc
    cdef GString *ownerpass 
    cdef GString *userpass 
    # Using string to store char array
    cdef bytes doc_data

    cdef dict get_info_dict(XPDFDoc self):
        cdef Object info 
        if self.doc.getDocInfo(&info).isDict() == gFalse:
            info.free()
            return dict()

        cdef Dict *info_dict = info.getDict()
        cdef Object obj
        cdef dict result = {}
        cdef const char* key 
        for i in range(info_dict.getLength()):
            key = info_dict.getKey(i)
            if info_dict.lookup(key, &obj).isString() == gTrue:
                result[key.decode('UTF-8')] = GString_to_unicode(obj.getString())

        obj.free()
        info.free()
        return result
        
    cdef get_metadata(self):
        cdef unique_ptr[GString] meta
        meta.reset(self.doc.readMetadata())
        if meta.get():
            return GString_to_unicode(meta.get())
        return None

    cdef _load_from_file(XPDFDoc self, GString *pdf):
        self.doc = new PDFDoc(pdf, self.ownerpass, self.userpass)
        if self.doc == NULL:
            raise MemoryError("Cannot allocate memory for internal objects")
        
    cdef _load_from_char_array(XPDFDoc self, char *pdf, int data_length):
        cdef Object *obj_null = new Object()
        cdef MemStream *mem_stream = new MemStream(pdf, 0, data_length, obj_null.initNull())
        if mem_stream == NULL:
            raise MemoryError("Cannot allocate memory for internal objects")
        self.doc = new PDFDoc(mem_stream, self.ownerpass, self.userpass)

    cdef check(self):
        if self.doc.isOk() == gTrue or self.doc.getErrorCode() == errEncrypted:
            if self.doc.getErrorCode() == errEncrypted:
                raise PDFError("PDF cannot be decrypted please provide correct passwords.")
        else:
            raise PDFError(f"Cannot Parse PDF. ErrorCode - {self.doc.getErrorCode()}")

    cdef Catalog *get_catalog(self):
        return self.doc.getCatalog()
        

    def __cinit__(self, pdf, ownerpass=None, userpass=None):
        # self.global_params.setTextEncoding(b"UTF-8")
        self.doc = NULL
        self.doc_data = string()

        # Type casting NULL to prebent MSVC/C14 errors
        self.ownerpass = <GString*> NULL if ownerpass == None else to_GString(ownerpass)
        self.userpass = <GString*> NULL if userpass == None else to_GString(userpass)

        # pdf file path
        if isinstance(pdf, basestring):
            self._load_from_file(to_GString(pdf))
        # file-like object
        elif callable(getattr(pdf, 'read', None)):
            # copy buffer
            self.doc_data = pdf.read()
            self._load_from_char_array(self.doc_data, len(self.doc_data))
        else:
            raise ValueError(f"pdf argument must be a string or a file-like object.")

        # check PDFDoc
        self.check()

    
    def __dealloc__(self):
        del self.doc
        del self.ownerpass
        del self.userpass

    @property
    def num_pages(self):
        return self.doc.getNumPages()

    @property
    def pdf_version(self):
        return self.doc.getPDFVersion()

    @property
    def is_linearized(self):
        return GBool_to_bool(self.doc.isLinearized())

    # PDF Permissions
    @property
    def ok_to_print(self):
        return GBool_to_bool(self.doc.okToPrint(ignoreOwnerPW=gFalse))
    
    @property
    def ok_to_change(self):
        return GBool_to_bool(self.doc.okToChange(ignoreOwnerPW=gFalse))
    
    @property
    def ok_to_copy(self):
        return GBool_to_bool(self.doc.okToCopy(ignoreOwnerPW=gFalse))
    
    @property
    def ok_to_add_notes(self):
        return GBool_to_bool(self.doc.okToAddNotes(ignoreOwnerPW=gFalse))

    
    def info_dict(self):
        return self.get_info_dict()

    def metadata(self):
        return self.get_metadata()


cdef class XPage:
    cdef Page *page
    cdef int index
    cdef readonly XPDFDoc doc

    def __cinit__(self, XPDFDoc doc not None, int index):
        if index < 0 or index >= doc.num_pages:
            raise IndexError("Page index must be positive integer less than total pages")
        self.page = doc.get_catalog().getPage(index + 1)
        self.index = index
        self.doc = doc


    def find_text(self, text, search_box=None, start_at_top=True, stop_at_bottom=True, start_at_last=False, 
                stop_at_last=False, case_sensitive=False, backward=False, wholeword=False, rotation=0):
        cdef double x_min = 0
        cdef double y_min = 0
        cdef double x_max = 0
        cdef double y_max = 0
        if search_box:
            x_min = search_box[0] or 0
            y_min = search_box[1] or 0
            x_max = search_box[2] or 0
            y_max = search_box[3] or 0

        cdef int rotation_value = rotation

        # Convert python str to xpdf Unicode
        cdef vector[Unicode] u
        utf32_to_Unicode_vector(text, u)

        cdef unique_ptr[TextOutputControl] text_control = make_unique[TextOutputControl]()
        cdef unique_ptr[TextOutputDev] td = make_unique[TextOutputDev](<char*>NULL, text_control.get(), gFalse)
        cdef unique_ptr[TextPage] text_page
        self.doc.doc.displayPage(td.get(), self.index + 1, 72, 72, rotation_value, gFalse, gTrue, gFalse)
        text_page.reset(deref(td).takeText())

        cdef GBool res = deref(text_page).findText(u.data(), u.size(), to_GBool(start_at_top), 
                                        to_GBool(stop_at_bottom), to_GBool(start_at_last), 
                                        to_GBool(stop_at_last), to_GBool(case_sensitive), 
                                        to_GBool(backward), to_GBool(wholeword),
                                        &x_min, &y_min, &x_max, &y_max)
        
        return (x_min, y_min, x_max, y_max) if res == gTrue else None


    def text_raw(self, search_box=None, XTextOutputControl control = None):
        cdef:
            TextOutputControl text_control = control.control if control else TextOutputControl()
            unique_ptr[string] out = make_unique[string]()
            unique_ptr[TextOutputDev] text_dev = make_unique[TextOutputDev](&append_to_cpp_string, out.get(), &text_control)

        if search_box == None:
            # Why crop=gTrue in displayPage?
            self.doc.doc.displayPage(text_dev.get(), self.index + 1, 72, 72, 0, gFalse, gTrue, gFalse)
        else:
            self.doc.doc.displayPageSlice(text_dev.get(), self.index + 1, 72, 72, 0, gFalse, gTrue, gFalse, 
                                        search_box[0], search_box[1], search_box[2], search_box[3])

        return deref(out)

    @property
    def label(self):
        cdef unique_ptr[GString] glabel 
        cdef unique_ptr[TextString] txt_label 
        if self.doc.get_catalog().hasPageLabels() == gTrue:
            txt_label.reset(self.doc.get_catalog().getPageLabel(self.index + 1))     
            if txt_label != NULL:
                glabel.reset(deref(txt_label).toPDFTextString())
                return GString_to_unicode(glabel.get())
            else:
                return None       
        return None

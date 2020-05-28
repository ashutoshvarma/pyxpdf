from pyxpdf.includes.xpdf_error cimport errEncrypted, errOpenFile
from pyxpdf.includes.CharTypes cimport Unicode
from pyxpdf.includes.TextString cimport TextString
from pyxpdf.includes.Object cimport Object
from pyxpdf.includes.Dict cimport Dict
from pyxpdf.includes.Stream cimport MemStream
from pyxpdf.includes.PDFDoc cimport PDFDoc
# Change import name as it was conflicting with cdef classes
from pyxpdf.includes.Page cimport Page as XPage
from pyxpdf.includes.OutputDev cimport OutputDev
from pyxpdf.includes.TextOutputDev cimport (
    TextOutputDev, TextPage, TextOutputControl
)
from pyxpdf.includes.Catalog cimport Catalog


cdef class Document:
    cdef:
        PDFDoc *doc
        GString *ownerpass
        GString *userpass
        # Using string to store char array
        bytes doc_data
        # for caching pages
        list _pages_cache


    cdef Catalog *get_catalog(self):
        return self.doc.getCatalog()

    cdef display_pages(self, OutputDev* out, int first, int end,
                        double hDPI = 72, double vDPI = 72, int rotate = 0,
                        GBool use_media_box = gFalse, GBool crop = gTrue,
                        GBool printing = gFalse):
        if first < 0 or first >= self.num_pages:
            first = 0
        if end < 0 or end >= self.num_pages:
            end = self.num_pages - 1
        self.doc.displayPages(out, first + 1, end + 1, hDPI, vDPI, rotate,
                            use_media_box, crop, printing)

    cdef dict get_info_dict(self):
        cdef:
            Object info
            dict result = {}
        if self.doc.getDocInfo(&info).isDict() == gTrue:
            Dict_to_pydict(info.getDict(), result)
        info.free()
        return result

    cdef get_metadata(self):
        cdef unique_ptr[GString] meta
        meta.reset(self.doc.readMetadata())
        if meta.get():
            return GString_to_unicode(meta.get())
        return None

    cdef _load_from_file(self, GString *pdf):
        self.doc = new PDFDoc(pdf, self.ownerpass, self.userpass)
        if self.doc == NULL:
            raise MemoryError("Cannot allocate memory for internal objects")

    cdef _load_from_char_array(self, char *pdf, int data_length):
        cdef Object *obj_null = new Object()
        cdef MemStream *mem_stream = new MemStream(pdf, 0, data_length, obj_null.initNull())
        if mem_stream == NULL:
            raise MemoryError("Cannot allocate memory for internal objects")
        self.doc = new PDFDoc(mem_stream, self.ownerpass, self.userpass)

    cdef check(self):
        if self.doc.isOk() == gTrue or self.doc.getErrorCode() == errEncrypted:
            if self.doc.getErrorCode() == errEncrypted:
                raise PDFPermissionError("PDF cannot be decrypted please provide correct passwords.")
        elif self.doc.getErrorCode() == errOpenFile:
            raise PDFIOError(f"Failed to load {self.filename}")
        else:
            err_code = self.doc.getErrorCode()
            raise ErrorCodeMapping[err_code]

    cdef int label_to_index(self, label):
        cdef:
            int pgno
            unique_ptr[TextString] tstr

        tstr.reset(to_TextString(label))
        pgno = self.get_catalog().getPageNumFromPageLabel(tstr.get())
        # xpdf page index start from 1 not 0
        if pgno != -1:
            pgno = pgno - 1
        return pgno

    cdef get_page(self, int idx):
        if idx < 0 or idx >= self.num_pages:
            raise IndexError(
                "The index {idx} is out of page range".format(idx=idx))
        # load page in cache if not present
        if self._pages_cache[idx] == None:
            self._pages_cache[idx] = Page(self, idx)
        return self._pages_cache[idx]


    def __cinit__(self, pdf, ownerpass=None, userpass=None):
        self.doc = NULL

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

        # build empty cache
        self._pages_cache = [None] * self.num_pages

    def __dealloc__(self):
        del self.doc
        del self.ownerpass
        del self.userpass

    def __repr__(self):
        fname = "Stream" if self.filename == "" else self.filename
        return "<Document [{fname}]>".format(fname=fname)

    def __str__(self):
        fname = "Stream" if self.filename == "" else self.filename
        return "<Document [{fname}] [{pages}]>".format(fname=fname, pages=self.num_pages)

    def __len__(self):
        return self.num_pages

    def __getitem__(self, key):
        if isinstance(key, str):
            pgno = self.label_to_index(key)
            if pgno == -1:
                raise KeyError(
                    "Could not find page with label '{key}'".format(key=key))
            return self.get_page(pgno)
        elif isinstance(key, int):
            # handle neg key
            if key < 0:
                key += self.num_pages
            return self.get_page(key)
        elif isinstance(key, slice):
            # Return the list of Pages
            return [self[i] for i in range(*key.indices(self.num_pages))]
        else:
            raise TypeError("Invalid Key type")

    def __iter__(self):
        return PageIterator(self)

    @property
    def filename(self):
        return GString_to_unicode(self.doc.getFileName())

    @property
    def has_page_labels(self):
        return GBool_to_bool(self.get_catalog().hasPageLabels())

    @property
    def num_pages(self):
        return self.doc.getNumPages()

    @property
    def pdf_version(self):
        return self.doc.getPDFVersion()

    @property
    def is_linearized(self):
        return GBool_to_bool(self.doc.isLinearized())

    @property
    def is_encrypted(self):
        return GBool_to_bool(self.doc.isEncrypted())

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


    def info(self):
        return self.get_info_dict()

    def xmp_metadata(self):
        return self.get_metadata()


    cpdef text_raw(self, int start=0, int end=-1, TextControl control=None):
        cdef:
            TextOutputControl text_control = deref(control.get_c_control()) if control else TextOutputControl()
            unique_ptr[string] out = make_unique[string]()
            unique_ptr[TextOutputDev] text_dev = make_unique[TextOutputDev](&append_to_cpp_string,
                                                                            out.get(), &text_control)

        self.display_pages(text_dev.get(), start, end)
        return deref(out)

    cpdef text(self, start=0, end=-1, control=None):
        return self.text_raw(start=start, end=end, control=control
                                  ).decode('UTF-8', errors='ignore')



cdef class PageIterator:
    cdef:
        Document doc
        int index

    def __init__(self, doc):
        self.doc = doc
        self.index = -1

    def __iter__(self):
        return self

    def __next__(self):
        self.index += 1
        if self.index >= len(self.doc):
            raise StopIteration()
        return self.doc[self.index]



cdef class Page:
    # No need to free Page* as it is own by PDFDoc
    cdef XPage *page
    cdef unique_ptr[TextPage] textpage
    cdef public int index
    cdef public object label
    cdef readonly Document doc


    cdef display_slice(self, OutputDev* out, int x1, int y1, int hgt, int wdt,
                        double hDPI = 72, double vDPI = 72, int rotate = 0,
                        GBool use_media_box = gFalse, GBool crop = gTrue,
                        GBool printing = gFalse):
        self.page.displaySlice(out, hDPI, vDPI, rotate, use_media_box, crop,
                                x1, y1, hgt, wdt, printing)

    cdef display(self, OutputDev* out, double hDPI = 72, double vDPI = 72,
                        int rotate = 0, GBool use_media_box = gFalse,
                        GBool crop = gTrue, GBool printing = gFalse):
        self.display_slice(out, -1, -1, -1, -1, hDPI, vDPI, rotate,
                            use_media_box, crop, printing)

    cdef _init_TextPage(self, int rotation):
        cdef:
            unique_ptr[TextOutputControl] text_control
            unique_ptr[TextOutputDev] td

        text_control = make_unique[TextOutputControl]()
        td = make_unique[TextOutputDev](<char*>NULL, text_control.get(), gFalse)

        self.display(td.get(), 72, 72, rotation)
        self.textpage.reset(deref(td).takeText())

    cdef get_label(self):
        cdef:
            unique_ptr[GString] glabel
            unique_ptr[TextString] txt_label

        if self.doc.get_catalog().hasPageLabels() == gTrue:
            txt_label.reset(self.doc.get_catalog().getPageLabel(self.index + 1))
            if txt_label != NULL:
                glabel.reset(deref(txt_label).toPDFTextString())
                return GString_to_unicode(glabel.get())
            else:
                return None
        return None

    cdef _find_text(self, text, search_box=None, start_at_top=True, stop_at_bottom=True, start_at_last=False,
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

        # Convert python str to xpdf Unicode
        cdef vector[Unicode] u
        utf32_to_Unicode_vector(text, u)

        # Lazy load TextPage
        if self.textpage.get() == NULL:
            self._init_TextPage(rotation)

        cdef GBool res = deref(self.textpage).findText(u.data(), u.size(), to_GBool(start_at_top),
                                        to_GBool(stop_at_bottom), to_GBool(start_at_last),
                                        to_GBool(stop_at_last), to_GBool(case_sensitive),
                                        to_GBool(backward), to_GBool(wholeword),
                                        &x_min, &y_min, &x_max, &y_max)

        return (x_min, y_min, x_max, y_max) if res == gTrue else None


    def __cinit__(self, Document doc not None, int index):
        if index < 0 or index >= doc.num_pages:
            raise IndexError("Page index must be positive integer less than total pages")
        self.page = doc.get_catalog().getPage(index + 1)
        # self.textpage.reset()
        self.doc = doc
        self.index = index
        self.label = self.get_label()

    def __repr__(self):
        if self.label == None:
            return "<Page[{index}]>".format(index=self.index)
        else:
            return "<Page[{index}](label='{label}')>".format(index=self.index, label=self.label)


    @property
    def rotation(self):
        return self.page.getRotate()

    @property
    def is_cropped(self):
        return GBool_to_bool(self.page.isCropped())

    @property
    def media_height(self):
        return self.page.getMediaHeight()

    @property
    def media_width(self):
        return self.page.getMediaWidth()

    @property
    def crop_height(self):
        return self.page.getCropHeight()

    @property
    def crop_width(self):
        return self.page.getCropWidth()

    @property
    def mediabox(self):
        return PDFRectangle_to_tuple(self.page.getMediaBox())

    @property
    def cropbox(self):
        return PDFRectangle_to_tuple(self.page.getCropBox())

    @property
    def bleedbox(self):
        return PDFRectangle_to_tuple(self.page.getBleedBox())

    @property
    def trimbox(self):
        return PDFRectangle_to_tuple(self.page.getTrimBox())

    @property
    def artbox(self):
        return PDFRectangle_to_tuple(self.page.getArtBox())


    def find_text(self, text, search_box=None, direction="top", case_sensitive=False,
                  wholeword=False, rotation=0):
        result = None
        if direction == "top":
            result = self._find_text(text, search_box, True, True, False, False,
                                          case_sensitive, False, wholeword, rotation)
        if direction == "next":
            result = self._find_text(text, search_box, False, True, True, False,
                                          case_sensitive, False, wholeword, rotation)
        if direction == "previous":
            result = self._find_text(text, search_box, False, True, True, False,
                                          case_sensitive, True, wholeword, rotation)
        return result


    def find_all_text(self, text, search_box=None, case_sensitive=False, wholeword=False,
                      rotation=0):
        res = self.find_text(text, search_box, "top",
                             case_sensitive, wholeword)
        while res:
            yield res
            res = self.find_text(text, search_box, "next",
                                 case_sensitive, wholeword)


    def text_raw(self, search_box=None, TextControl control = None):
        cdef:
            TextOutputControl text_control = deref(control.get_c_control()) if control else TextOutputControl()
            unique_ptr[string] out = make_unique[string]()
            unique_ptr[TextOutputDev] text_dev = make_unique[TextOutputDev](&append_to_cpp_string, out.get(), &text_control)

        if search_box == None:
            # Why crop=gTrue in displayPage?
            self.display(text_dev.get())
        else:
            self.display_slice(text_dev.get(), search_box[0], search_box[1],
                                search_box[2], search_box[3])

        return deref(out)


    def text(self, text_area=None, control=None):
        return self.text_raw(text_area, control).decode('UTF-8', errors='ignore')







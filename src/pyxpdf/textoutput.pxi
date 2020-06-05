from pyxpdf.includes.TextOutputDev cimport (
    TextOutputMode, TextOutputControl, TextPage
)


cdef class TextControl:
    cdef TextOutputControl _c_control

    def __cinit__(self, mode = "reading", double fixed_pitch = 0,
                  double fixed_line_spacing=0, enable_html=False, clip_text=False,
                  discard_diagonal=False, discard_invisible=False,
                  discard_clipped=False, insert_bom=False, double margin_left=0,
                  double margin_right=0, double margin_top=0, double margin_bottom=0):

        self._c_control.fixedPitch = fixed_pitch
        self._c_control.fixedLineSpacing = fixed_line_spacing

        self._c_control.html = to_GBool(enable_html)
        self._c_control.clipText = to_GBool(clip_text)
        self._c_control.discardDiagonalText = to_GBool(discard_diagonal)
        self._c_control.discardInvisibleText = to_GBool(discard_invisible)
        self._c_control.discardClippedText = to_GBool(discard_clipped)
        self._c_control.insertBOM = to_GBool(insert_bom)

        self._c_control.marginRight = margin_right
        self._c_control.marginLeft = margin_left
        self._c_control.marginTop = margin_top
        self._c_control.marginBottom = margin_bottom

        if mode == "physical":
            self._c_control.mode = TextOutputMode.textOutPhysLayout
        elif mode == "table":
            self._c_control.mode = TextOutputMode.textOutTableLayout
        elif mode == "simple":
            self._c_control.mode = TextOutputMode.textOutSimpleLayout
        elif mode == "lineprinter":
            self._c_control.mode = TextOutputMode.textOutLinePrinter
        elif mode == "raw":
            self._c_control.mode = TextOutputMode.textOutRawOrder
        elif mode == "reading":
            self._c_control.mode = TextOutputMode.textOutReadingOrder
        else:
            raise ValueError("Invalid TexOutput Mode")

    cdef TextOutputControl* get_c_control(self):
        return &self._c_control



cdef class TextOutput:
    cdef:
        unique_ptr[TextOutputDev] _c_textdev
        readonly TextControl control
        unique_ptr[string] _out_str
        readonly Document doc
        # caching resource
        list _cache_texts
        vector[unique_ptr[TextPage]] _c_text_pages

    def __cinit__(self, Document doc not None, TextControl control = None, **kargs):
        if control == None:
            control = TextControl(**kargs)
        self.doc = doc
        # keep a ref for TextOutput as TextOutputDev does not 
        # copy TextOutputControl
        self.control = control
        self._c_textdev = make_unique[TextOutputDev](&append_to_cpp_string, self._out_str.get(),
                                                     self.control.get_c_control())
        if self._c_textdev.get() == NULL:
            raise MemoryError("Cannot allocate memory for 'TextOutput' object.")
        # sanity check
        if self._c_textdev.get().isOk() == gFalse:
            raise XPDFInternalError
        # init caching
        self._init_cache()

    def __repr__(self):
        return f"<TextOutput[{self.doc.__repr__()}]>"


    # PRIVATE METHODS

    cdef bytes _get_bytes(self, int page_no):
        if self._cache_texts[page_no] == None:
            # load text
            self._get_TextPage(page_no)
        return self._cache_texts[page_no]

    cdef TextPage* _get_TextPage(self, page_no=0) except NULL:
        cdef:
            Page page = self.doc.get_page(page_no)
            bytes page_txt
        if page_no < 0:
           page_no = 0
        if page_no >= self.doc.num_pages:
            page_no = self.doc.num_pages - 1
        cdef:
            unique_ptr[string] out = make_unique[string]()
            unique_ptr[TextOutputDev] _c_dev = make_unique[TextOutputDev](&append_to_cpp_string,
                                                                          out.get(), self.control.get_c_control())
        if self._c_text_pages[page_no] == NULL:
            page.display(_c_dev.get())
            self._c_text_pages[page_no].reset(deref(_c_dev).takeText())
            # save raw text from page
            page_txt = deref(out.get())
            self._cache_texts[page_no] = page_txt

        return self._c_text_pages[page_no].get()


    cdef void _init_cache(self):
        cdef:
            unique_ptr[TextPage] _tp
            int pg_count
        pg_count = self.doc.num_pages
        self._cache_texts = [None] * pg_count
        for _ in range(pg_count):
            _tp = unique_ptr[TextPage]()
            self._c_text_pages.push_back(move(_tp))


    # PUBLIC METHODS

    cpdef bytes get_bytes(self, int page_no):
        if page_no < 0 or page_no >= self.doc.doc.getNumPages():
            raise ValueError(f"page_no should be within pdf page range.")
        return self._get_bytes(page_no)

    cpdef object get(self, int page_no):
        return self._get_bytes(page_no).decode('UTF-8', errors='ignore')

    cpdef list get_all(self):
        cdef:
            int i
            list txt_all = []

        for i in range(self.doc.doc.getNumPages()):
            txt_all.append(self._get_bytes(i).decode('UTF-8', errors='ignore'))
        return txt_all






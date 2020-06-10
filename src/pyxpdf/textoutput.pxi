from pyxpdf.includes.TextOutputDev cimport (
    TextOutputMode, TextOutputControl, TextPage
)


cdef class TextControl:
    """Parameters for Text extraction and layout analysis

    Text layout modes:
        - **reading**
            Keep the text in reading order. It 'undo' physical layout (columns,
            hyphenation, etc.) and output the text in reading order.
        - **physical**
            Maintain (as best as possible) the original physical layout of
            the text. If the `fixed_pitch` option is given, character spacing 
            within each line will be determined by the specified character pitch.
        - **table**
            It is similar to `physical` layout mode, but optimized for
            tabular data, with the goal of keeping rows and columns  aligned
            (at the expense of inserting extra whitespace). If the `fixed_pitch`
            option is given, character spacing  within  each  line  will  be
            determined by the specified character pitch.
        - **simple**
            Similar to `physical` layout, but optimized for simple one-column
            pages. This mode will do a better job of maintaining horizontal
            spacing, but it will only work properly with a single column
            of text.
        - **lineprinter**
            Line printer mode uses a strict fixed character pitch and height
            layout. That is, the page is broken into a grid, and characters
            are placed into that grid. If the grid spacing is too small for the
            actual characters, the result is extra  whitespace. If the grid
            spacing is too large, the result is missing whitespace.  The
            grid spacing can be specified using the  `fixed_pitch` and
            `fixed_line_spacing` options. If one or both are not given on the
            xpdf will attempt to compute appropriate value(s).
        - **raw**
            Keep the text in content stream order. Depending on how the PDF
            file was generated, this may or may not be useful.

    Parameters
    ----------
    mode : {"reading", "table", "simple", "physical", "lineprinter", "raw"}
        text analysis/extraction layout mode
    fixed_pitch : float, optional
        Specify the character pitch (character width), for
        `physical` , `table` ,or `lineprinter` mode. This is ignored
        in all other modes.
        (default is 0, means approximate characters' pitch will be calculated)
    fixed_line_spacing : float, optional
        Specify the line spacing, in  points, for `lineprinter` mode.
        This is ignored in all other modes.
        (default is `0`, means approximate line spacing will be calculated)
    enable_html : bool, optional
        enable extra proccessing for html. (default is :obj:`False`)
    clip_text : bool, optional
        Text which is hidden because of clipping is removed before doing
        layout, and then added back in. This can be helpful for tables
        where clipped (invisible) text would overlap the next column.
        (default is :obj:`False`)
    discard_clipped : bool, optional
        discard all clipped characters
        (default is :obj:`False`)
    discard_diagonal : bool, optional
        Diagonal text, i.e., text that is not close to one of the 0, 90,
        180, or 270 degree axes, is discarded. This is useful to skip
        watermarks drawn on top of body text, etc.
        (default is :obj:`False`)
    discard_invisible : bool, optional
        discard all invinsible characters
        (default is :obj:`False`)
    insert_bom : bool, optional
        Insert a Unicode byte order marker (BOM) at the start of the
        text output.
    margin_left : float, optional
        Specifies the left margin. Text in the left margin
        (i.e., within that many points of the left edge of the page) is
        discarded.
        (default is `0`)
    margin_right : float, optional
        Specifies the right margin. Text in the right margin
        (i.e., within that many points of the right edge of the page) is
        discarded.
        (default is `0`)
    margin_top : float, optional
        Specifies the top margin. Text in the top margin
        (i.e., within that many points of the top edge of the page) is
        discarded.
        (default is `0`)
    margin_bottom : float, optional
        Specifies the bottom margin. Text in the bottom margin
        (i.e., within that many points of the bottom edge of the page) is
        discarded.
        (default is `0`)

    Raises
    ------
    ValueError
        If `mode` invalid
    """
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



cdef class TextOutput(PDFOutputDevice):
    """Text extract/analysis PDF Output device

    Extract text and do layout analysis on from PDF :class:`Document`
    while caching results. Page texts are cached for faster access.
    Page texts are lazy loaded, they are loaded only when you first
    access them.

    Parameters
    ----------
    doc : Document
        PDF Document for this output device
    control : TextControl, optional
        An :class:`TextControl` object for settings to adjust TextControl
        extraction/analysis.
        (default is :obj:`None`)
    kwargs
        :class:`TextControl` parameters which will be used if `control` is
        not provided.

    Attributes
    ----------
    doc : Document, readonly
        Parent PDF Document
    control : TextControl
        Layout settings for output device

    Raises
    ------
    XPDFInternalError
        If cannot initialize internal `xpdf` objects will settings provided
    """
    cdef:
        unique_ptr[TextOutputDev] _c_textdev
        unique_ptr[string] _out_str
        readonly Document doc
        readonly TextControl control
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
        """Get the extracted text bytes from `page_no` indexed page

        This method should be use when text encoding (:attr:`Config.text_encoding`)
        is different than `UTF-8` or when you to control decoding of bytes
        by yourself.

        Parameters
        ----------
        page_no : int
            index of page to extract text bytes from

        Return
        ------
        bytes
            extracted text bytes
        """
        return self._get_bytes(page_no)

    cpdef object get(self, int page_no):
        """Get the extracted `UTF-8` decoded :any:`str` from `page_no` indexed
        page

        This method is almost similar to :meth:`get_bytes`, the only difference
        is that it decodes the extracted bytes in `UTF-8` with '`ignore`'
        (:func:`codecs.ignore_errors`) decoding error handler.

        Parameters
        ----------
        page_no : int
            index of page to extract text bytes from

        Return
        ------
        str
            extracted `UTF-8` decoded text
        """
        return self._get_bytes(page_no).decode('UTF-8', errors='ignore')

    cpdef list get_all(self):
        """Get the extracted `UTF-8` decoded text from all pages

        Return
        ------
        :any:`list` of str
            list of `UTF-8` decoded text from all the pages
        """
        cdef:
            int i
            list txt_all = []

        for i in range(self.doc.doc.getNumPages()):
            txt_all.append(self._get_bytes(i).decode('UTF-8', errors='ignore'))
        return txt_all






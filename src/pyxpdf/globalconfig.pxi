from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams, EndOfLineKind
from pyxpdf.includes.UnicodeMap cimport UnicodeMap

# NOTE: This class should be always a singleton
# only one object of this class should exist i.e 
# global variable `Config`
# This is beacuse xpdf `GlobalParams` class's destructor
# frees global builtin font tables. So more that one
# `_GlobalParamsConfig` class will lead to double free
# or corruption error.
cdef class _GlobalParamsConfig:
    cdef:
        object cfg_path
        GlobalParams* _global
        public object __doc__

    cdef _set_defaults(self):
        # only call after initialising self._global
        # default text encoding 
        self._global.setTextEncoding("UTF-8")

    cdef _get_default_xpdfrc(self):
        cdef:
            object pyxpdf_data
            object cfg = None
        try:
            import pyxpdf_data
            cfg = pyxpdf_data.get_xpdfrc()
        except ImportError:
            pass
        else:
            del pyxpdf_data
        return cfg

    def load_file(self, cfg_path=None):
        if cfg_path == None:
            self._global = new GlobalParams(<const char*>NULL)
        else:
            self._global = new GlobalParams(_chars(cfg_path))

        if self._global == NULL:
            raise MemoryError("Cannot create GlobalParamsConfig object.")
        self._set_defaults()

        global globalParams
        globalParams = self._global

    def reset(self):
        self.load_file(self.cfg_path)

    def __cinit__(self):
        self._global = NULL
        self.cfg_path = self._get_default_xpdfrc()
        self.load_file(self.cfg_path)

    def __dealloc__(self):
        global globalParams
        globalParams = NULL
        del self._global


    def setup_base_fonts(self, dir):
        self._global.setupBaseFonts(_chars(dir))


    @property
    def base_dir(self):
        return GString_to_unicode(self._global.getBaseDir())

    @base_dir.setter
    def base_dir(self, dir):
        self._global.setBaseDir(_chars(dir))


    def map_name_to_unicode(self, char_name):
        return self._global.mapNameToUnicode(_chars(char_name))


    @property
    def ps_paper_width(self):
        return self._global.getPSPaperWidth()

    @ps_paper_width.setter
    def ps_paper_width(self, int width):
        self._global.setPSPaperWidth(width)


    @property
    def ps_paper_height(self):
        return self._global.getPSPaperHeight()

    @ps_paper_height.setter
    def ps_paper_height(self, int height):
        self._global.setPSPaperHeight(height)


    @property
    def enable_freetype(self):
        return GBool_to_bool(self._global.getEnableFreeType())

    @enable_freetype.setter
    def enable_freetype(self, enable):
        self._global.setEnableFreeType('yes' if enable == True else 'no')


    @property
    def anti_alias(self):
        return GBool_to_bool(self._global.getAntialias())

    @anti_alias.setter
    def anti_alias(self, enable):
        self._global.setAntialias('yes' if enable == True else 'no')


    @property
    def vector_anti_alias(self):
        return GBool_to_bool(self._global.getVectorAntialias())

    @vector_anti_alias.setter
    def vector_anti_alias(self, enable):
        self._global.setVectorAntialias('yes' if enable == True else 'no')


    @property
    def text_encoding(self):
        return GString_to_unicode(self._global.getTextEncodingName())

    @text_encoding.setter
    def text_encoding(self, encoding):
        cdef UnicodeMap* umap
        self._global.setTextEncoding(_chars(encoding))
        umap = self._global.getTextEncoding()
        if umap == NULL:
            raise XPDFConfigError(f"No UnicodeMap file associated with {encoding} found.")


    @property
    def text_eol(self):
        cdef EndOfLineKind eol = self._global.getTextEOL()
        if eol == EndOfLineKind.eolUnix:
            return "unix"
        elif eol == EndOfLineKind.eolDOS:
            return "dos"
        else:
            return "mac"

    @text_eol.setter
    def text_eol(self, eol):
        cdef EndOfLineKind c_eol
        if eol == "unix":
            c_eol = EndOfLineKind.eolUnix
        elif eol == "dos":
            c_eol = EndOfLineKind.eolDOS
        elif eol == 'mac':
            c_eol = EndOfLineKind.eolMac
        else:
            raise XPDFConfigError(f"Invalid EOL type - {eol}.")
        self._global.setTextEOL(_chars(eol))


    @property
    def text_page_breaks(self):
        return GBool_to_bool(self._global.getTextPageBreaks())

    @text_page_breaks.setter
    def text_page_breaks(self, breaks):
        self._global.setTextPageBreaks(to_GBool(breaks))


    @property
    def text_keep_tiny(self):
        return GBool_to_bool(self._global.getTextKeepTinyChars())

    @text_keep_tiny.setter
    def text_keep_tiny(self, keep):
        self._global.setTextKeepTinyChars(to_GBool(keep))


    @property
    def print_commands(self):
        return GBool_to_bool(self._global.getPrintCommands())

    @print_commands.setter
    def print_commands(self, print_cmd):
        self._global.setPrintCommands(to_GBool(print_cmd))


    @property
    def error_quiet(self):
        return GBool_to_bool(self._global.getErrQuiet())

    @error_quiet.setter
    def error_quiet(self, quiet):
        self._global.setErrQuiet(to_GBool(quiet))


    @property
    def default_text_encoding(self):
        return self._global.defaultTextEncoding.decode('UTF-8')


Config = _GlobalParamsConfig()
Config.__doc__ = \
"""
Global XPDF config object

Methods
-------
Config.reset
    Reset the global configuration to default.

Config.load_file(cfg_path)
    load the settings from given `cfg_path` `xpdfrc`.


Attributes
----------
Config.text_encoding : str,
    Sets the encoding to use for text output. 'UTF-8', 'Latin1', 'ASCII7',
    'Symbol', 'ZapfDingbats', 'UCS-2' is pre defined. For more encodings
    support install ``pyxpdf_data`` package (see :ref:`Installation`).
    (default is `UTF-8`)

Config.text_eol : {'unix', 'dos', 'mac'}
    Sets the end-of-line convention to use for text output. The
    options are

    unix = LF

    dos  = CR+LF

    mac  = CR

    (default, platform dependent)

Config.text_page_breaks : bool
    If set to `True`, text extraction will insert page breaks (form
    feed characters) between pages.
    (default is True)

Config.text_keep_tiny : bool
    If set to `True`, text extraction will keep all characters. If
    set to "no", text extraction will discard tiny (smaller than 3
    point) characters after the first 50000 per page, avoiding
    extremely slow run times for PDF files that use special fonts to
    do shading or cross-hatching.
    (default is `True`)

Config.enable_freetype : bool
    Enables or disables use of FreeType (a TrueType/Type 1 font
    rasterizer).
    (default is `True`)

Config.anti_alias : bool
    Enables or disables font anti-aliasing in the PDF Output Devices.
    This option affects all font rasterizers.
    (default is `True`)

Config.vector_anti_alias : bool
    Enables or disables anti-aliasing of vector graphics in the PDF
    rasterizer.
    (default is 'True')

"""





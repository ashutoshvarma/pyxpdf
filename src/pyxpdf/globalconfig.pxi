from cython.operator cimport preincrement as inc, predecrement as dec

from libcpp.string cimport string
from pyxpdf.includes.GlobalParams cimport GlobalParams, globalParams, EndOfLineKind
from pyxpdf.includes.UnicodeMap cimport UnicodeMap


cdef class GlobalParamsConfig:
    cdef GlobalParams* _global

    def load_file(self, cfg_path):
        global globalParams
        # delete if already init
        if globalParams is not NULL:
            del globalParams

        if cfg_path == None:
            self._global = new GlobalParams(<const char*>NULL)
        else:
            self._global = new GlobalParams(_chars(cfg_path))

        if self._global == NULL:
            raise MemoryError("Cannot create GlobalParamsConfig object.")

        globalParams = self._global

    def reset(self):
        self.load_file(None)

    def __cinit__(self, cfg_path=None):
        self.load_file(cfg_path)

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
    def text_encoding(self):
        return GString_to_unicode(self._global.getTextEncodingName())

    @text_encoding.setter
    def text_encoding(self, encoding):
        cdef UnicodeMap* umap
        self._global.setTextEncoding(_chars(encoding.upper()))
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
        

    
Config = GlobalParamsConfig()
# default text encoding 
Config.text_encoding = 'utf-8'

    




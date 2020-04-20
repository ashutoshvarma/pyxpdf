__version__ = "0.1"

from pyxpdf.xpdf import pdftotext_raw, PDFError, Config
from pyxpdf.pdf import *

def pdftotext(pdf_file, start=1, end=0, layout="reading", ownerpass=None, userpass=None, cfg_file=None):
    """
    Extract text from pdf

    Args:
        pdf_file - path of pdf file
        start - (optional) Page to start (default - 1).
                Note: index start from 1
        end - (optional) Page to end (default - last page)
        layout - (optional) Text extraction layout (default - "reading")
                 Possible values :-
                 layout - Maintain (as best as possible) the original physical
                          layout  of the  text.
                 simple - Similar to -layout, but optimized for simple  one-column  pages.
                 table  - Table mode is similar to physical layout mode, but optimized for
                          tabular data, with the goal of keeping rows and columns  aligned
                          (at  the  expense of inserting extra whitespace).
                 lineprinter- the page is broken into  a  grid,  and characters  are  placed
                              into that grid.
                 raw   -  Keep the text in content stream order.  Depending on how the PDF
                          file was generated, this may or may not be useful.
                 reading- Keep the text in reading order.
        ownerpass - (optional) owner password (default - None)
        userpass - (optional) user password (default - None)
        cfg_file - (optional) XPDF Configuration file (default - None)

    Return:
        Unicode string
    
    Exceptions:
        `PDFError` - Base error for pyxpdf
    """
    return pdftotext_raw(pdf_file, start, end, layout, ownerpass, userpass, cfg_file).decode("UTF-8", errors="ignore")
__version__ = "0.0.1"

from pyxpdf.xpdf import pdftotext_raw, PDFError

def pdftotext(pdf_file, start=1, end=0, layout="reading", ownerpass=None, userpass=None, cfg_file=None):
    """
    Extract text from pdf

    Args:
        pdf_file - path of pdf file
        start - (optional) Page to start (default - 1).
                Note: index start from 1
        end - (optional) Page to end (default - last page)
        layout - (optional) Text extraction layout (default - "table")
        ownerpass - (optional) owner password (default - None)
        userpass - (optional) user password (default - None)
        cfg_file - (optional) XPDF Configuration file (default - None)

    Return:
        Unicode string
    
    Exceptions:
        `PDFError` - Base error for pyxpdf
    """
    return pdftotext_raw(pdf_file, start, end, layout, ownerpass, userpass, cfg_file).decode("UTF-8", errors="ignore")
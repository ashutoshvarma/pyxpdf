__version__ = "0.2.0"

from pyxpdf.xpdf import (
    pdftotext_raw, PDFError, Config, Document, Page
)

def pdftotext(pdf_file, start = 0, end = 0, ownerpass=None,
              userpass=None, layout = "reading", fixed_pitch=0,
              fixed_line_spacing=0, discard_clipped=False, discard_diagonal=False,
              insert_bom=False, margin_left=0, margin_right=0,
              margin_top=0, margin_bottom=0):
    """
    Extract text from pdf

    Args:
        pdf_file - path of pdf file
        start : (optional) Page to start (default - 1).
                Note: index start from 1
        end : (optional) Page to end (default - last page)
        layout : (optional) Text extraction layout (default - "reading")
                 Possible values :-
                 layout - Maintain (as best as possible) the original physical
                          layout  of the  text.
                 simple - Similar to -layout, but optimized for simple  one-column  pages.
                 table  - Table mode is similar to physical layout mode, but optimized for
                          tabular data, with the goal of keeping rows and columns  aligned
                          (at  the  expense of inserting extra whitespace).
                 lineprinter - the page is broken into  a  grid,  and characters  are  placed
                              into that grid.
                 raw    - Keep the text in content stream order.  Depending on how the PDF
                          file was generated, this may or may not be useful.
                 reading- Keep the text in reading order.
        fixed_pitch : Specify the character pitch (character width),  in  points,  for
                      physical  layout,  table, or lineprinter mode.  This is ignored
                      in all other modes.
        fixed_line_spacing : Specify the line spacing, in  points,  for  line  printer  mode.
                             This is ignored in all other modes.
        discard_clipped : Text which is hidden because of clipping is removed before doing
                    layout, and then added back in.  This can be helpful for  tables
                    where clipped (invisible) text would overlap the next column.
        discard_diagonal : Diagonal text, i.e., text that is not close to one of the 0, 90,
                           180, or 270 degree axes, is discarded.  This is useful  to  skip
                           watermarks drawn on top of body text, etc.
        insert_bom : Insert a Unicode byte order marker (BOM) at  the  start  of  the
                     text output.
        margin_[left, right, top, bottom] : Text within margin area is discarded.
        eol : Sets the end-of-line convention to use for text output.
        nopgbrk : Don't  insert  page breaks (form feed characters) between pages.
        ownerpass : (optional) owner password (default - None)
        userpass : (optional) user password (default - None)
        quiet : Don't print any messages or (xpdf) errors in stdout.
        cfg_file : (optional) XPDF Configuration file (default - None)

    Return:
        Unicode string

    Exceptions:
        `PDFError` - Base error for pyxpdf
    """
    return pdftotext_raw(**locals()).decode("UTF-8", errors="ignore")

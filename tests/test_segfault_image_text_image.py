"""
BUG: #9
Segmentation Fault when using `Document.text()` between `RawImageOutput.get()` calls

Observation:
`text()` and `text_bytes()` methods use `Document.display_pages()` wrapper method which
wrap the call to xpdf's `PDFDoc.displayPages()` cpp method which after running the loop
for `displayPage()` unloads the internal xpdf's `Page` Class by calling
`Catalog.doneWithPage()` cpp method.
But our wrapper Extension class `Page` keeps pointing to old pointer of xpdf's `Page`.
If you then do any operation involving them such as `displayPageSlice()` it causes
SEGFAULT.

Fix:
Changed the `Document.display_pages()` to just do the same as `displayPages()` except
unloading Pages.
"""

import unittest
from pathlib import Path

from pyxpdf import xpdf as x

# x.Config.print_commands = True


class Segfault_Image_Text_Image_TextCase(unittest.TestCase):
    def test_segfault_image_text_image(self):
        pdf = (Path(__file__).parents[1].absolute()) / "samples/nonfree/mandarin.pdf"
        doc = x.Document(pdf)

        # can be any PDFOutput except TextOutput
        iout = x.RawImageOutput(doc)

        iout.get(0)
        doc.text(end=1)
        iout.get(0)


def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(Segfault_Image_Text_Image_TextCase)])
    suite.level = 1
    return suite


if __name__ == "__main__":
    print("to test use test.py %s" % __file__)

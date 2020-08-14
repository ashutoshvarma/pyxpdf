import unittest

from pyxpdf.xpdf import Document, RawImageOutput, page_iterator

from .common_imports import InitGlobalTextCase, file_in_sample_dir


# TODO: add pillow image tests
class RawImageOutputTestCase(InitGlobalTextCase):
    pdfs = [
        file_in_sample_dir("poppler", "tests_jpeg.pdf"),
    ]

    img_modes = ["RGB", "RGBA", "L", "LA", "1", "CMYK"]

    def test_rawimageoutput(self):
        for pdf in self.pdfs:
            for mode in self.img_modes:
                imgout = RawImageOutput(
                    Document(pdf), mode, resolution=74, scale_before_rotation=True
                )
                for img in page_iterator(imgout, scale_pixel_box=(50, 50)):
                    pass


def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(RawImageOutputTestCase)])
    return suite


if __name__ == "__main__":
    print("to test use runtests.py %s" % __file__)

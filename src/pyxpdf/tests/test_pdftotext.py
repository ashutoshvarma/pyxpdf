import unittest
from io import open
from .common_imports import InitGlobalTextCase, PropertyTextCase, file_in_test_dir, file_in_sample_dir
from pyxpdf import pdftotext, pdftotext_raw, Config


class PTT_TestCase(InitGlobalTextCase):
    mandarin_pdf = file_in_sample_dir("nonfree", "mandarin.pdf")
    mandarin_txt = file_in_test_dir('mandarin_first.txt')
    def setUp(self):
        super(PTT_TestCase, self).setUp()
        with open(self.mandarin_txt, 'r', encoding="utf-8") as fp:
            self.text_raw = fp.read()

    def test_pdftotext_raw(self):
        text_raw = pdftotext_raw(self.mandarin_pdf, end=1)
        self.assertEqual(text_raw, self.text_raw.encode('utf-8'))

    def test_pdftotext(self):
        text_raw = pdftotext(self.mandarin_pdf, end=1)
        self.assertEqual(text_raw, self.text_raw)

def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(PTT_TestCase)])
    return suite


if __name__ == '__main__':
    print('to test use test.py %s' % __file__)

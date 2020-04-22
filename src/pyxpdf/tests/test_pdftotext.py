import unittest
from .common_imports import InitGlobalTextCase, PropertyTextCase, file_in_test_dir
from pyxpdf import pdftotext, pdftotext_raw, Config



class PTT_TestCase(InitGlobalTextCase):
    mandarin_pdf = 'samples/nonfree/mandarin.pdf'
    mandarin_txt = file_in_test_dir('mandarin_first.txt')
    def setUp(self):
        super().setUp()
        Config.text_eol = 'unix'
        with open(self.mandarin_txt, 'rb') as fp:
            self.text_raw = fp.read()

    def test_pdftotext_raw(self):
        text_raw = pdftotext_raw(self.mandarin_pdf, end=1)
        self.assertEqual(text_raw, self.text_raw)

    def test_pdftotext(self):
        text_raw = pdftotext(self.mandarin_pdf, end=1)
        self.assertEqual(text_raw, self.text_raw.decode('utf8'))

def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(PTT_TestCase)])
    return suite


if __name__ == '__main__':
    print('to test use test.py %s' % __file__)

# coding: utf8

import unittest
from .common_imports import InitGlobalTextCase, PropertyTextCase, file_in_test_dir
from pyxpdf.pdf import Document, Page
from pyxpdf.xpdf import Config


class PageTestCase(InitGlobalTextCase):
    mandarin_pdf = "samples/nonfree/mandarin.pdf"
    find_char = "通"
    find_result = [(
        122.69618999999997,
        149.79401400000003,
        132.71618999999998,
        160.57553400000006
    ),
    (
        282.53913,
        183.51330000000004,
        292.55913,
        194.11446
    ),
    (
        72.0, 
        473.912424, 
        82.02, 
        484.513584
    )
    ]

    def setUp(self):
        super().setUp()
        Config.text_encoding = 'utf-8'
        Config.text_eol = 'unix'
        self.doc = Document(self.mandarin_pdf)

    def test_page_text(self):
        with open(file_in_test_dir('mandarin_first.txt'), 'r', encoding='utf-8') as fp:
            self.assertEqual(self.doc[0].text(), fp.read())

    def test_page_find(self):
        self.assertEqual(self.find_result[0], self.doc[9].find_text(self.find_char))
        self.assertEqual(self.find_result[1], self.doc[9].find_text(self.find_char, direction="next"))
        self.assertEqual(self.find_result[2], self.doc[9].find_text(self.find_char, direction="next"))



def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(PageTestCase)])
    return suite

if __name__ == '__main__':
    print('to test use test.py %s' % __file__)
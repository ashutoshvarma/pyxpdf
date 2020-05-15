# coding: utf8

import unittest
from io import open
from .common_imports import InitGlobalTextCase, PropertyTextCase, file_in_test_dir, file_in_sample_dir
from pyxpdf.xpdf import Config, Document, Page


class PageTestCase(InitGlobalTextCase, PropertyTextCase):
    mandarin_pdf = file_in_sample_dir("nonfree", "mandarin.pdf")
    mandarin_prop = {
        'artbox': (0.0, 0.0, 612.0, 792.0),
        'bleedbox': (0.0, 0.0, 612.0, 792.0),
        'crop_height': 792.0,
        'crop_width': 612.0,
        'cropbox': (0.0, 0.0, 612.0, 792.0),
        'index': 0,
        'is_cropped': True,
        'label': '1',
        'media_height': 792.0,
        'media_width': 612.0,
        'mediabox': (0.0, 0.0, 612.0, 792.0),
        'rotation': 0,
        'trimbox': (0.0, 0.0, 612.0, 792.0)
    }

    find_char = u"通"
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
        super(PageTestCase, self).setUp()
        self.doc = Document(self.mandarin_pdf)

    def test_page_properties(self):
        for prop, val in self.mandarin_prop.items():
            self.assertProperty(self.doc[0], prop, val, setter=False)

    def test_page_text(self):
        with open(file_in_test_dir('mandarin_first.txt'), 'r', encoding='utf-8') as fp:
            self.assertEqual(self.doc[0].text(), fp.read())

    def test_page_find(self):
        self.assertEqual(self.find_result[0],
                         self.doc[9].find_text(self.find_char))
        self.assertEqual(self.find_result[1], self.doc[9].find_text(
            self.find_char, direction="next"))
        self.assertEqual(self.find_result[2], self.doc[9].find_text(
            self.find_char, direction="next"))


def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(PageTestCase)])
    return suite


if __name__ == '__main__':
    print('to test use test.py %s' % __file__)

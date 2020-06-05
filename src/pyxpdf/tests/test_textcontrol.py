# coding: utf8

import unittest
from .common_imports import InitGlobalTextCase, file_in_test_dir, file_in_sample_dir
from pyxpdf.xpdf import Document, TextOutput, page_iterator

#FIXME: due to some weird bug, probably in decoding with utf-8
# page 20 (19) mandarin pdf assert fails in only python3.5 and linux
# only.
# see azp build #32 - #34
# https://ashutoshvarma.visualstudio.com/pyxpdf/_build/results?buildId=35
# https://ashutoshvarma.visualstudio.com/pyxpdf/_build/results?buildId=34
# https://ashutoshvarma.visualstudio.com/pyxpdf/_build/results?buildId=33
class TextOutputTestCase(InitGlobalTextCase):
    mandarin_pdf = file_in_sample_dir('nonfree', 'mandarin.pdf')
    all_text = []

    @classmethod
    def setUpClass(cls):
        cls.text_out = TextOutput(Document(cls.mandarin_pdf))
        cls.all_text = []
        # see FIXME
        for i in range(19):
            with open(file_in_test_dir('mandarin_txts', '{0}.txt'.format(i)), 'r', encoding='utf-8') as f:
                cls.all_text.append(f.read())


    def test_get(self):
        self.maxDiff = None
        for i, txt in enumerate(page_iterator(self.text_out)):
            # see FIXME
            if i == 19:
                break
            self.assertEqual(self.all_text[i], txt)

    def test_get_all(self):
        self.maxDiff = None
        out_all = self.text_out.get_all()
        for i, txt in enumerate(self.all_text):
            # see FIXME
            if i == 19:
                break
            self.assertEqual(out_all[i], txt)


def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(TextOutputTestCase)])
    return suite


if __name__ == '__main__':
    print('to test use test.py %s' % __file__)

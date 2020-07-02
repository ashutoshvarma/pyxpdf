import unittest
import json
from .common_imports import InitGlobalTextCase, PropertyTextCase, file_in_test_dir, file_in_sample_dir
from pyxpdf.xpdf import Config, XPDFConfigError, Document, PDFImageOutput, page_iterator

#TODO: add pillow image tests
class PDFImageOutputTestCase(InitGlobalTextCase, PropertyTextCase):
    tests = [
        {
            'pdf'   :   file_in_sample_dir('poppler', 'tests_image.pdf'),
            'prop_file' : file_in_test_dir('image_props', 'tests_image_props.json')
        },
        {
            'pdf'   :   file_in_sample_dir('poppler', 'tests_inline_image.pdf'),
            'prop_file' : file_in_test_dir('image_props', 'tests_image_inline_props.json')
        },
        {
            'pdf'   :  file_in_sample_dir('poppler', 'tests_jpeg.pdf'),
            'prop_file' : file_in_test_dir('image_props', 'tests_jpeg_props.json')
        },
        # BUG: segfault when load tests_mask.pdf
        #{
        #    'pdf'   :   file_in_sample_dir('poppler', 'tests_mask.pdf'),
        #    'prop_file' : file_in_test_dir('image_props', 'tests_mask_props.json')
        #},
        {
            'pdf'   :   file_in_sample_dir('poppler', 'tests_mask_seams.pdf'),
            'prop_file' : file_in_test_dir('image_props', 'tests_mask_seams_props.json')
        }
    ]

    def fix_props(self, props):
        for prop in props:
            prop['bbox'] = tuple(prop['bbox'])
            del prop['image']
        return props

    def test_extracted_image_properties(self):
        for t in self.tests:
            iout = PDFImageOutput(Document(t['pdf']))
            with open(t['prop_file']) as f:
                img_props = self.fix_props(json.load(f))
                assert type(img_props) == list
                i = 0
                for imgs in page_iterator(iout):
                    for img in imgs:
                        self.assertPropertyDict(img, img_props[i])
                        i += 1

def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(PDFImageOutputTestCase)])
    return suite


if __name__ == '__main__':
    print('to test use runtests.py %s' % __file__)


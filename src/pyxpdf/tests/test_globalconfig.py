import unittest
from .common_imports import InitGlobalTextCase, PropertyTextCase
from pyxpdf.xpdf import Config, XPDFConfigError


class GlobalConfigTestCase(InitGlobalTextCase, PropertyTextCase):
    #TODO: add test for load_file
    
    def test_text_encoding(self):
        self.assertProperty(Config, 'text_encoding', 'utf-8'.upper())
        self.assertRaiseProperty(Config, 'text_encoding', 'ABC', exception=XPDFConfigError)

    def test_text_eol(self):
        eols = ("unix", "dos", "mac")
        for eol in eols:
            self.assertProperty(Config, 'text_eol', eol)
        self.assertRaiseProperty(Config, 'text_eol', "BAD_EOL", exception=XPDFConfigError)

    def test_text_page_breaks(self):
        self.assertProperty(Config, 'text_page_breaks', True)
        self.assertProperty(Config, 'text_page_breaks', False)

    def test_text_keep_tiny(self):
        self.assertProperty(Config, 'text_keep_tiny', True)
        self.assertProperty(Config, 'text_keep_tiny', False)

    def test_print_commands(self):
        self.assertProperty(Config, 'print_commands', True)
        self.assertProperty(Config, 'print_commands', False)

    def test_error_quiet(self):
        self.assertProperty(Config, 'error_quiet', True)
        self.assertProperty(Config, 'error_quiet', False)


def test_suite():
    suite = unittest.TestSuite()
    suite.addTests([unittest.makeSuite(GlobalConfigTestCase)])
    return suite

if __name__ == '__main__':
    print('to test use test.py %s' % __file__)
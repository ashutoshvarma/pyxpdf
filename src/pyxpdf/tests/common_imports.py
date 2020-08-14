import os
import unittest

from pyxpdf.xpdf import Config

TEST_DIR = os.path.dirname(os.path.realpath(__file__))
ROOT_DIR = os.sep.join(TEST_DIR.split(os.sep)[:-3])
SAMPLE_DIR = os.path.join(ROOT_DIR, "samples")


class InitGlobalTextCase(unittest.TestCase):
    def setUp(self):
        Config.reset()
        Config.text_eol = "unix"
        Config.error_quiet = True

    def tearDown(self):
        Config.reset()


class PropertyTextCase(unittest.TestCase):
    def assertProperty(
        self, parent, property, assert_value, set_value=None, setter=True
    ):
        if setter:
            if not set_value:
                set_value = assert_value
            setattr(parent, property, set_value)
        prop = getattr(parent, property)
        self.assertEqual(assert_value, prop)

    def assertRaiseProperty(self, parent, property, value, exception=Exception):
        with self.assertRaises(exception):
            setattr(parent, property, value)

    def assertPropertyDict(self, parent, property_dict):
        for k, v in property_dict.items():
            self.assertProperty(parent, k, v, setter=False)


def file_in_test_dir(*args):
    return os.path.join(TEST_DIR, *args)


def file_in_sample_dir(*args):
    return os.path.join(SAMPLE_DIR, *args)


def has_pyxpdf_data():
    try:
        import pyxpdf_data
    except ImportError:
        return False
    return True

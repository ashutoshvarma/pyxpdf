import unittest
from pyxpdf.xpdf import Config, GlobalParamsConfig

class InitGlobalTextCase(unittest.TestCase):
    def setUp(self):
        Config.reset()

    def tearDown(self):
        Config.reset()

class PropertyTextCase(unittest.TestCase):
    def assertProperty(self, parent, property, assert_value, set_value=None, setter=True):
        with self.subTest("Test setter and getter."):
            if setter:
                if not set_value:
                    set_value = assert_value
                setattr(parent, property, set_value)
            prop = getattr(parent, property)
            self.assertEqual(assert_value, prop)

    def assertRaiseProperty(self, parent, property, value, exception=Exception):
        with self.subTest("Test setter and getter with wrong value."):
            with self.assertRaises(exception):
                setattr(parent, property, value)


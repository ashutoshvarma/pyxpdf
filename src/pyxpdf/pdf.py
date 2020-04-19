# distutils: language=c++
# cython: language_level=2
# cython: profile=True

from __future__ import absolute_import
from __future__ import print_function

from pyxpdf.xpdf import XPDFDoc, XPage, TextControl, PDFError


class Document:
    _pages_cache = []

    def __init__(self, pdf, ownerpass=None, userpass=None):
        self.xdoc = XPDFDoc(pdf, ownerpass, userpass)
        self.filename = self.xdoc.filename

        # build empty cache
        self._pages_cache = [None] * self.num_pages

    def __repr__(self):
        fname = "Stream" if self.filename == "" else self.filename
        return "<Document [{fname}]>".format(fname=fname)

    def __str__(self):
        fname = "Stream" if self.filename == "" else self.filename
        return "<Document [{fname}] [{pages}]>".format(fname=fname, pages=self.num_pages)

    def __len__(self):
        return self.num_pages

    def __getitem__(self, key):
        if isinstance(key, str):
            pgno = self.xdoc.label_to_index(key)
            if pgno == -1:
                raise KeyError(
                    "Could not find page with label '{key}'".format(key=key))
            return self.get_page(pgno)
        elif isinstance(key, int):
            # handle neg key
            if key < 0:
                key += len(self)
            return self.get_page(key)
        elif isinstance(key, slice):
            # Return the list of Pages
            return [self[i] for i in range(*key.indices(len(self)))]
        else:
            raise TypeError("Invalid Key type")

    def __iter__(self):
        return PageIterator(self)

    def get_page(self, idx):
        if idx < 0 or idx >= len(self):
            raise IndexError(
                "The index {idx} is out of page range".format(idx=idx))
        # load page in cache if not present
        if self._pages_cache[idx] == None:
            self._pages_cache[idx] = Page(self.xdoc.get_page(idx))
        return self._pages_cache[idx]

    def text(self, start=0, end=-1, control=None):
        return self.xdoc.text_raw(start=start, end=end, control=control
                                  ).decode('UTF-8', errors='ignore')

    @property
    def num_pages(self):
        return self.xdoc.num_pages

    @property
    def pdf_version(self):
        return self.xdoc.pdf_version

    @property
    def is_linearized(self):
        return self.xdoc.is_linearized

    @property
    def ok_to_copy(self):
        return self.xdoc.ok_to_copy

    def info(self):
        return self.xdoc.info_dict()

    def xmp_metadata(self):
        return self.xdoc.metadata()


class PageIterator:
    def __init__(self, doc):
        self.doc = doc
        self.index = -1

    def __iter__(self):
        return self

    def __next__(self):
        self.index += 1
        if self.index >= len(self.doc):
            raise StopIteration()
        return self.doc[self.index]


class Page:
    def __init__(self, xpage):
        if not isinstance(xpage, XPage):
            raise TypeError("'xpage' arg must be a XPage object")

        self.xpage = xpage
        self.index = xpage.index
        self.label = self.xpage.label

    def __repr__(self):
        if self.label == None:
            return "<Page[{index}]>".format(index=self.index)
        else:
            return "<Page[{index}](label='{label}')>".format(index=self.index, label=self.label)

    @property
    def rotation(self):
        return self.xpage.rotation

    @property
    def is_cropped(self):
        return self.xpage.is_cropped

    @property
    def media_height(self):
        return self.xpage.media_height

    @property
    def media_width(self):
        return self.xpage.media_width

    @property
    def crop_height(self):
        return self.xpage.crop_height

    @property
    def crop_width(self):
        return self.xpage.crop_width

    @property
    def mediabox(self):
        return self.xpage.mediabox

    @property
    def cropbox(self):
        return self.xpage.cropbox

    @property
    def bleedbox(self):
        return self.xpage.bleedbox

    @property
    def trimbox(self):
        return self.xpage.trimbox

    @property
    def artbox(self):
        return self.xpage.artbox

    def btext(self, text_area=None, control=None):
        return self.xpage.text_raw(text_area, control)

    def text(self, text_area=None, control=None):
        return self.xpage.text_raw(text_area, control).decode('UTF-8', errors='ignore')

    def find_text(self, text, search_box=None, direction="top", case_sensitive=False,
                  wholeword=False, rotation=0):
        result = None
        if direction == "top":
            result = self.xpage.find_text(text, search_box, True, True, False, False,
                                          case_sensitive, False, wholeword, rotation)
        if direction == "next":
            result = self.xpage.find_text(text, search_box, False, True, True, False,
                                          case_sensitive, False, wholeword, rotation)
        if direction == "previous":
            result = self.xpage.find_text(text, search_box, False, True, True, False,
                                          case_sensitive, True, wholeword, rotation)
        return result

    def find_all_text(self, text, search_box=None, case_sensitive=False, wholeword=False,
                      rotation=0):
        res = self.find_text(text, search_box, "top",
                             case_sensitive, wholeword)
        while res:
            yield res
            res = self.find_text(text, search_box, "next",
                                 case_sensitive, wholeword)

# distutils: language=c++
# cython: language_level=2
# cython: profile=True

from __future__ import absolute_import
from __future__ import print_function

from pyxpdf.xpdf import XPDFDoc, XPage, TextControl, PDFError


class Document:
    def __init__(self, pdf, ownerpass=None, userpass=None):
        self.xdoc = XPDFDoc(pdf, ownerpass, userpass)
        self.filename = self.xdoc.filename

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
            xpage = self.xdoc.get_page_from_label(key)
            if xpage == None:
                raise KeyError(
                    "Could not find page with label '{key}'".format(key=key))
            return Page(xpage)
        elif isinstance(key, int):
            # handle neg key
            if key < 0:
                key += len(self)
            if key < 0 or key >= len(self):
                raise IndexError(
                    "The index {key} is out of page range".format(key=key))
            return Page(self.xdoc.get_page(key))
        elif isinstance(key, slice):
            # Return the list of Pages
            return [self[i] for i in range(*key.indices(len(self)))]
        else:
            raise TypeError("Invalid Key type")

    def __iter__(self):
        return PageIterator(self)

    def get_page(self, idx):
        return self[idx]

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

    def btext(self, text_area=None, control=None):
        return self.xpage.text_raw(text_area, control)

    def text(self, text_area=None, control=None):
        return self.xpage.text_raw(text_area, control).decode('UTF-8', errors='ignore')

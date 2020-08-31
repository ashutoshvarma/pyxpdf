pyxpdf changelog
================

.. begin changelog

0.2.3 (2020-08-31)
-------------------

- Config: make :any:`Config.cfg_path` public attribute
- Document: add support for :class:`~pathlib.Path` for loading pdf
- pyxpdf_data: add 35 base Postscript fonts from ghostscript

**Bugs Fixed**

- Fix #9: segfault using :meth:`~pyxpdf.xpdf.Document.text()`
- Fix #8: add checks for file in :any:`Config.add_font_file()`

0.2.2 (2020-07-03)
------------------

- Config: add function to add missing fonts :any:`Config.add_font_file()`
- Introduce :class:`~pyxpdf.xpdf.PDFImage` to represent a PDF Image.
- PDFImageOutput: :meth:`~pyxpdf.xpdf.PDFImageOutput.get` returns :class:`~pyxpdf.xpdf.PDFImage`
  instead of Pillow :class:`Image`

0.2.1 (2020-06-12)
------------------

**Bugs Fixed**

- fix all direct memory leaks
- Config: fix :any:`Config.text_encoding` setter, encodings with lowercase 
  characters were not able to set.
- fix weird bytes encoding problem in python debug builds

0.2.0 (2020-06-11)
------------------

- Python 2.7 support dropped
- 2 optional dependencies (`Pillow <https://pillow.readthedocs.io/>`_,
  `pyxpdf_data <https://github.com/ashutoshvarma/pyxpdf_data>`_)  
  introduced 

**New Features**

- Introduce (optional) package 
  `pyxpdf_data <https://github.com/ashutoshvarma/pyxpdf_data>`_ which
  add more encoding support.
- API: add specialised classes for pdf outputs,
  `PDFOuputDevice <https://pyxpdf.readthedocs.io/en/latest/api/pdfoutputdevice/index.html>`_.

    - **TextOutput** - For Text extraction
    - **RawImageOutput** - Render PDF Page as Image
    - **PDFImageOutput** - Extract images from PDF

- Config: add new global settings: 
    - :any:`Config.anti_alias` 
    - :any:`Config.enable_freetype` 
    - :any:`Config.vector_anti_alias`

**Bugs Fixed**

- pdftotext: extracted text contains clipped text even when explictly
  discarding it.

- Config: fix loading of external xdfrc with :any:`Config.load_file()` 

0.1.1 (2020-05-10)
------------------

- FIX: default :any:`Config.text_encoding` value i.e UTF-8
  does not persist :any:`Config.reset()` and changes to Latin1.

- pdftotext: remove all parameters that change global :data:`~pyxpdf.xpdf.Config`
  properties.


0.1 (2020-04-20)
----------------

Initial stable release.

.. end changelog


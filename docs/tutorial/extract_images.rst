Extract images from pdf file
============================

:class:`~pyxpdf.xpdf.PDFImageOutput` can extract `LZW`, `Run Length`, 
`CCITTFax`, `DCT`, `JBIG2`, `JPX` compressed  images and image masks.

.. code-block:: python

    from pyxpdf import Document
    from pyxpdf.xpdf import PDFImageOutput, page_iterator

    # https://www.mlcjapanese.co.jp/Download/HiraganaKatakanaWorksheet.pdf
    doc = Document("HiraganaKatakanaWorksheet.pdf")
    pdfimages_out = PDFImageOutput(doc)

    for images in page_iterator(pdfimages_out):
        print(images)


Output
------

.. code-block:: bash

    [<PIL.Image.Image image mode=RGB size=140x134 at 0x7F55765BAA00>, <PIL.Image.Image image mode=RGB size=100x43 at 0x7F55765BAE50>]
    [<PIL.Image.Image image mode=RGB size=80x34 at 0x7F55765BA820>, <PIL.Image.Image image mode=RGB size=653x305 at 0x7F557C162220>]
    [<PIL.Image.Image image mode=RGB size=80x34 at 0x7F55765BAE50>, <PIL.Image.Image image mode=RGB size=70x42 at 0x7F55765BA730>, <PIL.Image.Image image mode=RGB size=68x41 at 0x7F55765BA160>]
    ...


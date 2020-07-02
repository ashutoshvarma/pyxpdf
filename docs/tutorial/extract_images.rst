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

    [<pyxpdf.xpdf.PDFImage type=image compression=flate colorspace=icc bbox=(239.4, 539.45, 286.4, 588.45)>, <pyxpdf.xpdf.PDFImage type=image compression=flate colorspace=icc bbox=(147.35000000000002, 612.9459999999999, 163.35000000000002, 650.9459999999999)>]
    [<pyxpdf.xpdf.PDFImage type=image compression=flate colorspace=icc bbox=(292.75, 27.14999999999993, 304.75, 57.149999999999935)>, <pyxpdf.xpdf.PDFImage type=image compression=flate colorspace=icc bbox=(152.25, 179.24999999999994, 252.25, 393.24999999999994)>]
    [<pyxpdf.xpdf.PDFImage type=image compression=flate colorspace=icc bbox=(292.75, 27.14999999999993, 304.75, 57.149999999999935)>, <pyxpdf.xpdf.PDFImage type=image compression=jpeg colorspace=icc bbox=(174.85000000000002, 263.99, 188.85000000000002, 286.99)>, <pyxpdf.xpdf.PDFImage type=image compression=jpeg colorspace=icc bbox=(222.3, 264.59, 236.3, 287.59)>]
    ...


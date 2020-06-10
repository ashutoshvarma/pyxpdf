.. _api_pdfoutputdevice:

Output Devices
==================

Output devices process PDF :class:`~pyxpdf.xpdf.Page` and generate/extract
resources from them.

All the Output devices inherit from base Output Device:

.. autoclass:: pyxpdf.xpdf.PDFOutputDevice
   :members:


Currently there are three Output devices implemented:

.. toctree::
   :maxdepth: 1
   
   textoutput
   rawimageoutput
   pdfimageoutput



Page Iterator
-------------

To iterate over a PDF Output Device page wise, we have `page_iterator`:

.. autoclass:: pyxpdf.xpdf.page_iterator


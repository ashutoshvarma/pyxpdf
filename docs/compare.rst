Speed Comparsion
================
Thanks to the brillant `xpdf reader`_ sources and the fact that pyxpdf is 
written in `cython`_ as Python C-API module makes it much faster than pure
python based pdf parsers.

Text Extraction
---------------

Comparing text extraction (while maintaining layout) speed with popular 
`pdfminer.six`_ module.

    `Running Python 3.6.9, gcc (Ubuntu 7.5.0-3ubuntu1~18.04) 7.5.0, 
    Ubuntu 18.04, 
    on Azure Standard B2ms (2 vcpus, 8 GiB memory) 
    [Intel(R) Xeon(R) Platinum 8171M CPU @ 2.60GHz]`


.. code-block:: bash

    'pdfminer_text' took: 0.9271 sec
    'pyxpdf_text' took: 0.0424 sec

    'pdfminer_text_100mb' took: 7.2833 sec
    'pyxpdf_text_100mb' took: 0.3301 sec

    'pdfminer_text_500mb' took: 36.5288 sec
    'pyxpdf_text_500mb' took: 0.9786 sec

======  ============    ==========  ============
Size    pdfminer.six    pyxpdf      times faster
======  ============    ==========  ============
1 MB    0.9271 sec      0.0424 sec  x21
100 MB  7.2833 sec      0.3301 sec  x22
500 MB  36.5288 sec     0.9786 sec  x37
======  ============    ==========  ============

**pyxpdf is atleast x20 times faster**

.. _cython: https://cython.org/
.. _xpdf reader: https://www.xpdfreader.com/about.html
.. _pdfminer.six: https://pdfminersix.readthedocs.io/en/latest/

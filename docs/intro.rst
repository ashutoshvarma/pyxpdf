Getting started
===============

``pyxpdf`` is a wrapper on `xpdf reader <https://www.xpdfreader.com/about.html>`_
sources.

It aims to provide a fast and memory efficient pdf parser with easy to use API.

Installation
------------

.. code-block:: bash

    pip install pyxpdf

For additional encodings support, install optional dependency
`pyxpdf_data <https://github.com/ashutoshvarma/pyxpdf_data>`_

.. code-block:: bash

    pip install pyxpdf_data

For Image extraction and pdf to image support, install optional dependency
`Pillow <https://pillow.readthedocs.io/en/stable/>`_

.. code-block:: bash

    pip install Pillow

Quick Start
-----------

``pyxpdf`` use :class:`~pyxpdf.xpdf.Document` to represent and load a PDF file.
Similary :class:`~pyxpdf.xpdf.Page` for PDF Page.

All the xpdf related settings can be accessed with global :data:`~pyxpdf.xpdf.Config`
object.

.. code-block:: python

    from pyxpdf import Document, Page, Config
    from pyxpdf.xpdf import TextControl

    doc = Document("samples/nonfree/mandarin.pdf")
    # or
    # load pdf from file like object
    with open("samples/nonfree/mandarin.pdf", 'rb') as fp:
        doc = Document(fp)

    # get pdf metadata dict
    print(doc.info())
    # >>> doc.info()
    # {'CreationDate': "D:20080721141207-04'00'", 
    #  'Subject': 'Chinese Version of Universal PCXR8 ...', 
    #  'Author': 'SKC Inc.', 
    #  'Creator': 'PScript5.dll
    #   .....

    # get all text
    all_text = doc.text()

    # iter first 10 pages
    for page in doc[:10]:
        # get page label if any
        print(page.label)

    # get page by page label
    label_page = doc['1']

    # get text in table layout without discarding clipped
    # text.
    text_control = TextControl("table", discard_clipped=True)
    text = label_page.text(control=text_control)

    # find case sensitive text within [x_min, y_min, x_max, y_max]
    res_box = label_page.find_text('操作说明', search_box=[0, 0, 400, 400],
                                    case_sensitive=True)
    # >>> print(res_box)
    # (281.88, 269.718, 354.05819999999994, 287.7)

    # load xpdfrc
    Config.load_file('my_xpdfrc')
    # suppress stderr output for xpdf error log.
    Config.error_quiet = False

Checkout :doc:`api/index` for more details.



.. todo::

   Add bechmark and speed comparison with python pdf modules

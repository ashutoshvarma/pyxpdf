Extract text from pdf while maintaining layout
==============================================

1. Using ``text()`` method for :class:`~pyxpdf.xpdf.Document` and 
   :class:`~pyxpdf.xpdf.Page`:

.. code-block:: python

    from pyxpdf import Document
    from pyxpdf.xpdf import TextOutput, TextControl

    # http://www.kurims.kyoto-u.ac.jp/~terui/pssj.pdf
    # Install 'pyxpdf_data', needed for additional encodings (japanese)
    doc = Document("pssj.pdf")

    control = TextControl(mode = "physical")
    for page in doc:
        txt = page.text(control=control)
        print(txt)


2. Using :class:`~pyxpdf.xpdf.TextOutput`:

.. code-block:: python
    
    from pyxpdf import Document
    from pyxpdf.xpdf import TextOutput, TextControl, page_iterator

    # http://www.kurims.kyoto-u.ac.jp/~terui/pssj.pdf
    # Install 'pyxpdf_data', needed for additional encodings (japanese)
    doc = Document("pssj.pdf")

    control = TextControl(mode = "physical")
    text_out = TextOutput(doc, control)

    for pg_txt in page_iterator(text_out):
        print(pg_txt)


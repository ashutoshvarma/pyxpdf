pyxpdf
======
pyxpdf is a fast and memory efficient python module for parsing PDF documents based on xpdf reader sources.


.. start-badges

.. list-table::
    :stub-columns: 1

    * - docs
      - |docs|
    * - tests
      - |azure| |travis| |codecov| 
    * - package
      - |pypi| |pythonver| |wheel| |downloads|
    * - license
      - |license|

.. end-badges

Features
--------
- Almost x20 times faster than pure python based pdf parsers (see `Speed Comparison`_)
- Extract text while maintaining original document layout (best possible)
- Support almost all PDF encodings, CMaps and predefined CMaps.
- Extract LZW, RLE, CCITTFax, DCT, JBIG2 and JPX compressed images and image masks along with their BBox.
- Render PDF Pages as image with support of '1', 'L', 'LA', 'RGB', 'RGBA' and 'CMYK' color modes.
- No explict dependencies (except optional ones, see `Installation`_)
- Thread Safe

More Information
----------------

- `Documentation <https://pyxpdf.readthedocs.io/>`_

  - `Installation`_
  - `Quickstart <https://pyxpdf.readthedocs.io/en/latest/intro.html#quick-start>`_

- `Contribute <https://github.com/ashutoshvarma/pyxpdf/blob/master/.github/CONTRIBUTING.md>`_

  - `Build <https://github.com/ashutoshvarma/pyxpdf/blob/master/BUILD.rst>`_
  - `Issues <https://github.com/ashutoshvarma/pyxpdf/issues>`_
  - `Pull requests <https://github.com/ashutoshvarma/pyxpdf/pulls>`_

- `Speed Comparison`_

- `Changelog <https://pyxpdf.readthedocs.io/en/latest/changelog.html>`_

License
-------
``pyxpdf`` is licensed under the GNU General Public License (GPL), version 3. See the `LICENSE <https://github.com/ashutoshvarma/pyxpdf/blob/master/LICENSE>`_

Credits
-------
- `xpdf reader <https://www.xpdfreader.com/>`_ by Derek Noonburg
- `lxml <https://www.github.com/lxml/lxml>`_ - project structure and build adapted from lxml
- `poppler <https://poppler.freedesktop.org/>`_ project

.. _`Speed Comparison`: https://pyxpdf.readthedocs.io/en/latest/compare.html
.. _`Installation`: https://pyxpdf.readthedocs.io/en/latest/intro.html#installation

.. |azure| image:: https://img.shields.io/azure-devops/build/ashutoshvarma/pyxpdf/1/master?label=Azure%20Pipelines&style=for-the-badge   
   :alt: Azure DevOps builds (branch)
   :target: https://ashutoshvarma.visualstudio.com/pyxpdf/_build
.. |travis| image:: https://img.shields.io/travis/com/ashutoshvarma/pyxpdf?label=Travis&style=for-the-badge   
   :alt: Travis (.com)
   :target: https://travis-ci.com/github/ashutoshvarma/pyxpdf     
.. |docs| image:: https://img.shields.io/readthedocs/pyxpdf?style=for-the-badge         
   :alt: Read the Docs
   :target: https://pyxpdf.readthedocs.io/en/latest/
          
.. |codecov| image:: https://img.shields.io/codecov/c/github/ashutoshvarma/pyxpdf?style=for-the-badge   
   :alt: Codecov
   :target: https://codecov.io/gh/ashutoshvarma/pyxpdf/
             
.. |license| image:: https://img.shields.io/github/license/ashutoshvarma/pyxpdf?style=for-the-badge   
   :alt: GitHub
   :target: https://github.com/ashutoshvarma/pyxpdf/blob/master/LICENSE
             
.. |pypi| image:: https://img.shields.io/pypi/v/pyxpdf?color=light&style=for-the-badge   
   :alt: PyPI
   :target: https://pypi.org/project/pyxpdf/

.. |pythonver| image:: https://img.shields.io/pypi/pyversions/pyxpdf?style=for-the-badge   
   :alt: PyPI - Python Version
   :target: https://pypi.org/project/pyxpdf/

.. |wheel| image:: https://img.shields.io/pypi/wheel/pyxpdf?style=for-the-badge   
   :alt: PyPI - Wheel
   :target: https://pypi.org/project/pyxpdf/
           
.. |downloads| image:: https://img.shields.io/pypi/dm/pyxpdf?label=PyPI%20Downloads&style=for-the-badge   
   :alt: PyPI - Downloads
   :target: https://pypi.org/project/pyxpdf/

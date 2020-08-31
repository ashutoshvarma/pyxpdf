How to build pyxpdf from source
===============================

We are using pre-compiled `libxpdf <https://github.com/ashutoshvarma/libxpdf>`_
for given platforms :-

- Windows (both x86 and x86_64)
- Linux (both x86 and x86_64)
- macOS (only x86_64)

If you want to build ``pyxpdf`` for other platforms or want to debug libxpdf you can use ``--build-libxpdf`` flag for setup.py which will build lib using cmake.


The entire build system and folder structure is adpated from lxml project, so you might see some similarities.

.. contents::
..
   1 Cython
   2 C++ 
   3 Building the sources
   4 Running the tests and reporting errors
   5 Building an egg or wheel
   6 Building on Windows

Cython
------

.. _pip: http://pypi.python.org/pypi/pip
.. _Cython: http://cython.org
.. _wheel: https://wheel.readthedocs.io/en/latest/

The ```pyxpdf.xpdf`` module is written in Cython_. Since we distribute The
Cython-generated .cpp files with pyxpdf releases, however, you do not 
need Cython to build pyxpdf from the normal release sources.  We recommend you to build pyxpdf without Cython if you want a reliable build of pyxpdf, since the pre-generated release sources were tested and therefore are known
to work.

So, if you want a reliable build of pyxpdf, we suggest to a) use a
source release of pyxpdf and b) disable or uninstall Cython for the
build. 

*Only* if you are interested in building pyxpdf from a checkout of the
developer sources (e.g. to test a bug fix that has not been release
yet), then you do need a working Cython installation.  You can use pip_ 
to install it::

    pip install -r test_requirements.txt

https://github.com/ashutoshvarma/pyxpdf/blob/master/test_requirements.txt


C++
---

pyxpdf has some c++ sources to extend the libxpdf like ``BitmapoutputDev`` which is used in ``PDFImageOutput`` output device. C++ sources are located in src/pyxpdf/cpp folder and are c++14 standard compliant.


Building the sources
---------------------

Clone the source repository (or download the `source tar-ball`_ and unpack
it) and then type::
    
    python setup.py build

or::
    
    python setup.py bdist_egg       # requires `setuptools` or `distribute`

To (re-)build the C sources with Cython, you must additionally pass the option ``--with-cython``::

    python setup.py build --with-cython

If you want to test pyxpdf from the source directory, it is better to 
build it in-place like this::

  python setup.py build_ext -i --with-cython

or, in Unix-like environments::

  make inplace

To speed up the build in test environments (e.g. on a continuous
integration server), set the ``CFLAGS`` environment variable to
disable C compiler optimisations (e.g. "-O0" for gcc, that's
minus-oh-zero), for example::

  CFLAGS="-O0"  make inplace


To use pyxpdf.xpdf in-place, you can place pyxpdf's ``src`` directory
on your Python module search path (PYTHONPATH) and then import
``pyxpdf.xpdf`` to play with it::

  # cd pyxpdf
  # PYTHONPATH=src python
  Python 3.8.0
  Type "help", "copyright", "credits" or "license" for more information.
  >>> from pyxpdf import xpdf
  >>>

To make sure everything gets recompiled cleanly after changes, you can
run ``make clean`` or delete the file ``src/pyxpdf/xpdf.cpp``.


Running the tests and reporting errors
--------------------------------------

The source distribution (tgz) and the source repository contain a test
suite for pyxpdf.  You can run it from the top-level directory::

  python runtests.py

The test script will first search pyxpdf in site-packages and then in-placebuild (see distutils building above). You can use the following one-step command to trigger an in-place build and test it::

  make test

If the tests give failures, errors, or worse, segmentation faults, 
we'd really like to know.  Please open a issue in Github with the version
of pyxpdf and Python you were using, as well as your operating system 
type (Linux, Windows, MacOS-X, ...).


Building an egg or wheel
------------------------

This is the procedure to make an pyxpdf egg or wheel_ for your platform.
It assumes that you have ``setuptools`` or ``distribute`` installed,
as well as the ``wheel`` package.

First, download the pyxpdf-x.y.tar.gz release. This contains the 
pregenerated CXX files so that you can be sure you build exactly from the 
release sources or you can git clone.
Unpack them and ``cd`` into the resulting directory. Then, to build a wheel
,simply run the command

::

  python setup.py bdist_wheel


The resulting .whl file will be written into the ``dist`` directory.

To build an egg file, run

::

  python setup.py build_egg

If you are on a Unix-like platform, you can first build the extension modules
using

::

  python setup.py build

and then ``cd`` into the directory ``build/lib.your.platform`` to call
``strip`` on any ``.so`` file you find there.  This reduces the size of
the binary distribution considerably.  Then, from the package root directory,
call

::

  python setup.py bdist_egg

This will quickly package the pre-built packages into an egg file and
drop it into the ``dist`` directory.



Building on Windows
-------------------

.. _MSVC: https://visualstudio.microsoft.com/downloads/

In Windows, its recommend to use latest `MSVC`_ or the version that support
C++14 standard completely and report `__cplusplus` macro correctly





PYTHON?=python
PYTHON2?=python2
TESTFLAGS=-p -v
TESTOPTS=
SETUPFLAGS=
PYXPDFVERSION:=$(shell sed -ne '/__version__/s|.*__version__\s*=\s*"\([^"]*\)".*|\1|p' src/pyxpdf/__init__.py)

PARALLEL:=$(shell $(PYTHON) -c 'import sys; print("-j7" if sys.version_info >= (3, 5) else "")' )
PARALLEL2:=$(shell $(PYTHON2) -c 'import sys; print("-j7" if sys.version_info >= (3, 5) else "")' )
PYTHON_WITH_CYTHON:=$(shell $(PYTHON)  -c 'import Cython.Build.Dependencies' >/dev/null 2>/dev/null && echo " --with-cython" || true)
PY2_WITH_CYTHON:=$(shell $(PYTHON2) -c 'import Cython.Build.Dependencies' >/dev/null 2>/dev/null && echo " --with-cython" || true)
CYTHON_WITH_COVERAGE:=$(shell $(PYTHON) -c 'import Cython.Coverage; import sys; assert not hasattr(sys, "pypy_version_info")' >/dev/null 2>/dev/null && echo " --coverage" || true)
CYTHON2_WITH_COVERAGE:=$(shell $(PYTHON2) -c 'import Cython.Coverage; import sys; assert not hasattr(sys, "pypy_version_info")' >/dev/null 2>/dev/null && echo " --coverage" || true)


.PHONY: all inplace inplace2 rebuild-sdist sdist build require-cython wheel_manylinux wheel

all: inplace

# Build in-place
inplace:
	$(PYTHON) setup.py $(SETUPFLAGS) build_ext -i $(PYTHON_WITH_CYTHON) --warnings --with-coverage $(PARALLEL)

inplace2:
	$(PYTHON2) setup.py $(SETUPFLAGS) build_ext -i $(PY2_WITH_CYTHON) --warnings --with-coverage $(PARALLEL2)

rebuild-sdist: require-cython
	rm -f dist/pyxpdf-$(PYXPDFVERSION).tar.gz
	find src -name '*.c' -exec rm -f {} \;
	$(MAKE) dist/pyxpdf-$(PYXPDFVERSION).tar.gz

dist/pyxpdf-$(PYXPDFVERSION).tar.gz:
	$(PYTHON) setup.py $(SETUPFLAGS) sdist $(PYTHON_WITH_CYTHON)

sdist: dist/pyxpdf-$(PYXPDFVERSION).tar.gz

build:
	$(PYTHON) setup.py $(SETUPFLAGS) build $(PYTHON_WITH_CYTHON)

require-cython:
	@[ -n "$(PYTHON_WITH_CYTHON)" ] || { \
	    echo "NOTE: missing Cython - please use this command to install it: $(PYTHON) -m pip install Cython"; false; }

wheel:
	$(PYTHON) setup.py $(SETUPFLAGS) bdist_wheel $(PYTHON_WITH_CYTHON)

clean:
	find . \( -name '*.o' -o -name '*.so' -o -name '*.py[cod]' -o -name '*.dll' \) -exec rm -f {} \;
	rm -rf build

realclean: clean 
	find src -name '*.cpp' -exec rm -f {} \;
	rm -f TAGS
	$(PYTHON) setup.py clean -a --without-cython
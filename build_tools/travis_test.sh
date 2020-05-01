#!/bin/bash

set -ex

# setup env
if [ -r /usr/lib/libeatmydata/libeatmydata.so ]; then
  # much faster package installation
  export LD_PRELOAD='/usr/lib/libeatmydata/libeatmydata.so'
elif [ -r /usr/lib/*/libeatmydata.so ]; then
  # much faster package installation
  export LD_PRELOAD='/usr/$LIB/libeatmydata.so'
fi


# travis venv tests override python
PYTHON=${PYTHON:-python}
PIP=${PIP:-pip}

if [ -n "$PYTHON_OPTS" ]; then
  PYTHON="${PYTHON} $PYTHON_OPTS"
fi

# make some warnings fatal, mostly to match windows compilers
werrors="-Werror=vla -Werror=nonnull -Werror=pointer-arith"
werrors="$werrors -Werror=implicit-function-declaration"

# build with c++14 by default
# setupinfo.py will load extra_compile_args from env CFLAGS
# but still setting CPPFLAGS for future proofing.
export CFLAGS="-std=c++14"
export CPPFLAGS="-std=c++14"

setup_base()
{
  # use default python flags but remove sign-compare
  sysflags="$($PYTHON -c "from distutils import sysconfig; \
    print (sysconfig.get_config_var('CFLAGS'))")"
  export CFLAGS=$CFLAGS" $sysflags $werrors -Wlogical-op -Wno-sign-compare"
 
  # Using 'pip install' also has the advantage that it tests that pyxpdf 
  # is 'pip install' compatible,
  $PIP install -vv . 2>&1 | tee log
}

run_test()
{
  # Install the test dependencies.
  $PIP install -r test_requirements.txt


  export PYTHONWARNINGS=default

  # Ideally we should change dir so that tests don't find
  # local pyxpdf but due the problem with our test runner 
  # script and Cython.Coverage which require test script 
  # to run from source root otherwise it won't find sources
  # and crash. So for now we are running tests from source dir.

  if [ "$WITH_COVERAGE" == "true" ]; then
    export PYTHONWARNINGS="ignore::DeprecationWarning:virtualenv"
    $PYTHON -b runtests.py -vv --coverage
    bash <(curl -s https://codecov.io/bash) -X coveragepy || echo "codecov upload failed"
  else
    $PYTHON runtests.py -v 
  fi
}


export PYTHON
export PIP

if [ "$USE_WHEEL" == "true" ] && [ $# -eq 0 ]; then
  # ensure some warnings are not issued
  export CFLAGS=$CFLAGS" -Wno-sign-compare -Wno-unused-result"

  $PYTHON setup.py build  --warnings --with-cython bdist_wheel 
  # Make virtualenv to install into
  virtualenv --python=`which $PYTHON` venv-for-wheel
  . venv-for-wheel/bin/activate
  # Move out of source directory to avoid finding local pyxpdf
  pushd dist
  $PIP install -vv --pre --no-index --upgrade --find-links=. pyxpdf
  popd

  run_test

elif [ "$USE_SDIST" == "true" ] && [ $# -eq 0 ]; then
  # ensure some warnings are not issued
  export CFLAGS=$CFLAGS" -Wno-sign-compare -Wno-unused-result"
  if [ -n "$RUN_COVERAGE" ]; then
    COVERAGE_FLAG=--with-coverage
  fi
  $PYTHON setup.py sdist --with-cython --warnings $COVERAGE_FLAG
  # Make another virtualenv to install into
  virtualenv --python=`which $PYTHON` venv-for-sdist
  . venv-for-sdist/bin/activate
  
  # install test dependencies
  $PIP install -r test_requirements.txt
  
  # Move out of source directory to avoid finding local pyxpdf
  pushd dist
  $PIP install -vv pyxpdf*
  popd
  run_test
else
  setup_base
  run_test
fi
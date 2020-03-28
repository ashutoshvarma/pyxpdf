# export PYTHONPATH=$PYTHONPATH:../build/depd/lib
# export PATH=$PATH:../build/depd/lib

# Note the `../../../DEPENDENCIES/libcproject`...

CC="gcc"   \
CXX="g++"   \
    python setup.py build_ext --inplace
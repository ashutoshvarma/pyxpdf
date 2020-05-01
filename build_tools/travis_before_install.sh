#!/bin/bash

# Exit the script immediately if a command exits with a non-zero status,
# and print commands and their arguments as they are executed.
set -ex

uname -a
free -m
df -h
ulimit -a

mkdir builds
pushd builds

python -V
gcc --version

popd

pip install --upgrade pip
pip install setuptools wheel 
pip install -r requirements.txt
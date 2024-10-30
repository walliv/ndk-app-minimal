#!/bin/sh

ROOT_PATH=../../../../..

PKG_COCOTBEXT_OFM=$ROOT_PATH/python/cocotbext/

# Python virtual environment
python -m venv venv-fifox
source venv-fifox/bin/activate

python -m pip install setuptools
python -m pip install $PKG_COCOTBEXT_OFM

echo ""
echo "Now activate environment with:"
echo "source venv-fifox/bin/activate"

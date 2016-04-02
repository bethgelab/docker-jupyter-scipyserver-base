#!/usr/bin/env bash

set -xe

mkdir /tmp/build
cd /tmp/build
git config --global url.https://github.com/.insteadOf git://github.com/

git clone -q https://github.com/numpy/numpy.git
cp /tmp/numpy-site.cfg numpy/site.cfg

git clone -q https://github.com/scipy/scipy.git
cp /tmp/scipy-site.cfg scipy/site.cfg

apt-get -y update
apt-get build-dep -y python3 python3-numpy python3-scipy cython3

curl https://bootstrap.pypa.io/get-pip.py | python2
curl https://bootstrap.pypa.io/get-pip.py | python3

apt-get -y remove cython

for PYTHONVER in 2 3 ; do
  PYTHON="python$PYTHONVER"
  PIP="pip$PYTHONVER"

  $PIP install --no-cache-dir --upgrade cython

  # Build NumPy and SciPy from source against OpenBLAS installed
  (cd numpy && $PIP install --no-cache-dir --quiet .)
  (cd scipy && $PIP install --no-cache-dir --quiet .)
done

# Reduce the image size
apt-get autoremove -y
apt-get clean -y

rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

cd /
rm -rf /tmp/build

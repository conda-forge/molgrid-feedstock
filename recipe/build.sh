#!/bin/bash
set -ex

NUMPY_INCLUDE_DIR=$($PYTHON -c "import numpy; print(numpy.get_include())")

if [[ ${cuda_compiler_version} != "None" ]]; then
  export NCCL_ROOT_DIR=$PREFIX
  export NCCL_INCLUDE_DIR=$PREFIX/include
  export USE_SYSTEM_NCCL=1
  export USE_STATIC_NCCL=0
  export USE_STATIC_CUDNN=0
  export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  export CUDNN_INCLUDE_DIR=$PREFIX/include
else
  echo "molgrid does not support CPU build"
  exit 1
fi

mkdir -p build/
cd build/

cmake -GNinja ${CMAKE_ARGS} .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DOPENBABEL3_INCLUDE_DIR=$PREFIX/include/openbabel3/ \
  -DOPENBABEL3_LIBRARIES=$PREFIX/lib/libopenbabel.so \
  -DPYTHON_NUMPY_INCLUDE_DIR=$NUMPY_INCLUDE_DIR \
  -DBUILD_STATIC=0 \
  -DBUILD_SHARED=1

ninja -v -j $CPU_COUNT
ninja -v install

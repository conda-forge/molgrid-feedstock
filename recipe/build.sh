#!/bin/bash
set -ex

NUMPY_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")

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

# NOTE: fix the error:
# `error: 'virtual std::pair<int, float> libmolgrid::CallbackIndexTyper::get_atom_type_index(OpenBabel::OBAtom*) const' was hidden [-Werror=overloaded-virtual=]`
export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -Wno-error=overloaded-virtual"

mkdir -p build/
cd build/

cmake ${CMAKE_ARGS} .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DOPENBABEL3_INCLUDE_DIR=$PREFIX/include/openbabel3/ \
  -DOPENBABEL3_LIBRARIES=$PREFIX/lib/libopenbabel.so \
  -DPYTHON_NUMPY_INCLUDE_DIR=$NUMPY_INCLUDE_DIR \
  -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} \
  -DBUILD_STATIC=0 \
  -DBUILD_SHARED=1

make -j $CPU_COUNT
make install

# NOTE(hadim): Install the python module from here since the CMake installation fails here.
$PYTHON python/setup.py install

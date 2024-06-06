#!/bin/bash

set -ex

make config CXX=$CXX PREFIX=$PREFIX MFEM_SHARED=YES MFEM_STATIC=NO MFEM_USE_MPI=YES MFEM_USE_METIS_5=YES CXXFLAGS="$CXXFLAGS" LDFLAGS="$LDFLAGS" LIBS="$LIBS" HYPRE_OPT="-I$PREFIX/include" GHV_CXX=$CXX_FOR_BUILD

cat config/config.mk

if [[ $(uname) == Darwin ]]; then
  # Fix for older MacOS SDKs (<10.12?)
  sed -i.bak s,MAP_ANONYMOUS,MAP_ANON, general/mem_manager.cpp
fi

# Fix for hypre 2.21.0 / mfem 4.2
sed -i.bak s,hypre_ParcsrAdd,hypre_ParCSRMatrixAdd, linalg/hypre.cpp

make lib -j${CPU_COUNT}
make install

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != "1" ]]; then
  make check
fi

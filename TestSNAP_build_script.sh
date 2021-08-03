#!/bin/bash
module purge
module load cgpu
#module load dgx
module load nvhpc/21.7
module load cuda/11.2.1
module load cmake/3.18.2
module load gcc/8.3.0
module list
set -x
set -e

export OMP_NUM_THREADS=1
export OMP_PLACES=threads
export OMP_PROC_BIND=spread

RUN="srun -n 1 -c 16 --cpu-bind=cores"

HOME=$(pwd)

if [ ! -d kokkos ]; then
    echo "Kokkos not found. Please run the Kokkos script first."
    exit 1
fi

KOKKOS_PATH=$(pwd)/kokkos
cd ${KOKKOS_PATH}

if [ ! -d build_cuda_nvhpc ]; then
    echo "Cuda build of kokkos not found. Please run the Kokkos script first."
fi

if [ ! -d build_cuda_ompt ]; then
    echo "OpenMPTarget build of kokkos not found. Please run the Kokkos script first."
fi
cd ${HOME}

if [ ! -d TestSNAP ]; then
    git clone --single-branch --branch Kokkos-nvhpc https://github.com/rgayatri23/TestSNAP.git TestSNAP-Kokkos
fi

cd TestSNAP

    if [ -d build_cuda_nvhpc ]; then
        rm -rf build_cuda_nvhpc
    fi
    mkdir build_cuda_nvhpc && cd build_cuda_nvhpc
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_CXX_COMPILER=${KOKKOS_PATH}/bin/nvcc_wrapper \
          -D CMAKE_C_COMPILER=$(which gcc) \
          -D CMAKE_CXX_STANDARD=17 \
          -D CMAKE_CXX_EXTENSIONS=OFF \
          -D Kokkos_ROOT=${KOKKOS_PATH}/install_cuda_nvhpc \
          -D ref_data=14 \
          ..
    make
    ${RUN} ./test_snap -ns 100
    cd ..

    if [ -d build_ompt_nvhpc ]; then
        rm -rf build_ompt_nvhpc
    fi
    mkdir build_ompt_nvhpc && cd build_ompt_nvhpc
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_CXX_COMPILER=nvc++ \
          -D CMAKE_C_COMPILER=nvc \
          -D CMAKE_CXX_STANDARD=17 \
          -D CMAKE_CXX_EXTENSIONS=OFF \
          -D Kokkos_ROOT=${KOKKOS_PATH}/install_ompt_nvhpc \
          -D ref_data=14 \
          ..
    make
    ${RUN} ./test_snap -ns 100
    cd ..

cd ..

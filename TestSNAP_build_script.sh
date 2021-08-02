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

#ARCH="VOLTA70"
ARCH="AMPERE80"

if [[ ${ARCH} == "VOLTA70" ]] 
then
    RUN="srun -n 1 -c 10 --cpu-bind=cores"
else
    RUN="srun -n 1 -c 16 --cpu-bind=cores"
fi

BUILD_KOKKOS=1
KOKKOS_PATH=$(pwd)/kokkos

if [[ $BUILD_KOKKOS -eq 1 ]]; then
    if [ ! -d kokkos ]; then
        git clone --single-branch --branch develop https://github.com/kokkos/kokkos.git
    fi 
    cd kokkos
    if [ -d build_cuda_nvhpc_${ARCH} ]; then
        rm -rf build_cuda_nvhpc
    fi
    mkdir build_cuda_nvhpc_${ARCH} && cd build_cuda_nvhpc_${ARCH}
    cmake -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_INSTALL_PREFIX=${KOKKOS_PATH}/install_cuda_nvhpc \
	  -D CMAKE_CXX_COMPILER=${KOKKOS_PATH}/bin/nvcc_wrapper \
      -D CMAKE_C_COMPILER= gcc \
	  -D CMAKE_CXX_STANDARD=17 \
	  -D Kokkos_ARCH_${ARCH}=ON \
	  -D Kokkos_ENABLE_CUDA=ON \
	  -D Kokkos_ENABLE_CUDA_LAMBDA=ON \
	  ..
    make -j8
    make install
cd ..

    if [ ! -d build_cuda_nvhpc_${ARCH} ]; then
        rm -rf build_ompt_nvhpc_${ARCH}
    fi
    mkdir build_ompt_nvhpc_${ARCH} && cd build_ompt_nvhpc_${ARCH}
    cmake -D CMAKE_BUILD_TYPE=Release \
	  -D CMAKE_INSTALL_PREFIX=${KOKKOS_PATH}/install_ompt_nvhpc \
	  -D CMAKE_CXX_COMPILER=nvc++ \
	  -D CMAKE_CXX_STANDARD=17 \
	  -D Kokkos_ARCH_${ARCH}=ON \
	  -D Kokkos_ENABLE_OPENMPTARGET=ON \
	  -D Kokkos_ENABLE_IMPL_DESUL_ATOMICS=OFF \
	  ..
    make -j8
    make install
    cd ..

    cd ..
fi

if [ ! -d TestSNAP-Kokkos ]; then
    git clone --single-branch --branch Kokkos-nvhpc https://github.com/rgayatri23/TestSNAP.git TestSNAP-Kokkos
fi

cd TestSNAP-Kokkos

    if [ -d build_cuda_nvhpc_${ARCH} ]; then
        rm -rf build_cuda_nvhpc_${ARCH}
    fi
    mkdir build_cuda_nvhpc_${ARCH} && cd build_cuda_nvhpc_${ARCH}
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_CXX_COMPILER=${KOKKOS_PATH}/bin/nvcc_wrapper \
          -D CMAKE_C_COMPILER=$(which gcc) \
          -D CMAKE_CXX_STANDARD=17 \
          -D CMAKE_CXX_EXTENSIONS=OFF \
          -D Kokkos_ROOT=../../kokkos/install_cuda_nvhpc \
          -D ref_data=14 \
          ..
    make
    ${RUN} ./test_snap -ns 100
    cd ..

    if [ -d build_ompt_nvhpc_${ARCH} ]; then
        rm -rf build_ompt_nvhpc_${ARCH}
    fi
    mkdir build_ompt_nvhpc_${ARCH} && cd build_ompt_nvhpc_${ARCH}
    cmake -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_CXX_COMPILER=nvc++ \
          -D CMAKE_C_COMPILER=nvc \
          -D CMAKE_CXX_STANDARD=17 \
          -D CMAKE_CXX_EXTENSIONS=OFF \
          -D Kokkos_ROOT=../../kokkos/install_ompt_nvhpc \
          -D ref_data=14 \
          ..
    make
    ${RUN} ./test_snap -ns 100
    cd ..

cd ..

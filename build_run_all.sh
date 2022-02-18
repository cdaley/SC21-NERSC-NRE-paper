#!/bin/bash -l
#SBATCH -N 1
#SBATCH -t 1:00:00
#SBATCH -C gpu
#SBATCH -A nstaff_g
#SBATCH --exclusive
#SBATCH -c 128
#SBATCH -G 4
#SBATCH --job-name=openmp
#SBATCH -q early_science

echo -e "\n\nBuilding and running Babelstream..."
./BabelStream_build_script.sh

echo -e "\n\nBuilding and running BerkeleyGW (GPP)..."
./BerkeleyGW_build_script.sh

echo -e "\n\nBuilding and running Kokkos incremental tests..."
./Kokkos_build_script.sh

echo -e "\n\nBuilding and running the Kokkos version of TestSNAP with both CUDA and OpenMPTarget backends..."
./TestSNAP_build_script.sh

echo -e "\n\nBuilding and running the native OpenMP version of TestSNAP..."
./TestSNAP_native_build_script.sh

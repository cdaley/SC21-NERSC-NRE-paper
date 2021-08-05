# Description
This repository contains artifacts for the SC21 paper titled "Non-Recurring Engineering (NRE) Best Practices: A Case Study with the NERSC/NVIDIA OpenMP Contract" (DOI=https://doi.org/10.1145/3458817.3476213).

As each of the applications maintain their own GitHub/GitLab repositories, they are added here as a submodules.

# Clone the repository and its submodules
In order to clone the repository use one of the following two approaches:

```console
git clone --recurse-submodules https://github.com/NERSC/SC21-NERSC-NRE-paper
```
or
```console
git clone https://github.com/NERSC/SC21-NERSC-NRE-paper
cd SC21-NERSC-NRE-paper
git submodule update --init --recursive
```

# Running the benchmarks
A build and run script is provided for each of the applications and are named with the application name as the prefix.
The build scripts are tuned for NVIDIA's A100 architectures.
The build scripts checkout the specific commit of each repository whose results are presented in the paper.

> **_Note_** The TestSNAP build script is dependent on Kokkos. We recommend running the Kokkos build script before running TestSNAP.

### Kokkos

The script `Kokkos_build_script.sh` builds and runs the Kokkos incremental tests. This is setup to run the 17 incremental Kokkos tests. The output should look like the following:
```console
+ ./core/unit_test/KokkosCore_IncrementalTest_OPENMPTARGET
[==========] Running 17 tests from 1 test case.
[----------] Global test environment set-up.
[----------] 17 tests from OPENMPTARGET
[ RUN      ] OPENMPTARGET.IncrTest_01_execspace_typedef
[       OK ] OPENMPTARGET.IncrTest_01_execspace_typedef (0 ms)
```

Kokkos is used by TestSNAP. Therefore, this script must be executed before `TestSNAP_build_script.sh`.


### TestSNAP (Kokkos)

The script `TestSNAP_build_script.sh` builds and runs the Kokkos version of TestSNAP with both CUDA and OpenMPTarget Kokkos backends. The key performance metric is referred to as the grind time and measures the time to advance 1 atom step. The script runs TestSNAP 10 times with the CUDA backend and 10 times with the OpenMPTarget backend. The output should look like the following
```console
grind time = 0.0174961 [msec/atom-step]
```


# Hardware Configuration
This repository contains a log file named `dgx_info.log` detailing the system we used to collect performance results. This system, named "Cori-DGX" in the paper, is 2 nodes of NVIDIA DGX with nodes consisting of 2 AMD Rome CPUs and 8 NVIDIA A100 GPUs. The log file shows the default environment on Cori-DGX. Where necessary, our build/run scripts contain the appropriate modulefile commands to use a non-default environment.

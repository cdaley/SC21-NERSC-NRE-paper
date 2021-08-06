# Description
This repository contains artifacts for the SC21 paper titled "Non-Recurring Engineering (NRE) Best Practices: A Case Study with the NERSC/NVIDIA OpenMP Contract" (DOI=https://doi.org/10.1145/3458817.3476213).

As each of the applications maintain their own GitHub/GitLab repositories, they are added here as submodules.

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
The collection of benchmarks can be built and run with a single script named `build_run_all.sh`. This script executes the individual benchmark scripts, which are named according to the benchmark. The individual benchmark scripts may also be run independently. The scripts checkout the specific commit of each repository corresponding to the results presented in the paper. All the benchmarks are single process applications and have no MPI dependence.

The scripts are primarily designed to be executed on the DGX nodes at NERSC under the Slurm job scheduler. The DGX nodes have 2 64-core AMD Rome CPUs and 8 NVIDIA A100 GPUs. The scripts assume use of NVIDIA A100 GPUs and the NVIDIA HPC SDK compilers. One eighth of a DGX node is 16 cores (32 hyperthreads) and 1 GPU. Therefore each script runs Slurm job steps that use 32 CPUs, i.e. hyperthreads, and 1 GPU.

> **_Note_** The TestSNAP build script `TestSNAP_build_script.sh` depends on Kokkos being installed first. Kokkos can be installed by executing the Kokkos build script `Kokkos_build_script.sh`.


### Babelstream

The script `BabelStream_build_script.sh` builds and runs a patched version of Babelstream. Our patch `add_loop_directive_to_babelstream_8f9ca7.diff` adds an additional code variant using the OpenMP-5.0 "loop" directive. There are three versions of Babelstream tested: CUDA, OpenMP Target offload, and OpenMP Target offload using the "loop" directive. Each test is run 10 times. The performance metric of interest is the calculated memory bandwidth in MBytes/sec. The output should look like the following
```console
BabelStream
Version: 3.4
Implementation: OpenMP
Running kernels 1000 times
Precision: double
Array size: 268.4 MB (=0.3 GB)
Total size: 805.3 MB (=0.8 GB)
Function    MBytes/sec  Min (sec)   Max         Average
Copy        1383602.334 0.00039     0.00040     0.00039
Mul         1346945.467 0.00040     0.00095     0.00040
Add         1365629.694 0.00059     0.00060     0.00060
Triad       1371198.700 0.00059     0.00060     0.00060
Dot         1291747.459 0.00042     0.00043     0.00042
```

### BerkeleyGW

The script `BerkeleyGW_build_script.sh` builds and runs the BerkeleyGW GPP mini application written in Fortran. There are 3 OpenMP target offload versions tested: OpenMP-4.5 compute directives, OpenMP-5.0 "loop" directives, and OpenMP-5.0 "loop" directives with a value specified for the OpenMP thread_limit clause. The performance metric of interest is the execution time in seconds. The performance of each version is nearly the same when using NVIDIA HPC SDK 21.7. This was not the case with earlier compilers. Each test is run 10 times. The output should look like the following
```console
 nstart,nend            2            3
 ngpown,ncouls,ntband_dist         1385        11075          800
Time =   0.404 seconds.
 asxtemp correct!
 achtemp correct!
```
The FLOP/s can be obtained by running the application under NVIDIA Nsight Compute (https://developer.nvidia.com/nsight-compute).


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

The script `TestSNAP_build_script.sh` builds and runs the Kokkos version of TestSNAP with both CUDA and OpenMPTarget Kokkos backends. The key performance metric is referred to as the grind time and measures the time in milliseconds to advance 1 atom step. The script runs TestSNAP 10 times with the CUDA backend and 10 times with the OpenMPTarget backend. The output should look like the following
```console
grind time = 0.0174961 [msec/atom-step]
```

### TestSNAP (native OpenMP)

The script `TestSNAP_native_build_script.sh` builds and runs a OpenMP target offload version of TestSNAP. Here, OpenMP target offload is used directly instead of through Kokkos. The key performance metric and application output is the same as the Kokkos version of TestSNAP.


# Hardware Configuration
This repository contains a log file in directory `hardware-configuration` named `dgx_info.log` detailing the system we used to collect performance results. This system, named "Cori-DGX" in the paper, is 2 nodes of NVIDIA DGX with nodes consisting of 2 AMD Rome CPUs and 8 NVIDIA A100 GPUs. The log file shows the default environment on Cori-DGX. Where necessary, our build/run scripts contain the appropriate modulefile commands to use a non-default environment.


# Acknowledgements
This research used resources of the National Energy Research Scientific Computing Center (NERSC), a U.S. Department of Energy Office of Science User Facility operated under Contract No. DE-AC02-05CH11231.

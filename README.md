# Description
The repo is a collection of applications presented in the SC2021-NERSC-NVIDIA NRE paper titled "Revision: Non-Recurring Engineering (NRE) Best Practices: ACase Study with the NERSC/NVIDIA OpenMP Contract".
As each of the applications maintain their own GitHub repos, they are added here as a submodules.
Additionally a build and run script is provided for each of the applications and are named with the application name as the prefix.
The build scripts are tuned for NVIDIA's V100 and A100 architectures.

# Clone the repo and its submodules
In order to clone the repo use one of the following two approaches: 

```console
git clone --recurse-submodules https://github.com/NERSC/SC21-NERSC-NRE-paper
```
or
```console
git clone https://github.com/NERSC/SC21-NERSC-NRE-paper
cd SC21-NERSC-NRE-paper
git submodule update --init --recursive
```

#!/bin/bash

mpiifort -fopenmp precision.f90 data_distribution.f90 data_types.f90 parallel_dot_mpi_omp_test.f90 -o parallel_dot_mpi_omp_test.x

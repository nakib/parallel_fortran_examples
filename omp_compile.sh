#!/bin/bash

ifort -fopenmp precision.f90 data_types.f90 parallel_dot_omp_test.f90 -o parallel_dot_omp_test.x

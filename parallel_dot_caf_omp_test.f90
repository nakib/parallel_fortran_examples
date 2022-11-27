program parallel_dot_caf_omp_test

  use precision, only: dp
  use data_distribution, only: distribution_map
  use data_types, only: vector, operator(*)
 
  implicit none

  type(vector) :: A, B

  integer, parameter :: N = 2000000
  integer :: i, omp_get_thread_num, omp_get_max_threads

  real(dp), allocatable :: data(:)[:] !Will be distributed over images
  integer :: chunk_size, first, last
  real(dp) :: analytical_result, numerical_result
  
  !Generate a data distribution map over coarray images
  call distribution_map(N, chunk_size, first, last)
  
  !Generate some test data
  allocate(data(chunk_size)[*])
  data = [(i, i = first, last)]/(N + 0.0_dp)

  ! Distributed [1 2 3 ... N]/N
  call A%create(data)

  ! Distributed [2 3 4 ... N + 1]/N
  call B%create(data + 1.0_dp/N)

  numerical_result = A*B !<~ OMP parallel dot product
  !Reduce from all images
  sync all
  call co_sum(numerical_result)
  sync all
  
  analytical_result = (N + 1.0_dp)/N*(0.5_dp + (2.0_dp*N + 1.0_dp)/6.0_dp)

  if(this_image() ==  1) then
     print*, 'Numerical result: ', numerical_result
     print*, 'Analytical result:', analytical_result
  end if
end program parallel_dot_caf_omp_test

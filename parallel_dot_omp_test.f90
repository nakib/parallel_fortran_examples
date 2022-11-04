program parallel_dot_omp_test

  use precision, only: dp
  use data_types, only: vector, operator(*)
 
  implicit none

  type(vector) :: A, B

  integer, parameter :: N = 2000000
  integer :: i, omp_get_thread_num, omp_get_max_threads

  real(dp), allocatable :: data(:)
  real(dp) :: analytical_result
 
  !Generate some test data
  allocate(data(N)) 
  data = [(i, i = 1, N)]/(N + 0.0_dp)

  ! [1 2 3 ... N]/N
  call A%create(data)

  ! [2 3 4 ... N + 1]/N
  call B%create(data + 1.0_dp/N)

  analytical_result = (N + 1.0_dp)/N*(0.5_dp + (2.0_dp*N + 1.0_dp)/6.0_dp)

  if(this_image() ==  1) then
     print*, 'Numerical result: ', A*B !<~ OMP parallel dot product
     print*, 'Analytical result:', analytical_result
  end if
end program parallel_dot_omp_test

program parallel_dot_mpi_test
  use precision, only: dp
  use data_distribution, only: distribution_map
  use data_types, only: vector, operator(*)
  use mpi_wrappers, only: mpi_info_type, mpi_sum
 
  implicit none

  type(mpi_info_type) :: mpi_info 

  type(vector) :: A, B

  integer, parameter :: N = 2000000
  integer :: i

  real(dp), allocatable :: data(:) !Will be distributed over images
  integer :: chunk_size, first, last
  real(dp) :: analytical_result, numerical_result, local_numerical_result

  call mpi_info%init()
  call mpi_info%distribute(N, chunk_size, first, last)
  
  !Generate some test data
  allocate(data(chunk_size))
  data = [(i, i = first, last)]/(N + 0.0_dp)

  ! [first ... last]/N
  call A%create(data)

  ! [first + 1 ... last + 1]/N
  call B%create(data + 1.0_dp/N)

  local_numerical_result = A*B !<~ OMP parallel dot product
  call mpi_info%reduce(local_numerical_result, numerical_result, mpi_sum)
 
  if(mpi_info%is_root) then
     analytical_result = (N + 1.0_dp)/N*(0.5_dp + (2.0_dp*N + 1.0_dp)/6.0_dp)
     print*, 'Numerical result: ', numerical_result
     print*, 'Analytical result:', analytical_result
  end if

  call mpi_info%finalize()
end program parallel_dot_mpi_test  
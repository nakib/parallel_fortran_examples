program parallel_dot_mpi_test
  ! Include mpi library routines and globals
  use mpi

  use precision, only: dp
  use data_distribution, only: distribution_map
  use data_types, only: vector, operator(*)
 
  implicit none

  type(vector) :: A, B

  integer, parameter :: N = 2000000
  integer :: i, mpi_rank, ierr

  real(dp), allocatable :: data(:) !Will be distributed over images
  integer :: chunk_size, first, last
  real(dp) :: analytical_result, numerical_result, local_numerical_result

  ! Initialize MPI
  call mpi_init(ierr)
  if (ierr /= 0) then
    print*, 'MPI error(mpi_init): ierr: ', ierr
    call mpi_abort(mpi_comm_world, 101, ierr) ! Termination is done by an MPI
  end if

  ! Get MPI rank
  call mpi_comm_rank(mpi_comm_world, mpi_rank, ierr)
  if (ierr /= 0) then
    print*, 'MPI error(mpi_comm_rank): ierr: ', ierr
    call mpi_abort(mpi_comm_world, 101, ierr) ! Termination is done by an MPI
  end if
  
  !Generate a data distribution map over coarray images
  call distribution_map(N, chunk_size, first, last)
  
  !Generate some test data
  allocate(data(chunk_size))
  data = [(i, i = first, last)]/(N + 0.0_dp)

  ! [first ... last]/N
  call A%create(data)

  ! [first + 1 ... last + 1]/N
  call B%create(data + 1.0_dp/N)

  local_numerical_result = A*B !<~ OMP parallel dot product
  print*, first, last, chunk_size
  !Reduce from all ranks
  numerical_result = 0.0_dp 
  call mpi_reduce( &
          local_numerical_result, &  ! send buffer
          numerical_result, &        ! recieve buffer
          1, &                       ! count
          mpi_double, &              ! data type
          mpi_sum, &                 ! operation
          0, &                       ! root 
          mpi_comm_world, &          ! communicator
          ierr)                      ! error flag
  if (ierr /= 0) then
    print*, 'MPI error(mpi_reduce): ierr: ', ierr
    call mpi_abort(mpi_comm_world, 101, ierr) ! Termination is done by an MPI
  end if        

  if(mpi_rank ==  0) then
     analytical_result = (N + 1.0_dp)/N*(0.5_dp + (2.0_dp*N + 1.0_dp)/6.0_dp)
     print*, 4 * local_numerical_result / analytical_result
     print*, 'Numerical result: ', numerical_result
     print*, 'Analytical result:', analytical_result
  end if
end program parallel_dot_mpi_test  
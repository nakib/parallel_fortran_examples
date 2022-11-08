module mpi_wrappers
  use mpi 

  use precision

  private
  public :: mpi_info_type, mpi_sum

  integer, parameter :: error_code_abort = 101
  integer, parameter :: root_rank = 0          ! Root process is always defined as rank 0

  type mpi_info_type         !! communicator
    integer :: rank = -1          !! rank
    integer :: procs = -1         !! number of processes
    logical :: is_root = .false.  !! process is root or not

    contains 

    procedure :: init => mpi_info_init
    procedure :: finalize => mpi_info_finalize
    procedure :: barrier => mpi_info_barrier
    procedure :: distribute => mpi_info_distribution

    procedure :: mpi_info_reduce_double_rank_0
    generic :: reduce => mpi_info_reduce_double_rank_0
  end type mpi_info_type

  contains 

  subroutine mpi_info_init(this)
    class(mpi_info_type) :: this

    integer :: ierr

    call mpi_init(ierr)
    call assert_mpi_error('mpi_init', ierr)

    call mpi_comm_size(mpi_comm_world, this%procs, ierr)
    call assert_mpi_error('mpi_comm_size', ierr)

    call mpi_comm_rank(mpi_comm_world, this%rank, ierr)
    call assert_mpi_error('mpi_comm_rank', ierr)

    this%is_root = this%rank == root_rank
  end subroutine mpi_info_init

  subroutine mpi_info_finalize(this)
    class(mpi_info_type) :: this

    integer :: ierr

    call mpi_finalize(ierr)
    call assert_mpi_error('mpi_finalize', ierr)

    this%rank = -1
    this%procs = -1
    this%is_root = .false.
  end subroutine mpi_info_finalize

  subroutine mpi_info_barrier(this)
    class(mpi_info_type) :: this

    integer :: ierr

    call mpi_barrier(mpi_comm_world, ierr)
    call assert_mpi_error('mpi_barrier', ierr)
  end subroutine  

  subroutine mpi_info_distribution(this, full_size, chunk_size, first, last)
    class(mpi_info_type), intent(in) :: this
    integer, intent(in) :: full_size
    integer, intent(out) :: chunk_size, first, last 

    if(this%procs > full_size) then
      if(this%is_root) print*, 'Number of images larger than array size is not allowed.'
      call mpi_abort(mpi_comm_world, error_code_abort, ierr)
    end if
    
    chunk_size = ceiling(dble(full_size)/this%procs)
    first = this%rank*chunk_size + 1
    last = min((this%rank + 1)*chunk_size, full_size)

    if(first < last) then
      chunk_size = last - first + 1
    else
      chunk_size = 1
    end if  
  end subroutine mpi_info_distribution

  subroutine mpi_info_reduce_double_rank_0(this, send_buffer, recieve_buffer, operation)
    class(mpi_info_type), intent(in) :: this 
    real(dp), intent(in) :: send_buffer
    real(dp), intent(out) :: recieve_buffer
    integer, intent(in) :: operation

    real(dp) :: recieve_buffer_local 

    call mpi_reduce( &
          send_buffer, &             ! send buffer
          recieve_buffer_local, &             ! recieve buffer
          1, &                       ! count
          mpi_double, &              ! data type
          operation, &               ! operation
          root_rank, &               ! root 
          mpi_comm_world, &               ! communicator
          ierr)                      ! error flag
    call assert_mpi_error('mpi_reduce', ierr)
    
    recieve_buffer = recieve_buffer_local
  end subroutine mpi_info_reduce_double_rank_0


  subroutine assert_mpi_error(routine_name, ierr)
    character(*), intent(in) :: routine_name
    integer, intent(in) :: ierr

    if (ierr /= 0) then
      print*, 'MPI error (', routine_name, '): ierr: ', ierr
      call mpi_abort(mpi_comm_world, error_code_abort, ierr)
    end if  
  end subroutine assert_mpi_error
end module mpi_wrappers

module mpi_info

  integer, parameter :: error_code_abort = 101

  type mpi_info_type
    integer :: comm = -1
    integer :: rank = -1
    integer :: procs = -1
    integer :: ierr = -1
    logical :: is_root = .false.
  end type mpi_info_type

  contains 

  subroutine mpi_info_init(this)
    class(mpi_info_type) :: this

    call 

  end subroutine mpi_info_init


  subroutine assert_mpi_error(routine_name, ierr)
    character(*), intent(in) :: routine_name
    integer, intent(in) :: ierr 

    if (ierr /= 0) then
      print*, 'MPI error (', routine_name, '): ierr: ', ierr
      call mpi_abort(mpi_comm_world, error_code_abort, ierr)
    end if  
end module mpi_info  
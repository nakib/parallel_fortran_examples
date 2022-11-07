module data_types

  use precision, only: dp
 
  implicit none

  private
  public vector, operator(*)
 
  type vector
     integer :: length = 0
     real(dp), allocatable :: vector(:)
     
   contains
     
     procedure :: create, destroy
  end type vector

  interface operator(*)
     module procedure dot
  end interface operator(*)

contains

  subroutine create(self, data)
    class(vector), intent(out) :: self
    real(dp), intent(in) :: data(:)

    self%length = size(data)
    allocate(self%vector(self%length))
    self%vector = data
  end subroutine create

  subroutine destroy(self)
    class(vector), intent(inout) :: self

    if(allocated(self%vector)) then
       deallocate(self%vector)
       self%length = 0
    end if
  end subroutine destroy
 
  real(dp) function dot(A, B)
    type(vector), intent(in) :: A, B

    integer :: i
   
    if(A%length /= B%length) then
       print*, 'Vector size mismatch detected in dot product call. Exiting.'
       call exit
    end if

    dot = 0.0_dp

    !CPU parallel
    !$omp parallel do &
    !$omp private(i) shared(A, B) reduction(+ : dot)
    do i = 1, A%length
       dot = dot + A%vector(i)*B%vector(i)
    end do

!!$    !GPU parallel
!!$    !$omp target map(to: A, B) map(tofrom: dot)
!!$    !$omp parallel do
!!$    !$omp private(i) shared(A, B) reduction(+ : dot)
!!$    do i = 1, A%length
!!$       dot = dot + A%vector(i)*B%vector(i)
!!$    end do
!!$    !$omp end target

  end function dot
end module data_types

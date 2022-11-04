module precision
 
  implicit none

  integer, parameter :: r_real = 200
  !! Exponent range for reals.
  integer, parameter :: p_real = 14
  !! Number of digits for reals.
  integer, parameter :: dp = selected_real_kind(p_real, r_real)
end module precision

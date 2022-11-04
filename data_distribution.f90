module data_distribution

  implicit none

contains

  subroutine distribution_map(full_size, chunk_size, first, last)
    integer, intent(in) :: full_size
    integer, intent(out) :: chunk_size, first, last

    if(num_images() > full_size) then
       if(this_image() == 1) print*, 'Number of images larger than array size is not allowed.'
       sync all
       call exit
    end if

    chunk_size = ceiling(dble(full_size)/num_images())
    first = (this_image() - 1)*chunk_size + 1
    last = min(this_image()*chunk_size, full_size)
    !Update chunk_size
    if(first < last) then
       chunk_size = last - first + 1
    else
       chunk_size = 1
    end if
  end subroutine distribution_map
end module data_distribution

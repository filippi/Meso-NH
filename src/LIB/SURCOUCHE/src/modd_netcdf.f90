MODULE MODD_NETCDF
IMPLICIT NONE 

TYPE IOCDF
   INTEGER :: NCID
   TYPE(DIMCDF), POINTER :: DIMX
   TYPE(DIMCDF), POINTER :: DIMY
   TYPE(DIMCDF), POINTER :: DIMZ
   TYPE(DIMCDF), POINTER :: DIMSTR
   TYPE(DIMCDF), POINTER :: DIMLIST
END TYPE IOCDF

TYPE DIMCDF
   CHARACTER(LEN=8)      :: NAME
   INTEGER               :: LEN
   INTEGER               :: ID
   TYPE(DIMCDF), POINTER :: NEXT
END TYPE DIMCDF

END MODULE MODD_NETCDF
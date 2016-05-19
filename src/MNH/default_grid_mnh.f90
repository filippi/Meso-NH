!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 surfex 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     ######################################
      SUBROUTINE DEFAULT_GRID_MNH(HGRID)
!     ######################################
!!
!!    PURPOSE
!!    -------
!!   set default for the surface GRID.
!!
!!    METHOD
!!    ------
!!   
!!    EXTERNAL
!!    --------
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!
!!    V. Masson                   Meteo-France
!!
!!    MODIFICATION
!!    ------------
!!
!!    Original     13/10/03
!----------------------------------------------------------------------------
!
!*    0.     DECLARATION
!            -----------
!
USE MODD_CONF, ONLY : CPROGRAM
!
IMPLICIT NONE
!
!*    0.1    Declaration of dummy arguments
!            ------------------------------
!
CHARACTER(LEN=10), INTENT(OUT) :: HGRID  ! grid type
!
!
!*    0.2    Declaration of local variables
!            ------------------------------
!
!------------------------------------------------------------------------------
!
IF (CPROGRAM=='IDEAL ') THEN
  HGRID = 'NONE      '
ELSE
  HGRID = 'CONF PROJ '
END IF
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE DEFAULT_GRID_MNH

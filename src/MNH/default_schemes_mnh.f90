!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 surfex 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     ######################################
      SUBROUTINE DEFAULT_SCHEMES_MNH(HNATURE,HSEA,HTOWN,HWATER)
!     ######################################
!!
!!    PURPOSE
!!    -------
!!   initializes the surface SCHEMES.
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
CHARACTER(LEN=6),  INTENT(OUT) :: HNATURE  ! scheme for natural surfaces
CHARACTER(LEN=6),  INTENT(OUT) :: HSEA     ! scheme for sea
CHARACTER(LEN=6),  INTENT(OUT) :: HTOWN    ! scheme for towns
CHARACTER(LEN=6),  INTENT(OUT) :: HWATER   ! scheme for inland water
!
!
!*    0.2    Declaration of local variables
!            ------------------------------
!
!------------------------------------------------------------------------------
!
IF (CPROGRAM=='IDEAL ') THEN
  HNATURE = 'NONE  '
  HSEA    = 'NONE  '
  HTOWN   = 'NONE  '
  HWATER  = 'NONE  '
ELSE
  HNATURE = 'ISBA  '
  HSEA    = 'SEAFLX'
  HTOWN   = 'TEB   '
  HWATER  = 'WATFLX'
END IF
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE DEFAULT_SCHEMES_MNH

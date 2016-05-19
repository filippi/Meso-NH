!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 surfex 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     ##################################
      SUBROUTINE MNHCLOSE_WRITE_COVER_TEX
!     ##################################
!
!!****  *MNHCLOSE_WRITE_COVER_TEX* - closes cover listing file
!!
!!    PURPOSE
!!    -------
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!	V. Masson   *Meteo France*	
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    01/2003 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_CONF, ONLY : CPROGRAM
USE MODE_IO_ll
USE MODI_TRANSFER_FILE
!
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!              -------------------------
!

!
!*       0.2   Declarations of local variables
!              -------------------------------
!
CHARACTER(LEN=20) :: YTEX           ! name of tex file
!-------------------------------------------------------------------------------
!
!*       5.     Prints of cover parameters in a tex file
!               ----------------------------------------
!
IF (CPROGRAM =='PGD   ') THEN
  YTEX='class_cover_data.tex'
  !
  CALL CLOSE_ll(YTEX)
  CALL TRANSFER_FILE('fujitransfer.x','NIL',YTEX)
END IF
!-------------------------------------------------------------------------------
!
END SUBROUTINE MNHCLOSE_WRITE_COVER_TEX

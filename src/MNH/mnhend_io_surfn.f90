!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 surfex 2006/05/23 15:58:05
!-----------------------------------------------------------------
!     #########################
      MODULE MODI_MNHEND_IO_SURF_n
!     #########################
INTERFACE
      SUBROUTINE MNHEND_IO_SURF_n(HPROGRAM)
!
CHARACTER(LEN=6),  INTENT(IN)  :: HPROGRAM ! main program
!
END SUBROUTINE MNHEND_IO_SURF_n
!
END INTERFACE
END MODULE MODI_MNHEND_IO_SURF_n
!
!     #######################################################
      SUBROUTINE MNHEND_IO_SURF_n(HPROGRAM)
!     #######################################################
!
!!****  *MNHEND_IO_SURF_n* - routine to close IO files in MESONH universe 
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
!!	S.Malardel   *Meteo France*	
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    09/2003 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODE_ll
USE MODE_FM
USE MODE_IO_ll

USE MODD_IO_SURF_MNH, ONLY : CACTION, CFILE, COUTFILE, NMASK, NMASK_ALL
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!              -------------------------
!
CHARACTER(LEN=6),  INTENT(IN)  :: HPROGRAM ! main program
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER           :: IRESP          ! return-code if a problem appears
!
!-------------------------------------------------------------------------------
!
CACTION='     '
!
CFILE    = '                           '
COUTFILE = '                           '
!
DEALLOCATE(NMASK)
DEALLOCATE(NMASK_ALL)
!-------------------------------------------------------------------------------
!
END SUBROUTINE MNHEND_IO_SURF_n

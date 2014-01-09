!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 microph 2006/05/18 13:07:25
!-----------------------------------------------------------------
!      #########################################
       MODULE MODI_CLEAN_CONC_RAIN_C2R2 
!      #########################################
!
INTERFACE
!
      SUBROUTINE CLEAN_CONC_RAIN_C2R2 (HLUOUT,PR,PSV)
!
CHARACTER (LEN=*),         INTENT(IN) :: HLUOUT    ! name of the output-listing
!
REAL, DIMENSION(:,:,:,:),  INTENT(INOUT) :: PR     ! microphysical mixing 
REAL,  DIMENSION(:,:,:,:), INTENT(INOUT) :: PSV    ! microphys. concentrations
!
END SUBROUTINE CLEAN_CONC_RAIN_C2R2
!
END INTERFACE
!
END MODULE MODI_CLEAN_CONC_RAIN_C2R2
!
!     ########################################################
      SUBROUTINE CLEAN_CONC_RAIN_C2R2 (HLUOUT,PR,PSV)
!     ########################################################
!
!!****  *CLEAN_CONC_RAIN_C2R2 * - reinitialize the droplet/raindrop
!!                             concentration before STARTing the C2R2 scheme
!!
!!
!!    PURPOSE
!!    -------
!!      The purpose of this routine is to reinitialize cloud ativated CCN, the
!!    droplet and the rain drop concentrations when the cloud droplet and rain
!!    drop mixing ratios have very low values and when these concentrations
!!    have negative values (after a spawning or prep_real_case operation).
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!      None
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_RAIN_C2R2_DESCR, ONLY : XRTMIN, XCTMIN
!!      Module MODD_CONF,            ONLY : NVERB
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation ( routine CLEAN_CONC_RAIN_C2R2 )
!!
!!    AUTHOR
!!    ------
!!      J.-P. Pinty      * Laboratoire d'Aerologie*
!!      P. Jabouille     * CNRM/GMME *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    15/12/00
!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_RAIN_C2R2_DESCR, ONLY : XRTMIN, XCTMIN
USE MODD_CONF,            ONLY : NVERB
!
USE MODE_FM
!
IMPLICIT NONE
!
!*       0.1   Declarations of dummy arguments :
!
CHARACTER (LEN=*),         INTENT(IN) :: HLUOUT    ! name of the output-listing
!
REAL, DIMENSION(:,:,:,:),  INTENT(INOUT) :: PR     ! microphysical mixing 
REAL,  DIMENSION(:,:,:,:), INTENT(INOUT) :: PSV    ! microphys. concentrations
!
!
!*       0.2   Declarations of local variables :
!
INTEGER    :: IRESP   ! Return code of FM routines
INTEGER    :: ILUOUT  ! Logical unit number of output-listing
!  
!-------------------------------------------------------------------------------
!  
!*       1.    RETRIEVE LOGICAL UNIT NUMBER
!              ----------------------------
!
CALL FMLOOK_ll(HLUOUT,HLUOUT,ILUOUT,IRESP)
!
!*       2.    INITIALIZATION
!              --------------
!
PSV(:,:,:,1:3) = MAX( PSV(:,:,:,1:3),0.0 )
WHERE (PR(:,:,:,2) <= XRTMIN(2) .OR. PSV(:,:,:,2) <= XCTMIN(2))
  PSV(:,:,:,1) = 0.0
  PSV(:,:,:,2) = 0.0
  PR (:,:,:,2) = 0.0
ENDWHERE
WHERE (PR(:,:,:,3) <= XRTMIN(3) .OR. PSV(:,:,:,3) <= XCTMIN(3))
  PSV(:,:,:,3) = 0.0
  PR (:,:,:,3) = 0.0
ENDWHERE
!
IF( NVERB >= 5 ) THEN
  WRITE (UNIT=ILUOUT,FMT=*) "!INI_MODEL$n: The droplet/drop concentrations are"
  WRITE (UNIT=ILUOUT,FMT=*) "cleaned to avoid very low and negative values"
END IF
!
END SUBROUTINE CLEAN_CONC_RAIN_C2R2

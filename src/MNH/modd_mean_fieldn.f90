!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/06/27 14:17:24
!-----------------------------------------------------------------
!     ###################
      MODULE MODD_MEAN_FIELD_n
!     ###################
!
!!****  *MODD_MEAN_FIELD$n* - declaration of mean variables
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to specify  the 
!     mean variables. 
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None 
!!
!!    REFERENCE
!!    ---------
!!      
!!
!!    AUTHOR
!!    ------
!!	P.Aumond     *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original       01/07/11                      
!!
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE MEAN_FIELD_t
  REAL, DIMENSION(:,:,:), POINTER :: XUM_MEAN=>NULL(),XVM_MEAN=>NULL(),XWM_MEAN=>NULL()
  REAL, DIMENSION(:,:,:), POINTER :: XTHM_MEAN=>NULL()     
  REAL, DIMENSION(:,:,:), POINTER :: XTEMPM_MEAN=>NULL()  
  REAL, DIMENSION(:,:,:), POINTER :: XTKEM_MEAN=>NULL()   
  REAL, DIMENSION(:,:,:), POINTER :: XPABSM_MEAN=>NULL()

  REAL, DIMENSION(:,:,:), POINTER :: XU2_MEAN=>NULL(),XV2_MEAN=>NULL(),XW2_MEAN=>NULL()
  REAL, DIMENSION(:,:,:), POINTER :: XTH2_MEAN=>NULL()      
  REAL, DIMENSION(:,:,:), POINTER :: XTEMP2_MEAN=>NULL() 
  REAL, DIMENSION(:,:,:), POINTER :: XPABS2_MEAN=>NULL()  
  
          
  INTEGER :: MEAN_COUNT

 !
END TYPE MEAN_FIELD_t

TYPE(MEAN_FIELD_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: MEAN_FIELD_MODEL

REAL, DIMENSION(:,:,:), POINTER :: XUM_MEAN=>NULL(),XVM_MEAN=>NULL(),XWM_MEAN=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XTHM_MEAN=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XTEMPM_MEAN=>NULL() 
REAL, DIMENSION(:,:,:), POINTER :: XTKEM_MEAN=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XPABSM_MEAN=>NULL()

REAL, DIMENSION(:,:,:), POINTER :: XU2_MEAN=>NULL(),XV2_MEAN=>NULL(),XW2_MEAN=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XTH2_MEAN=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XTEMP2_MEAN=>NULL() 
REAL, DIMENSION(:,:,:), POINTER :: XPABS2_MEAN=>NULL()

INTEGER, POINTER :: MEAN_COUNT =>NULL()

CONTAINS

SUBROUTINE MEAN_FIELD_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
MEAN_FIELD_MODEL(KFROM)%XUM_MEAN=>XUM_MEAN
MEAN_FIELD_MODEL(KFROM)%XVM_MEAN=>XVM_MEAN
MEAN_FIELD_MODEL(KFROM)%XWM_MEAN=>XWM_MEAN
MEAN_FIELD_MODEL(KFROM)%XTHM_MEAN=>XTHM_MEAN
MEAN_FIELD_MODEL(KFROM)%XTEMPM_MEAN=>XTEMPM_MEAN
MEAN_FIELD_MODEL(KFROM)%XTKEM_MEAN=>XTKEM_MEAN
MEAN_FIELD_MODEL(KFROM)%XPABSM_MEAN=>XPABSM_MEAN

MEAN_FIELD_MODEL(KFROM)%XU2_MEAN=>XU2_MEAN
MEAN_FIELD_MODEL(KFROM)%XV2_MEAN=>XV2_MEAN
MEAN_FIELD_MODEL(KFROM)%XW2_MEAN=>XW2_MEAN
MEAN_FIELD_MODEL(KFROM)%XTH2_MEAN=>XTH2_MEAN
MEAN_FIELD_MODEL(KFROM)%XTEMP2_MEAN=>XTEMP2_MEAN
MEAN_FIELD_MODEL(KFROM)%XPABS2_MEAN=>XPABS2_MEAN

!
! Current model is set to model KTO
XUM_MEAN=>MEAN_FIELD_MODEL(KTO)%XUM_MEAN
XVM_MEAN=>MEAN_FIELD_MODEL(KTO)%XVM_MEAN
XWM_MEAN=>MEAN_FIELD_MODEL(KTO)%XWM_MEAN
XTHM_MEAN=>MEAN_FIELD_MODEL(KTO)%XTHM_MEAN
XTEMPM_MEAN=>MEAN_FIELD_MODEL(KTO)%XTEMPM_MEAN
XTKEM_MEAN=>MEAN_FIELD_MODEL(KTO)%XTKEM_MEAN
XPABSM_MEAN=>MEAN_FIELD_MODEL(KTO)%XPABSM_MEAN

XU2_MEAN=>MEAN_FIELD_MODEL(KTO)%XU2_MEAN
XV2_MEAN=>MEAN_FIELD_MODEL(KTO)%XV2_MEAN
XW2_MEAN=>MEAN_FIELD_MODEL(KTO)%XW2_MEAN
XTH2_MEAN=>MEAN_FIELD_MODEL(KTO)%XTH2_MEAN
XTEMP2_MEAN=>MEAN_FIELD_MODEL(KTO)%XTEMP2_MEAN
XPABS2_MEAN=>MEAN_FIELD_MODEL(KTO)%XPABS2_MEAN

MEAN_COUNT=>MEAN_FIELD_MODEL(KTO)%MEAN_COUNT

END SUBROUTINE MEAN_FIELD_GOTO_MODEL

END MODULE MODD_MEAN_FIELD_n

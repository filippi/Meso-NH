!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$ $Date$
!-----------------------------------------------------------------
!-----------------------------------------------------------------
!-----------------------------------------------------------------
!     #####################
      MODULE MODD_CH_CONST_n
!     ######################
!
!!
!!    PURPOSE
!!    -------
!     
!   
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None
!!
!
!!    AUTHOR
!!    ------
!!  P. Tulet  (16/01/01) *Meteo France*
!!  M. Leriche (9/12/09) passage en $n
!!
!!    MODIFICATIONS
!!    -------------
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE CH_CONST_t
!

  REAL, DIMENSION(:), POINTER :: XSREALMASSMOLVAL ! final molecular
                                                          ! diffusivity value
  REAL, DIMENSION(:), POINTER :: XSREALREACTVAL ! final chemical
                                                        ! reactivity factor
                                                        ! with biologie
  REAL, DIMENSION(:,:), POINTER :: XSREALHENRYVAL ! chemical Henry
                                                          ! constant value
  REAL                            :: XCONVERSION ! emission unit 
                                                     ! conversion factor
!


END TYPE CH_CONST_t

TYPE(CH_CONST_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: CH_CONST_MODEL

REAL, DIMENSION(:), POINTER :: XSREALMASSMOLVAL=>NULL()
REAL, DIMENSION(:), POINTER :: XSREALREACTVAL=>NULL()
REAL, DIMENSION(:,:), POINTER :: XSREALHENRYVAL=>NULL()
REAL, POINTER :: XCONVERSION=>NULL()

CONTAINS

SUBROUTINE CH_CONST_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
CH_CONST_MODEL(KFROM)%XSREALMASSMOLVAL=>XSREALMASSMOLVAL
CH_CONST_MODEL(KFROM)%XSREALREACTVAL=>XSREALREACTVAL
CH_CONST_MODEL(KFROM)%XSREALHENRYVAL=>XSREALHENRYVAL
!
! Current model is set to model KTO
XSREALMASSMOLVAL=>CH_CONST_MODEL(KTO)%XSREALMASSMOLVAL
XSREALREACTVAL=>CH_CONST_MODEL(KTO)%XSREALREACTVAL
XSREALHENRYVAL=>CH_CONST_MODEL(KTO)%XSREALHENRYVAL
XCONVERSION=>CH_CONST_MODEL(KTO)%XCONVERSION

END SUBROUTINE CH_CONST_GOTO_MODEL

END MODULE MODD_CH_CONST_n

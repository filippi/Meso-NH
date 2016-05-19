!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/06/28 09:45:01
!-----------------------------------------------------------------
!     #####################
      MODULE MODD_LSFIELD_n
!     #####################
!
!!****  *MODD_LSFIELD$n* - declaration of Larger Scale variables
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to specify  the
!    larger scale variables.
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (module MODD_LSFIELDn)
!!
!!
!!    AUTHOR
!!    ------
!!  J.Stein   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    06/12/94
!!                  15/03/95  (J.Stein)  remove R from the historical variables
!!                  21/01/97  (J.P.Lafore) extention to all variables though
!!                                 2D arrays to store values at lateral boundaries
!!                  20/05/06  Remove EPS
!-------------------------------------------------------------------------------
!
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE LSFIELD_t
!
!  Large scale variables for variables which are relaxed at the model top
!
  REAL, DIMENSION(:,:,:), POINTER :: XLSUM=>NULL(),XLSVM=>NULL(),XLSWM=>NULL() !  
!                              ! U,V,W for larger scales at time t-dt
  REAL, DIMENSION(:,:,:), POINTER :: XLSTHM=>NULL()     ! theta at 
!                              ! time t-dt for larger scales 
  REAL, DIMENSION(:,:,:), POINTER :: XLSRVM=>NULL() ! Rv (mixing ratio for vapor)
!                              ! at time t-dt for larger scales 
  REAL, DIMENSION(:,:,:), POINTER :: XLSUS=>NULL(),XLSVS=>NULL(),XLSWS=>NULL() ! Tendency of 
                              ! U,V,W for larger scales 
  REAL, DIMENSION(:,:,:), POINTER :: XLSTHS=>NULL()     ! Tendency of 
                              ! theta for larger scales
  REAL, DIMENSION(:,:,:), POINTER :: XLSRVS=>NULL() ! Tendency of 
!                              ! RV for larger scales
!    previously  present for LS for V * Prhodj
!
!  Large scale variables for horizontal lbc
!
     ! larger scales values at X-dir lateral boundaries at time t-dt
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXUM=>NULL(),XLBXVM=>NULL(),XLBXWM=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXTHM=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXTKEM=>NULL()
  REAL, DIMENSION(:,:,:,:), POINTER :: XLBXRM=>NULL(), XLBXSVM=>NULL()
     ! larger scales tendency at X-dir lateral boundaries
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXUS=>NULL(),XLBXVS=>NULL(),XLBXWS=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXTHS=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBXTKES=>NULL()
  REAL, DIMENSION(:,:,:,:), POINTER :: XLBXRS=>NULL(), XLBXSVS=>NULL()
!
     ! larger scales values at Y-dir lateral boundaries at time t-dt
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYUM=>NULL(),XLBYVM=>NULL(),XLBYWM=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYTHM=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYTKEM=>NULL()
  REAL, DIMENSION(:,:,:,:), POINTER :: XLBYRM=>NULL(), XLBYSVM=>NULL()
     ! larger scales tendency at Y-dir lateral boundaries
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYUS=>NULL(),XLBYVS=>NULL(),XLBYWS=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYTHS=>NULL()
  REAL, DIMENSION(:,:,:),   POINTER :: XLBYTKES=>NULL()
  REAL, DIMENSION(:,:,:,:), POINTER :: XLBYRS=>NULL(), XLBYSVS=>NULL()
!
! Coefficient for linear vertical interpolatiuon of the larger scales
! fields for lateral boundaries
  REAL, DIMENSION(:,:,:), POINTER :: XCOEFLIN_LBXU=>NULL(),XCOEFLIN_LBXV=>NULL(), &
                                     XCOEFLIN_LBXW=>NULL(),XCOEFLIN_LBXM=>NULL(), &
                                     XCOEFLIN_LBYU=>NULL(),XCOEFLIN_LBYV=>NULL(), &
                                     XCOEFLIN_LBYW=>NULL(),XCOEFLIN_LBYM=>NULL()
  INTEGER, DIMENSION(:,:,:), POINTER :: NKLIN_LBXU=>NULL(),NKLIN_LBXV=>NULL(), &
                                        NKLIN_LBXW=>NULL(),NKLIN_LBXM=>NULL(), &
                                        NKLIN_LBYU=>NULL(),NKLIN_LBYV=>NULL(), &
                                        NKLIN_LBYW=>NULL(),NKLIN_LBYM=>NULL()
END TYPE LSFIELD_t

TYPE(LSFIELD_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: LSFIELD_MODEL

REAL, DIMENSION(:,:,:), POINTER :: XLSUM=>NULL(),XLSVM=>NULL(),XLSWM=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XLSTHM=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XLSRVM=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XLSUS=>NULL(),XLSVS=>NULL(),XLSWS=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XLSTHS=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XLSRVS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXUM=>NULL(),XLBXVM=>NULL(),XLBXWM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXTHM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXTKEM=>NULL()
REAL, DIMENSION(:,:,:,:), POINTER :: XLBXRM=>NULL(),XLBXSVM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXUS=>NULL(),XLBXVS=>NULL(),XLBXWS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXTHS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBXTKES=>NULL()
REAL, DIMENSION(:,:,:,:), POINTER :: XLBXRS=>NULL(),XLBXSVS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYUM=>NULL(),XLBYVM=>NULL(),XLBYWM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYTHM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYTKEM=>NULL()
REAL, DIMENSION(:,:,:,:), POINTER :: XLBYRM=>NULL(),XLBYSVM=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYUS=>NULL(),XLBYVS=>NULL(),XLBYWS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYTHS=>NULL()
REAL, DIMENSION(:,:,:),   POINTER :: XLBYTKES=>NULL()
REAL, DIMENSION(:,:,:,:), POINTER :: XLBYRS=>NULL(),XLBYSVS=>NULL()
REAL, DIMENSION(:,:,:),    POINTER :: XCOEFLIN_LBXU=>NULL(),XCOEFLIN_LBXV=>NULL(), &
XCOEFLIN_LBXW=>NULL(),XCOEFLIN_LBXM=>NULL(), &
XCOEFLIN_LBYU=>NULL(),XCOEFLIN_LBYV=>NULL(), &
XCOEFLIN_LBYW=>NULL(),XCOEFLIN_LBYM=>NULL()
INTEGER, DIMENSION(:,:,:), POINTER :: NKLIN_LBXU=>NULL(),NKLIN_LBXV=>NULL(), &
NKLIN_LBXW=>NULL(),NKLIN_LBXM=>NULL(), &
NKLIN_LBYU=>NULL(),NKLIN_LBYV=>NULL(), &
NKLIN_LBYW=>NULL(),NKLIN_LBYM=>NULL()

CONTAINS

SUBROUTINE LSFIELD_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
LSFIELD_MODEL(KFROM)%XLSUM=>XLSUM
LSFIELD_MODEL(KFROM)%XLSVM=>XLSVM
LSFIELD_MODEL(KFROM)%XLSWM=>XLSWM
LSFIELD_MODEL(KFROM)%XLSTHM=>XLSTHM
LSFIELD_MODEL(KFROM)%XLSRVM=>XLSRVM
LSFIELD_MODEL(KFROM)%XLSUS=>XLSUS
LSFIELD_MODEL(KFROM)%XLSVS=>XLSVS
LSFIELD_MODEL(KFROM)%XLSWS=>XLSWS
LSFIELD_MODEL(KFROM)%XLSTHS=>XLSTHS
LSFIELD_MODEL(KFROM)%XLSRVS=>XLSRVS
LSFIELD_MODEL(KFROM)%XLBXUM=>XLBXUM
LSFIELD_MODEL(KFROM)%XLBXVM=>XLBXVM
LSFIELD_MODEL(KFROM)%XLBXWM=>XLBXWM
LSFIELD_MODEL(KFROM)%XLBXTHM=>XLBXTHM
LSFIELD_MODEL(KFROM)%XLBXTKEM=>XLBXTKEM
LSFIELD_MODEL(KFROM)%XLBXRM=>XLBXRM
LSFIELD_MODEL(KFROM)%XLBXSVM=>XLBXSVM
LSFIELD_MODEL(KFROM)%XLBXUS=>XLBXUS
LSFIELD_MODEL(KFROM)%XLBXVS=>XLBXVS
LSFIELD_MODEL(KFROM)%XLBXWS=>XLBXWS
LSFIELD_MODEL(KFROM)%XLBXTHS=>XLBXTHS
LSFIELD_MODEL(KFROM)%XLBXTKES=>XLBXTKES
LSFIELD_MODEL(KFROM)%XLBXRS=>XLBXRS
LSFIELD_MODEL(KFROM)%XLBXSVS=>XLBXSVS
LSFIELD_MODEL(KFROM)%XLBYUM=>XLBYUM
LSFIELD_MODEL(KFROM)%XLBYVM=>XLBYVM
LSFIELD_MODEL(KFROM)%XLBYWM=>XLBYWM
LSFIELD_MODEL(KFROM)%XLBYTHM=>XLBYTHM
LSFIELD_MODEL(KFROM)%XLBYTKEM=>XLBYTKEM
LSFIELD_MODEL(KFROM)%XLBYRM=>XLBYRM
LSFIELD_MODEL(KFROM)%XLBYSVM=>XLBYSVM
LSFIELD_MODEL(KFROM)%XLBYUS=>XLBYUS
LSFIELD_MODEL(KFROM)%XLBYVS=>XLBYVS
LSFIELD_MODEL(KFROM)%XLBYWS=>XLBYWS
LSFIELD_MODEL(KFROM)%XLBYTHS=>XLBYTHS
LSFIELD_MODEL(KFROM)%XLBYTKES=>XLBYTKES
LSFIELD_MODEL(KFROM)%XLBYRS=>XLBYRS
LSFIELD_MODEL(KFROM)%XLBYSVS=>XLBYSVS
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBXU=>XCOEFLIN_LBXU
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBXV=>XCOEFLIN_LBXV
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBXW=>XCOEFLIN_LBXW
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBXM=>XCOEFLIN_LBXM
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBYU=>XCOEFLIN_LBYU
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBYV=>XCOEFLIN_LBYV
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBYW=>XCOEFLIN_LBYW
LSFIELD_MODEL(KFROM)%XCOEFLIN_LBYM=>XCOEFLIN_LBYM
LSFIELD_MODEL(KFROM)%NKLIN_LBXU=>NKLIN_LBXU
LSFIELD_MODEL(KFROM)%NKLIN_LBXV=>NKLIN_LBXV
LSFIELD_MODEL(KFROM)%NKLIN_LBXW=>NKLIN_LBXW
LSFIELD_MODEL(KFROM)%NKLIN_LBXM=>NKLIN_LBXM
LSFIELD_MODEL(KFROM)%NKLIN_LBYU=>NKLIN_LBYU
LSFIELD_MODEL(KFROM)%NKLIN_LBYV=>NKLIN_LBYV
LSFIELD_MODEL(KFROM)%NKLIN_LBYW=>NKLIN_LBYW
LSFIELD_MODEL(KFROM)%NKLIN_LBYM=>NKLIN_LBYM
!
! Current model is set to model KTO
XLSUM=>LSFIELD_MODEL(KTO)%XLSUM
XLSVM=>LSFIELD_MODEL(KTO)%XLSVM
XLSWM=>LSFIELD_MODEL(KTO)%XLSWM
XLSTHM=>LSFIELD_MODEL(KTO)%XLSTHM
XLSRVM=>LSFIELD_MODEL(KTO)%XLSRVM
XLSUS=>LSFIELD_MODEL(KTO)%XLSUS
XLSVS=>LSFIELD_MODEL(KTO)%XLSVS
XLSWS=>LSFIELD_MODEL(KTO)%XLSWS
XLSTHS=>LSFIELD_MODEL(KTO)%XLSTHS
XLSRVS=>LSFIELD_MODEL(KTO)%XLSRVS
XLBXUM=>LSFIELD_MODEL(KTO)%XLBXUM
XLBXVM=>LSFIELD_MODEL(KTO)%XLBXVM
XLBXWM=>LSFIELD_MODEL(KTO)%XLBXWM
XLBXTHM=>LSFIELD_MODEL(KTO)%XLBXTHM
XLBXTKEM=>LSFIELD_MODEL(KTO)%XLBXTKEM
XLBXRM=>LSFIELD_MODEL(KTO)%XLBXRM
XLBXSVM=>LSFIELD_MODEL(KTO)%XLBXSVM
XLBXUS=>LSFIELD_MODEL(KTO)%XLBXUS
XLBXVS=>LSFIELD_MODEL(KTO)%XLBXVS
XLBXWS=>LSFIELD_MODEL(KTO)%XLBXWS
XLBXTHS=>LSFIELD_MODEL(KTO)%XLBXTHS
XLBXTKES=>LSFIELD_MODEL(KTO)%XLBXTKES
XLBXRS=>LSFIELD_MODEL(KTO)%XLBXRS
XLBXSVS=>LSFIELD_MODEL(KTO)%XLBXSVS
XLBYUM=>LSFIELD_MODEL(KTO)%XLBYUM
XLBYVM=>LSFIELD_MODEL(KTO)%XLBYVM
XLBYWM=>LSFIELD_MODEL(KTO)%XLBYWM
XLBYTHM=>LSFIELD_MODEL(KTO)%XLBYTHM
XLBYTKEM=>LSFIELD_MODEL(KTO)%XLBYTKEM
XLBYRM=>LSFIELD_MODEL(KTO)%XLBYRM
XLBYSVM=>LSFIELD_MODEL(KTO)%XLBYSVM
XLBYUS=>LSFIELD_MODEL(KTO)%XLBYUS
XLBYVS=>LSFIELD_MODEL(KTO)%XLBYVS
XLBYWS=>LSFIELD_MODEL(KTO)%XLBYWS
XLBYTHS=>LSFIELD_MODEL(KTO)%XLBYTHS
XLBYTKES=>LSFIELD_MODEL(KTO)%XLBYTKES
XLBYRS=>LSFIELD_MODEL(KTO)%XLBYRS
XLBYSVS=>LSFIELD_MODEL(KTO)%XLBYSVS
XCOEFLIN_LBXU=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBXU
XCOEFLIN_LBXV=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBXV
XCOEFLIN_LBXW=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBXW
XCOEFLIN_LBXM=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBXM
XCOEFLIN_LBYU=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBYU
XCOEFLIN_LBYV=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBYV
XCOEFLIN_LBYW=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBYW
XCOEFLIN_LBYM=>LSFIELD_MODEL(KTO)%XCOEFLIN_LBYM
NKLIN_LBXU=>LSFIELD_MODEL(KTO)%NKLIN_LBXU
NKLIN_LBXV=>LSFIELD_MODEL(KTO)%NKLIN_LBXV
NKLIN_LBXW=>LSFIELD_MODEL(KTO)%NKLIN_LBXW
NKLIN_LBXM=>LSFIELD_MODEL(KTO)%NKLIN_LBXM
NKLIN_LBYU=>LSFIELD_MODEL(KTO)%NKLIN_LBYU
NKLIN_LBYV=>LSFIELD_MODEL(KTO)%NKLIN_LBYV
NKLIN_LBYW=>LSFIELD_MODEL(KTO)%NKLIN_LBYW
NKLIN_LBYM=>LSFIELD_MODEL(KTO)%NKLIN_LBYM

END SUBROUTINE LSFIELD_GOTO_MODEL

END MODULE MODD_LSFIELD_n

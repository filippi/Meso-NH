!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$ $Date$
!-----------------------------------------------------------------
!-----------------------------------------------------------------
!-----------------------------------------------------------------
!     ####################
      MODULE MODI_EXCHANGE
!     ####################
!
INTERFACE
!
!     ##############################################################################
      SUBROUTINE EXCHANGE (PTSTEP,PTSTEP_MET,PTSTEP_SV,KRR,KSV,PRHODJ,TPFIELDS_ll, &
                           PRUS,PRVS,PRWS,PRTHS,PRRS,PRTKES,PRSVS                  )
!     ##############################################################################
!
USE MODD_ARGSLIST_ll, ONLY : LIST_ll
!
REAL,                     INTENT(IN) :: PTSTEP            !  Double Time step
                                       ! (or single if cold start)
REAL,                     INTENT(IN) :: PTSTEP_MET        !  Time step for
                                       ! scalar meteorological variables
REAL,                     INTENT(IN) :: PTSTEP_SV         !  Time step for
                                       ! scalar tracer variables
INTEGER,                  INTENT(IN) :: KRR               !  Number of water var.
INTEGER,                  INTENT(IN) :: KSV               !  Number of scal. var.
                                                          ! (=1 at the segment beginning)
REAL, DIMENSION(:,:,:),   INTENT(IN) :: PRHODJ            ! (Rho) dry * Jacobian
TYPE(LIST_ll), POINTER               :: TPFIELDS_ll       ! list of fields to exchange
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PRUS,PRVS,PRWS,   &!
                                           PRTHS,PRTKES       ! Source terms
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRRS,PRSVS         !
!
END SUBROUTINE EXCHANGE
!
END INTERFACE
!
END MODULE MODI_EXCHANGE
!
!
!
!     #######################################################################
      SUBROUTINE EXCHANGE (PTSTEP,PTSTEP_MET,PTSTEP_SV,KRR,KSV,PRHODJ,TPFIELDS_ll, &
                           PRUS,PRVS,PRWS,PRTHS,PRRS,PRTKES,PRSVS                  )
!     #######################################################################
!
!!****  * EXCHANGE* - update the halo of each subdomains for the variables at time step t+dt
!!
!!    PURPOSE
!!    -------
!!
!!    The purpose of EXCHANGE is to transform the source terms in the variables at time step t+dt
!!    and update the halo of each subdomains. This routine also takes into account the
!!    cyclic conditions
!
!!**  METHOD
!!    ------
!!    The source term is multipied by twice the time step (except for the first time step)
!!    and divided by ( rhod J ) to obtain the value of the variables at
!!    time step t+dt. The halos of these fields are updated with the values computed by the
!!    neighbor subdomains. Cyclic conditions are treated during this exchange.
!!
!!    EXTERNAL
!!    --------
!!       UPDATE_HALO_ll  :   routine to update the halo
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!          MODD_CONF
!!
!!    REFERENCE
!!    ---------
!!    Book2 of documentation
!!
!!    AUTHOR
!!    ------
!!    P. Jabouille  Meteo France
!!
!!    MODIFICATIONS
!!    -------------
!!
!!    original     18/09/98
!!                 05/2006   Remove KEPS
!!                 10/2009 (C.Lac) FIT for variables advected by PPM
!------------------------------------------------------------------------------
!
!*      0.   DECLARATIONS
!            ------------
!
USE MODE_ll
!
USE MODD_ARGSLIST_ll, ONLY : LIST_ll
USE MODD_CONF, ONLY : CCONF
USE MODD_GRID_n
USE MODI_SHUMAN
!
IMPLICIT NONE
!
!*      0.1  DECLARATIONS OF ARGUMENTS
!
REAL,                     INTENT(IN) :: PTSTEP            !  Double Time step
                                       ! (or single if cold start)
REAL,                     INTENT(IN) :: PTSTEP_MET        !  Time step for
                                       ! scalar meteorological variables
REAL,                     INTENT(IN) :: PTSTEP_SV         !  Time step for
                                       ! scalar tracer variables
INTEGER,                  INTENT(IN) :: KRR               !  Number of water var.
INTEGER,                  INTENT(IN) :: KSV               !  Number of scal. var.
REAL, DIMENSION(:,:,:),   INTENT(IN) :: PRHODJ            ! (Rho) dry * Jacobian
TYPE(LIST_ll), POINTER               :: TPFIELDS_ll       ! list of fields to exchange
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PRUS,PRVS,PRWS,   &!
                                           PRTHS,PRTKES       ! Source terms
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRRS,PRSVS         !
!
!!
!*      0.2  DECLARATIONS OF LOCAL VARIABLES
!
INTEGER   :: IINFO_ll              ! return code of parallel routine
INTEGER   :: JRR,JSV              ! loop counters
REAL      :: ZTSTEP               !  Time step for temporal advance
!
INTEGER :: IKU
!------------------------------------------------------------------------------
!
IKU=SIZE(XZHAT)
!*       1.     TRANSFORMS THE SOURCE TERMS INTO PROGNOSTIC VARIABLES
!               -----------------------------------------------------
!
!        1.a Momentum variables
!
PRUS(:,:,:) = PRUS(:,:,:)*PTSTEP / MXM(PRHODJ)
PRVS(:,:,:) = PRVS(:,:,:)*PTSTEP / MYM(PRHODJ)
PRWS(:,:,:) = PRWS(:,:,:)*PTSTEP / MZM(1,IKU,1,PRHODJ)
!
!        1.b Meteorological scalar variables
!
PRTHS(:,:,:) = PRTHS(:,:,:)*PTSTEP_MET/PRHODJ
DO JRR=1,KRR
  PRRS(:,:,:,JRR) = PRRS(:,:,:,JRR)*PTSTEP_MET/PRHODJ
END DO
IF (SIZE(PRTKES,1) /= 0) PRTKES(:,:,:) = PRTKES(:,:,:)*PTSTEP_MET/PRHODJ
!
!        1.c Tracer scalar variables
!
DO JSV=1,KSV
  PRSVS(:,:,:,JSV) = PRSVS(:,:,:,JSV)*PTSTEP_SV/PRHODJ
END DO
!
!------------------------------------------------------------------------------
!
!*      2      UPDATE THE FIRST LAYER OF THE HALO
!              ----------------------------------
!
CALL UPDATE_HALO_ll(TPFIELDS_ll, IINFO_ll)
!
END SUBROUTINE EXCHANGE

!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 spawn 2006/05/19 18:48:54
!-----------------------------------------------------------------
!#######################
MODULE MODI_VER_INTERP_FIELD
!#######################
!
INTERFACE
!
      SUBROUTINE VER_INTERP_FIELD(HTURB,KRR,KSV,PZZ_LS,PZZ,                    &
                              PUT,PVT,PWT,PTHVT,PRT,PHUT,PTKET,PSVT,           &
                              PSRCT,PSIGS,                                     &
                              PLSUM,PLSVM,PLSWM,PLSTHM,PLSRVM                  )
!
CHARACTER (LEN=4), INTENT(IN) :: HTURB !  Kind of turbulence parameterization
INTEGER,           INTENT(IN) :: KRR   ! number of moist variables
INTEGER,           INTENT(IN) :: KSV   ! number of scalar variables
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ_LS ! initial 3D grid
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ    ! new     3D grid
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PUT,PVT,PWT        !  model 2
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PTKET              ! variables
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRT,PSVT           !   at t
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PTHVT,PHUT         !
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PSRCT,PSIGS  ! secondary
                                                            ! prognostic variables
           ! Larger Scale fields
REAL, DIMENSION(:,:,:),          INTENT(INOUT) :: PLSUM, PLSVM, PLSWM  ! Wind
REAL, DIMENSION(:,:,:),          INTENT(INOUT) :: PLSTHM,  PLSRVM      ! Mass
END SUBROUTINE VER_INTERP_FIELD
!
END INTERFACE
!
END MODULE MODI_VER_INTERP_FIELD
!
!     ##########################################################################
      SUBROUTINE VER_INTERP_FIELD(HTURB,KRR,KSV,PZZ_LS,PZZ,                    &
                              PUT,PVT,PWT,PTHVT,PRT,PHUT,PTKET,PSVT,           &
                              PSRCT,PSIGS,                                     &
                              PLSUM,PLSVM,PLSWM,PLSTHM,PLSRVM                  )
!     ##########################################################################
!
!!****  *VER_INTERP_FIELD * - interpolate the 3D and LS 2D fields from one
!!                            vertical grid PZZ_LS to another PZZ
!!
!!    PURPOSE
!!    -------
!!
!!
!!**  METHOD
!!    ------
!!
!!
!!    EXTERNAL
!!    --------
!!
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!       Book1 of the documentation
!!       SUBROUTINE VER_INTERP_FIELD (Book2 of the documentation)
!!
!!
!!    AUTHOR
!!    ------
!!
!!       V. Masson     * METEO-FRANCE *
!!
!!    MODIFICATIONS
!!    -------------
!!
!!      Original    17/07/97
!!                  14/09/97 (V. Masson) Interpolation of relative humidity
!!                  05/06     Remobe KEPS
!-------------------------------------------------------------------------------
!
!*       0.     DECLARATIONS
!               ------------
!
USE MODD_CONF_n, ONLY : CONF_MODEL
USE MODD_CTURB
USE MODD_PARAMETERS
USE MODD_VER_INTERP_LIN
!
USE MODI_SHUMAN
USE MODI_COEF_VER_INTERP_LIN
USE MODI_VER_INTERP_LIN
!
IMPLICIT NONE
!
!*       0.1   Declarations of dummy arguments :
!
!
CHARACTER (LEN=4), INTENT(IN) :: HTURB !  Kind of turbulence parameterization
INTEGER,           INTENT(IN) :: KRR   ! number of moist variables
INTEGER,           INTENT(IN) :: KSV   ! number of scalar variables
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ_LS ! initial 3D grid
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ    ! new     3D grid
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PUT,PVT,PWT        !  model 2
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PTKET              ! variables
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRT,PSVT           !   at t
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PTHVT,PHUT         !
!
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PSRCT,PSIGS  ! secondary
                                                       ! prognostic variables
           ! Larger Scale fields
REAL, DIMENSION(:,:,:),          INTENT(INOUT) :: PLSUM, PLSVM, PLSWM  ! Wind
REAL, DIMENSION(:,:,:),          INTENT(INOUT) :: PLSTHM,  PLSRVM      ! Mass
!*       0.2    Declarations of local variables
!
INTEGER :: JRR, JSV
INTEGER :: IKU
INTEGER :: IKB
REAL, DIMENSION(SIZE(PZZ_LS,1),SIZE(PZZ_LS,2),SIZE(PZZ_LS,3)) :: ZGRID1, ZGRID2
!-------------------------------------------------------------------------------
!
!*       1.     Prologue
!               --------
!
IKU=SIZE(PZZ,3)
!
IKB=1+JPVEXT
!
!-------------------------------------------------------------------------------
!
!*       2.     variables which always exist
!               ----------------------------
!
!*       2.1    U component
!               -----------
!
!* shift of grids to mass points
ZGRID1(:,:,:)=MZF(1,IKU,1,PZZ_LS(:,:,:))
ZGRID1(:,:,IKU)=2.*ZGRID1(:,:,IKU-1)-ZGRID1(:,:,IKU-2)
ZGRID2(:,:,:)=MZF(1,IKU,1,PZZ(:,:,:))
ZGRID2(:,:,IKU)=2.*ZGRID2(:,:,IKU-1)-ZGRID2(:,:,IKU-2)
!* move the first physical level if above the target grid
ZGRID1(:,:,1:IKB)=MIN(ZGRID1(:,:,1:IKB),ZGRID2(:,:,1:IKB))
!* shift to U points
ZGRID1(:,:,:)=MXM(ZGRID1(:,:,:))
ZGRID1(1,:,:)=2.*ZGRID1(2,:,:)-ZGRID1(3,:,:)
ZGRID2(:,:,:)=MXM(ZGRID2(:,:,:))
ZGRID2(1,:,:)=2.*ZGRID2(2,:,:)-ZGRID2(3,:,:)
!
CALL COEF_VER_INTERP_LIN(ZGRID1(:,:,:),ZGRID2(:,:,:))
!
PUT  (:,:,:)   =  VER_INTERP_LIN(PUT   (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
PLSUM (:,:,:)  =  VER_INTERP_LIN(PLSUM (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
!
!*       2.2    V component
!               -----------
!
!* shift of grids to mass points
ZGRID1(:,:,:)=MZF(1,IKU,1,PZZ_LS(:,:,:))
ZGRID1(:,:,IKU)=2.*ZGRID1(:,:,IKU-1)-ZGRID1(:,:,IKU-2)
ZGRID2(:,:,:)=MZF(1,IKU,1,PZZ(:,:,:))
ZGRID2(:,:,IKU)=2.*ZGRID2(:,:,IKU-1)-ZGRID2(:,:,IKU-2)
!* move the first physical level if above the target grid
ZGRID1(:,:,1:IKB)=MIN(ZGRID1(:,:,1:IKB),ZGRID2(:,:,1:IKB))
!* shift to V points
ZGRID1(:,:,:)=MYM(ZGRID1(:,:,:))
ZGRID1(:,1,:)=2.*ZGRID1(:,2,:)-ZGRID1(:,3,:)
ZGRID2(:,:,:)=MYM(ZGRID2(:,:,:))
ZGRID2(:,1,:)=2.*ZGRID2(:,2,:)-ZGRID2(:,3,:)
!
CALL COEF_VER_INTERP_LIN(ZGRID1(:,:,:),ZGRID2(:,:,:))
!
PVT  (:,:,:)   =  VER_INTERP_LIN(PVT   (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
PLSVM (:,:,:)  =  VER_INTERP_LIN(PLSVM (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
!
!*       2.3    W component
!               -----------
!
ZGRID1(:,:,:)=PZZ_LS(:,:,:)
ZGRID2(:,:,:)=PZZ   (:,:,:)
!* move the first physical level if above the target grid
ZGRID1(:,:,1:IKB)=MIN(ZGRID1(:,:,1:IKB),ZGRID2(:,:,1:IKB))
!
CALL COEF_VER_INTERP_LIN(ZGRID1(:,:,:),ZGRID2(:,:,:))
!
PWT  (:,:,:)   =  VER_INTERP_LIN(PWT   (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
PLSWM (:,:,:)  =  VER_INTERP_LIN(PLSWM (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
!
!*       2.4    thermodynamical variables
!               -------------------------
!
!* shift of grids to mass points
ZGRID1(:,:,:)=MZF(1,IKU,1,PZZ_LS(:,:,:))
ZGRID1(:,:,IKU)=2.*ZGRID1(:,:,IKU-1)-ZGRID1(:,:,IKU-2)
ZGRID2(:,:,:)=MZF(1,IKU,1,PZZ(:,:,:))
ZGRID2(:,:,IKU)=2.*ZGRID2(:,:,IKU-1)-ZGRID2(:,:,IKU-2)
!
CALL COEF_VER_INTERP_LIN(ZGRID1(:,:,:),ZGRID2(:,:,:))
!
PTHVT (:,:,:)   =  VER_INTERP_LIN(PTHVT  (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
PLSTHM(:,:,:)  =  VER_INTERP_LIN(PLSTHM(:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
!
IF ( SIZE(PLSRVM,1) /= 0 ) THEN
  PLSRVM(:,:,:)  =  VER_INTERP_LIN(PLSRVM(:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PLSRVM=MAX(PLSRVM,0.)
END IF
!
!-------------------------------------------------------------------------------
!
!*       3.     moist variables
!               ---------------
!
DO JRR=1,KRR
  PRT  (:,:,:,JRR) =  VER_INTERP_LIN(PRT (:,:,:,JRR),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PRT (:,:,:,JRR) = MAX(PRT(:,:,:,JRR),0.)
END DO
!
IF (CONF_MODEL(1)%NRR>=1) THEN
  PHUT(:,:,:)   =  VER_INTERP_LIN(PHUT  (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PHUT(:,:,:)   = MIN(MAX(PHUT(:,:,:),0.),100.)
END IF
!
!-------------------------------------------------------------------------------
!
!*       4.     scalar variables
!               ----------------
!
DO JSV=1,KSV
  PSVT (:,:,:,JSV) =  VER_INTERP_LIN(PSVT (:,:,:,JSV),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PSVT (:,:,:,JSV) = MAX(PSVT(:,:,:,JSV),0.)
END DO
!
!-------------------------------------------------------------------------------
!
!*       5.     TKE variable
!               ------------
!
!* shift of grids to mass points
ZGRID1(:,:,:)=MZF(1,IKU,1,PZZ_LS(:,:,:))
ZGRID1(:,:,IKU)=2.*ZGRID1(:,:,IKU-1)-ZGRID1(:,:,IKU-2)
ZGRID2(:,:,:)=MZF(1,IKU,1,PZZ(:,:,:))
ZGRID2(:,:,IKU)=2.*ZGRID2(:,:,IKU-1)-ZGRID2(:,:,IKU-2)
!* move the first physical level if above the target grid
ZGRID1(:,:,1:IKB)=MIN(ZGRID1(:,:,1:IKB),ZGRID2(:,:,1:IKB))
!
CALL COEF_VER_INTERP_LIN(ZGRID1(:,:,:),ZGRID2(:,:,:))
!
IF (HTURB /= 'NONE') THEN
  PTKET(:,:,:)   =  VER_INTERP_LIN(PTKET (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PTKET=MAX(PTKET,XTKEMIN)
ENDIF
!
!
!-------------------------------------------------------------------------------
!
!*       6.     secondary prognostic variables
!               ------------------------------
!
IF (KRR > 1 .AND. HTURB /= 'NONE') THEN
  PSRCT (:,:,:) =  VER_INTERP_LIN(PSRCT (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
  PSIGS (:,:,:) =  VER_INTERP_LIN(PSIGS (:,:,:),NKLIN(:,:,:),XCOEFLIN(:,:,:))
ENDIF
!
!-------------------------------------------------------------------------------
!
DEALLOCATE(NKLIN)
DEALLOCATE(XCOEFLIN)
!-------------------------------------------------------------------------------
!
END SUBROUTINE VER_INTERP_FIELD
!

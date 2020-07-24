!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 mode 2006/05/18 13:07:25
!-----------------------------------------------------------------
!    #################### 
     MODULE MODE_PRANDTL
!    #################### 
!
!* modification 08/2010  V. Masson  smoothing of the discontinuity in functions 
!                                   used for implicitation of exchange coefficients
!               05/2020   V. Masson and C. Lac : bug in D_PHI3DTDZ2_O_DDTDZ
!
USE MODD_CTURB,      ONLY : XCTV, XCSHF, XCTD, XPHI_LIM, XCPR3, XCPR4, XCPR5
USE MODD_PARAMETERS, ONLY : JPVEXT_TURB
!
USE MODI_SHUMAN
IMPLICIT NONE
!----------------------------------------------------------------------------
CONTAINS
!----------------------------------------------------------------------------
SUBROUTINE SMOOTH_TURB_FUNCT(PPHI3,PF_LIM,PF)
!
REAL, DIMENSION(:,:,:), INTENT(IN)    :: PPHI3   ! Phi3
REAL, DIMENSION(:,:,:), INTENT(IN)    :: PF_LIM  ! Value of F when Phi3 is
!                                                ! larger than Phi_lim
REAL, DIMENSION(:,:,:), INTENT(INOUT) :: PF      ! function F to smooth
!
REAL, DIMENSION(SIZE(PF,1),SIZE(PF,2),SIZE(PF,3)) :: ZCOEF
!
!* adds a artificial correction to smooth the function near the discontinuity
!  point at Phi3 = Phi_lim
!  This smoothing is applied between 0.9*phi_lim (=2.7) and Phi_lim (=3)
!   Note that in the Boundary layer, phi is usually between 0.8 and 1
!
!
ZCOEF = MAX(MIN((  10.*(1.-PPHI3/XPHI_LIM)) ,1.), 0.) 
!
PF(:,:,:) =     ZCOEF(:,:,:)   * PF    &
          + (1.-ZCOEF(:,:,:))  * PF_LIM
!
END SUBROUTINE SMOOTH_TURB_FUNCT
!----------------------------------------------------------------------------
FUNCTION PHI3(PREDTH1,PREDR1,PRED2TH3,PRED2R3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2TH3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2R3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: PHI3
!
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: ZW1, ZW2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PREDTH1,3)-JPVEXT_TURB
!
IF (HTURBDIM=='3DIM') THEN
        !* 3DIM case
  IF (OUSERV) THEN
    ZW1(:,:,:) = 1. + 1.5* (PREDTH1(:,:,:)+PREDR1(:,:,:)) +      &
                   ( 0.5 * (PREDTH1(:,:,:)**2+PREDR1(:,:,:)**2)  &
                         + PREDTH1(:,:,:) * PREDR1(:,:,:)        &
                   )

    ZW2(:,:,:) = 0.5 * (PRED2TH3(:,:,:)-PRED2R3(:,:,:))

    PHI3(:,:,:)= 1. -                                          &
    ( ( (1.+PREDR1(:,:,:)) *                                   &
        (PRED2THR3(:,:,:) + PRED2TH3(:,:,:)) / PREDTH1(:,:,:)  &
      ) + ZW2(:,:,:)                                           &
    ) / ZW1(:,:,:)
  ELSE
    ZW1(:,:,:) = 1. + 1.5* PREDTH1(:,:,:) + &
                 0.5* PREDTH1(:,:,:)**2

    ZW2(:,:,:) = 0.5* PRED2TH3(:,:,:)

    PHI3(:,:,:)= 1. -                                       &
            (PRED2TH3(:,:,:) / PREDTH1(:,:,:) + ZW2(:,:,:)) / ZW1(:,:,:)
  END IF
  WHERE( PHI3 <= 0. .OR. PHI3 > XPHI_LIM )
    PHI3 = XPHI_LIM
  END WHERE

ELSE
        !* 1DIM case
  IF (OUSERV) THEN
    PHI3(:,:,:)= 1./(1.+PREDTH1(:,:,:)+PREDR1(:,:,:))
  ELSE
    PHI3(:,:,:)= 1./(1.+PREDTH1(:,:,:))
  END IF
END IF
!
PHI3(:,:,IKB-1)=PHI3(:,:,IKB)
PHI3(:,:,IKE+1)=PHI3(:,:,IKE)
!
END FUNCTION PHI3
!----------------------------------------------------------------------------
FUNCTION PSI_SV(PREDTH1,PREDR1,PREDS1,PRED2THS,PRED2RS,PPHI3,PPSI3)
  REAL, DIMENSION(:,:,:),   INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:),   INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:,:), INTENT(IN) :: PREDS1
  REAL, DIMENSION(:,:,:,:), INTENT(IN) :: PRED2THS
  REAL, DIMENSION(:,:,:,:), INTENT(IN) :: PRED2RS
  REAL, DIMENSION(:,:,:),   INTENT(IN) :: PPHI3
  REAL, DIMENSION(:,:,:),   INTENT(IN) :: PPSI3
  REAL, DIMENSION(SIZE(PRED2THS,1),SIZE(PRED2THS,2),SIZE(PRED2THS,3),SIZE(PRED2THS,4)) :: PSI_SV
!
  INTEGER :: IKB, IKE
  INTEGER :: JSV
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PREDTH1,3)-JPVEXT_TURB
!
DO JSV=1,SIZE(PSI_SV,4)
  PSI_SV(:,:,:,JSV) = ( 1.                                             &
    - (XCPR3+XCPR5) * (PRED2THS(:,:,:,JSV)/PREDS1(:,:,:,JSV)-PREDTH1) &
    - (XCPR4+XCPR5) * (PRED2RS (:,:,:,JSV)/PREDS1(:,:,:,JSV)-PREDR1 ) &
    - XCPR3 * PREDTH1 * PPHI3 - XCPR4 * PREDR1 * PPSI3                 &
                ) / (  1. + XCPR5 * ( PREDTH1 + PREDR1 ) )           
  
!        control of the PSI_SV positivity
  WHERE ( (PSI_SV(:,:,:,JSV) <=0.).AND. (PREDTH1+PREDR1) <= 0. )
    PSI_SV(:,:,:,JSV)=XPHI_LIM
  END WHERE
  PSI_SV(:,:,:,JSV) = MAX( 1.E-4, MIN(XPHI_LIM,PSI_SV(:,:,:,JSV)) )
!
  PSI_SV(:,:,IKB-1,JSV)=PSI_SV(:,:,IKB,JSV)
  PSI_SV(:,:,IKE+1,JSV)=PSI_SV(:,:,IKE,JSV)
END DO
!
END FUNCTION PSI_SV
!----------------------------------------------------------------------------
FUNCTION D_PHI3DTDZ_O_DDTDZ(PPHI3,PREDTH1,PREDR1,PRED2TH3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPHI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2TH3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PHI3DTDZ_O_DDTDZ
  INTEGER :: IKB, IKE,JL,JK,JJ
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PREDTH1,3)-JPVEXT_TURB
!
IF (HTURBDIM=='3DIM') THEN
        !* 3DIM case
  IF (OUSERV) THEN
    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
    D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)                       &
          * (1. - PREDTH1(:,:,:) * (3./2.+PREDTH1+PREDR1)          &
               /((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))) &
          + (1.+PREDR1)*(PRED2THR3+PRED2TH3)                       &
               / (PREDTH1*(1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1))) &
          - (1./2.*PREDTH1+PREDR1 * (1.+PREDTH1+PREDR1))           &
               / ((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))
    ELSEWHERE
      D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)
    ENDWHERE

!
  ELSE
    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
    D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)             &
          * (1. - PREDTH1(:,:,:) * (3./2.+PREDTH1)      &
               /((1.+PREDTH1)*(1.+1./2.*PREDTH1)))        &
          + PRED2TH3 / (PREDTH1*(1.+PREDTH1)*(1.+1./2.*PREDTH1)) &
          - 1./2.*PREDTH1 / ((1.+PREDTH1)*(1.+1./2.*PREDTH1))
    ELSEWHERE
      D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)
    ENDWHERE
!
  END IF
ELSE
        !* 1DIM case
!  WHERE (PPHI3(:,:,:)<=XPHI_LIM)
!    D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)                           &
!        * (1. - PREDTH1(:,:,:)*PPHI3(:,:,:))
!  ELSEWHERE
!    D_PHI3DTDZ_O_DDTDZ(:,:,:) = PPHI3(:,:,:)
!  ENDWHERE
DO JJ=1,SIZE(PPHI3,2)
  DO JL=1,SIZE(PPHI3,1)
    DO JK=1,SIZE(PPHI3,3)
      IF ( ABS(PPHI3(JL,JJ,JK)-XPHI_LIM) < 1.E-12 ) THEN
         D_PHI3DTDZ_O_DDTDZ(JL,JJ,JK)=PPHI3(JL,JJ,JK)*&
&       (1. - PREDTH1(JL,JJ,JK)*PPHI3(JL,JJ,JK))
      ELSE
         D_PHI3DTDZ_O_DDTDZ(JL,JJ,JK)=PPHI3(JL,JJ,JK)
      ENDIF
    ENDDO
  ENDDO
ENDDO
END IF
!
!* smoothing
CALL SMOOTH_TURB_FUNCT(PPHI3,PPHI3,D_PHI3DTDZ_O_DDTDZ)
!
D_PHI3DTDZ_O_DDTDZ(:,:,IKB-1)=D_PHI3DTDZ_O_DDTDZ(:,:,IKB)
D_PHI3DTDZ_O_DDTDZ(:,:,IKE+1)=D_PHI3DTDZ_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_PHI3DTDZ_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION D_PHI3DRDZ_O_DDRDZ(PPHI3,PREDTH1,PREDR1,PRED2TH3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPHI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2TH3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
   REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PHI3DRDZ_O_DDRDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PREDTH1,3)-JPVEXT_TURB
!
!
IF (HTURBDIM=='3DIM') THEN
        !* 3DIM case
  IF (OUSERV) THEN
    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
      D_PHI3DRDZ_O_DDRDZ(:,:,:) =          &
                PPHI3(:,:,:) * (1.-PREDR1(:,:,:)*(3./2.+PREDTH1+PREDR1) &
                  / ((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1))))  &
              - PREDR1(:,:,:) * (PRED2THR3+PRED2TH3) / (PREDTH1         &
                  * (1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))    &
              + PREDR1(:,:,:) * (1./2.+PREDTH1+PREDR1)                  &
                  / ((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))
    ELSEWHERE
      D_PHI3DRDZ_O_DDRDZ(:,:,:) = PPHI3(:,:,:)
    END WHERE
  ELSE
    D_PHI3DRDZ_O_DDRDZ(:,:,:) = PPHI3(:,:,:)
  END IF
ELSE
        !* 1DIM case
  WHERE (PPHI3(:,:,:)<=XPHI_LIM)
    D_PHI3DRDZ_O_DDRDZ(:,:,:) = PPHI3(:,:,:)                           &
          * (1. - PREDR1(:,:,:)*PPHI3(:,:,:))
  ELSEWHERE
    D_PHI3DRDZ_O_DDRDZ(:,:,:) = PPHI3(:,:,:)
  END WHERE
END IF
!
!* smoothing
CALL SMOOTH_TURB_FUNCT(PPHI3,PPHI3,D_PHI3DRDZ_O_DDRDZ)
!
D_PHI3DRDZ_O_DDRDZ(:,:,IKB-1)=D_PHI3DRDZ_O_DDRDZ(:,:,IKB)
D_PHI3DRDZ_O_DDRDZ(:,:,IKE+1)=D_PHI3DRDZ_O_DDRDZ(:,:,IKE)
!
END FUNCTION D_PHI3DRDZ_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION D_PHI3DTDZ2_O_DDTDZ(PPHI3,PREDTH1,PREDR1,PRED2TH3,PRED2THR3,PDTDZ,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPHI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2TH3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PHI3DTDZ2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PREDTH1,3)-JPVEXT_TURB
!
!
IF (HTURBDIM=='3DIM') THEN
   ! by derivation of (phi3 dtdz) * dtdz according to dtdz we obtain:
   D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PDTDZ * (PPHI3 +  &
           D_PHI3DTDZ_O_DDTDZ(PPHI3,PREDTH1,PREDR1,PRED2TH3,PRED2THR3,HTURBDIM,OUSERV) )

!        !* 3DIM case
!  IF (OUSERV) THEN
!    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
!    D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:)                      &
!          * PDTDZ(:,:,:)*(2.-PREDTH1(:,:,:)*(3./2.+PREDTH1+PREDR1) &
!               /((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))) &
!          + (1.+PREDR1)*(PRED2THR3+PRED2TH3)                       &
!               / (PREDTH1*(1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1))) &
!          - (1./2.*PREDTH1+PREDR1 * (1.+PREDTH1+PREDR1))           &
!               / ((1.+PREDTH1+PREDR1)*(1.+1./2.*(PREDTH1+PREDR1)))
!    ELSEWHERE
!      D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:) * 2. * PDTDZ(:,:,:)
!    ENDWHERE
!
!!
!  ELSE
!    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
!    D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:)                  &
!          * PDTDZ(:,:,:)*(2.-PREDTH1(:,:,:)*(3./2.+PREDTH1)   &
!               /((1.+PREDTH1)*(1.+1./2.*PREDTH1)))             &
!          + PRED2TH3 / (PREDTH1*(1.+PREDTH1)*(1.+1./2.*PREDTH1)) &
!          - 1./2.*PREDTH1 / ((1.+PREDTH1)*(1.+1./2.*PREDTH1))
!    ELSEWHERE
!      D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:) * 2. * PDTDZ(:,:,:)
!    ENDWHERE
!  END IF
ELSE
        !* 1DIM case
    WHERE (PPHI3(:,:,:)<=XPHI_LIM)
      D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:)*PDTDZ(:,:,:)             &
          * (2. - PREDTH1(:,:,:)*PPHI3(:,:,:))
    ELSEWHERE
      D_PHI3DTDZ2_O_DDTDZ(:,:,:) = PPHI3(:,:,:) * 2. * PDTDZ(:,:,:)
    END WHERE
END IF
!
!* smoothing
CALL SMOOTH_TURB_FUNCT(PPHI3,PPHI3*2.*PDTDZ,D_PHI3DTDZ2_O_DDTDZ)
!
!
D_PHI3DTDZ2_O_DDTDZ(:,:,IKB-1)=D_PHI3DTDZ2_O_DDTDZ(:,:,IKB)
D_PHI3DTDZ2_O_DDTDZ(:,:,IKE+1)=D_PHI3DTDZ2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_PHI3DTDZ2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_WTH_WTH2(PREDTH1,PREDR1,PD,PBLL_O_E,PETHETA)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WTH_WTH2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_WTH_WTH2(:,:,:) = XCSHF*PBLL_O_E*PETHETA*0.5/XCTD        &
                   * (1.+0.5*PREDTH1+PREDR1) / PD
M3_WTH_WTH2(:,:,IKB-1)=M3_WTH_WTH2(:,:,IKB)
M3_WTH_WTH2(:,:,IKE+1)=M3_WTH_WTH2(:,:,IKE)
!
END FUNCTION M3_WTH_WTH2
!----------------------------------------------------------------------------
FUNCTION D_M3_WTH_WTH2_O_DDTDZ(PM3_WTH_WTH2,PREDTH1,PREDR1,PD,PBLL_O_E,PETHETA)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PM3_WTH_WTH2
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WTH_WTH2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_WTH_WTH2_O_DDTDZ(:,:,:) = (  0.5*XCSHF*PBLL_O_E*PETHETA*0.5/XCTD/PD &
                                - PM3_WTH_WTH2/PD*(1.5+PREDTH1+PREDR1)  )&
                             * PBLL_O_E * PETHETA * XCTV
!
D_M3_WTH_WTH2_O_DDTDZ(:,:,IKB-1)=D_M3_WTH_WTH2_O_DDTDZ(:,:,IKB)
D_M3_WTH_WTH2_O_DDTDZ(:,:,IKE+1)=D_M3_WTH_WTH2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_WTH_WTH2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_WTH_W2TH(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PKEFF,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WTH_W2TH
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_WTH_W2TH(:,:,:) = XCSHF*PKEFF*1.5/MZM(KKA,KKU,KKL,PTKE)              &
  * (1. - 0.5*PREDR1*(1.+PREDR1)/PD ) / (1.+PREDTH1)
!
M3_WTH_W2TH(:,:,IKB-1)=M3_WTH_W2TH(:,:,IKB)
M3_WTH_W2TH(:,:,IKE+1)=M3_WTH_W2TH(:,:,IKE)
!
END FUNCTION M3_WTH_W2TH
!----------------------------------------------------------------------------
FUNCTION D_M3_WTH_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PBLL_O_E,PETHETA,PKEFF,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WTH_W2TH_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_WTH_W2TH_O_DDTDZ(:,:,:) = &
 - XCSHF*PKEFF*1.5/MZM(KKA,KKU,KKL,PTKE)/(1.+PREDTH1)**2*XCTV*PBLL_O_E*PETHETA  &
 * (1. - 0.5*PREDR1*(1.+PREDR1)/PD*( 1.+(1.+PREDTH1)*(1.5+PREDR1+PREDTH1)/PD) )
!
D_M3_WTH_W2TH_O_DDTDZ(:,:,IKB-1)=D_M3_WTH_W2TH_O_DDTDZ(:,:,IKB)
D_M3_WTH_W2TH_O_DDTDZ(:,:,IKE+1)=D_M3_WTH_W2TH_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_WTH_W2TH_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_WTH_W2R(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PKEFF,PTKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WTH_W2R
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_WTH_W2R(:,:,:) = - XCSHF*PKEFF*0.75*XCTV*PBLL_O_E/MZM(KKA,KKU,KKL,PTKE)*PEMOIST*PDTDZ/PD
!
M3_WTH_W2R(:,:,IKB-1)=M3_WTH_W2R(:,:,IKB)
M3_WTH_W2R(:,:,IKE+1)=M3_WTH_W2R(:,:,IKE)
!
END FUNCTION M3_WTH_W2R
!----------------------------------------------------------------------------
FUNCTION D_M3_WTH_W2R_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PKEFF,PTKE,PBLL_O_E,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WTH_W2R_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_WTH_W2R_O_DDTDZ(:,:,:) = - XCSHF*PKEFF*0.75*XCTV*PBLL_O_E/MZM(KKA,KKU,KKL,PTKE)*PEMOIST/PD &
                                     * (1. -  PREDTH1*(1.5+PREDTH1+PREDR1)/PD)
!
D_M3_WTH_W2R_O_DDTDZ(:,:,IKB-1)=D_M3_WTH_W2R_O_DDTDZ(:,:,IKB)
D_M3_WTH_W2R_O_DDTDZ(:,:,IKE+1)=D_M3_WTH_W2R_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_WTH_W2R_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_WTH_WR2(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WTH_WR2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_WTH_WR2(:,:,:) = - XCSHF*PKEFF*0.25*PBLL_O_E*XCTV*PEMOIST**2       &
                           *MZM(KKA,KKU,KKL,PBETA*PLEPS/(PSQRT_TKE*PTKE))/XCTD*PDTDZ/PD
!
M3_WTH_WR2(:,:,IKB-1)=M3_WTH_WR2(:,:,IKB)
M3_WTH_WR2(:,:,IKE+1)=M3_WTH_WR2(:,:,IKE)
!
END FUNCTION M3_WTH_WR2
!----------------------------------------------------------------------------
FUNCTION D_M3_WTH_WR2_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WTH_WR2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_WTH_WR2_O_DDTDZ(:,:,:) = - XCSHF*PKEFF*0.25*PBLL_O_E*XCTV*PEMOIST**2 &
                           *MZM(KKA,KKU,KKL,PBETA*PLEPS/(PSQRT_TKE*PTKE))/XCTD/PD     &
                           * (1. -  PREDTH1*(1.5+PREDTH1+PREDR1)/PD)
!
D_M3_WTH_WR2_O_DDTDZ(:,:,IKB-1)=D_M3_WTH_WR2_O_DDTDZ(:,:,IKB)
D_M3_WTH_WR2_O_DDTDZ(:,:,IKE+1)=D_M3_WTH_WR2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_WTH_WR2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_WTH_WTHR(KKA,KKU,KKL,PREDR1,PD,PKEFF,PTKE,PSQRT_TKE,PBETA,PLEPS,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PREDR1,1),SIZE(PREDR1,2),SIZE(PREDR1,3)) :: M3_WTH_WTHR
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

!M3_WTH_WTHR(:,:,:) = XCSHF*PKEFF*PEMOIST/MZM(KKA,KKU,KKL,PBETA*PTKE*PSQRT_TKE) &
!                         *0.5*PLEPS/XCTD*(1+PREDR1)/PD
M3_WTH_WTHR(:,:,:) = XCSHF*PKEFF*PEMOIST*MZM(KKA,KKU,KKL,PBETA/PTKE*PSQRT_TKE) &
                         *0.5*PLEPS/XCTD*(1+PREDR1)/PD
!
M3_WTH_WTHR(:,:,IKB-1)=M3_WTH_WTHR(:,:,IKB)
M3_WTH_WTHR(:,:,IKE+1)=M3_WTH_WTHR(:,:,IKE)
!
END FUNCTION M3_WTH_WTHR
!----------------------------------------------------------------------------
FUNCTION D_M3_WTH_WTHR_O_DDTDZ(PM3_WTH_WTHR,PREDTH1,PREDR1,PD,PBLL_O_E,PETHETA)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PM3_WTH_WTHR
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WTH_WTHR_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_WTH_WTHR_O_DDTDZ(:,:,:) = - PM3_WTH_WTHR * (1.5+PREDTH1+PREDR1)/PD*XCTV*PBLL_O_E*PETHETA
!
D_M3_WTH_WTHR_O_DDTDZ(:,:,IKB-1)=D_M3_WTH_WTHR_O_DDTDZ(:,:,IKB)
D_M3_WTH_WTHR_O_DDTDZ(:,:,IKE+1)=D_M3_WTH_WTHR_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_WTH_WTHR_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_TH2_W2TH(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PDTDZ,PLM,PLEPS,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_TH2_W2TH
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_TH2_W2TH(:,:,:) = - MZF(KKA,KKU,KKL,(1.-0.5*PREDR1*(1.+PREDR1)/PD)/(1.+PREDTH1)*PDTDZ) &
                       * 1.5*PLM*PLEPS/PTKE*XCTV
!
M3_TH2_W2TH(:,:,IKB-1)=M3_TH2_W2TH(:,:,IKB)
M3_TH2_W2TH(:,:,IKE+1)=M3_TH2_W2TH(:,:,IKE)
!
END FUNCTION M3_TH2_W2TH
!----------------------------------------------------------------------------
FUNCTION D_M3_TH2_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLM,PLEPS,PTKE,OUSERV)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  LOGICAL,                INTENT(IN) :: OUSERV
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_TH2_W2TH_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

IF (OUSERV) THEN
!  D_M3_TH2_W2TH_O_DDTDZ(:,:,:) = - 1.5*PLM*PLEPS/PTKE*XCTV * MZF(KKA,KKU,KKL,                    &
!          (1.-0.5*PREDR1*(1.+PREDR1)/PD)*(1.-(1.5+PREDTH1+PREDR1)*(1.+PREDTH1)/PD )  &
!        / (1.+PREDTH1)**2                                        )
  D_M3_TH2_W2TH_O_DDTDZ(:,:,:) = - 1.5*PLM*PLEPS/PTKE*XCTV * MZF(KKA,KKU,KKL,    &
          (1.-0.5*PREDR1*(1.+PREDR1)/PD)*(1.-(1.5+PREDTH1+PREDR1)*   &
             PREDTH1*(1.+PREDTH1)/PD ) / (1.+PREDTH1)**2      )

ELSE
  D_M3_TH2_W2TH_O_DDTDZ(:,:,:) = - 1.5*PLM*PLEPS/PTKE*XCTV * MZF(KKA,KKU,KKL,1./(1.+PREDTH1)**2)
END IF
!
D_M3_TH2_W2TH_O_DDTDZ(:,:,IKB-1)=D_M3_TH2_W2TH_O_DDTDZ(:,:,IKB)
D_M3_TH2_W2TH_O_DDTDZ(:,:,IKE+1)=D_M3_TH2_W2TH_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_TH2_W2TH_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_TH2_WTH2(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_TH2_WTH2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_TH2_WTH2(:,:,:) = PLEPS*0.5/XCTD/PSQRT_TKE          &
  * MZF(KKA,KKU,KKL, (1.+0.5*PREDTH1+1.5*PREDR1+0.5*PREDR1**2)/PD )
!
M3_TH2_WTH2(:,:,IKB-1)=M3_TH2_WTH2(:,:,IKB)
M3_TH2_WTH2(:,:,IKE+1)=M3_TH2_WTH2(:,:,IKE)
!
END FUNCTION M3_TH2_WTH2
!----------------------------------------------------------------------------
FUNCTION D_M3_TH2_WTH2_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_TH2_WTH2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_TH2_WTH2_O_DDTDZ(:,:,:) = PLEPS*0.5/XCTD/PSQRT_TKE*XCTV                        &
 * MZF(KKA,KKU,KKL, PBLL_O_E*PETHETA* (0.5/PD                                                   &
             - (1.5+PREDTH1+PREDR1)*(1.+0.5*PREDTH1+1.5*PREDR1+0.5*PREDR1**2)/PD**2 &
                           )  )
!
D_M3_TH2_WTH2_O_DDTDZ(:,:,IKB-1)=D_M3_TH2_WTH2_O_DDTDZ(:,:,IKB)
D_M3_TH2_WTH2_O_DDTDZ(:,:,IKE+1)=D_M3_TH2_WTH2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_TH2_WTH2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_TH2_W2R(KKA,KKU,KKL,PD,PLM,PLEPS,PTKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_TH2_W2R
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_TH2_W2R(:,:,:) = 0.75*XCTV**2*MZF(KKA,KKU,KKL,PBLL_O_E*PEMOIST/PD*PDTDZ**2)*PLM*PLEPS/PTKE
!
M3_TH2_W2R(:,:,IKB-1)=M3_TH2_W2R(:,:,IKB)
M3_TH2_W2R(:,:,IKE+1)=M3_TH2_W2R(:,:,IKE)
!
END FUNCTION M3_TH2_W2R
!----------------------------------------------------------------------------
FUNCTION D_M3_TH2_W2R_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_TH2_W2R_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_TH2_W2R_O_DDTDZ(:,:,:) = 0.75*XCTV**2*PLM*PLEPS/PTKE &
 * MZF(KKA,KKU,KKL, PBLL_O_E*PEMOIST/PD*PDTDZ*(2.-PREDTH1*(1.5+PREDTH1+PREDR1)/PD) )
!
D_M3_TH2_W2R_O_DDTDZ(:,:,IKB-1)=D_M3_TH2_W2R_O_DDTDZ(:,:,IKB)
D_M3_TH2_W2R_O_DDTDZ(:,:,IKE+1)=D_M3_TH2_W2R_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_TH2_W2R_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_TH2_WR2(KKA,KKU,KKL,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_TH2_WR2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_TH2_WR2(:,:,:) = 0.25*XCTV**2*MZF(KKA,KKU,KKL,(PBLL_O_E*PEMOIST*PDTDZ)**2/PD)*PLEPS/PSQRT_TKE/XCTD
!
M3_TH2_WR2(:,:,IKB-1)=M3_TH2_WR2(:,:,IKB)
M3_TH2_WR2(:,:,IKE+1)=M3_TH2_WR2(:,:,IKE)
!
END FUNCTION M3_TH2_WR2
!----------------------------------------------------------------------------
FUNCTION D_M3_TH2_WR2_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_TH2_WR2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_TH2_WR2_O_DDTDZ(:,:,:) = 0.25*XCTV**2*PLEPS/PSQRT_TKE/XCTD &
  *  MZF(KKA,KKU,KKL, (PBLL_O_E*PEMOIST)**2*PDTDZ/PD*(2.-PREDTH1*(1.5+PREDTH1+PREDR1)/PD) )
!
D_M3_TH2_WR2_O_DDTDZ(:,:,IKB-1)=D_M3_TH2_WR2_O_DDTDZ(:,:,IKB)
D_M3_TH2_WR2_O_DDTDZ(:,:,IKE+1)=D_M3_TH2_WR2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_TH2_WR2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_TH2_WTHR(KKA,KKU,KKL,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_TH2_WTHR
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_TH2_WTHR(:,:,:) = - 0.5*XCTV*PLEPS/PSQRT_TKE/XCTD &
 * MZF(KKA,KKU,KKL, PBLL_O_E*PEMOIST*PDTDZ*(1.+PREDR1)/PD )
!
M3_TH2_WTHR(:,:,IKB-1)=M3_TH2_WTHR(:,:,IKB)
M3_TH2_WTHR(:,:,IKE+1)=M3_TH2_WTHR(:,:,IKE)
!
END FUNCTION M3_TH2_WTHR
!----------------------------------------------------------------------------
FUNCTION D_M3_TH2_WTHR_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_TH2_WTHR_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_TH2_WTHR_O_DDTDZ(:,:,:) = - 0.5*XCTV*PLEPS/PSQRT_TKE/XCTD &
 * MZF(KKA,KKU,KKL, PBLL_O_E*PEMOIST*(1.+PREDR1)/PD * (1. -PREDTH1*(1.5+PREDTH1+PREDR1)/PD) )
!
D_M3_TH2_WTHR_O_DDTDZ(:,:,IKB-1)=D_M3_TH2_WTHR_O_DDTDZ(:,:,IKB)
D_M3_TH2_WTHR_O_DDTDZ(:,:,IKE+1)=D_M3_TH2_WTHR_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_TH2_WTHR_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_THR_WTHR(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_THR_WTHR
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_THR_WTHR(:,:,:) = 0.5*PLEPS/PSQRT_TKE/XCTD &
 * MZF(KKA,KKU,KKL, (1.+PREDTH1)*(1.+PREDR1)/PD )
!
M3_THR_WTHR(:,:,IKB-1)=M3_THR_WTHR(:,:,IKB)
M3_THR_WTHR(:,:,IKE+1)=M3_THR_WTHR(:,:,IKE)
!
END FUNCTION M3_THR_WTHR
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WTHR_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WTHR_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_THR_WTHR_O_DDTDZ(:,:,:) = 0.5*PLEPS/PSQRT_TKE/XCTD * XCTV &
 * MZF(KKA,KKU,KKL, PETHETA*PBLL_O_E/PD*(1.+PREDR1)*(1.-(1.+PREDTH1)*(1.5+PREDTH1+PREDR1)/PD) )
!
D_M3_THR_WTHR_O_DDTDZ(:,:,IKB-1)=D_M3_THR_WTHR_O_DDTDZ(:,:,IKB)
D_M3_THR_WTHR_O_DDTDZ(:,:,IKE+1)=D_M3_THR_WTHR_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_THR_WTHR_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_THR_WTH2(KKA,KKU,KKL,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_THR_WTH2
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_THR_WTH2(:,:,:) = - 0.25*PLEPS/PSQRT_TKE/XCTD*XCTV &
 * MZF(KKA,KKU,KKL, (1.+PREDR1)*PBLL_O_E*PETHETA*PDRDZ/PD )
!
M3_THR_WTH2(:,:,IKB-1)=M3_THR_WTH2(:,:,IKB)
M3_THR_WTH2(:,:,IKE+1)=M3_THR_WTH2(:,:,IKE)
!
END FUNCTION M3_THR_WTH2
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WTH2_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WTH2_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_THR_WTH2_O_DDTDZ(:,:,:) = - 0.25*PLEPS/PSQRT_TKE/XCTD*XCTV**2 &
 * MZF(KKA,KKU,KKL, -(1.+PREDR1)*(PBLL_O_E*PETHETA/PD)**2*PDRDZ*(1.5+PREDTH1+PREDR1) )
!
D_M3_THR_WTH2_O_DDTDZ(:,:,IKB-1)=D_M3_THR_WTH2_O_DDTDZ(:,:,IKB)
D_M3_THR_WTH2_O_DDTDZ(:,:,IKE+1)=D_M3_THR_WTH2_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_THR_WTH2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WTH2_O_DDRDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WTH2_O_DDRDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_THR_WTH2_O_DDRDZ(:,:,:) = - 0.25*PLEPS/PSQRT_TKE/XCTD*XCTV          &
 * MZF(KKA,KKU,KKL, PBLL_O_E*PETHETA/PD                                              &
       *(-(1.+PREDR1)*PREDR1/PD*(1.5+PREDTH1+PREDR1)+(1.+2.*PREDR1))     &
      )
!
D_M3_THR_WTH2_O_DDRDZ(:,:,IKB-1)=D_M3_THR_WTH2_O_DDRDZ(:,:,IKB)
D_M3_THR_WTH2_O_DDRDZ(:,:,IKE+1)=D_M3_THR_WTH2_O_DDRDZ(:,:,IKE)
!
END FUNCTION D_M3_THR_WTH2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_THR_W2TH(KKA,KKU,KKL,PREDR1,PD,PLM,PLEPS,PTKE,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_THR_W2TH
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

M3_THR_W2TH(:,:,:) = - 0.75*PLM*PLEPS/PTKE * XCTV      &
 * MZF(KKA,KKU,KKL, (1.+PREDR1)*PDRDZ/PD )
!
M3_THR_W2TH(:,:,IKB-1)=M3_THR_W2TH(:,:,IKB)
M3_THR_W2TH(:,:,IKE+1)=M3_THR_W2TH(:,:,IKE)
!
END FUNCTION M3_THR_W2TH
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PDRDZ,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_W2TH_O_DDTDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_THR_W2TH_O_DDTDZ(:,:,:) = - 0.75*PLM*PLEPS/PTKE * XCTV**2    &
 * MZF(KKA,KKU,KKL, -PETHETA*PBLL_O_E*(1.+PREDR1)*PDRDZ*(1.5+PREDTH1+PREDR1)/PD**2 )

!
D_M3_THR_W2TH_O_DDTDZ(:,:,IKB-1)=D_M3_THR_W2TH_O_DDTDZ(:,:,IKB)
D_M3_THR_W2TH_O_DDTDZ(:,:,IKE+1)=D_M3_THR_W2TH_O_DDTDZ(:,:,IKE)
!
END FUNCTION D_M3_THR_W2TH_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_W2TH_O_DDRDZ(KKA,KKU,KKL,PREDTH1,PREDR1,PD,PLM,PLEPS,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_W2TH_O_DDRDZ
  INTEGER :: IKB, IKE
!
IKB = 1+JPVEXT_TURB
IKE = SIZE(PD,3)-JPVEXT_TURB

D_M3_THR_W2TH_O_DDRDZ(:,:,:) = - 0.75*PLM*PLEPS/PTKE * XCTV     &
 * MZF(KKA,KKU,KKL, -(1.+PREDR1)*PREDR1*(1.5+PREDTH1+PREDR1)/PD**2          &
        +(1.+2.*PREDR1)/PD                                      &
      )

!
D_M3_THR_W2TH_O_DDRDZ(:,:,IKB-1)=D_M3_THR_W2TH_O_DDRDZ(:,:,IKB)
D_M3_THR_W2TH_O_DDRDZ(:,:,IKE+1)=D_M3_THR_W2TH_O_DDRDZ(:,:,IKE)
!
END FUNCTION D_M3_THR_W2TH_O_DDRDZ
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!
FUNCTION PSI3(PREDR1,PREDTH1,PRED2R3,PRED2TH3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2TH3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2R3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: PSI3
!
PSI3 = PHI3(PREDR1,PREDTH1,PRED2R3,PRED2TH3,PRED2THR3,HTURBDIM,OUSERV)
!
END FUNCTION PSI3
!----------------------------------------------------------------------------
FUNCTION D_PSI3DRDZ_O_DDRDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPSI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2R3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PSI3DRDZ_O_DDRDZ

D_PSI3DRDZ_O_DDRDZ = D_PHI3DTDZ_O_DDTDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,HTURBDIM,OUSERV)
!
!C'est ok?!
!
END FUNCTION D_PSI3DRDZ_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION D_PSI3DTDZ_O_DDTDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPSI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2R3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PSI3DTDZ_O_DDTDZ
!
D_PSI3DTDZ_O_DDTDZ = D_PHI3DRDZ_O_DDRDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,HTURBDIM,OUSERV)
!
END FUNCTION D_PSI3DTDZ_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION D_PSI3DRDZ2_O_DDRDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,PDRDZ,HTURBDIM,OUSERV)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PPSI3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2R3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PRED2THR3
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  CHARACTER(len=4),       INTENT(IN) :: HTURBDIM  ! 1DIM or 3DIM turb. scheme
  LOGICAL,                INTENT(IN) :: OUSERV    ! flag to use vapor
  REAL, DIMENSION(SIZE(PREDTH1,1),SIZE(PREDTH1,2),SIZE(PREDTH1,3)) :: D_PSI3DRDZ2_O_DDRDZ
!
D_PSI3DRDZ2_O_DDRDZ = D_PHI3DTDZ2_O_DDTDZ(PPSI3,PREDR1,PREDTH1,PRED2R3,PRED2THR3,PDRDZ,HTURBDIM,OUSERV)
!
END FUNCTION D_PSI3DRDZ2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_WR_WR2(PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WR_WR2
!
M3_WR_WR2 = M3_WTH_WTH2(PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
!
END FUNCTION M3_WR_WR2
!----------------------------------------------------------------------------
FUNCTION D_M3_WR_WR2_O_DDRDZ(PM3_WR_WR2,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PM3_WR_WR2
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WR_WR2_O_DDRDZ
!
D_M3_WR_WR2_O_DDRDZ = D_M3_WTH_WTH2_O_DDTDZ(PM3_WR_WR2,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
!
END FUNCTION D_M3_WR_WR2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_WR_W2R(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WR_W2R
!
M3_WR_W2R = M3_WTH_W2TH(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE)
!
END FUNCTION M3_WR_W2R
!----------------------------------------------------------------------------
FUNCTION D_M3_WR_W2R_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST,PKEFF,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WR_W2R_O_DDRDZ
!
D_M3_WR_W2R_O_DDRDZ = D_M3_WTH_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST,PKEFF,PTKE)
!
END FUNCTION D_M3_WR_W2R_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_WR_W2TH(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WR_W2TH
!
M3_WR_W2TH = M3_WTH_W2R(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION M3_WR_W2TH
!----------------------------------------------------------------------------
FUNCTION D_M3_WR_W2TH_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PBLL_O_E,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WR_W2TH_O_DDRDZ
!
D_M3_WR_W2TH_O_DDRDZ = D_M3_WTH_W2R_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PBLL_O_E,PETHETA)
!
END FUNCTION D_M3_WR_W2TH_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_WR_WTH2(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WR_WTH2
!
M3_WR_WTH2 = M3_WTH_WR2(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PETHETA,PDRDZ)
!
END FUNCTION M3_WR_WTH2
!----------------------------------------------------------------------------
FUNCTION D_M3_WR_WTH2_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WR_WTH2_O_DDRDZ
!
D_M3_WR_WTH2_O_DDRDZ = D_M3_WTH_WR2_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBLL_O_E,PBETA,PLEPS,PETHETA)
!
END FUNCTION D_M3_WR_WTH2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_WR_WTHR(KKA,KKU,KKL,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBETA,PLEPS,PETHETA)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PKEFF
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_WR_WTHR
!
M3_WR_WTHR = M3_WTH_WTHR(KKA,KKU,KKL,PREDTH1,PD,PKEFF,PTKE,PSQRT_TKE,PBETA,PLEPS,PETHETA)
!
END FUNCTION M3_WR_WTHR
!----------------------------------------------------------------------------
FUNCTION D_M3_WR_WTHR_O_DDRDZ(KKA,KKU,KKL,PM3_WR_WTHR,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PM3_WR_WTHR
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_WR_WTHR_O_DDRDZ
!
D_M3_WR_WTHR_O_DDRDZ = D_M3_WTH_WTHR_O_DDTDZ(PM3_WR_WTHR,PREDR1,PREDTH1,PD,PBLL_O_E,PEMOIST)
!
END FUNCTION D_M3_WR_WTHR_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_R2_W2R(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PDRDZ,PLM,PLEPS,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_R2_W2R
!
M3_R2_W2R = M3_TH2_W2TH(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PDRDZ,PLM,PLEPS,PTKE)
!
END FUNCTION M3_R2_W2R
!----------------------------------------------------------------------------
FUNCTION D_M3_R2_W2R_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,OUSERV)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  LOGICAL,                INTENT(IN) :: OUSERV
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_R2_W2R_O_DDRDZ
!
D_M3_R2_W2R_O_DDRDZ = D_M3_TH2_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,OUSERV)
!
END FUNCTION D_M3_R2_W2R_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_R2_WR2(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_R2_WR2
!
M3_R2_WR2 = M3_TH2_WTH2(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE)
!
END FUNCTION M3_R2_WR2
!----------------------------------------------------------------------------
FUNCTION D_M3_R2_WR2_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_R2_WR2_O_DDRDZ
!
D_M3_R2_WR2_O_DDRDZ = D_M3_TH2_WTH2_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
!
END FUNCTION D_M3_R2_WR2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_R2_W2TH(KKA,KKU,KKL,PD,PLM,PLEPS,PTKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_R2_W2TH
!
M3_R2_W2TH = M3_TH2_W2R(KKA,KKU,KKL,PD,PLM,PLEPS,PTKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION M3_R2_W2TH
!----------------------------------------------------------------------------
FUNCTION D_M3_R2_W2TH_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_R2_W2TH_O_DDRDZ
!
D_M3_R2_W2TH_O_DDRDZ = D_M3_TH2_W2R_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION D_M3_R2_W2TH_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_R2_WTH2(KKA,KKU,KKL,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_R2_WTH2
!
M3_R2_WTH2 = M3_TH2_WR2(KKA,KKU,KKL,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION M3_R2_WTH2
!----------------------------------------------------------------------------
FUNCTION D_M3_R2_WTH2_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_R2_WTH2_O_DDRDZ
!
D_M3_R2_WTH2_O_DDRDZ = D_M3_TH2_WR2_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION D_M3_R2_WTH2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_R2_WTHR(KKA,KKU,KKL,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_R2_WTHR
!
M3_R2_WTHR = M3_TH2_WTHR(KKA,KKU,KKL,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION M3_R2_WTHR
!----------------------------------------------------------------------------
FUNCTION D_M3_R2_WTHR_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PETHETA
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDRDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_R2_WTHR_O_DDRDZ
!
D_M3_R2_WTHR_O_DDRDZ = D_M3_TH2_WTHR_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PETHETA,PDRDZ)
!
END FUNCTION D_M3_R2_WTHR_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WTHR_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WTHR_O_DDRDZ
!
D_M3_THR_WTHR_O_DDRDZ = D_M3_THR_WTHR_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
!
END FUNCTION D_M3_THR_WTHR_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION M3_THR_WR2(KKA,KKU,KKL,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_THR_WR2
!
M3_THR_WR2 = M3_THR_WTH2(KKA,KKU,KKL,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
!
END FUNCTION M3_THR_WR2
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WR2_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WR2_O_DDRDZ
!
D_M3_THR_WR2_O_DDRDZ = D_M3_THR_WTH2_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST,PDTDZ)
!
END FUNCTION D_M3_THR_WR2_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_WR2_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PSQRT_TKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_WR2_O_DDTDZ
!
D_M3_THR_WR2_O_DDTDZ = D_M3_THR_WTH2_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLEPS,PSQRT_TKE,PBLL_O_E,PEMOIST)
!
END FUNCTION D_M3_THR_WR2_O_DDTDZ
!----------------------------------------------------------------------------
FUNCTION M3_THR_W2R(KKA,KKU,KKL,PREDTH1,PD,PLM,PLEPS,PTKE,PDTDZ)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: M3_THR_W2R
!
M3_THR_W2R = M3_THR_W2TH(KKA,KKU,KKL,PREDTH1,PD,PLM,PLEPS,PTKE,PDTDZ)
!
END FUNCTION M3_THR_W2R
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_W2R_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PDTDZ,PEMOIST)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PBLL_O_E
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PDTDZ
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PEMOIST
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_W2R_O_DDRDZ
!
D_M3_THR_W2R_O_DDRDZ = D_M3_THR_W2TH_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE,PBLL_O_E,PDTDZ,PEMOIST)
!
END FUNCTION D_M3_THR_W2R_O_DDRDZ
!----------------------------------------------------------------------------
FUNCTION D_M3_THR_W2R_O_DDTDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE)
  INTEGER,                INTENT(IN) :: KKA 
  INTEGER,                INTENT(IN) :: KKU  
  INTEGER,                INTENT(IN) :: KKL
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDR1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PREDTH1
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PD
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLM
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PLEPS
  REAL, DIMENSION(:,:,:), INTENT(IN) :: PTKE
  REAL, DIMENSION(SIZE(PD,1),SIZE(PD,2),SIZE(PD,3)) :: D_M3_THR_W2R_O_DDTDZ
!
D_M3_THR_W2R_O_DDTDZ = D_M3_THR_W2TH_O_DDRDZ(KKA,KKU,KKL,PREDR1,PREDTH1,PD,PLM,PLEPS,PTKE)
!
END FUNCTION D_M3_THR_W2R_O_DDTDZ
!----------------------------------------------------------------------------
!
END MODULE MODE_PRANDTL

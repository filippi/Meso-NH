!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 turb 2006/05/24 18:05:53
!-----------------------------------------------------------------
!    ###################
     MODULE MODI_PRANDTL
!    ###################
!
INTERFACE
!
      SUBROUTINE PRANDTL(KKA,KKU,KKL,KRR,KRRI,OCLOSE_OUT,OTURB_DIAG,&
                         HTURBDIM,                             &
                         HFMFILE,HLUOUT,                       &
                         PDXX,PDYY,PDZZ,PDZX,PDZY,             &
                         PTHVREF,PLOCPEXNM,PATHETA,PAMOIST,    &
                         PLM,PLEPS,PTKEM,PTHLM,PRM,PSVM,PSRCM, &
                         PREDTH1,PREDR1,                       &
                         PRED2TH3, PRED2R3, PRED2THR3,         &
                         PREDS1,PRED2THS3, PRED2RS3,           &
                         PBLL_O_E,                             &
                         PETHETA, PEMOIST                      )
!
!
INTEGER,                INTENT(IN)   :: KKA           !near ground array index  
INTEGER,                INTENT(IN)   :: KKU           !uppest atmosphere array index
INTEGER,                INTENT(IN)   :: KKL           !vert. levels type 1=MNH -1=ARO
INTEGER,                INTENT(IN)   :: KRR           ! number of moist var.
INTEGER,                INTENT(IN)   :: KRRI          ! number of ice var.
!
LOGICAL,                INTENT(IN)   ::  OCLOSE_OUT   ! switch for syncronous
                                                      ! file opening
LOGICAL,                INTENT(IN)   ::  OTURB_DIAG   ! switch to write some
                                 ! diagnostic fields in the syncronous FM-file
CHARACTER*4           , INTENT(IN)   ::  HTURBDIM     ! Kind of turbulence param.
CHARACTER(LEN=*),       INTENT(IN)   ::  HFMFILE      ! Name of the output
                                                      ! FM-file
CHARACTER(LEN=*),       INTENT(IN)   ::  HLUOUT       ! Output-listing name for
                                                      ! model n
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PDXX,PDYY,PDZZ,PDZX,PDZY
                                                  ! metric coefficients
!
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PTHVREF  ! Virtual Potential Temp.
                                                  ! of the reference state
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLOCPEXNM ! Lv(T)/Cp/Exner at t-1 
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PATHETA      ! coefficients between 
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PAMOIST      ! s and Thetal and Rnp
!
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLM      ! Turbulent Mixing length
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLEPS    ! Dissipative length
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PTHLM,PTKEM! Conservative Potential 
                                                  ! Temperature and TKE at t-1
REAL, DIMENSION(:,:,:,:), INTENT(IN) ::  PRM      ! Mixing ratios at  t-1
                                                  ! with PRM(:,:,:,1) = cons.
                                                  ! mixing ratio
REAL, DIMENSION(:,:,:,:), INTENT(IN) ::  PSVM     ! Scalars at t-1      
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PSRCM
                                  ! s'r'c/2Sigma_s2 at t-1 multiplied by Lambda_3
!
!
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PREDTH1 ! Redelsperger number R_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PREDR1  ! Redelsperger number R_q
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2TH3 ! Redelsperger number R*2_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2R3  ! Redelsperger number R*2_q
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2THR3! Redelsperger number R*2_thq
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PREDS1   ! Redelsperger number R_sv
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PRED2THS3! Redelsperger number R*2_thsv
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PRED2RS3 ! Redelsperger number R*2_qsv
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PBLL_O_E! beta*Lk*Leps/tke
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PETHETA ! coefficient E_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PEMOIST ! coefficient E_moist
!
END SUBROUTINE PRANDTL
!
END INTERFACE
!
END MODULE MODI_PRANDTL
!
!
!
!     ###########################################################
      SUBROUTINE PRANDTL(KKA,KKU,KKL,KRR,KRRI,OCLOSE_OUT,OTURB_DIAG,       &
                         HTURBDIM,                             &
                         HFMFILE,HLUOUT,                       &
                         PDXX,PDYY,PDZZ,PDZX,PDZY,             &
                         PTHVREF,PLOCPEXNM,PATHETA,PAMOIST,    &
                         PLM,PLEPS,PTKEM,PTHLM,PRM,PSVM,PSRCM, &
                         PREDTH1,PREDR1,                       &
                         PRED2TH3, PRED2R3, PRED2THR3,         &
                         PREDS1,PRED2THS3, PRED2RS3,           &
                         PBLL_O_E,                             &
                         PETHETA, PEMOIST                      )
!     ###########################################################
!
!
!!****  *PRANDTL* - routine to compute the Prandtl turbulent numbers
!!
!!    PURPOSE
!!    -------
!       The purpose of this routine is to compute the Redelsperger 
!     numbers and then get the turbulent Prandtl and Schmidt numbers:
!       * for the heat fluxes     - PHI3 = 1/ Prandtl
!       * for the moisture fluxes - PSI3 = 1/ Schmidt
!
!!**  METHOD
!!    ------
!!    The following steps are performed:
!!
!!     1 - default values of 1 are taken for phi3 and psi3 and different masks
!!       are defined depending on the presence of turbulence, stratification and
!!       humidity. The 1D Redelsperger numbers are computed  
!!         * ZREDTH1 : (g / THVREF ) (LT**2 / TKE ) ETHETA (D Theta / Dz)   
!!         * ZREDR1  : (g / THVREF ) (LT**2 / TKE ) EMOIST (D TW    / Dz)  
!!     2 - 3D Redelsperger numbers are computed only for turbulent 
!!       grid points where  ZREDTH1 or ZREDR1 are > 0.
!!     3 - PHI3 is  computed only for turbulent grid points where ZREDTH1 > 0
!!      (turbulent thermally stratified points)
!!     4 - PSI3 is computed only for turbulent grid points where ZREDR1 > 0
!!      (turbulent moist points)
!!    
!!
!!    EXTERNAL
!!    --------
!!      FUNCTIONs ETHETA and EMOIST  :  
!!            allows to compute the coefficients 
!!            for the turbulent correlation between any variable
!!            and the virtual potential temperature, of its correlations 
!!            with the conservative potential temperature and the humidity 
!!            conservative variable:
!!            -------              -------              -------
!!            A' Thv'  =  ETHETA   A' Thl'  +  EMOIST   A' Rnp'  
!!
!!      GX_M_M, GY_M_M, GZ_M_M :  Cartesian gradient operators
!!      MZM : Shuman function (mean operator in the z direction)
!!      Module MODI_ETHETA    : interface module for ETHETA
!!      Module MODI_EMOIST    : interface module for EMOIST
!!      Module MODI_SHUMAN    : interface module for Shuman operators
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_CST : contains physical constants
!!           XG         : gravity constant
!!
!!      Module MODD_CTURB: contains the set of constants for
!!                        the turbulence scheme
!!       XCTV,XCPR2    : constants for the turbulent prandtl numbers
!!       XTKEMIN        : minimum value allowed for the TKE
!!
!!      Module MODD_PARAMETERS 
!!       JPVEXT_TURB         : number of vertical marginal points
!!
!!    REFERENCE
!!    ---------
!!      Book 2 of documentation (routine PRANDTL)
!!      Book 1 of documentation (Chapter: Turbulence)
!!
!!    AUTHOR
!!    ------
!!      Joan Cuxart             * INM and Meteo-France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original         18/10/94
!!      Modifications: Feb 14, 1995 (J.Cuxart and J.Stein) 
!!                                  Doctorization and Optimization
!!      Modifications: March 21, 1995 (J.M. Carriere) 
!!                                  Introduction of cloud water
!!      Modifications: March 21, 1995 (J. Cuxart and J.Stein)
!!                                  Phi3 and Psi3 at w point + cleaning
!!      Modifications: July 2, 1995 (J.Cuxart and Ph.Bougeault)
!!                         change the value of Phi3 and Psi3 if negative
!!      Modifications: Sept 20, 1995 (J. Stein, J. Cuxart, J.L. Redelsperger)
!!                         remove the Where + use REDTH1+REDR1 for the tests
!!      Modifications: October 10, 1995 (J. Cuxart and J.Stein)
!!                         Psi3 for tPREDS1he scalar variables
!!      Modifications: February 27, 1996 (J.Stein) optimization
!!      Modifications: June 15, 1996 (P.Jabouille) return to the previous
!!                          computation of Phi3 and Psi3
!!      Modifications: October 10, 1996 (J. Stein) change the temporal
!!                          discretization
!!      Modifications: May 23, 1997 (J. Stein) bug in 3D Redels number at ground
!!                                             with orography
!!      Modifications: Feb 20, 1998 (J. Stein) bug in all the 3D cases due to
!!                                             the use of ZW1 instead of ZW2
!!                     Feb 20, 2003 (JP Pinty) Add PFRAC_ICE
!!                     July    2005 (Tomas, Masson) implicitation of PHI3 and PSI3
!!                     October 2009 (G. Tanguy) add ILENCH=LEN(YCOMMENT) after
!!                                              change of YCOMMENT
!!                     2012-02 Y. Seity,  add possibility to run with reversed 
!!                                               vertical levels
!! --------------------------------------------------------------------------
!       
!*      0. DECLARATIONS
!          ------------
!
USE MODD_CST
USE MODD_CONF
USE MODD_CTURB
USE MODD_PARAMETERS
!
USE MODI_GRADIENT_M
USE MODI_EMOIST
USE MODI_ETHETA
USE MODI_SHUMAN
USE MODE_FMWRIT
!
IMPLICIT NONE
!
!
!*      0.1  declarations of arguments
!
INTEGER,                INTENT(IN)   :: KKA           !near ground array index  
INTEGER,                INTENT(IN)   :: KKU           !uppest atmosphere array index
INTEGER,                INTENT(IN)   :: KKL           !vert. levels type 1=MNH -1=ARO

INTEGER,                INTENT(IN)   :: KRR           ! number of moist var.
INTEGER,                INTENT(IN)   :: KRRI          ! number of ice var.
!
LOGICAL,                INTENT(IN)   ::  OCLOSE_OUT   ! switch for syncronous
                                                      ! file opening
LOGICAL,                INTENT(IN)   ::  OTURB_DIAG   ! switch to write some
                                 ! diagnostic fields in the syncronous FM-file
CHARACTER*4           , INTENT(IN)   ::  HTURBDIM     ! Kind of turbulence param.
CHARACTER(LEN=*),       INTENT(IN)   ::  HFMFILE      ! Name of the output
                                                      ! FM-file
CHARACTER(LEN=*),       INTENT(IN)   ::  HLUOUT       ! Output-listing name for
                                                      ! model n
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PDXX,PDYY,PDZZ,PDZX,PDZY
                                                  ! metric coefficients
!
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PTHVREF  ! Virtual Potential Temp.
                                                  ! of the reference state
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLOCPEXNM ! Lv(T)/Cp/Exner at t-1 
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PATHETA      ! coefficients between 
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PAMOIST      ! s and Thetal and Rnp
!
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLM      ! Turbulent Mixing length
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PLEPS    ! Dissipative length
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PTHLM,PTKEM! Conservative Potential 
                                                  ! Temperature and TKE at t-1
REAL, DIMENSION(:,:,:,:), INTENT(IN) ::  PRM      ! Mixing ratios at  t-1
                                                  ! with PRM(:,:,:,1) = cons.
                                                  ! mixing ratio
REAL, DIMENSION(:,:,:,:), INTENT(IN) ::  PSVM     ! Scalars at t-1      
REAL, DIMENSION(:,:,:), INTENT(IN)   ::  PSRCM
                                  ! s'r'c/2Sigma_s2 at t-1 multiplied by Lambda_3
!
!
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PREDTH1 ! Redelsperger number R_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PREDR1  ! Redelsperger number R_q
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2TH3 ! Redelsperger number R*2_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2R3  ! Redelsperger number R*2_q
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PRED2THR3! Redelsperger number R*2_thq
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PREDS1   ! Redelsperger number R_s
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PRED2THS3! Redelsperger number R*2_thsv
REAL, DIMENSION(:,:,:,:), INTENT(OUT)::  PRED2RS3 ! Redelsperger number R*2_qsv
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PBLL_O_E! beta*Lk*Leps/tke
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PETHETA ! coefficient E_theta
REAL, DIMENSION(:,:,:), INTENT(OUT)  ::  PEMOIST ! coefficient E_moist
!
!
!       0.2  declaration of local variables
!
REAL, DIMENSION(SIZE(PTHLM,1),SIZE(PTHLM,2),SIZE(PTHLM,3)) ::  &
                  ZW1, ZW2, ZW3
!                                                 working variables
!                                                     
INTEGER :: IKB      ! vertical index value for the first inner mass point
INTEGER :: IKE      ! vertical index value for the last inner mass point
INTEGER             :: IRESP        ! Return code of FM routines
INTEGER             :: ILENG        ! Length of the data field in LFIFM file
INTEGER             :: IGRID        ! C-grid indicator in LFIFM file
INTEGER             :: ILENCH       ! Length of comment string in LFIFM file
CHARACTER (LEN=100) :: YCOMMENT     ! comment string in LFIFM file
CHARACTER (LEN=16)  :: YRECFM       ! Name of the desired field in LFIFM file
INTEGER::  ISV                      ! number of scalar variables       
INTEGER::  JSV                      ! loop index for the scalar variables  

INTEGER :: JLOOP
REAL    :: ZMINVAL
! ---------------------------------------------------------------------------
!
!
!*      1.  DEFAULT VALUES,  1D REDELSPERGER NUMBERS 
!           ----------------------------------------
!
IKB = KKA+JPVEXT_TURB*KKL
IKE = KKU-JPVEXT_TURB*KKL 
ILENG=SIZE(PTHLM,1)*SIZE(PTHLM,2)*SIZE(PTHLM,3)
ISV  =SIZE(PSVM,4)
!
PETHETA(:,:,:) = MZM(KKA,KKU,KKL, ETHETA(KRR,KRRI,PTHLM,PRM,PLOCPEXNM,PATHETA,PSRCM) )
PEMOIST(:,:,:) = MZM(KKA,KKU,KKL, EMOIST(KRR,KRRI,PTHLM,PRM,PLOCPEXNM,PAMOIST,PSRCM) )
PETHETA(:,:,KKA) = 2.*PETHETA(:,:,IKB) - PETHETA(:,:,IKB+KKL)
PEMOIST(:,:,KKA) = 2.*PEMOIST(:,:,IKB) - PEMOIST(:,:,IKB+KKL)
!
!---------------------------------------------------------------------------
!
!          1.3 1D Redelsperger numbers
!
PBLL_O_E(:,:,:) = MZM(KKA,KKU,KKL, XG / PTHVREF(:,:,:) * PLM(:,:,:) * PLEPS(:,:,:) / PTKEM(:,:,:) )  
IF (KRR /= 0) THEN                ! moist case
  PREDTH1(:,:,:)= XCTV*PBLL_O_E(:,:,:) * PETHETA(:,:,:) * &
                   & GZ_M_W(KKA,KKU,KKL,PTHLM,PDZZ)
  PREDR1(:,:,:) = XCTV*PBLL_O_E(:,:,:) * PEMOIST(:,:,:) * &
                   & GZ_M_W(KKA,KKU,KKL,PRM(:,:,:,1),PDZZ)
ELSE                              ! dry case
  PREDTH1(:,:,:)= XCTV*PBLL_O_E(:,:,:)  * GZ_M_W(KKA,KKU,KKL,PTHLM,PDZZ)
  PREDR1(:,:,:) = 0.
END IF
!
!       3. Limits on 1D Redelperger numbers
!          --------------------------------
!
ZMINVAL = (1.-1./XPHI_LIM)
!
ZW1 = 1.
ZW2 = 1.
!
WHERE (PREDTH1+PREDR1<-ZMINVAL)
  ZW1 = (-ZMINVAL) / (PREDTH1+PREDR1)
END WHERE
!
WHERE (PREDTH1<-ZMINVAL)
  ZW2 = (-ZMINVAL) / (PREDTH1)
END WHERE
ZW2 = MIN(ZW1,ZW2)
!
ZW1 = 1.
WHERE (PREDR1<-ZMINVAL)
  ZW1 = (-ZMINVAL) / (PREDR1)
END WHERE
ZW1 = MIN(ZW2,ZW1)
!
!
!       3. Modification of Mixing length and dissipative length
!          ----------------------------------------------------
!
PBLL_O_E(:,:,:) = PBLL_O_E(:,:,:) * ZW1(:,:,:)
PREDTH1 (:,:,:) = PREDTH1 (:,:,:) * ZW1(:,:,:)
PREDR1  (:,:,:) = PREDR1  (:,:,:) * ZW1(:,:,:)
!
!       4. Threshold for very small (in absolute value) Redelperger numbers
!          ----------------------------------------------------------------
!
ZW2=SIGN(1.,PREDTH1(:,:,:))
PREDTH1(:,:,:)= ZW2(:,:,:) * MAX(XMNH_TINY_12, ZW2(:,:,:)*PREDTH1(:,:,:))
!
IF (KRR /= 0) THEN                ! dry case
  ZW2=SIGN(1.,PREDR1(:,:,:))
  PREDR1(:,:,:)= ZW2(:,:,:) * MAX(XMNH_TINY_12, ZW2(:,:,:)*PREDR1(:,:,:))
END IF
!
!
!---------------------------------------------------------------------------
!
!          For the scalar variables
DO JSV=1,ISV
  PREDS1(:,:,:,JSV)=XCTV*PBLL_O_E(:,:,:)*GZ_M_W(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDZZ)
END DO
!
DO JSV=1,ISV
  ZW2=SIGN(1.,PREDS1(:,:,:,JSV))
  PREDS1(:,:,:,JSV)= ZW2(:,:,:) * MAX(1.E-30, ZW2(:,:,:)*PREDS1(:,:,:,JSV))
END DO
!
!---------------------------------------------------------------------------
!
!*      2.  3D REDELSPERGER NUMBERS
!           ------------------------
!
IF(HTURBDIM=='1DIM') THEN        ! 1D case
!
!
  PRED2TH3(:,:,:)  = PREDTH1(:,:,:)**2
!
  PRED2R3(:,:,:)   = PREDR1(:,:,:) **2
!
  PRED2THR3(:,:,:) = PREDTH1(:,:,:) * PREDR1(:,:,:)
!
ELSE IF (L2D) THEN                      ! 3D case in a 2D model
!
  IF (KRR /= 0) THEN                 ! moist 3D case
    PRED2TH3(:,:,:)= PREDTH1(:,:,:)**2+(XCTV*PBLL_O_E(:,:,:)*PETHETA(:,:,:) )**2 * &
      MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)**2 )
    PRED2TH3(:,:,IKB)=PRED2TH3(:,:,IKB+KKL)
!
    PRED2R3(:,:,:)= PREDR1(:,:,:)**2 + (XCTV*PBLL_O_E(:,:,:)*PEMOIST(:,:,:))**2 * &
        MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)**2 )
    PRED2R3(:,:,IKB)=PRED2R3(:,:,IKB+KKL)
!
    PRED2THR3(:,:,:)= PREDR1(:,:,:) * PREDTH1(:,:,:) +  XCTV**2*PBLL_O_E(:,:,:)**2 *   &
                  PEMOIST(:,:,:) * PETHETA(:,:,:) *                         &
      MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)*     &
                     GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX))
    PRED2THR3(:,:,IKB)=PRED2THR3(:,:,IKB+KKL)
!
  ELSE                 ! dry 3D case in a 2D model
    PRED2TH3(:,:,:) = PREDTH1(:,:,:)**2 +  XCTV**2*PBLL_O_E(:,:,:)**2 *     &
      MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)**2 )
    PRED2TH3(:,:,IKB)=PRED2TH3(:,:,IKB+KKL)
!
    PRED2R3(:,:,:) = 0.
!
    PRED2THR3(:,:,:) = 0.
!
  END IF
!
ELSE                                 ! 3D case in a 3D model
!
  IF (KRR /= 0) THEN                 ! moist 3D case
    PRED2TH3(:,:,:)= PREDTH1(:,:,:)**2 +  ( XCTV*PBLL_O_E(:,:,:)*PETHETA(:,:,:) )**2 * &
      MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)**2 &
      + GY_M_M(KKA,KKU,KKL,PTHLM,PDYY,PDZZ,PDZY)**2 )
    PRED2TH3(:,:,IKB)=PRED2TH3(:,:,IKB+KKL)
!
    PRED2R3(:,:,:)= PREDR1(:,:,:)**2 + (XCTV*PBLL_O_E(:,:,:)*PEMOIST(:,:,:))**2 *      &
        MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)**2 + &
        GY_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDYY,PDZZ,PDZY)**2 )
    PRED2R3(:,:,IKB)=PRED2R3(:,:,IKB+KKL)
!
    PRED2THR3(:,:,:)= PREDR1(:,:,:) * PREDTH1(:,:,:) +  XCTV**2*PBLL_O_E(:,:,:)**2 *   &
         PEMOIST(:,:,:) * PETHETA(:,:,:) *                            &
         MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)*   &
         GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)+                           &
         GY_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDYY,PDZZ,PDZY)*                    &
         GY_M_M(KKA,KKU,KKL,PTHLM,PDYY,PDZZ,PDZY) )
    PRED2THR3(:,:,IKB)=PRED2THR3(:,:,IKB+KKL)
!
  ELSE                 ! dry 3D case in a 3D model
    PRED2TH3(:,:,:) = PREDTH1(:,:,:)**2 +  XCTV**2*PBLL_O_E(:,:,:)**2 *                &
      MZM(KKA,KKU,KKL, GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)**2 &
      + GY_M_M(KKA,KKU,KKL,PTHLM,PDYY,PDZZ,PDZY)**2 )
    PRED2TH3(:,:,IKB)=PRED2TH3(:,:,IKB+KKL)
!
    PRED2R3(:,:,:) = 0.
!
    PRED2THR3(:,:,:) = 0.
!
  END IF
!
END IF   ! end of the if structure on the turbulence dimensionnality
!
!
!---------------------------------------------------------------------------
!
!           5. Prandtl numbers for scalars
!              ---------------------------
DO JSV=1,ISV
!
  IF(HTURBDIM=='1DIM') THEN
!        1D case
    PRED2THS3(:,:,:,JSV)  = PREDS1(:,:,:,JSV) * PREDTH1(:,:,:)
    IF (KRR /= 0) THEN
      PRED2RS3(:,:,:,JSV)   = PREDR1(:,:,:) *PREDS1(:,:,:,JSV)
    ELSE
      PRED2RS3(:,:,:,JSV)   = 0.
    END IF
!
  ELSE  IF (L2D) THEN ! 3D case in a 2D model
!
    IF (KRR /= 0) THEN
      ZW1 = MZM(KKA,KKU,KKL, (XG / PTHVREF * PLM * PLEPS / PTKEM)**2 ) *PETHETA
    ELSE
      ZW1 = MZM(KKA,KKU,KKL, (XG / PTHVREF * PLM * PLEPS / PTKEM)**2)
    END IF
    PRED2THS3(:,:,:,JSV) = PREDTH1(:,:,:) * PREDS1(:,:,:,JSV)   +        &
                       ZW1*                                              &
                       MZM(KKA,KKU,KKL,GX_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDXX,PDZZ,PDZX)*       &
                           GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)                  &
                          )
!
    IF (KRR /= 0) THEN
      PRED2RS3(:,:,:,JSV) = PREDR1(:,:,:) * PREDS1(:,:,:,JSV)   +        &
                       ZW1 * PEMOIST *                                   &
                       MZM(KKA,KKU,KKL,GX_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDXX,PDZZ,PDZX)*       &
                           GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)           &
                          )
    ELSE
      PRED2RS3(:,:,:,JSV) = 0.
    END IF
!
  ELSE ! 3D case in a 3D model
!
    IF (KRR /= 0) THEN
      ZW1 = MZM(KKA,KKU,KKL, (XG / PTHVREF * PLM * PLEPS / PTKEM)**2 ) *PETHETA
    ELSE
      ZW1 = MZM(KKA,KKU,KKL, (XG / PTHVREF * PLM * PLEPS / PTKEM)**2)
    END IF
    PRED2THS3(:,:,:,JSV) = PREDTH1(:,:,:) * PREDS1(:,:,:,JSV)   +        &
                       ZW1*                                              &
                       MZM(KKA,KKU,KKL,GX_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDXX,PDZZ,PDZX)*       &
                           GX_M_M(KKA,KKU,KKL,PTHLM,PDXX,PDZZ,PDZX)                  &
                          +GY_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDYY,PDZZ,PDZY)*       &
                           GY_M_M(KKA,KKU,KKL,PTHLM,PDYY,PDZZ,PDZY)                  &
                          )
!
    IF (KRR /= 0) THEN
      PRED2RS3(:,:,:,JSV) = PREDR1(:,:,:) * PREDS1(:,:,:,JSV)   +        &
                       ZW1 * PEMOIST *                                   &
                       MZM(KKA,KKU,KKL,GX_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDXX,PDZZ,PDZX)*       &
                           GX_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDXX,PDZZ,PDZX)           &
                          +GY_M_M(KKA,KKU,KKL,PSVM(:,:,:,JSV),PDYY,PDZZ,PDZY)*       &
                           GY_M_M(KKA,KKU,KKL,PRM(:,:,:,1),PDYY,PDZZ,PDZY)           &
                          )
    ELSE
      PRED2RS3(:,:,:,JSV) = 0.
    END IF
!
  END IF ! end of HTURBDIM if-block
!
END DO
!
!---------------------------------------------------------------------------
!
!*          6. SAVES THE REDELSPERGER NUMBERS
!              ------------------------------
!
IF ( OTURB_DIAG .AND. OCLOSE_OUT ) THEN
  !
  ! stores the RED_TH1
  YRECFM  ='RED_TH1'
  YCOMMENT='X_Y_Z_RED_TH1 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,HLUOUT,'XY',PREDTH1,IGRID,ILENCH,YCOMMENT,IRESP)
  !
  ! stores the RED_R1
  YRECFM  ='RED_R1'
  YCOMMENT='X_Y_Z_RED_R1 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,HLUOUT,'XY',PREDR1,IGRID,ILENCH,YCOMMENT,IRESP)
  !
  ! stores the RED2_TH3
  YRECFM  ='RED2_TH3'
  YCOMMENT='X_Y_Z_RED2_TH3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,HLUOUT,'XY',PRED2TH3,IGRID,ILENCH,YCOMMENT,IRESP)
  !
  ! stores the RED2_R3
  YRECFM  ='RED2_R3'
  YCOMMENT='X_Y_Z_RED2_R3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,HLUOUT,'XY',PRED2R3,IGRID,ILENCH,YCOMMENT,IRESP)
  !
  ! stores the RED2_THR3
  YRECFM  ='RED2_THR3'
  YCOMMENT='X_Y_Z_RED2_THR3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,HLUOUT,'XY',PRED2THR3,IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!
!---------------------------------------------------------------------------
!
END SUBROUTINE PRANDTL

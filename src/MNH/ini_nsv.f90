!MNH_LIC Copyright 2001-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ###################
      MODULE MODI_INI_NSV
!     ###################
INTERFACE 
!
  SUBROUTINE INI_NSV(KMI)
  INTEGER, INTENT(IN)            :: KMI ! model index
  END SUBROUTINE INI_NSV
!
END INTERFACE
!
END MODULE MODI_INI_NSV
!
!
!     ###########################
      SUBROUTINE INI_NSV(KMI)
!     ###########################
!
!!****   *INI_NSV* - compute NSV_* values and indices for model KMI
!!
!!    PURPOSE
!!    -------
!     
!
!     
!!**  METHOD
!!    ------
!!
!!    This routine is called from any routine which stores values in 
!!    the first model module (for example READ_EXSEG).
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_NSV     : contains NSV_A array variable
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!      D. Gazen              * LA *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original   01/02/01
!!      Modification   29/11/02  (Pinty)  add SV for C3R5 and ELEC
!!      Modification   01/2004   (Masson) add scalar names
!!      Modification   03/2006   (O.Geoffroy) add KHKO scheme
!!      Modification   04/2007   (Leriche) add SV for aqueous chemistry
!!      M. Chong       26/01/10   Add Small ions
!!      Modification   07/2010   (Leriche) add SV for ice chemistry
!!      X.Pialat & J.Escobar 11/2012 remove deprecated line NSV_A(KMI) = ISV
!!      Modification   15/02/12  (Pialat/Tulet) Add SV for ForeFire scalars
!!                     03/2013   (C.Lac) add supersaturation as 
!!                               the 4th C2R2 scalar variable
!!       J.escobar     04/08/2015 suit Pb with writ_lfin JSA increment , modif in ini_nsv to have good order initialization
!!      Modification    01/2016  (JP Pinty) Add LIMA and LUSECHEM condition
!!      Modification    07/2017  (V. Vionnet) Add blowing snow condition
!  P. Wautelet 09/03/2021: move some chemistry initializations to ini_nsv
!  P. Wautelet 10/03/2021: move scalar variable name initializations to ini_nsv
!  P. Wautelet 10/03/2021: add CSVNAMES and CSVNAMES_A to store the name of all the scalar variables
!  P. Wautelet 30/03/2021: move NINDICE_CCN_IMM and NIMM initializations from init_aerosol_properties to ini_nsv
!  B. Vie         06/2021: add prognostic supersaturation for LIMA
!! 
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_BLOWSNOW,        ONLY: CSNOWNAMES, LBLOWSNOW, NBLOWSNOW3D, YPSNOW_INI
USE MODD_CH_AEROSOL,      ONLY: CAERONAMES, CDEAERNAMES, JPMODE, LAERINIT, LDEPOS_AER, LORILAM, &
                                LVARSIGI, LVARSIGJ, NCARB, NM6_AER, NSOA, NSP
USE MODD_CH_M9_n,         ONLY: CICNAMES, CNAMES, NEQ, NEQAQ
USE MODD_CH_MNHC_n,       ONLY: LCH_PH, LUSECHEM, LUSECHAQ, LUSECHIC, CCH_SCHEME, LCH_CONV_LINOX
USE MODD_CONDSAMP,        ONLY: LCONDSAMP, NCONDSAMP
USE MODD_CONF,            ONLY: LLG, CPROGRAM, NVERB
USE MODD_CST,             ONLY: XMNH_TINY
USE MODD_DIAG_FLAG,       ONLY: LCHEMDIAG, LCHAQDIAG
USE MODD_DUST,            ONLY: CDEDSTNAMES, CDUSTNAMES, JPDUSTORDER, LDEPOS_DST, LDSTINIT, LDSTPRES, LDUST, &
                                LRGFIX_DST, LVARSIG, NMODE_DST, YPDEDST_INI, YPDUST_INI
USE MODD_DYN_n,           ONLY: LHORELAX_SV,LHORELAX_SVC2R2,LHORELAX_SVC1R3,   &
                                LHORELAX_SVLIMA,                               &
                                LHORELAX_SVELEC,LHORELAX_SVCHEM,LHORELAX_SVLG, &
                                LHORELAX_SVDST,LHORELAX_SVAER, LHORELAX_SVSLT, &
                                LHORELAX_SVPP,LHORELAX_SVCS, LHORELAX_SVCHIC,  &
                                LHORELAX_SVSNW
#ifdef MNH_FOREFIRE
USE MODD_DYN_n,           ONLY: LHORELAX_SVFF
#endif
USE MODD_ELEC_DESCR,      ONLY: LLNOX_EXPLICIT
USE MODD_ELEC_DESCR,      ONLY: CELECNAMES
#ifdef MNH_FOREFIRE
USE MODD_FOREFIRE
#endif
USE MODD_ICE_C1R3_DESCR,  ONLY: C1R3NAMES
USE MODD_LG,              ONLY: CLGNAMES, XLG1MIN, XLG2MIN, XLG3MIN
USE MODD_LUNIT_n,         ONLY: TLUOUT
USE MODD_NSV
USE MODD_PARAM_C2R2,      ONLY: LSUPSAT
USE MODD_PARAM_LIMA,      ONLY: NINDICE_CCN_IMM, NIMM, NMOD_CCN, LSCAV, LAERO_MASS, &
                                NMOD_IFN, NMOD_IMM, LHHONI, LSNOW, LHAIL, &
                                LWARM, LCOLD, LRAIN, LSPRO,  &
                                NMOM_C, NMOM_R, NMOM_I, NMOM_S, NMOM_G, NMOM_H
USE MODD_PARAM_LIMA_COLD, ONLY: CLIMA_COLD_NAMES
USE MODD_PARAM_LIMA_WARM, ONLY: CAERO_MASS, CLIMA_WARM_NAMES
USE MODD_PARAM_n,         ONLY: CCLOUD, CELEC
USE MODD_PASPOL,          ONLY: LPASPOL, NRELEASE
USE MODD_PREP_REAL,       ONLY: XT_LS
USE MODD_RAIN_C2R2_DESCR, ONLY: C2R2NAMES
USE MODD_SALT,            ONLY: CSALTNAMES, CDESLTNAMES, JPSALTORDER, &
                                LRGFIX_SLT, LSALT, LSLTINIT, LSLTPRES, LDEPOS_SLT, LVARSIG_SLT, NMODE_SLT, YPDESLT_INI, YPSALT_INI

USE MODE_MSG

USE MODI_CH_AER_INIT_SOA,  ONLY: CH_AER_INIT_SOA
USE MODI_CH_INIT_SCHEME_n, ONLY: CH_INIT_SCHEME_n
USE MODI_UPDATE_NSV,       ONLY: UPDATE_NSV
!
IMPLICIT NONE 
!
!-------------------------------------------------------------------------------
!
!*       0.1   Declarations of arguments
!
INTEGER, INTENT(IN)             :: KMI ! model index
!
!*       0.2   Declarations of local variables
!
CHARACTER(LEN=2) :: YNUM2
CHARACTER(LEN=3) :: YNUM3
INTEGER :: ILUOUT
INTEGER :: ISV ! total number of scalar variables
INTEGER :: IMODEIDX, IMOMENTS
INTEGER :: JI, JJ, JSV
INTEGER :: JMODE, JMOM, JSV_NAME
!
!-------------------------------------------------------------------------------
!
LINI_NSV = .TRUE.

ILUOUT = TLUOUT%NLU
!
! Users scalar variables are first considered
!
NSV_USER_A(KMI) = NSV_USER
ISV = NSV_USER
!
! scalar variables used in microphysical schemes C2R2,KHKO and C3R5
!
IF (CCLOUD == 'C2R2' .OR. CCLOUD == 'C3R5' .OR. CCLOUD == 'KHKO' ) THEN
  IF ((CCLOUD == 'C2R2' .AND. LSUPSAT) .OR. (CCLOUD == 'KHKO'.AND. LSUPSAT)) THEN
   ! 4th scalar field = supersaturation
    NSV_C2R2_A(KMI)    = 4
  ELSE
    NSV_C2R2_A(KMI)    = 3
  END IF
  NSV_C2R2BEG_A(KMI) = ISV+1
  NSV_C2R2END_A(KMI) = ISV+NSV_C2R2_A(KMI)
  ISV                = NSV_C2R2END_A(KMI)
  IF (CCLOUD == 'C3R5') THEN  ! the SVs for C2R2 and C1R3 must be contiguous
    NSV_C1R3_A(KMI)    = 2
    NSV_C1R3BEG_A(KMI) = ISV+1
    NSV_C1R3END_A(KMI) = ISV+NSV_C1R3_A(KMI)
    ISV                = NSV_C1R3END_A(KMI)
  ELSE
    NSV_C1R3_A(KMI)    = 0
  ! force First index to be superior to last index
  ! in order to create a null section
    NSV_C1R3BEG_A(KMI) = 1
    NSV_C1R3END_A(KMI) = 0
  END IF
ELSE
  NSV_C2R2_A(KMI)    = 0
  NSV_C1R3_A(KMI)    = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_C2R2BEG_A(KMI) = 1
  NSV_C2R2END_A(KMI) = 0
  NSV_C1R3BEG_A(KMI) = 1
  NSV_C1R3END_A(KMI) = 0
END IF
!
! scalar variables used in the LIMA microphysical scheme
!
IF (CCLOUD == 'LIMA' ) THEN
   ISV = ISV+1
   NSV_LIMA_BEG_A(KMI) = ISV
   IF (LWARM .AND. NMOM_C.GE.2) THEN
! Nc
      NSV_LIMA_NC_A(KMI) = ISV
      ISV = ISV+1
   END IF
! Nr
      IF (LWARM .AND. LRAIN .AND. NMOM_R.GE.2) THEN
         NSV_LIMA_NR_A(KMI) = ISV
         ISV = ISV+1
      END IF
! CCN
   IF (NMOD_CCN .GT. 0) THEN
      NSV_LIMA_CCN_FREE_A(KMI) = ISV
      ISV = ISV + NMOD_CCN
      NSV_LIMA_CCN_ACTI_A(KMI) = ISV
      ISV = ISV + NMOD_CCN
   END IF
! Scavenging
   IF (LSCAV .AND. LAERO_MASS) THEN
      NSV_LIMA_SCAVMASS_A(KMI) = ISV
      ISV = ISV+1
   END IF
! Ni
   IF (LCOLD .AND. NMOM_I.GE.2) THEN
      NSV_LIMA_NI_A(KMI) = ISV
      ISV = ISV+1
   END IF
! Ns
   IF (LCOLD .AND. LSNOW .AND. NMOM_S.GE.2) THEN
      NSV_LIMA_NS_A(KMI) = ISV
      ISV = ISV+1
   END IF
! Ng
   IF (LCOLD .AND. LWARM .AND. LSNOW .AND. NMOM_G.GE.2) THEN
      NSV_LIMA_NG_A(KMI) = ISV
      ISV = ISV+1
   END IF
! Nh
   IF (LCOLD .AND. LWARM .AND. LSNOW .AND. LHAIL .AND. NMOM_H.GE.2) THEN
      NSV_LIMA_NH_A(KMI) = ISV
      ISV = ISV+1
   END IF
! IFN
   IF (NMOD_IFN .GT. 0) THEN
      NSV_LIMA_IFN_FREE_A(KMI) = ISV
      ISV = ISV + NMOD_IFN
      NSV_LIMA_IFN_NUCL_A(KMI) = ISV
      ISV = ISV + NMOD_IFN
   END IF
! IMM
   IF (NMOD_IMM .GT. 0) THEN
      NSV_LIMA_IMM_NUCL_A(KMI) = ISV
      ISV = ISV + MAX(1,NMOD_IMM)
   END IF
!
  IF ( NMOD_IFN > 0 ) THEN
    IF ( .NOT. ALLOCATED( NIMM ) ) ALLOCATE( NIMM(NMOD_CCN) )
    NIMM(:) = 0
    IF ( ALLOCATED( NINDICE_CCN_IMM ) ) DEALLOCATE( NINDICE_CCN_IMM )
    ALLOCATE( NINDICE_CCN_IMM(MAX( 1, NMOD_IMM )) )
    IF (NMOD_IMM > 0 ) THEN
      DO JI = 0, NMOD_IMM - 1
        NIMM(NMOD_CCN - JI) = 1
        NINDICE_CCN_IMM(NMOD_IMM - JI) = NMOD_CCN - JI
      END DO
!     ELSE IF (NMOD_IMM == 0) THEN ! PNIS exists but is 0 for the call to resolved_cloud
!       NMOD_IMM = 1
!       NINDICE_CCN_IMM(1) = 0
    END IF
  END IF

! Homogeneous freezing of CCN
   IF (LCOLD .AND. LHHONI) THEN
      NSV_LIMA_HOM_HAZE_A(KMI) = ISV
      ISV = ISV + 1
   END IF
! Supersaturation
   IF (LSPRO) THEN
      NSV_LIMA_SPRO_A(KMI) = ISV
      ISV = ISV + 1
   END IF
!
! End and total variables
!
   ISV = ISV - 1
   NSV_LIMA_END_A(KMI) = ISV
   NSV_LIMA_A(KMI) = NSV_LIMA_END_A(KMI) - NSV_LIMA_BEG_A(KMI) + 1
ELSE
   NSV_LIMA_A(KMI)    = 0
!
! force First index to be superior to last index
! in order to create a null section
!
   NSV_LIMA_BEG_A(KMI) = 1
   NSV_LIMA_END_A(KMI) = 0
END IF ! CCLOUD = LIMA
!
!
!  Add one scalar for negative ion
!   First variable: positive ion (NSV_ELECBEG_A index number)
!   Last  --------: negative ion (NSV_ELECEND_A index number)
! Correspondence for ICE3:
! Relative index    1       2        3       4      5      6       7
! Charge for     ion+     cloud    rain     ice   snow  graupel  ion-
!
! Correspondence for ICE4:
! Relative index    1       2        3       4      5      6       7       8
! Charge for     ion+     cloud    rain     ice   snow  graupel   hail   ion-
!
IF (CELEC /= 'NONE') THEN
  IF (CCLOUD == 'ICE3') THEN
    NSV_ELEC_A(KMI)   = 7 
    NSV_ELECBEG_A(KMI)= ISV+1
    NSV_ELECEND_A(KMI)= ISV+NSV_ELEC_A(KMI)
    ISV               = NSV_ELECEND_A(KMI)
    CELECNAMES(7) = CELECNAMES(8) 
  ELSE IF (CCLOUD == 'ICE4') THEN
    NSV_ELEC_A(KMI)   = 8 
    NSV_ELECBEG_A(KMI)= ISV+1
    NSV_ELECEND_A(KMI)= ISV+NSV_ELEC_A(KMI)
    ISV               = NSV_ELECEND_A(KMI)
  END IF
ELSE
  NSV_ELEC_A(KMI)    = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_ELECBEG_A(KMI) = 1
  NSV_ELECEND_A(KMI) = 0
END IF
!
! scalar variables used as lagragian variables
!
IF (LLG) THEN
  NSV_LG_A(KMI)     = 3
  NSV_LGBEG_A(KMI)  = ISV+1
  NSV_LGEND_A(KMI)  = ISV+NSV_LG_A(KMI)
  ISV               = NSV_LGEND_A(KMI)
ELSE
  NSV_LG_A(KMI)     = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_LGBEG_A(KMI)  = 1
  NSV_LGEND_A(KMI)  = 0
END IF
!
! scalar variables used as LiNOX passive tracer
!
! In case without chemistry
IF (LPASPOL) THEN
  NSV_PP_A(KMI)   = NRELEASE
  NSV_PPBEG_A(KMI)= ISV+1
  NSV_PPEND_A(KMI)= ISV+NSV_PP_A(KMI)
  ISV               = NSV_PPEND_A(KMI)
ELSE
  NSV_PP_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_PPBEG_A(KMI)= 1
  NSV_PPEND_A(KMI)= 0
END IF
!
#ifdef MNH_FOREFIRE

! ForeFire tracers
IF (LFOREFIRE .AND. NFFSCALARS .GT. 0) THEN
  NSV_FF_A(KMI)    = NFFSCALARS
  NSV_FFBEG_A(KMI) = ISV+1
  NSV_FFEND_A(KMI) = ISV+NSV_FF_A(KMI)
  ISV              = NSV_FFEND_A(KMI)
ELSE
  NSV_FF_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_FFBEG_A(KMI)= 1
  NSV_FFEND_A(KMI)= 0
END IF
#endif
! Conditional sampling variables  
IF (LCONDSAMP) THEN
  NSV_CS_A(KMI)   = NCONDSAMP
  NSV_CSBEG_A(KMI)= ISV+1
  NSV_CSEND_A(KMI)= ISV+NSV_CS_A(KMI)
  ISV               = NSV_CSEND_A(KMI)
ELSE
  NSV_CS_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_CSBEG_A(KMI)= 1
  NSV_CSEND_A(KMI)= 0
END IF
!
! scalar variables used in chemical core system
!
IF (LUSECHEM) THEN
  CALL CH_INIT_SCHEME_n(KMI,LUSECHAQ,LUSECHIC,LCH_PH,ILUOUT,NVERB)
  IF (LORILAM) CALL CH_AER_INIT_SOA(ILUOUT, NVERB)
END IF

IF (LUSECHEM .AND.(NEQ .GT. 0)) THEN
  NSV_CHEM_A(KMI)   = NEQ
  NSV_CHEMBEG_A(KMI)= ISV+1
  NSV_CHEMEND_A(KMI)= ISV+NSV_CHEM_A(KMI)
  ISV               = NSV_CHEMEND_A(KMI)
ELSE
  NSV_CHEM_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_CHEMBEG_A(KMI)= 1
  NSV_CHEMEND_A(KMI)= 0
END IF
!
! aqueous chemistry (part of the "chem" variables)       
!                                                        
IF ((LUSECHAQ .OR. LCHAQDIAG).AND.(NEQ .GT. 0)) THEN     
  NSV_CHGS_A(KMI) = NEQ-NEQAQ                            
  NSV_CHGSBEG_A(KMI)= NSV_CHEMBEG_A(KMI)                 
  NSV_CHGSEND_A(KMI)= NSV_CHEMBEG_A(KMI)+(NEQ-NEQAQ)-1   
  NSV_CHAC_A(KMI) = NEQAQ                                
  NSV_CHACBEG_A(KMI)= NSV_CHGSEND_A(KMI)+1               
  NSV_CHACEND_A(KMI)= NSV_CHEMEND_A(KMI)                 
!  ice phase chemistry
  IF (LUSECHIC) THEN
    NSV_CHIC_A(KMI) = NEQAQ/2. -1.
    NSV_CHICBEG_A(KMI)= ISV+1
    NSV_CHICEND_A(KMI)= ISV+NSV_CHIC_A(KMI)
    ISV               = NSV_CHICEND_A(KMI)
  ELSE
    NSV_CHIC_A(KMI) = 0
    NSV_CHICBEG_A(KMI)= 1
    NSV_CHICEND_A(KMI)= 0
  ENDIF
ELSE                                                     
  IF (NEQ .GT. 0) THEN
    NSV_CHGS_A(KMI) = NEQ-NEQAQ                            
    NSV_CHGSBEG_A(KMI)= NSV_CHEMBEG_A(KMI)                 
    NSV_CHGSEND_A(KMI)= NSV_CHEMBEG_A(KMI)+(NEQ-NEQAQ)-1   
    NSV_CHAC_A(KMI) = 0                                    
    NSV_CHACBEG_A(KMI)= 1                                  
    NSV_CHACEND_A(KMI)= 0                                  
    NSV_CHIC_A(KMI) = 0
    NSV_CHICBEG_A(KMI)= 1
    NSV_CHICEND_A(KMI)= 0
  ELSE
    NSV_CHGS_A(KMI) = 0
    NSV_CHGSBEG_A(KMI)= 1
    NSV_CHGSEND_A(KMI)= 0
    NSV_CHAC_A(KMI) = 0
    NSV_CHACBEG_A(KMI)= 1
    NSV_CHACEND_A(KMI)= 0   
    NSV_CHIC_A(KMI) = 0
    NSV_CHICBEG_A(KMI)= 1
    NSV_CHICEND_A(KMI)= 0    
  ENDIF
END IF
! aerosol variables
IF (LORILAM.AND.(NEQ .GT. 0)) THEN
  IF (ALLOCATED(XT_LS)) LAERINIT=.TRUE.
  NM6_AER = 0
  IF (LVARSIGI) NM6_AER = 1
  IF (LVARSIGJ) NM6_AER = NM6_AER + 1
  NSV_AER_A(KMI)   = (NSP+NCARB+NSOA+1)*JPMODE + NM6_AER
  NSV_AERBEG_A(KMI)= ISV+1
  NSV_AEREND_A(KMI)= ISV+NSV_AER_A(KMI)
  ISV              = NSV_AEREND_A(KMI)
ELSE
  NSV_AER_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_AERBEG_A(KMI)= 1
  NSV_AEREND_A(KMI)= 0
END IF
IF (LORILAM .AND. LDEPOS_AER(KMI)) THEN
  NSV_AERDEP_A(KMI)   = JPMODE*2
  NSV_AERDEPBEG_A(KMI)= ISV+1
  NSV_AERDEPEND_A(KMI)= ISV+NSV_AERDEP_A(KMI)
  ISV                  = NSV_AERDEPEND_A(KMI)       
ELSE
  NSV_AERDEP_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_AERDEPBEG_A(KMI)= 1
  NSV_AERDEPEND_A(KMI)= 0       
! force First index to be superior to last index
! in order to create a null section
END IF
!
! scalar variables used in dust model
!
IF (LDUST) THEN
  IF (ALLOCATED(XT_LS).AND. .NOT.(LDSTPRES)) LDSTINIT=.TRUE.
  IF (CPROGRAM == 'IDEAL ') LVARSIG = .TRUE.
  IF ((CPROGRAM == 'REAL  ').AND.LDSTINIT) LVARSIG = .TRUE.
  NSV_DST_A(KMI)   = NMODE_DST*2
  IF (LRGFIX_DST) THEN
        NSV_DST_A(KMI) = NMODE_DST
        LVARSIG = .FALSE.
  END IF
  IF (LVARSIG) NSV_DST_A(KMI) = NSV_DST_A(KMI) + NMODE_DST
  NSV_DSTBEG_A(KMI)= ISV+1
  NSV_DSTEND_A(KMI)= ISV+NSV_DST_A(KMI)
  ISV              = NSV_DSTEND_A(KMI)
ELSE
  NSV_DST_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_DSTBEG_A(KMI)= 1
  NSV_DSTEND_A(KMI)= 0
END IF
IF ( LDUST .AND. LDEPOS_DST(KMI) ) THEN
  NSV_DSTDEP_A(KMI)   = NMODE_DST*2
  NSV_DSTDEPBEG_A(KMI)= ISV+1
  NSV_DSTDEPEND_A(KMI)= ISV+NSV_DSTDEP_A(KMI)
  ISV                  = NSV_DSTDEPEND_A(KMI)       
ELSE
  NSV_DSTDEP_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_DSTDEPBEG_A(KMI)= 1
  NSV_DSTDEPEND_A(KMI)= 0       
! force First index to be superior to last index
! in order to create a null section

 END IF
! scalar variables used in sea salt model
!
IF (LSALT) THEN
  IF (ALLOCATED(XT_LS).AND. .NOT.(LSLTPRES)) LSLTINIT=.TRUE.
  IF (CPROGRAM == 'IDEAL ') LVARSIG_SLT = .TRUE.
  IF ((CPROGRAM == 'REAL  ').AND. LSLTINIT ) LVARSIG_SLT = .TRUE.
  NSV_SLT_A(KMI)   = NMODE_SLT*2
  IF (LRGFIX_SLT) THEN
        NSV_SLT_A(KMI) = NMODE_SLT
        LVARSIG_SLT = .FALSE.
  END IF
  IF (LVARSIG_SLT) NSV_SLT_A(KMI) = NSV_SLT_A(KMI) + NMODE_SLT
  NSV_SLTBEG_A(KMI)= ISV+1
  NSV_SLTEND_A(KMI)= ISV+NSV_SLT_A(KMI)
  ISV              = NSV_SLTEND_A(KMI)
ELSE
  NSV_SLT_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_SLTBEG_A(KMI)= 1
  NSV_SLTEND_A(KMI)= 0
END IF
IF ( LSALT .AND. LDEPOS_SLT(KMI) ) THEN
  NSV_SLTDEP_A(KMI)   = NMODE_SLT*2
  NSV_SLTDEPBEG_A(KMI)= ISV+1
  NSV_SLTDEPEND_A(KMI)= ISV+NSV_SLTDEP_A(KMI)
  ISV                  = NSV_SLTDEPEND_A(KMI)       
ELSE
  NSV_SLTDEP_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_SLTDEPBEG_A(KMI)= 1
  NSV_SLTDEPEND_A(KMI)= 0       
! force First index to be superior to last index
! in order to create a null section
END IF
!
! scalar variables used in blowing snow model
!
IF (LBLOWSNOW) THEN
  NSV_SNW_A(KMI)   = NBLOWSNOW3D
  NSV_SNWBEG_A(KMI)= ISV+1
  NSV_SNWEND_A(KMI)= ISV+NSV_SNW_A(KMI)
  ISV              = NSV_SNWEND_A(KMI)
ELSE
  NSV_SNW_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_SNWBEG_A(KMI)= 1
  NSV_SNWEND_A(KMI)= 0
END IF
!
! scalar variables used as LiNOX passive tracer
!
! In case without chemistry
IF (.NOT.(LUSECHEM.OR.LCHEMDIAG) .AND. (LCH_CONV_LINOX.OR.LLNOX_EXPLICIT)) THEN
  NSV_LNOX_A(KMI)   = 1
  NSV_LNOXBEG_A(KMI)= ISV+1
  NSV_LNOXEND_A(KMI)= ISV+NSV_LNOX_A(KMI)
  ISV               = NSV_LNOXEND_A(KMI)
ELSE
  NSV_LNOX_A(KMI)   = 0
! force First index to be superior to last index
! in order to create a null section
  NSV_LNOXBEG_A(KMI)= 1
  NSV_LNOXEND_A(KMI)= 0
END IF
!
! finale number of NSV variable
!
NSV_A(KMI) = ISV
!
!
!*        Update LHORELAX_SV,CGETSVM,CGETSVT for NON USER SV 
!
! C2R2  or KHKO SV case
!*BUG*JPC*MAR2006
! IF (CCLOUD == 'C2R2'  .OR. CCLOUD == 'KHKO' ) &
IF (CCLOUD == 'C2R2' .OR. CCLOUD == 'C3R5' .OR.  CCLOUD == 'KHKO' ) &
!*BUG*JPC*MAR2006
LHORELAX_SV(NSV_C2R2BEG_A(KMI):NSV_C2R2END_A(KMI))=LHORELAX_SVC2R2
! C3R5 SV case
IF (CCLOUD == 'C3R5') &
LHORELAX_SV(NSV_C1R3BEG_A(KMI):NSV_C1R3END_A(KMI))=LHORELAX_SVC1R3
! LIMA SV case
IF (CCLOUD == 'LIMA') &
LHORELAX_SV(NSV_LIMA_BEG_A(KMI):NSV_LIMA_END_A(KMI))=LHORELAX_SVLIMA
! Electrical SV case
IF (CELEC /= 'NONE') &
LHORELAX_SV(NSV_ELECBEG_A(KMI):NSV_ELECEND_A(KMI))=LHORELAX_SVELEC
! Chemical SV case
IF (LUSECHEM .OR. LCHEMDIAG) &
LHORELAX_SV(NSV_CHEMBEG_A(KMI):NSV_CHEMEND_A(KMI))=LHORELAX_SVCHEM
! Ice phase Chemical SV case
IF (LUSECHIC) &
LHORELAX_SV(NSV_CHICBEG_A(KMI):NSV_CHICEND_A(KMI))=LHORELAX_SVCHIC
! LINOX SV case
IF (.NOT.(LUSECHEM .OR. LCHEMDIAG) .AND. LCH_CONV_LINOX) &
LHORELAX_SV(NSV_LNOXBEG_A(KMI):NSV_LNOXEND_A(KMI))=LHORELAX_SVCHEM
! Dust SV case
IF (LDUST) &
LHORELAX_SV(NSV_DSTBEG_A(KMI):NSV_DSTEND_A(KMI))=LHORELAX_SVDST
! Sea Salt SV case
IF (LSALT) &
LHORELAX_SV(NSV_SLTBEG_A(KMI):NSV_SLTEND_A(KMI))=LHORELAX_SVSLT
! Aerosols SV case
IF (LORILAM) &
LHORELAX_SV(NSV_AERBEG_A(KMI):NSV_AEREND_A(KMI))=LHORELAX_SVAER
! Lagrangian variables
IF (LLG) &
LHORELAX_SV(NSV_LGBEG_A(KMI):NSV_LGEND_A(KMI))=LHORELAX_SVLG
! Passive pollutants  
IF (LPASPOL) &
LHORELAX_SV(NSV_PPBEG_A(KMI):NSV_PPEND_A(KMI))=LHORELAX_SVPP
#ifdef MNH_FOREFIRE
! Fire pollutants
IF (LFOREFIRE) &
LHORELAX_SV(NSV_FFBEG_A(KMI):NSV_FFEND_A(KMI))=LHORELAX_SVFF
#endif
! Conditional sampling
IF (LCONDSAMP) &
LHORELAX_SV(NSV_CSBEG_A(KMI):NSV_CSEND_A(KMI))=LHORELAX_SVCS
! Blowing snow case
IF (LBLOWSNOW) &
LHORELAX_SV(NSV_SNWBEG_A(KMI):NSV_SNWEND_A(KMI))=LHORELAX_SVSNW
! Update NSV* variables for model KMI
CALL UPDATE_NSV(KMI)
!
!  SET MINIMUN VALUE FOR DIFFERENT SV GROUPS
!
XSVMIN(1:NSV_USER_A(KMI))=0.
IF (CCLOUD == 'C2R2' .OR. CCLOUD == 'C3R5' .OR.  CCLOUD == 'KHKO' ) &
XSVMIN(NSV_C2R2BEG_A(KMI):NSV_C2R2END_A(KMI))=0.
IF (CCLOUD == 'C3R5') &
XSVMIN(NSV_C1R3BEG_A(KMI):NSV_C1R3END_A(KMI))=0.
IF (CCLOUD == 'LIMA') &
XSVMIN(NSV_LIMA_BEG_A(KMI):NSV_LIMA_END_A(KMI))=0.
IF (CELEC /= 'NONE') &
XSVMIN(NSV_ELECBEG_A(KMI):NSV_ELECEND_A(KMI))=0.
IF (LUSECHEM .OR. LCHEMDIAG) &
XSVMIN(NSV_CHEMBEG_A(KMI):NSV_CHEMEND_A(KMI))=0.
IF (LUSECHIC) &
XSVMIN(NSV_CHICBEG_A(KMI):NSV_CHICEND_A(KMI))=0.
IF (.NOT.(LUSECHEM .OR. LCHEMDIAG) .AND. LCH_CONV_LINOX) &
XSVMIN(NSV_LNOXBEG_A(KMI):NSV_LNOXEND_A(KMI))=0.
IF (LORILAM .OR. LCHEMDIAG) &
XSVMIN(NSV_AERBEG_A(KMI):NSV_AEREND_A(KMI))=0.
IF (LDUST) XSVMIN(NSV_DSTBEG_A(KMI):NSV_DSTEND_A(KMI))=XMNH_TINY
IF ((LDUST).AND.(LDEPOS_DST(KMI))) &
XSVMIN(NSV_DSTDEPBEG_A(KMI):NSV_DSTDEPEND_A(KMI))=XMNH_TINY
IF (LSALT) XSVMIN(NSV_SLTBEG_A(KMI):NSV_SLTEND_A(KMI))=XMNH_TINY
IF (LLG) THEN
  XSVMIN(NSV_LGBEG_A(KMI))  =XLG1MIN
  XSVMIN(NSV_LGBEG_A(KMI)+1)=XLG2MIN
  XSVMIN(NSV_LGEND_A(KMI))  =XLG3MIN
ENDIF
IF ((LSALT).AND.(LDEPOS_SLT(KMI))) &
XSVMIN(NSV_SLTDEPBEG_A(KMI):NSV_SLTDEPEND_A(KMI))=XMNH_TINY
IF ((LORILAM).AND.(LDEPOS_AER(KMI))) &
XSVMIN(NSV_AERDEPBEG_A(KMI):NSV_AERDEPEND_A(KMI))=XMNH_TINY
IF (LPASPOL) XSVMIN(NSV_PPBEG_A(KMI):NSV_PPEND_A(KMI))=0.    
#ifdef MNH_FOREFIRE      
IF (LFOREFIRE) XSVMIN(NSV_FFBEG_A(KMI):NSV_FFEND_A(KMI))=0.
#endif
IF (LCONDSAMP) XSVMIN(NSV_CSBEG_A(KMI):NSV_CSEND_A(KMI))=0.   
IF (LBLOWSNOW) XSVMIN(NSV_SNWBEG_A(KMI):NSV_SNWEND_A(KMI))=XMNH_TINY
!
!  NAME OF THE SCALAR VARIABLES IN THE DIFFERENT SV GROUPS
!
IF (ALLOCATED(CSV)) DEALLOCATE(CSV)
ALLOCATE(CSV(NSV))
CSV(:) = '      '
IF (LLG) THEN
  CSV(NSV_LGBEG_A(KMI)  ) = 'X0     '
  CSV(NSV_LGBEG_A(KMI)+1) = 'Y0     '
  CSV(NSV_LGEND_A(KMI)  ) = 'Z0     '
ENDIF

! Initialize scalar variable names for dust
IF ( LDUST ) THEN
  IF ( NMODE_DST < 1 .OR. NMODE_DST > 3 ) CALL Print_msg( NVERB_FATAL, 'GEN', 'INI_NSV', 'NMODE_DST must in the 1 to 3 interval' )

  ! Initialization of dust names
  IF( .NOT. ALLOCATED( CDUSTNAMES ) ) THEN
    IMOMENTS = ( NSV_DSTEND_A(KMI) - NSV_DSTBEG_A(KMI) + 1 ) / NMODE_DST
    ALLOCATE( CDUSTNAMES(IMOMENTS * NMODE_DST) )
    !Loop on all dust modes
    IF ( IMOMENTS == 1 ) THEN
      DO JMODE = 1, NMODE_DST
        IMODEIDX = JPDUSTORDER(JMODE)
        JSV_NAME = ( IMODEIDX - 1 ) * 3 + 2
        CDUSTNAMES(JMODE) = YPDUST_INI(JSV_NAME)
      END DO
    ELSE
      DO JMODE = 1,NMODE_DST
        !Find which mode we are dealing with
        IMODEIDX = JPDUSTORDER(JMODE)
        DO JMOM = 1, IMOMENTS
          !Find which number this is of the list of scalars
          JSV = ( JMODE - 1 ) * IMOMENTS + JMOM
          !Find what name this corresponds to, always 3 moments assumed in YPDUST_INI
          JSV_NAME = ( IMODEIDX - 1) * 3 + JMOM
          !Get the right CDUSTNAMES which should follow the list of scalars transported in XSVM/XSVT
          CDUSTNAMES(JSV) = YPDUST_INI(JSV_NAME)
        ENDDO ! Loop on moments
      ENDDO    ! Loop on dust modes
    END IF
  END IF

  ! Initialization of deposition scheme names
  IF ( LDEPOS_DST(KMI) ) THEN
    IF( .NOT. ALLOCATED( CDEDSTNAMES ) ) THEN
      ALLOCATE( CDEDSTNAMES(NMODE_DST * 2) )
      DO JMODE = 1, NMODE_DST
        IMODEIDX = JPDUSTORDER(JMODE)
        CDEDSTNAMES(JMODE)             = YPDEDST_INI(IMODEIDX)
        CDEDSTNAMES(NMODE_DST + JMODE) = YPDEDST_INI(NMODE_DST + IMODEIDX)
      ENDDO
    END IF
  END IF
END IF

! Initialize scalar variable names for salt
IF ( LSALT ) THEN
  IF ( NMODE_SLT < 1 .OR. NMODE_SLT > 8 ) CALL Print_msg( NVERB_FATAL, 'GEN', 'INI_NSV', 'NMODE_SLT must in the 1 to 8 interval' )

  IF( .NOT. ALLOCATED( CSALTNAMES ) ) THEN
    IMOMENTS = ( NSV_SLTEND_A(KMI) - NSV_SLTBEG_A(KMI) + 1 ) / NMODE_SLT
    ALLOCATE( CSALTNAMES(IMOMENTS * NMODE_SLT) )
    !Loop on all dust modes
    IF ( IMOMENTS == 1 ) THEN
      DO JMODE = 1, NMODE_SLT
        IMODEIDX = JPSALTORDER(JMODE)
        JSV_NAME = ( IMODEIDX - 1 ) * 3 + 2
        CSALTNAMES(JMODE) = YPSALT_INI(JSV_NAME)
      END DO
    ELSE
      DO JMODE = 1, NMODE_SLT
        !Find which mode we are dealing with
        IMODEIDX = JPSALTORDER(JMODE)
        DO JMOM = 1, IMOMENTS
          !Find which number this is of the list of scalars
          JSV = ( JMODE - 1 ) * IMOMENTS + JMOM
          !Find what name this corresponds to, always 3 moments assumed in YPSALT_INI
          JSV_NAME = ( IMODEIDX - 1 ) * 3 + JMOM
          !Get the right CSALTNAMES which should follow the list of scalars transported in XSVM/XSVT
          CSALTNAMES(JSV) = YPSALT_INI(JSV_NAME)
        ENDDO ! Loop on moments
      ENDDO    ! Loop on dust modes
    END IF
  END IF
  ! Initialization of deposition scheme
  IF ( LDEPOS_SLT(KMI) ) THEN
    IF( .NOT. ALLOCATED( CDESLTNAMES ) ) THEN
      ALLOCATE( CDESLTNAMES(NMODE_SLT * 2) )
      DO JMODE = 1, NMODE_SLT
        IMODEIDX = JPSALTORDER(JMODE)
        CDESLTNAMES(JMODE)             = YPDESLT_INI(IMODEIDX)
        CDESLTNAMES(NMODE_SLT + JMODE) = YPDESLT_INI(NMODE_SLT + IMODEIDX)
      ENDDO
    ENDIF
  ENDIF
END IF

! Initialize scalar variable names for snow
IF ( LBLOWSNOW ) THEN
  IF( .NOT. ALLOCATED( CSNOWNAMES ) ) THEN
    IMOMENTS = ( NSV_SNWEND_A(KMI) - NSV_SNWBEG_A(KMI) + 1 )
    ALLOCATE( CSNOWNAMES(IMOMENTS) )
    DO JMOM = 1, IMOMENTS
      CSNOWNAMES(JMOM) = YPSNOW_INI(JMOM)
    ENDDO ! Loop on moments
  END IF
END IF

!Fill CSVNAMES_A for model KMI
DO JSV = 1, NSV_USER_A(KMI)
  WRITE( YNUM3, '( I3.3 )' ) JSV
  CSVNAMES_A(JSV,KMI) = 'SVUSER'//YNUM3
END DO

DO JSV = NSV_C2R2BEG_A(KMI), NSV_C2R2END_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( C2R2NAMES(JSV-NSV_C2R2BEG_A(KMI)+1) )
END DO

DO JSV = NSV_C1R3BEG_A(KMI), NSV_C1R3END_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( C1R3NAMES(JSV-NSV_C1R3BEG_A(KMI)+1) )
END DO

DO JSV = NSV_LIMA_BEG_A(KMI), NSV_LIMA_END_A(KMI)
  IF ( JSV == NSV_LIMA_NC_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_WARM_NAMES(1) )
  ELSE IF ( JSV == NSV_LIMA_NR_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_WARM_NAMES(2) )
  ELSE IF ( JSV >= NSV_LIMA_CCN_FREE_A(KMI) .AND. JSV < NSV_LIMA_CCN_ACTI_A(KMI) ) THEN
    WRITE( YNUM2, '( I2.2 )' ) JSV - NSV_LIMA_CCN_FREE_A(KMI) + 1
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_WARM_NAMES(3) ) // YNUM2
  ELSE IF (JSV >= NSV_LIMA_CCN_ACTI_A(KMI) .AND. JSV < ( NSV_LIMA_CCN_ACTI_A(KMI) + NMOD_CCN ) ) THEN
    WRITE( YNUM2, '( I2.2 )' ) JSV - NSV_LIMA_CCN_ACTI_A(KMI) + 1
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_WARM_NAMES(4) ) // YNUM2
  ELSE IF ( JSV == NSV_LIMA_SCAVMASS_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CAERO_MASS(1) )
  ELSE IF ( JSV == NSV_LIMA_NI_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(1) )
  ELSE IF ( JSV == NSV_LIMA_NS_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(2) )
  ELSE IF ( JSV == NSV_LIMA_NG_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(3) )
  ELSE IF ( JSV == NSV_LIMA_NH_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(4) )
  ELSE IF ( JSV >= NSV_LIMA_IFN_FREE_A(KMI) .AND. JSV < NSV_LIMA_IFN_NUCL_A(KMI) ) THEN
    WRITE( YNUM2, '( I2.2 )' ) JSV - NSV_LIMA_IFN_FREE_A(KMI) + 1
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(5) ) // YNUM2
  ELSE IF ( JSV >= NSV_LIMA_IFN_NUCL_A(KMI) .AND. JSV < ( NSV_LIMA_IFN_NUCL_A(KMI) + NMOD_IFN ) ) THEN
    WRITE( YNUM2, '( I2.2 )' ) JSV - NSV_LIMA_IFN_NUCL_A(KMI) + 1
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(6) ) // YNUM2
  ELSE IF ( JSV >= NSV_LIMA_IMM_NUCL_A(KMI) .AND. JSV < ( NSV_LIMA_IMM_NUCL_A(KMI) + NMOD_IMM ) ) THEN
    WRITE( YNUM2, '( I2.2 )' ) NINDICE_CCN_IMM(JSV-NSV_LIMA_IMM_NUCL_A(KMI)+1)
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(7) ) // YNUM2
  ELSE IF ( JSV == NSV_LIMA_HOM_HAZE_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_COLD_NAMES(8) )
  ELSE IF ( JSV == NSV_LIMA_SPRO_A(KMI) ) THEN
    CSVNAMES_A(JSV,KMI) = TRIM( CLIMA_WARM_NAMES(5) )
  ELSE
    CALL Print_msg( NVERB_FATAL, 'GEN', 'INI_NSV', 'invalid index for LIMA' )
  END IF
END DO

DO JSV = NSV_ELECBEG_A(KMI), NSV_ELECEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CELECNAMES(JSV-NSV_ELECBEG_A(KMI)+1) )
END DO

DO JSV = NSV_LGBEG_A(KMI), NSV_LGEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CLGNAMES(JSV-NSV_LGBEG_A(KMI)+1) )
END DO

DO JSV = NSV_PPBEG_A(KMI), NSV_PPEND_A(KMI)
  WRITE( YNUM3, '( I3.3 )' ) JSV-NSV_PPBEG_A(KMI)+1
  CSVNAMES_A(JSV,KMI) = 'SVPP'//YNUM3
END DO

#ifdef MNH_FOREFIRE
DO JSV = NSV_FFBEG_A(KMI), NSV_FFEND_A(KMI)
  WRITE( YNUM3, '( I3.3 )' ) JSV-NSV_FFBEG_A(KMI)+1
  CSVNAMES_A(JSV,KMI) = 'SVFF'//YNUM3
END DO
#endif

DO JSV = NSV_CSBEG_A(KMI), NSV_CSEND_A(KMI)
  WRITE( YNUM3, '( I3.3 )' ) JSV-NSV_CSBEG_A(KMI)
  CSVNAMES_A(JSV,KMI) = 'SVCS'//YNUM3
END DO

DO JSV = NSV_CHEMBEG_A(KMI), NSV_CHEMEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CNAMES(JSV-NSV_CHEMBEG_A(KMI)+1) )
END DO

DO JSV = NSV_CHICBEG_A(KMI), NSV_CHICEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CICNAMES(JSV-NSV_CHICBEG_A(KMI)+1) )
END DO

DO JSV = NSV_AERBEG_A(KMI), NSV_AEREND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CAERONAMES(JSV-NSV_AERBEG_A(KMI)+1) )
END DO

DO JSV = NSV_AERDEPBEG_A(KMI), NSV_AERDEPEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CDEAERNAMES(JSV-NSV_AERDEPBEG_A(KMI)+1) )
END DO

DO JSV = NSV_DSTBEG_A(KMI), NSV_DSTEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CDUSTNAMES(JSV-NSV_DSTBEG_A(KMI)+1) )
END DO

DO JSV = NSV_DSTDEPBEG_A(KMI), NSV_DSTDEPEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CDEDSTNAMES(JSV-NSV_DSTDEPBEG_A(KMI)+1) )
END DO

DO JSV = NSV_SLTBEG_A(KMI), NSV_SLTEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CSALTNAMES(JSV-NSV_SLTBEG_A(KMI)+1) )
END DO

DO JSV = NSV_SLTDEPBEG_A(KMI), NSV_SLTDEPEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CDESLTNAMES(JSV-NSV_SLTDEPBEG_A(KMI)+1) )
END DO

DO JSV = NSV_SNWBEG_A(KMI), NSV_SNWEND_A(KMI)
  CSVNAMES_A(JSV,KMI) = TRIM( CSNOWNAMES(JSV-NSV_SNWBEG_A(KMI)+1) )
END DO

DO JSV = NSV_LNOXBEG_A(KMI), NSV_LNOXEND_A(KMI)
  WRITE( YNUM3, '( I3.3 )' ) JSV-NSV_LNOXBEG_A(KMI)+1
  CSVNAMES_A(JSV,KMI) = 'SVLNOX'//YNUM3
END DO

END SUBROUTINE INI_NSV

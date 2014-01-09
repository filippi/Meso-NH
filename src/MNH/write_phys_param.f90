!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
#ifdef MNH_NCWRIT
!     ############################
      MODULE MODI_WRITE_PHYS_PARAM
!     ############################
!
INTERFACE
!
SUBROUTINE WRITE_PHYS_PARAM(HFMFILE,HDADFILE)
CHARACTER(LEN=28), INTENT(IN) :: HFMFILE      ! Name of FM-file to write
CHARACTER(LEN=28), INTENT(IN) :: HDADFILE     ! corresponding FM-file name of 
                                              ! its DAD model
END SUBROUTINE WRITE_PHYS_PARAM
!
END INTERFACE
!
END MODULE MODI_WRITE_PHYS_PARAM
!
!
!     #############################################
      SUBROUTINE WRITE_PHYS_PARAM(HFMFILE,HDADFILE)
!     #############################################
!
!!****  *WRITE_PHYS_PARAM* - routine to define the netcdf variables written in phys_param for model $n
!!
!!    PURPOSE
!!    -------
!        The purpose of this routine is to define the variables in case of
!        netcdf output  
!
!!**  METHOD
!!    ------
!!      The data are defined in the NC file :
!!        - dimensions
!!        - grid variables
!!        - configuration variables
!!        - prognostic variables at time t and t-dt
!!        - 1D anelastic reference state
!!
!!      The localization on the model grid is also indicated :
!!
!!        IGRID = 1 for mass grid point
!!        IGRID = 2 for U grid point
!!        IGRID = 3 for V grid point
!!        IGRID = 4 for w grid point
!!        IGRID = 0 for meaningless case
!!          
!!
!!    EXTERNAL
!!    --------
!!      FMWRIT     : FM-routine to write a record
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_DIM_n   : contains dimensions
!!      Module MODD_TIME    : contains time variables for all models
!!      Module MODD_TIME_n   : contains time variables 
!!      Module MODD_GRID    : contains spatial grid variables for all models
!!      Module MODD_GRID_n : contains spatial grid variables
!!      Module MODD_REF     : contains reference state variables
!!      Module MODD_LUNIT_n: contains logical unit variables.
!!      Module MODD_CONF    : contains configuration variables for all models
!!      Module MODD_CONF_n  : contains configuration variables
!!      Module MODD_FIELD_n  : contains prognostic variables
!!      Module MODD_GR_FIELD_n : contains surface prognostic variables
!!      Module MODD_LSFIELD_n  : contains Larger Scale variables
!!      Module MODD_PARAM_n    : contains parameterization options
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!  	S. Bielli   *Laboratoire d'Aerologie* 
!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_DIM_n
USE MODD_CONF
USE MODD_CONF_n
USE MODD_GRID
USE MODD_GRID_n
USE MODD_TIME
USE MODD_TIME_n
USE MODD_FIELD_n
USE MODD_MEAN_FIELD_n
USE MODD_DUMMY_GR_FIELD_n
USE MODD_LSFIELD_n
USE MODD_DYN_n
USE MODD_PARAM_n
USE MODD_REF
USE MODD_LUNIT_n
USE MODD_NSV
USE MODD_TURB_n
USE MODD_TURB_CLOUD
USE MODD_RADIATIONS_n
USE MODD_REF_n,  ONLY : XRHODREF
USE MODD_FRC
USE MODD_PRECIP_n
USE MODD_ELEC_n
USE MODD_CST
USE MODD_CLOUDPAR
USE MODD_DEEP_CONVECTION_n
USE MODD_PARAM_KAFR_n
USE MODD_NESTING
USE MODD_PARAMETERS
USE MODD_PARAM_MFSHALL_n
USE MODD_PARAM_RAD_n
USE MODD_SUB_MODEL_n
USE MODD_GR_FIELD_n
USE MODD_CH_MNHC_n,       ONLY: LUSECHEM,LCH_CONV_LINOX, &
                                LUSECHAQ,LUSECHIC,LCH_PH
USE MODD_CH_PH_n
USE MODD_CH_M9_n
USE MODD_PARAM_C2R2
USE MODD_RAIN_C2R2_DESCR, ONLY: C2R2NAMES
USE MODD_ICE_C1R3_DESCR,  ONLY: C1R3NAMES
USE MODD_ELEC_DESCR,      ONLY: CELECNAMES
USE MODD_LG,              ONLY: CLGNAMES
USE MODD_NSV
USE MODD_AIRCRAFT_BALLOON
USE MODD_HURR_CONF, ONLY: LFILTERING,CFILTERING,NDIAG_FILT
USE MODD_HURR_FIELD_n
USE MODD_PREP_REAL, ONLY: CDUMMY_2D, XDUMMY_2D
USE MODD_DUST
USE MODD_SALT
USE MODD_PASPOL
USE MODD_CONDSAMP
USE MODD_CH_AEROSOL
!
USE MODE_FMWRIT
USE MODE_ll
USE MODE_IO_ll, ONLY: UPCASE,CLOSE_ll
USE MODE_GRIDPROJ
USE MODE_MODELN_HANDLER
!
USE MODI_GATHER_ll
USE MODI_WRITE_LB_n
USE MODI_WRITE_BALLOON_n
USE MODI_DUSTLFI_n
USE MODI_SALTLFI_n
USE MODI_CH_AER_REALLFI_n
!SB
USE MODN_NCOUT
use mode_util
!SB
!
! 
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!
CHARACTER(LEN=28), INTENT(IN) :: HFMFILE      ! Name of FM-file to write
CHARACTER(LEN=28), INTENT(IN) :: HDADFILE     ! corresponding FM-file name of 
                                              ! its DAD model
!
!*       0.2   Declarations of local variables
!
INTEGER           :: ILUOUT         ! logical unit
INTEGER           :: IRESP          ! IRESP  : return-code if a problem appears 
                                    !in LFI subroutines at the open of the file              
INTEGER           :: IGRID          ! IGRID : grid indicator
INTEGER           :: ILENCH         ! ILENCH : length of comment string 
!
CHARACTER(LEN=16) :: YRECFM         ! Name of the article to be written
CHARACTER(LEN=100):: YCOMMENT       ! Comment string
CHARACTER (LEN=2) :: YDIR           ! Type of the data field
!
INTEGER           :: IRR            ! Index for moist variables
INTEGER           :: JSV            ! loop index for scalar variables
INTEGER           :: JSA            ! beginning of chemical-aerosol variables

! 
CHARACTER(LEN=3)  :: YFRC           ! to mark the time of the forcing
INTEGER           :: JT             ! loop index
!
CHARACTER (LEN=4), DIMENSION(NSWB) :: YBAND_NAME  ! Solar band name
INTEGER                         :: JBAND       ! Solar band index       
INTEGER :: INIR          ! index corresponding to NIR fisrt band (in SW)
!
INTEGER           :: JMOM, IMOMENTS, JMODE, ISV_NAME_IDX  ! dust modes
!
INTEGER :: IIU, IJU, IKU                                                    
! 
REAL,DIMENSION(:,:), ALLOCATABLE  :: ZSTORE_2D     ! Working array
REAL,DIMENSION(:,:,:), ALLOCATABLE  :: ZSTORE_3D     ! Working array
REAL,DIMENSION(:,:,:), ALLOCATABLE  :: ZSTORE_3DWL     ! Working array
!
REAL                              :: ZLATOR, ZLONOR ! geographical coordinates of 1st mass point
REAL                              :: ZXHATM, ZYHATM ! conformal    coordinates of 1st mass point
REAL, DIMENSION(:), ALLOCATABLE   :: ZXHAT_ll    !  Position x in the conformal
                                                 ! plane (array on the complete domain)
REAL, DIMENSION(:), ALLOCATABLE   :: ZYHAT_ll    !   Position y in the conformal
                                                 ! plane (array on the complete domain)
INTEGER :: IMI ! Current model index
INTEGER :: KSPLT ! 
!
INTEGER           :: ICH_NBR        ! to write number and names of scalar 
INTEGER,DIMENSION(:),ALLOCATABLE :: ICH_NAMES !(chem+aero+dust) variables
CHARACTER(LEN=16),DIMENSION(:),ALLOCATABLE :: YDSTNAMES,YCHNAMES, YSLTNAMES
INTEGER           :: ILREC,ILENG    !in NSV.DIM and NSV.TITRE
INTEGER           :: INFO_ll
!-------------------------------------------------------------------------------
!
!*	0. Initialization


!
IMI = GET_CURRENT_MODEL_INDEX()
IIU=NIMAX+2*JPHEXT
IJU=NJMAX+2*JPHEXT
IKU=NKMAX+2*JPVEXT
KSPLT = 1 
!
CALL FMLOOK_ll(CLUOUT,CLUOUT,ILUOUT,IRESP)
!
ALLOCATE(ZSTORE_2D(IIU,IJU))
ALLOCATE(ZSTORE_3D(IIU,IJU,IKU))
!! Array for radiations fields on 6 sprectral bands
ALLOCATE(ZSTORE_3DWL(IIU,IJU,NSWB_MNH))

ZSTORE_2D(:,:)=0
ZSTORE_3D(:,:,:)=0
ZSTORE_3DWL(:,:,:)=0

!

!*       1.     WRITES IN THE PHYS_PARAM SUBROUTINE (FOR NETCDF ONLY)
! 
!!!!! RADIATIONS.F90 !!!!
!!! ADD A TEST AS A FUNCTION OF NAMELIST VARIABLE
IF( CRAD == 'ECMW' ) THEN
!!!
  IF( NRAD_DIAG >= 1 ) THEN
    IF( NRAD_DIAG >= 1) THEN
        !!!!! 3D variables
      YDIR='XY'
      YRECFM   = 'SWF_DOWN'
      YCOMMENT = 'X_Y_Z_SWF_DOWN (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'SWF_UP'
      YCOMMENT = 'X_Y_Z_SWF_UP (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_DOWN'
      YCOMMENT = 'X_Y_Z_LWF_DOWN (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_UP'
      YCOMMENT = 'X_Y_Z_LWF_UP (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_NET'
      YCOMMENT = 'X_Y_Z_LWF_NET (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'SWF_NET'
      YCOMMENT = 'X_Y_Z_SWF_NET (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'DTRAD_LW'
      YCOMMENT = 'X_Y_Z_DTRAD_LW (K/DAY)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'DTRAD_SW'
      YCOMMENT = 'X_Y_Z_DTRAD_SW (K/DAY)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
        !!!!! 2D variables
      YRECFM   = 'RADSWD_VIS'
      YCOMMENT = 'X_Y_RADSWD_VIS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RADSWD_NIR'
      YCOMMENT = 'X_Y_RADSWD_NIR'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RADLWD'
      YCOMMENT = 'X_Y_RADLWD'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ENDIF
    IF( NRAD_DIAG >= 2) THEN
      YDIR='XY'
      YRECFM   = 'SWF_DOWN_CS'
      YCOMMENT = 'X_Y_Z_SWF_DOWN_CS (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'SWF_UP_CS'
      YCOMMENT = 'X_Y_Z_SWF_UP_CS (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_DOWN_CS'
      YCOMMENT = 'X_Y_Z_LWF_DOWN (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_UP_CS'
      YCOMMENT = 'X_Y_Z_LWF_UP_CS (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'LWF_NET_CS'
      YCOMMENT = 'X_Y_Z_SWF_NET_CS (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'SWF_NET_CS'
      YCOMMENT = 'X_Y_Z_SWF_NET_CS (W/M2)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'DTRAD_SW_CS'
      YCOMMENT = 'X_Y_Z_DTRAD_SW_CS (K/DAY)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'DTRAD_LW_CS'
      YCOMMENT = 'X_Y_Z_DTRAD_LW_CS (K/DAY)'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RADSWD_VIS_CS'
      YCOMMENT = 'X_Y_RADSWD_VIS_CS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RADSWD_NIR_CS'
      YCOMMENT = 'X_Y_RADSWD_NIR_CS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RADLWD_CS'
      YCOMMENT = 'X_Y_RADLWD_CS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ENDIF
!!
    IF( NRAD_DIAG >= 3) THEN
!!
      YRECFM   = 'PLAN_ALB_VIS'
      YCOMMENT = 'X_Y_PLAN_ALB_VIS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'PLAN_ALB_NIR'
      YCOMMENT = 'X_Y_PLAN_ALB_NIR'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'PLAN_TRA_VIS'
      YCOMMENT = 'X_Y_PLAN_TRA_VIS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'PLAN_TRA_NIR'
      YCOMMENT = 'X_Y_PLAN_TRA_NIR'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'PLAN_ABS_VIS'
      YCOMMENT = 'X_Y_PLAN_ABS_VIS'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'PLAN_ABS_NIR'
      YCOMMENT = 'X_Y_PLAN_ABS_NIR'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_2D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ENDIF
!!
    IF( NRAD_DIAG >= 4) THEN
!!
      YRECFM   = 'EFNEB_DOWN'
      YCOMMENT = 'X_Y_Z_EFNEB_DOWN'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'EFNEB_UP'
      YCOMMENT = 'X_Y_Z_EFNEB_UP'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'FLWP'
      YCOMMENT = 'X_Y_Z_FLWP'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'FIWP'
      YCOMMENT = 'X_Y_Z_FIWP'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'EFRADL'
      YCOMMENT = 'X_Y_Z_RAD_microm'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'EFRADI'
      YCOMMENT = 'X_Y_Z_RAD_microm'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'SW_NEB'
      YCOMMENT = 'X_Y_Z_SW_NEB'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'RRTM_LW_NEB'
      YCOMMENT = 'X_Y_Z_LW_NEB'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
!!! 3D  X,Y,Z for each ban ( 6 )
!!! DO LOOP ????
       ! spectral bands
      IF (NSWB==6) THEN
         INIR = 4
      ELSE
        INIR = 2
      END IF

      DO JBAND=1,INIR-1
        WRITE(YBAND_NAME(JBAND),'(A3,I1)') 'VIS', JBAND
      END DO
      DO JBAND= INIR,NSWB
        WRITE(YBAND_NAME(JBAND),'(A3,I1)') 'NIR', JBAND
      END DO
!!
      DO JBAND = 1,NSWB
        YRECFM   = 'ODAER_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_OD_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
        YRECFM   = 'SSAAER_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_SSA_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
        YRECFM   = 'GAER_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_G_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
!! 3D ??
        YRECFM   = 'OTH_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_OTH_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
        YRECFM   = 'SSA_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_SSA_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
        YRECFM   = 'ASF_'//YBAND_NAME(JBAND)
        YCOMMENT = 'X_Y_Z_ASF_'//YBAND_NAME(JBAND)
        IGRID    = 1
        ILENCH   = LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
!!! END DO LOOP  ON JBAND ?
      END DO
    ENDIF
!!
    IF (NRAD_DIAG >= 5)   THEN
!!
      YDIR='XY'
      YRECFM   = 'O3CLIM'
      YCOMMENT = 'X_Y_Z_O3 Pa/Pa'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_LAND'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_SEA'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_DES'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_URB'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_VOL'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      YRECFM   = 'CUM_AER_STRB'
      YCOMMENT = 'X_Y_Z_CUM_AER_OPT'
      IGRID    = 1
      ILENCH   = LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
    ENDIF
  ENDIF
ENDIF

!!!!!!!!! paspol
DO JSV=1,NSV_PP
  IGRID =  1
  YDIR  = 'XY'
  WRITE(YRECFM,'(A3,I3.3)')'ATC',JSV+NSV_PPBEG-1
  WRITE(YCOMMENT,'(A6,A3,I3.3,A8)')'X_Y_Z_','ATC',JSV+NSV_PPBEG-1,' (1/M3) '
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,YDIR,ZSTORE_3D,IGRID,ILENCH,    &
              YCOMMENT,IRESP)
END DO
!!
!!!!!!!!! turb
IF (NRRL >=1) THEN
  IF (LTURB_DIAG) THEN
    YRECFM  ='ATHETA'
    YCOMMENT='X_Y_Z_ATHETA (M)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!
    YRECFM  ='AMOIST'
    YCOMMENT='X_Y_Z_AMOIST (M)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
  END IF
END IF
!! 
!! cloud_modif_lm
IF (NMODEL_CLOUD==IMI .AND. CTURBLEN_CLOUD/='NONE') THEN
  YRECFM  ='LM_CLEAR_SKY'
  YCOMMENT='X_Y_Z_LM CLEAR SKY (M)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='COEF_AMPL'
  YCOMMENT='X_Y_Z_COEF AMPL (-)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='LM_CLOUD'
  YCOMMENT='X_Y_Z_LM CLOUD (M)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!! turb_ver
!!!! prandtl
IF ( LTURB_FLX ) THEN
  ! stores the RED_TH1
  YRECFM  ='RED_TH1'
  YCOMMENT='X_Y_Z_RED_TH1 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the RED_R1
  YRECFM  ='RED_R1'
  YCOMMENT='X_Y_Z_RED_R1 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the RED2_TH3
  YRECFM  ='RED2_TH3'
  YCOMMENT='X_Y_Z_RED2_TH3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the RED2_R3
  YRECFM  ='RED2_R3'
  YCOMMENT='X_Y_Z_RED2_R3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the RED2_THR3
  YRECFM  ='RED2_THR3'
  YCOMMENT='X_Y_Z_RED2_THR3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
END IF

!!!! turb_ver_thermo_flux 
IF ( LTURB_FLX ) THEN
  ! stores the conservative potential temperature vertical flux
  YRECFM  ='THW_FLX'
  YCOMMENT='X_Y_Z_THW_FLX (K*M/S)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the conservative mixing ratio vertical flux
  YRECFM  ='RCONSW_FLX'
  YCOMMENT='X_Y_Z_RCONSW_FLX (KG*M/S/KG)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! store the liquid water mixing ratio vertical flux
  YRECFM  ='RCW_FLX'
  YCOMMENT='X_Y_Z_RCW_FLX (KG*M/S/KG)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
!!!! turb_ver_thermo_corr
  ! stores <THl THl>
  YRECFM  ='THL_VVAR'
  YCOMMENT='X_Y_Z_THL_VVAR (KELVIN**2)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores <THl Rnp>
  IF ( NRR /= 0 ) THEN
    YRECFM  ='THLRCONS_VCOR'
    YCOMMENT='X_Y_Z_THLRCONS_VCOR (KELVIN*KG/KG)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores <Rnp Rnp>
    YRECFM  ='RTOT_VVAR'
    YCOMMENT='X_Y_Z_RTOT_VVAR (KG/KG **2)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
  END IF
!!
!!!! turb_ver_dyn_flux
  ! stores the U wind component vertical flux
  YRECFM  ='UW_VFLX'
  YCOMMENT='X_Y_Z_UW_VFLX (M**2/S**2)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the V wind component vertical flux
  YRECFM  ='VW_VFLX'
  YCOMMENT='X_Y_Z_VW_VFLX (M**2/S**2)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
!!
  IF ( CTURBDIM == '1DIM') THEN
    ! stores the W variance
    YRECFM  ='W_VVAR'
    YCOMMENT='X_Y_Z_W_VVAR (M**2/S**2)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
  END IF
END IF
!!!! turb_ver_sv_flux
IF (SIZE(XSVT,4)>0)  THEN
  DO JSV=1, SIZE(XSVT,4)
    IF (LTURB_FLX ) THEN
      ! stores the JSVth vertical flux
      WRITE(YRECFM,'("WSV_FLX_",I3.3)') JSV
      YCOMMENT='X_Y_Z_'//YRECFM//' (SVUNIT*M/S)'
      IGRID   = 4
      ILENCH=LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
    END IF
  END DO
END IF
!! back to turb_ver
IF ( LTURB_FLX ) THEN
  ! stores the Turbulent Prandtl number
  YRECFM  ='PHI3'
  YCOMMENT='X_Y_Z_PHI3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!
  ! stores the Turbulent Schmidt number
  YRECFM  ='PSI3'
  YCOMMENT='X_Y_Z_PSI3 (0)'
  IGRID   = 4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!
! stores the Turbulent Schmidt number for the scalar variables
!
  DO JSV=1,NSV
    WRITE(YRECFM, '("PSI_SV_",I3.3)') JSV
    YCOMMENT='X_Y_Z_'//YRECFM//' (0)'
    IGRID   = 4
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,   &
                    IGRID,ILENCH,YCOMMENT,IRESP)
  END DO
END IF
IF (CTURBDIM=='3DIM') THEN
!! turb_hor_splt
!!!! turb_hor case split and no split  == idem A VERIFIER
  !! turb_hor
   !!!!!! turb_hor_thermo_flux
  IF ( LTURB_FLX ) THEN
    ! stores the horizontal  <U THl>
    YRECFM  ='UTHL_FLX'
    YCOMMENT='X_Y_Z_UTHL_FLX (KELVIN*M/S)  '
    IGRID   = 2
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores the horizontal  <U Rnp>
    YRECFM  ='UR_FLX'
    YCOMMENT='X_Y_Z_UR_FLX (KG/KG * M/S)  '
    IGRID   = 2
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores the horizontal  <V THl>
    YRECFM  ='VTHL_FLX'
    YCOMMENT='X_Y_Z_VTHL_FLX (KELVIN*M/S)  '
    IGRID   = 3
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    IF (NRR/=0) THEN
      ! stores the horizontal  <V Rnp>
      YRECFM  ='VR_FLX'
      YCOMMENT='X_Y_Z_VR_FLX (KG/KG * M/S)  '
      IGRID   = 3
      ILENCH=LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
    END IF
!!
  END IF
!!
  IF (KSPLT==1) THEN
!!!!!! turb_hor_thermo_corr
    IF ( LTURB_FLX ) THEN
      ! stores <THl THl>
      YRECFM  ='THL_HVAR'
      YCOMMENT='X_Y_Z_THL_HVAR (KELVIN**2)'
      IGRID   = 1
      ILENCH=LEN(YCOMMENT)
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
      IF ( NRR /= 0 ) THEN
        YRECFM  ='THLR_HCOR'
        YCOMMENT='X_Y_Z_THLR_HCOR (KELVIN*KG/KG)'
        IGRID   = 1
        ILENCH=LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
!!
        YRECFM  ='R_HVAR'
        YCOMMENT='X_Y_Z_R_HVAR (KG/KG **2)'
        IGRID   = 1
        ILENCH=LEN(YCOMMENT)
        CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
            IGRID,ILENCH,YCOMMENT,IRESP)
      END IF
    END IF
!!!!!! turb_hor_dyn_corr
    ! stores <U U>
    YRECFM  ='U_VAR'
    YCOMMENT='X_Y_Z_U_VAR ( (M/S)**2)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores <V V>
    YRECFM  ='V_VAR'
    YCOMMENT='X_Y_Z_V_VAR ( (M/S)**2)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores <W W>
    YRECFM  ='W_VAR'
    YCOMMENT='X_Y_Z_W_VAR ( (M/S)**2)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!!!!! turb_hor_uv
  ! stores  <U V>
    YRECFM  ='UV_FLX'
    YCOMMENT='X_Y_Z_UV_FLX ( (M/S) **2 )  '
    IGRID   = 5
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
  END IF
END IF
!!
IF ( LTURB_DIAG ) THEN
! stores the mixing length
!
  YRECFM  ='LM'
  YCOMMENT='X_Y_Z_LM (M)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  IF (NRR /= 0) THEN
!
! stores the conservative potential temperature
!
    YRECFM  ='THLM'
    YCOMMENT='X_Y_Z_THLM (KELVIN)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the conservative mixing ratio
  !
    YRECFM  ='RNPM'
    YCOMMENT='X_Y_Z_RNPM (KG/KG)'
    IGRID   = 1
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,       &
                           YCOMMENT,IRESP)
  END IF
!!
!!
END IF
!!!!!! turb_hor_uw
IF ( LTURB_FLX ) THEN
  ! stores  <U W>
  YRECFM  ='UW_HFLX'
  YCOMMENT='X_Y_Z_UW_HFLX ( (M/S) **2 )  '
  IGRID   = 6
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!!!!!! turb_hor_vw
IF ( LTURB_FLX ) THEN
  ! stores  <V W>
  YRECFM  ='VW_HFLX'
  YCOMMENT='X_Y_Z_VW_HFLX ( (M/S) **2 )  '
  IGRID   = 7
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!!!!!! turb_hor_sv_flux
IF ( LTURB_FLX ) THEN
  DO JSV=1,NSV_USER
   ! stores  <U SVth>
   WRITE(YRECFM,'("USV_FLX_",I3.3)') JSV
   YCOMMENT='X_Y_Z_'//YRECFM//' (SVUNIT*M/S)'
   IGRID   = 2
   ILENCH=LEN(YCOMMENT)
   CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
   IF (.NOT. L2D) THEN
    ! stores  <V SVth>
    WRITE(YRECFM,'("VSV_FLX_",I3.3)') JSV
    YCOMMENT='X_Y_Z_'//YRECFM//' (SVUNIT*M/S)'
    IGRID   = 3
    ILENCH=LEN(YCOMMENT)
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
   END IF
 END DO
END IF
!!
IF ( LTURB_DIAG ) THEN
 ! stores the mixing length
 YRECFM  ='LM'
 YCOMMENT='X_Y_Z_LM (M)'
 IGRID   = 1
 ILENCH=LEN(YCOMMENT)
 CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
 IF (NRR /= 0) THEN
   ! stores the conservative potential temperature
   YRECFM  ='THLM'
   YCOMMENT='X_Y_Z_THLM (KELVIN)'
   IGRID   = 1
   ILENCH=LEN(YCOMMENT)
   CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
   ! stores the conservative mixing ratio
   YRECFM  ='RNPM'
   YCOMMENT='X_Y_Z_RNPM (KG/KG)'
   IGRID   = 1
   ILENCH=LEN(YCOMMENT)
   CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,       &
                                 YCOMMENT,IRESP)
 END IF
END IF
!!
IF ( LTURB_DIAG ) THEN
  YRECFM  ='LM_CLEAR_SKY'
  YCOMMENT='X_Y_Z_LM CLEAR SKY (M)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='COEF_AMPL'
  YCOMMENT='X_Y_Z_COEF AMPL (-)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='LM_CLOUD'
  YCOMMENT='X_Y_Z_LM CLOUD (M)'
  IGRID   = 1
  ILENCH  = LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
END IF
!!!! tke_eps_sources
IF ( LTURB_DIAG ) THEN
  ! stores the dynamic production
  YRECFM  ='DP'
  YCOMMENT='X_Y_Z_DP (M**2/S**3)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the thermal production
  YRECFM  ='TP'
  YCOMMENT='X_Y_Z_TP (M**2/S**3)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the whole turbulent transport
  YRECFM  ='TR'
  YCOMMENT='X_Y_Z_TR (M**2/S**3)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
!!
  ! stores the dissipation of TKE
  YRECFM  ='DISS'
  YCOMMENT='X_Y_Z_DISS (M**2/S**3)'
  IGRID   = 1
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D,IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!!
!!!!!!!!! Shallow_mf_pack
IF (CSCONV == 'EDKF') THEN
  IF ( LMF_FLX ) THEN
    ! stores the conservative potential temperature vertical flux
    YRECFM  ='MF_THW_FLX'
    YCOMMENT='X_Y_Z_MF_THW_FLX (K*M/S)'
    ILENCH  = LEN(YCOMMENT)
    IGRID   = 4
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
   ! stores the conservative mixing ratio vertical flux
    YRECFM  ='MF_RCONSW_FLX'
    YCOMMENT='X_Y_Z_MF_RCONSW_FLX (K*M/S)'
    ILENCH  = LEN(YCOMMENT)
    IGRID   = 4
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    ! stores the theta_v vertical flux
    YRECFM  ='MF_THVW_FLX'
    YCOMMENT='X_Y_Z_MF_THVW_FLX (K*M/S)'
    ILENCH  = LEN(YCOMMENT)
    IGRID   = 4
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
!!
    IF (LMIXUV) THEN
      ! stores the U momentum vertical flux
      YRECFM  ='MF_UW_FLX'
      YCOMMENT='X_Y_Z_MF_UW_FLX (M2/S2)'
      ILENCH  = LEN(YCOMMENT)
      IGRID   = 4
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
!!
      ! stores the V momentum vertical flux
      YRECFM  ='MF_VW_FLX'
      YCOMMENT='X_Y_Z_MF_VW_FLX (M2/S2)'
      ILENCH  = LEN(YCOMMENT)
      IGRID   = 4
      CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
          IGRID,ILENCH,YCOMMENT,IRESP)
    END IF
  END IF
END IF
!!
! RESOLVED CLOUD CASE C2R2
!!! rain_c2r2
IF (CCLOUD == 'C2R2' ) THEN
  YRECFM  ='RAY'
  YCOMMENT='X_Y_Z_DIAM'
  ILENCH=LEN(YCOMMENT)
  IGRID   = 1
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
     IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='TERM_VEL'
  YCOMMENT='X_Y_Z_TERM_VEL'
  ILENCH=LEN(YCOMMENT)
  IGRID   = 1
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  IF ( LSEDC ) THEN
    YRECFM  ='SEDSPEEDC'
    YCOMMENT='X_Y_Z_SEDSPEEDC'
    ILENCH=LEN(YCOMMENT)
    IGRID   = 1
    CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
        IGRID,ILENCH,YCOMMENT,IRESP)
  END IF
!!
  YRECFM  ='ZCHEN'
  YCOMMENT='X_Y_Z_ZCHEN'
  ILENCH=LEN(YCOMMENT)
  IGRID   = 1
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!
  YRECFM  ='SURSAT'
  YCOMMENT='X_Y_Z_SURSAT'
  ILENCH=LEN(YCOMMENT)
  IGRID   = 1
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!! c2r2_adjust
  YRECFM  ='NEB'
  YCOMMENT='X_Y_Z_NEB (0)'
  ILENCH=LEN(YCOMMENT)
  IGRID   = 1
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,'XY',ZSTORE_3D, &
      IGRID,ILENCH,YCOMMENT,IRESP)
!!

END IF
!
!!!!!!!!!!!!CALL WRITE_LB_n(HFMFILE)
!
!
!
DEALLOCATE(ZSTORE_2D,ZSTORE_3D,ZSTORE_3DWL)
!
!-------------------------------------------------------------------------------!
!
END SUBROUTINE WRITE_PHYS_PARAM
#endif

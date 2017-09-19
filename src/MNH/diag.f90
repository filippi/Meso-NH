!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
! $Source: /home/cvsroot/MNH-VX-Y-Z/src/MNH/diag.f90,v $ $Revision: 1.3.2.4.2.4.2.5.2.6.2.3.2.6 $ $Date: 2015/11/26 14:55:02 $
!-----------------------------------------------------------------
!     ############
      PROGRAM DIAG
!     ############
!
!!****
!!
!!    PURPOSE
!!    -------
!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!          MODD_DYN
!!          MODD_CONF
!!          MODD_PARAMETERS
!!          MODD_CONF_n
!!          MODD_DYN_n
!!          MODD_DIM_n
!!          MODD_ADV_n
!!          MODD_FIELD_n
!!          MODD_GRID_n
!!          MODD_LBC_n
!!          MODD_PARAM_n
!!          MODD_REF_n
!!          MODD_LUNIT_n
!!          MODD_OUT_n
!!          MODD_TIME_n
!!          MODD_TURB_n
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!      E. Richard                  * LA *
!!
!!    MODIFICATIONS
!!    -------------
!!
!!  15/03/99    (V. Masson)    call to PHYS_PARAM1 and new PGD fields
!!  08/06/01    (F. Meleux)    call to diagnostics for chemistry
!!  13/07/01    (J Stein)      trajectory computation
!!  15/10/01    (I.Mallet)     allow namelists in different orders
!!  05/02/02    (G.Jaubert)    aircraft and balloon computation
!!  15/03/02    (F Solmon)     replace NMODE by NRAD_DIAG
!!  29/11/02    (J.-P. Pinty)  add C3R5, ICE2, ICE4, ELEC
!!  15/04/03    (J.-P. Chaboureau) add LRAD_SUBG_COND
!!  01/2004     (Masson)       surface externalization
!!  19/03/2008  (J.Escobar)    rename INIT to INIT_MNH --> grib problem
!!  04/2008     (O. Caumont)   radar simulator
!!  10/2009     (C.Lac)        Correction on FIT temporal scheme for variables
!!                             advected with PPM
!!  03/2010     (G.Tanguy)     Clean up of unuseful variables
!!  05/2010                    Add lidar
!!!  03/2012     (S. Bielli)   Add NAM_NCOUT for netcdf output (removed 11/07/2016)
!!  03/2013     (O.Caumont)    Modif call aircraft_balloon
!!  03/2013     (C. Augros)    Add variables for radar simulator in NAMELIST:
!!                             NBAZIM,LSNRT,XSNRMIN
!!  D.Ricard 2015 : add LMOIST_ES
!!  July, 2015 (O.Nuissier/F.Duffourg) Add microphysics diagnostic for
!!                                      aircraft, ballon and profiler
!!  J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1
!!   P.Tulet : 11/2015 : new diagnostic for aerosol
!!  09/2015     (S. Bielli)    Add netcdf call for phys_param
!!  04/2016     (G.Delautier) replace print by write in OUTPUT LISTING
!!  06/2016     (G.Delautier) phasage surfex 8
!!  11/07/2016 (P.Wautelet)   removed MNH_NCWRIT define
!!  09/2016      (JP Pinty) Add LIMA
!!  10/2016      (C.LAC) add LVISI
!!  10/2016     (F Brosse) Add prod/loss terms computation for chemistry  
!!
!-------------------------------------------------------------------------------
!
!*       0.     DECLARATIONS
!               ------------
!
USE MODD_VAR_ll
!
USE MODD_DYN
USE MODD_CONF
USE MODD_GRID, ONLY: XLONORI,XLATORI
USE MODD_LUNIT
USE MODD_PARAMETERS
!
USE MODD_DIAG_FLAG
USE MODD_STO_FILE
!
USE MODD_CONF_n
USE MODD_DIM_n
USE MODD_DYN_n
USE MODD_ADV_n
USE MODD_DEEP_CONVECTION_n
USE MODD_FIELD_n
USE MODD_GRID_n
USE MODD_LBC_n
USE MODD_PARAM_n
USE MODD_PARAM_KAFR_n
USE MODD_PARAM_RAD_n
USE MODD_RADIATIONS_n
USE MODD_TURB_n
USE MODD_PARAM_MFSHALL_n
USE MODD_REF_n
USE MODD_LUNIT_n
USE MODD_OUT_n
USE MODD_TIME_n
USE MODD_NESTING, ONLY: CDAD_NAME
USE MODD_NSV
USE MODD_AIRCRAFT_BALLOON
USE MODD_TIME
USE MODD_GR_FIELD_n
USE MODD_LES
USE MODD_LES_BUDGET
USE MODD_BUDGET
USE MODD_RADAR
USE MODD_PARAM_LIMA, ONLY : LLIMA_DIAG
USE MODD_IO_ll, ONLY: LIOCDF4,LLFIOUT,TFILEDATA,TFILE_SURFEX
!
USE MODN_DIAG_BLANK
!
USE MODI_PHYS_PARAM_n
USE MODI_WRITE_LFIFM1_FOR_DIAG
USE MODI_WRITE_LFIFM1_FOR_DIAG_SUPP
USE MODI_COMPUTE_R00
USE MODI_WRITE_LFIFMN_FORDIACHRO_n
USE MODI_AIRCRAFT_BALLOON
USE MODI_WRITE_AIRCRAFT_BALLOON
!
USE MODE_POS
USE MODE_TIME
USE MODE_FM
USE MODE_FMWRIT, ONLY : IO_WRITE_HEADER
USE MODE_IO_ll
USE MODE_IO_MANAGE_STRUCT, ONLY : IO_FILE_ADD2LIST
USE MODE_ll
USE MODE_MODELN_HANDLER
USE MODE_MSG
!
USE MODD_AIRCRAFT_BALLOON
USE MODD_PROFILER_n
USE MODD_STATION_n
USE MODE_MNH_TIMING
USE MODE_FMREAD
USE MODN_CONFZ
!
USE MODI_MNHGET_SURF_PARAM_n
!
USE MODI_VERSION
USE MODI_INIT_MNH
USE MODI_MENU_DIACHRO
USE MODI_WRITE_SURF_ATM_N
USE MODI_DIAG_SURF_ATM_N
USE MODI_WRITE_DIAG_SURF_ATM_N  
USE MODD_MNH_SURFEX_n
!  
USE MODN_CONF, ONLY : JPHEXT , NHALO
USE MODN_CONFIO, ONLY : NAM_CONFIO
!
IMPLICIT NONE
!
!*       0.1   declarations of local variables
!
TYPE(DATE_TIME)   :: TXDTBAL   ! current time and date for BALLOON and AIRCRAFT trajectories
CHARACTER (LEN=28), DIMENSION(1) :: YINIFILE ! names of the INPUT FM-file
CHARACTER (LEN=28), DIMENSION(1) :: YINIFILEPGD ! names of the INPUT FM-file
CHARACTER (LEN=5)  :: YSUFFIX   ! character string for the OUTPUT FM-file number
CHARACTER (LEN=4)  :: YRAD      ! initial flag to call to radiation schemes
CHARACTER (LEN=4)  :: YDCONV    ! initial flag to call to deep convection schemes
CHARACTER (LEN=4)  :: YSCONV    ! initial flag to call to shallow convection schemes
CHARACTER (LEN=4)  :: YTURB     ! initial flag to call to turbulence schemes
CHARACTER (LEN=40) :: YFMT,YFMT2! format for cpu analysis printing
INTEGER  :: IRESP               ! return code in FM routines
INTEGER  :: ILUOUT0             ! Logical unit number for the output listing
REAL*8,DIMENSION(2)     :: ZTIME0,ZTIME1,ZTIME2,ZRAD,ZDCONV,ZSHADOWS,ZGROUND, &
                         ZTRACER,ZDRAG,ZTURB,ZMAFL,ZCHEM,ZTIME_BU ! CPU time 
REAL*8,DIMENSION(2)     :: ZSTART,ZINIT,ZWRIT,ZBALL,ZPHYS,ZSURF,ZWRITS,ZTRAJ ! storing variables
INTEGER :: INPRAR               ! number of articles predicted  in
                                !  the LFIFM file
LOGICAL :: GCLOSE_OUT = .FALSE. ! conditional closure of the OUTPUT FM-file
INTEGER :: ISTEPBAL   ! loop indice for balloons and aircraft
INTEGER :: ILUNAM      ! Logical unit numbers for the namelist file
                       ! and for output_listing file
CHARACTER (LEN=9) :: YNAM ! name of the namelist file
INTEGER        :: JF =0   !  loop index
LOGICAL :: GFOUND         ! Return code when searching namelist
LOGICAL, DIMENSION(:,:),ALLOCATABLE     :: GMASKkids ! kids domains mask
!
INTEGER :: IIU, IJU, IKU
INTEGER :: IINFO_ll               ! return code for _ll routines 
REAL, DIMENSION(:,:),ALLOCATABLE          :: ZSEA,ZTOWN
!
TYPE(TFILEDATA),POINTER :: TZFILE
TYPE(TFILEDATA),POINTER :: TZDIACFILE
!
NAMELIST/NAM_DIAG/ CISO, LVAR_RS, LVAR_LS,   &
                   NCONV_KF, NRAD_3D, CRAD_SAT, NRTTOVINFO, LRAD_SUBG_COND,  &
                   LVAR_TURB,LTURBFLX,LTURBDIAG,LMFFLX,XDTSTEP,  &
                   LVAR_MRW, LVAR_MRSV, LVAR_FRC, &
                   LTPZH, LMOIST_V, LMOIST_E,LMOIST_ES, LCOREF, &
                   LVORT, LDIV, LMEAN_POVO, XMEAN_POVO, &
                   LGEO, LAGEO, LWIND_ZM, LMSLP, LTHW, &
                   LCLD_COV, LVAR_PR, LTOTAL_PR, LMEAN_PR, XMEAN_PR, &
                   NCAPE, LBV_FR, LRADAR, LBLTOP, LTRAJ, &
                   LDIAG,XDIAG,LCHEMDIAG,LCHAQDIAG,XCHEMLAT,XCHEMLON,&
                   CSPEC_BU_DIAG,CSPEC_DIAG,LAIRCRAFT_BALLOON,NTIME_AIRCRAFT_BALLOON,&
                   XSTEP_AIRCRAFT_BALLOON,&
                   XLAT_BALLOON,XLON_BALLOON,XALT_BALLOON,&
                   LC2R2, LC3R5, LELECDIAG, CAERDIAG, &
                   NGPS,XLAT_GPS,XLON_GPS,XZS_GPS,CNAM_GPS,XDIFFORO, &
                   NVERSION_RAD, NCURV_INTERPOL, LCART_RAD, CARF,LREFR,LDNDZ,&
                   XLON_RAD,XLAT_RAD,XALT_RAD,CNAME_RAD,XLAM_RAD,XDT_RAD, &
                   NDIFF,LATT,NPTS_GAULAG,NPTS_H,NPTS_V,XSTEP_RAD,NBSTEPMAX,NBAZIM, &
                   XGRID,NBELEV,XELEV,NBRAD,LQUAD,LFALL,LWBSCS,LWREFL,&
                   XREFLMIN,XREFLVDOPMIN,LSNRT,XSNRMIN,&
                   LLIDAR,CVIEW_LIDAR,XALT_LIDAR,XWVL_LIDAR,&
                   LISOPR,XISOPR,LISOTH,XISOTH, LHU_FLX,LVISI, LLIMA_DIAG
!
NAMELIST/NAM_DIAG_FILE/ YINIFILE,YINIFILEPGD, YSUFFIX
NAMELIST/NAM_STO_FILE/ CFILES, NSTART_SUPP
NAMELIST/NAM_CONF_DIAG/JPHEXT, NHALO 
!
!-------------------------------------------------------------------------------
!
!*       0.0   Initializations
!              ---------------
!
TZFILE => NULL()
TZDIACFILE => NULL()
!
CALL GOTO_MODEL(1)
!
CALL VERSION
CPROGRAM='DIAG  '
!
CALL INITIO_ll()
CALL SECOND_MNH2(ZTIME1)
ZTIME0=ZTIME1
!
! initialization of logical for the diagnostics
!
CISO='PREVTK'
LVAR_RS=.TRUE.
LVAR_LS=.FALSE.
NCONV_KF=-1
NRAD_3D=-1
CRAD_SAT='                                            '
LRAD_SUBG_COND=.TRUE.
NRTTOVINFO(:,:)=NUNDEF
LVAR_TURB=.FALSE.
LTURBFLX=.FALSE.
LTURBDIAG=.FALSE.
LMFFLX=.FALSE.
XDTSTEP=XUNDEF
LVAR_MRW=.FALSE.
LVAR_MRSV=.FALSE.
LTPZH=.FALSE.
LMOIST_V=.FALSE.
LMOIST_E=.FALSE.
LMOIST_ES=.FALSE.
LCOREF=.FALSE.
LVORT=.FALSE.
LDIV=.FALSE.
LMEAN_POVO=.FALSE.
XMEAN_POVO(1)=15000
XMEAN_POVO(2)=50000
LGEO=.FALSE.
LAGEO=.FALSE.
LWIND_ZM=.FALSE.
LMSLP=.FALSE.
LTHW=.FALSE.
LCLD_COV=.FALSE.
LVAR_PR=.FALSE.
LTOTAL_PR=.FALSE.
LHU_FLX=.FALSE.
LMEAN_PR=.FALSE.
XMEAN_PR(1:2)=1.
NCAPE=-1
LBV_FR=.FALSE.
LRADAR=.FALSE.
LBLTOP=.FALSE.
LVISI=.FALSE.
LVAR_FRC=.FALSE.
LCHEMDIAG=.FALSE.
CAERDIAG='CLIM'
LCHAQDIAG=.FALSE.
XCHEMLAT(:)=XUNDEF
XCHEMLON(:)=XUNDEF
CSPEC_BU_DIAG=''
CSPEC_DIAG=''
LTRAJ=.FALSE.
LLIMA_DIAG=.FALSE.
!
LAIRCRAFT_BALLOON=.FALSE.
NTIME_AIRCRAFT_BALLOON=NUNDEF
XSTEP_AIRCRAFT_BALLOON=XUNDEF
XLAT_BALLOON(:)=XUNDEF
XLON_BALLOON(:)=XUNDEF
XALT_BALLOON(:)=XUNDEF
!
NGPS=-1
CNAM_GPS(:)=''
XLAT_GPS(:)=XUNDEF
XLON_GPS(:)=XUNDEF
XZS_GPS(:)=-999.0
XDIFFORO=150.0

!! initialization of radar parameters
NVERSION_RAD=1
XSTEP_RAD=XUNDEF
NCURV_INTERPOL=0
LCART_RAD=.TRUE.
NBAZIM=720
XLON_RAD(:)=XUNDEF
XLAT_RAD(:)=XUNDEF
XALT_RAD(:)=XUNDEF
CNAME_RAD(:)="UNDEF"
XLAM_RAD(:)=XUNDEF
XDT_RAD(:)=XUNDEF  
XELEV(:,:)=XUNDEF
NBSTEPMAX=-1
LATT=.FALSE.
LQUAD=.FALSE.
NPTS_H=1
NPTS_V=1
CARF="PB70"
LREFR=.FALSE.
LDNDZ=.FALSE.
NCURV_INTERPOL=0
LCART_RAD=.TRUE.
NDIFF=0
NPTS_GAULAG=7
XGRID=2000.
LQUAD=.FALSE.
NDGS=2
LFALL=.FALSE.
LWREFL=.FALSE.
LWBSCS=.FALSE.
XREFLMIN=-30.
XREFLVDOPMIN=-990.
LSNRT=.TRUE.
XSNRMIN=0
!
LDIAG(:)=.FALSE.
XDIAG(:)=XUNDEF
!
YINIFILE(:) = '                         '
YINIFILEPGD(:) = '                         '
YSUFFIX='_DIAG'
!
CFILES(:) = '                         '
NSTART_SUPP(:) = NUNDEF
!
LLIDAR=.FALSE.
CVIEW_LIDAR='NADIR'
XALT_LIDAR=0
XWVL_LIDAR=0.532E-6
!
LISOPR=.FALSE.
XISOPR(:)=0.
LISOTH=.FALSE.
XISOTH(:)=0.
!
!-------------------------------------------------------------------------------
!
!*       1.0   Namelist reading
!              ----------------
!
YNAM  = 'DIAG1.nam'
CALL OPEN_ll (UNIT=ILUNAM,FILE=YNAM,IOSTAT=IRESP,STATUS="OLD",ACTION='READ', &
     FORM="FORMATTED",POSITION="REWIND",MODE=GLOBAL)
!
!
CALL POSNAM(ILUNAM,'NAM_DIAG',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_DIAG)
END IF
!
CALL POSNAM(ILUNAM,'NAM_DIAG_BLANK',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_DIAG_BLANK)
END IF
!
CALL POSNAM(ILUNAM,'NAM_DIAG_FILE',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_DIAG_FILE)
END IF
!
CALL POSNAM(ILUNAM,'NAM_STO_FILE',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_STO_FILE)
END IF
CALL POSNAM(ILUNAM,'NAM_CONFZ',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_CONFZ)
END IF
CALL POSNAM(ILUNAM,'NAM_CONFIO',GFOUND)
IF (GFOUND) THEN
  READ(UNIT=ILUNAM,NML=NAM_CONFIO)
END IF
CALL SET_CONFIO_ll()
!
CALL CLOSE_ll(YNAM)
!
CINIFILE = YINIFILE(1)
CINIFILEPGD = YINIFILEPGD(1)
!!
IF (LTRAJ) THEN
  JF=1
  DO WHILE (LEN_TRIM(CFILES(JF))/=0)
    JF=JF+1
  END DO
  !
  IF (JF/=1) THEN
    IF (CINIFILE==CFILES(JF-1)) THEN
      PRINT*,'*****************************'
      PRINT*,'* INITIAL FILE NON TREATED  *'
      PRINT*,'*****************************'
!callabortstop
      CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
      CALL ABORT
      STOP
    END IF
  END IF
!
END IF
!
!
!-------------------------------------------------------------------------------
!
!*       2.0   MESONH file
!              -----------
!
IF ( LEN_TRIM(CINIFILE)==0 ) THEN
       !callabortstop
      CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
      CALL ABORT
 STOP
ENDIF
!
INPRAR = 24 +2*(4+NRR+NSV)
COUTFMFILE=TRIM(CINIFILE)//YSUFFIX
!
CALL IO_FILE_ADD2LIST(TZFILE,TRIM(CINIFILE)//YSUFFIX,'DIAG','WRITE',KLFINPRAR=INPRAR,KLFITYPE=1,KLFIVERB=NVERB)
!
CALL IO_FILE_OPEN_ll(TZFILE,CLUOUT,IRESP)
!
CALL SECOND_MNH2(ZTIME2)
ZSTART=ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       3.0   Fields initialization
!
CALL INIT_MNH
!
CALL FMLOOK_ll(CLUOUT0,CLUOUT0,ILUOUT0,IRESP)
!
WRITE(ILUOUT0,*) ' '
WRITE(ILUOUT0,*) '****************************************'
WRITE(ILUOUT0,*) 'Treatment of file: ',CINIFILE
WRITE(ILUOUT0,*) '****************************************'
!
CALL GET_DIM_EXT_ll('B',IIU,IJU)
IKU=NKMAX+2*JPVEXT
!
!* allocation of variables used 
!
ALLOCATE(GMASKkids  (IIU,IJU))
GMASKkids(:,:)=.FALSE.
! 
CALL INI_DIAG_IN_RUN(IIU,IJU,IKU,LFLYER,LSTATION,LPROFILER)
!
CALL SECOND_MNH2(ZTIME2)
ZINIT =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!
IF (LRADAR .AND. NVERSION_RAD==2 .AND. NPROC/=1) THEN
      PRINT*, '***************************************'
      PRINT*, ' WITH NVERSION_RAD=2, DIAG HAS TO BE &
                      & PERFORMED WITH MONOPROCESSOR MODE '
      PRINT*, '-> JOB ABORTED'
      PRINT*, '***************************************'
     !callabortstop
      CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
      CALL ABORT
      STOP

ENDIF
!-------------------------------------------------------------------------------
!
!*       4.0    Stores the fields in MESONH files if necessary
!
CALL WRITE_LFIFM1_FOR_DIAG(TZFILE,CDAD_NAME(1))
!
WRITE(ILUOUT0,*) ' '
WRITE(ILUOUT0,*) 'DIAG AFTER WRITE_LFIFM1_FOR_DIAG'
WRITE(ILUOUT0,*) ' '
!
CALL SECOND_MNH2(ZTIME2)
ZWRIT =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       4.1    BALLOON and AIRCRAFT
!
IF ( LAIRCRAFT_BALLOON ) THEN
!
  CALL IO_FILE_ADD2LIST(TZDIACFILE,TRIM(CINIFILE)//'BAL','DIACHRONIC','WRITE',KLFINPRAR=INPRAR,KLFITYPE=1,KLFIVERB=NVERB)
!
  CALL IO_FILE_OPEN_ll(TZDIACFILE,CLUOUT,IRESP)
!
  WRITE(ILUOUT0,*) ' '
  WRITE(ILUOUT0,*) 'DIAG AFTER OPEN DIACHRONIC FILE'
  WRITE(ILUOUT0,*) ' '
!
  TXDTBAL%TDATE%YEAR = TDTCUR%TDATE%YEAR
  TXDTBAL%TDATE%MONTH = TDTCUR%TDATE%MONTH
  TXDTBAL%TDATE%DAY = TDTCUR%TDATE%DAY
  TXDTBAL%TIME = TDTCUR%TIME - NTIME_AIRCRAFT_BALLOON/2.
  CALL SUBTRACT_TO_DATE(TXDTBAL%TDATE%YEAR, &
                          TXDTBAL%TDATE%MONTH,&
                          TXDTBAL%TDATE%DAY,  &
                          TXDTBAL%TIME        )
!
  ALLOCATE (ZSEA(SIZE(XRHODJ,1),SIZE(XRHODJ,2)))
  ALLOCATE (ZTOWN(SIZE(XRHODJ,1),SIZE(XRHODJ,2)))
  ZSEA(:,:) = 0.
  ZTOWN(:,:)= 0.
  CALL MNHGET_SURF_PARAM_n (PSEA=ZSEA(:,:),PTOWN=ZTOWN(:,:))
  DO ISTEPBAL=1,NTIME_AIRCRAFT_BALLOON,INT(XSTEP_AIRCRAFT_BALLOON)
!
    CALL AIRCRAFT_BALLOON(CLUOUT,XSTEP_AIRCRAFT_BALLOON, &
                      TDTEXP, TDTMOD, TDTCUR, TXDTBAL, &
                      XXHAT, XYHAT, XZZ, XMAP, XLONORI, XLATORI, &
                      XUT, XVT, XWT, XPABST, XTHT, XRT, XSVT,    &
                      XTKET, XTSRAD, XRHODREF,XCIT,ZSEA)
  DEALLOCATE (ZSEA,ZTOWN)
!
!-----------------------------
!
    TXDTBAL%TIME=TXDTBAL%TIME + XSTEP_AIRCRAFT_BALLOON
    CALL ADD_FORECAST_TO_DATE(TXDTBAL%TDATE%YEAR, &
                          TXDTBAL%TDATE%MONTH,&
                          TXDTBAL%TDATE%DAY,  &
                          TXDTBAL%TIME        )
  ENDDO
  CALL IO_WRITE_HEADER(TZDIACFILE)
  CALL WRITE_LFIFMN_FORDIACHRO_n(TZDIACFILE)
  CALL WRITE_AIRCRAFT_BALLOON(TZDIACFILE)
  CALL MENU_DIACHRO(TZDIACFILE,CLUOUT,'END')
  CALL IO_FILE_CLOSE_ll(TZDIACFILE,CLUOUT,IRESP)
  WRITE(ILUOUT0,*) ' '
  WRITE(ILUOUT0,*) 'DIAG AFTER CLOSE DIACHRONIC FILE'
  WRITE(ILUOUT0,*) ' '
END IF
!
CALL SECOND_MNH2(ZTIME2)
ZBALL =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       5.0   Call to physics
!
!* initialise the source terms
!
XRUS (:,:,:) = 0.
XRVS (:,:,:) = 0.
XRWS (:,:,:) = 0.
XRTHS(:,:,:) = 0.
IF (NRR>=1)             XRRS  (:,:,:,:) = 0.
IF (NSV>=1)             XRSVS (:,:,:,:) = 0.
IF (CTURB /= 'NONE')    XRTKES(:,:,:) = 0.
!
!* stores the initial flags

!
YTURB  = CTURB
YDCONV = CDCONV
YSCONV = CSCONV
YRAD   = CRAD
!
!* turbulence scheme
!
LTURB_DIAG=LTURBDIAG
LTURB_FLX =LTURBFLX
LMF_FLX =LMFFLX
! no need to recompute the turbulent tendencies.
IF ( .NOT. LTURB_FLX .AND. .NOT. LTURB_DIAG .AND. &
     .NOT. LMF_FLX ) THEN
  CTURB  = 'NONE'
END IF
! no way to compute the turbulent tendencies.
!IF ( ( LTURB_FLX .OR. LTURB_DIAG .OR. LMF_FLX )   &
!       .AND. CSTORAGE_TYPE/='MT' ) THEN
!  CTURB  = 'NONE'
!  PRINT*, '******************* WARNING in DIAG ***********************'
!  PRINT*, ' '
!  PRINT*, 'You wanted to compute turbulence fluxes or diagnostics,'
!  PRINT*, 'But the initial file comes from PREP_REAL_CASE.'
!  PRINT*, 'Therefore, the boundary layer turbulence is meaningless.'
!  PRINT*, 'Turbulence fluxes and diagnostics will NOT be computed'
!  PRINT*, 'Please make your turbulence diagnostics from a meso-NH file'
!  PRINT*, 'coming from a MESO-NH simulation.'
!END IF
!
!* convective scheme
!
IF (NCONV_KF == -1) CDCONV = 'NONE'
!
IF (NCONV_KF >= 0 ) THEN
  CALL  SM_PRINT_TIME(TDTCUR,CLUOUT0,'CURRENT TIME ')
  CALL  SM_PRINT_TIME(TDTDCONV,CLUOUT0,'LAST CONVECTION CALL')
  CDCONV='KAFR'
  LDIAGCONV= .TRUE.
  TDTDCONV=TDTCUR
END IF
!
!* radiation scheme
!
IF (NRAD_3D == -1) CRAD = 'NONE'
!
IF (NRAD_3D >= 0) THEN
  CAER=CAERDIAG
  IF (YRAD=='ECMW') THEN
    ! radiative fields are already initialized by INIT
    CRAD = 'NONE'
  ELSE
    CRAD = 'ECMW'
  ENDIF
  IF (NRAD_3D >= 1) THEN
    NRAD_DIAG = NRAD_3D
    CRAD = 'ECMW'    ! radiation scheme is called to compute extra diags
  END IF
END IF
!
IF (LEN_TRIM(CRAD_SAT) /= 0 .AND. YRAD/='ECMW') THEN
  CRAD = 'ECMW'
END IF
!
!
IF ( CTURB /= 'NONE' .OR. CDCONV /= 'NONE' .OR. CSCONV /= 'NONE' &                 
     .OR. CRAD /= 'NONE' ) THEN
! IF (CSTORAGE_TYPE/='MT') THEN
    IF (XDTSTEP==XUNDEF) THEN
      WRITE(ILUOUT0,*) ' '
      WRITE(ILUOUT0,*) '******************* WARNING in DIAG ***********************'
      WRITE(ILUOUT0,*) ' '
      WRITE(ILUOUT0,*) 'You asked for diagnostics that need to call the physics monitor:'
      WRITE(ILUOUT0,*) ' be aware of the time step used'
      WRITE(ILUOUT0,*) 'you can modify it with XDTSTEP in namelist NAM_DIAG'
      WRITE(ILUOUT0,*) ' '
    ELSE
      XTSTEP=XDTSTEP
    END IF
! END IF
  WRITE(ILUOUT0,*)' XTSTEP= ', XTSTEP
  WRITE(ILUOUT0,*) ' '
  WRITE(ILUOUT0,*) 'DIAG BEFORE PHYS_PARAM1: CTURB=',CTURB,' CDCONV=',CDCONV, &
          ' CSCONV=',CSCONV,' CRAD=',CRAD
END IF
!
!* call to physics monitor
!
GCLOSE_OUT=.TRUE.
ZRAD=0.
ZSHADOWS=0.
ZDCONV=0.
ZGROUND=0.
ZTRACER=0.
ZTURB=0.
ZDRAG=0.
ZMAFL=0.
ZCHEM=0.
XTIME_LES=0.
XTIME_LES_BU_PROCESS=0.
XTIME_BU_PROCESS=0.
CALL PHYS_PARAM_n(1,TZFILE,GCLOSE_OUT,                      &
                  ZRAD,ZSHADOWS,ZDCONV,ZGROUND,ZMAFL,ZDRAG, &
                  ZTURB,ZTRACER, ZCHEM,ZTIME_BU,GMASKkids)
WRITE(ILUOUT0,*) 'DIAG AFTER PHYS_PARAM1'
!
!* restores the initial flags
!
CTURB  = YTURB
CDCONV = YDCONV
CRAD   = YRAD
!
CALL SECOND_MNH2(ZTIME2)
ZPHYS =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       6.0    Surface diagnostics
!
IF (CSURF=='EXTE') THEN
  CALL GOTO_SURFEX(1)
  TFILE_SURFEX => TZFILE
  CALL WRITE_SURF_ATM_n(YSURF_CUR,'MESONH','ALL',.FALSE.)
  CALL DIAG_SURF_ATM_n(YSURF_CUR%IM%DGEI, YSURF_CUR%FM%DGF, YSURF_CUR%DGL, YSURF_CUR%IM%DGI, &
                             YSURF_CUR%SM%DGS, YSURF_CUR%DGU, YSURF_CUR%TM%DGT, YSURF_CUR%WM%DGW, &
                             YSURF_CUR%U, YSURF_CUR%USS,'MESONH')
  CALL WRITE_DIAG_SURF_ATM_n(YSURF_CUR,'MESONH','ALL')
  NULLIFY(TFILE_SURFEX)
  WRITE(ILUOUT0,*) ' '
  WRITE(ILUOUT0,*) 'DIAG AFTER WRITE_DIAG_SURF_ATM_n'
ENDIF
!
CALL SECOND_MNH2(ZTIME2)
ZSURF =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!
!-------------------------------------------------------------------------------
!
!*       7.0    Stores other fields in MESONH files if necessary
!
CALL WRITE_LFIFM1_FOR_DIAG_SUPP(TZFILE)
WRITE(ILUOUT0,*) ' '
WRITE(ILUOUT0,*) 'DIAG AFTER WRITE_LFIFM1_FOR_DIAG_SUPP'
!
CALL SECOND_MNH2(ZTIME2)
ZWRITS=ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       8.0    Initial positions computation (back into simulation segments)
!
IF (LTRAJ .AND. JF/=1) CALL COMPUTE_R00(TZFILE)
!
CALL SECOND_MNH2(ZTIME2)
ZTRAJ =ZTIME2-ZTIME1
ZTIME1=ZTIME2
!-------------------------------------------------------------------------------
!
!*       9.0    Closes the FM files
!
DEALLOCATE(GMASKkids)
IF (GCLOSE_OUT) THEN
  GCLOSE_OUT=.FALSE.
  CALL IO_FILE_CLOSE_ll(TZFILE,CLUOUT,IRESP)
END IF
!
CALL CLOSE_ll (CLUOUT,IOSTAT=IRESP)
!
CALL SECOND_MNH2(ZTIME2)
ZTIME2=ZTIME2-ZTIME0
!-------------------------------------------------------------------------------
!
!CALL FMLOOK_ll(CLUOUT0,CLUOUT0,ILUOUT0,IRESP)
!
!WRITE(ILUOUT0,*) '+--------------------------------------------------------------+'
!WRITE(ILUOUT0,*) '|                                                              |'
!WRITE(ILUOUT0,*) '|            COMPUTING TIME ANALYSIS in DIAG                   |'
!WRITE(ILUOUT0,*) '|                                                              |'
!WRITE(ILUOUT0,*) '|--------------------------------------------------------------|'
!WRITE(ILUOUT0,*) '|                     |                    |                   |'
!WRITE(ILUOUT0,*) '|    ROUTINE NAME     |      CPU-TIME      |   PERCENTAGE %    |'
!WRITE(ILUOUT0,*) '|                     |                    |                   |'
!WRITE(ILUOUT0,*) '|---------------------| -------------------|-------------------|'
!WRITE(ILUOUT0,*) '|                     |                    |                   |'
!YFMT='(A,F9.3,A,F9.3,A)'
!YFMT2='(A,A4,A,F9.3)'
!WRITE(ILUOUT0,YFMT) '|        START        |     ',ZSTART,'      |     ',100.*ZSTART/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        INIT         |     ',ZINIT,'      |     ',100.*ZINIT/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        WRIT         |     ',ZWRIT,'      |     ',100.*ZWRIT/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        BALL         |     ',ZBALL,'      |     ',100.*ZBALL/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        PHYS         |     ',ZPHYS,'      |     ',100.*ZPHYS/ZTIME2,'     |'
!IF (ZRAD>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          ',CRAD,'       |     ',ZRAD
!IF (ZDCONV>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          ',CDCONV,'       |     ',ZDCONV
!IF (ZGROUND>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          ',CSURF,'       |     ',ZGROUND
!IF (ZTRACER>0.) &
!  WRITE(ILUOUT0,YFMT2) '|    LCONDSAMP and LPASPOL |     ',ZTRACER
!IF (ZMAFL>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          ',CSCONV,'       |     ',ZMAFL
!IF (ZDRAG>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          DRAGTREE        |     ',ZDRAG
!IF (ZTURB>0.) &
!  WRITE(ILUOUT0,YFMT2) '|          ',CTURB,'       |     ',ZTURB
!IF (ZCHEM>0.) &
!  WRITE(ILUOUT0,'(A,F9.3)') '|       CHEM          |     ',ZCHEM
!WRITE(ILUOUT0,YFMT) '|        SURF         |     ',ZSURF,'      |     ',100.*ZSURF/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        WRITS        |     ',ZWRITS,'      |     ',100.*ZWRITS/ZTIME2,'     |'
!WRITE(ILUOUT0,YFMT) '|        TRAJ         |     ',ZTRAJ,'      |     ',100.*ZTRAJ/ZTIME2,'     |'
!WRITE(ILUOUT0,*) '|                     |                    |                   |'
!WRITE(ILUOUT0,*) '|---------------------| -------------------|-------------------|'
!
!
WRITE(ILUOUT0,*) ' '
WRITE(ILUOUT0,*) '***************************** **************'
WRITE(ILUOUT0,*) '*            EXIT  DIAG CORRECTLY          *'
WRITE(ILUOUT0,*) '**************************** ***************'
!WRITE(ILUOUT0,*) '  (see time analysis in ',TRIM(CLUOUT0),' )'
WRITE(ILUOUT0,*) ' '
CALL CLOSE_ll (CLUOUT0,IOSTAT=IRESP)
!-------------------------------------------------------------------------------
!
!*      10.    FINALIZE THE PARALLEL SESSION
!              -----------------------------
!
CALL END_PARA_ll(IINFO_ll)
!
!-------------------------------------------------------------------------------
END PROGRAM DIAG

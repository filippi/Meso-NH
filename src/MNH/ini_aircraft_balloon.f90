!MNH_LIC Copyright 2000-2022 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Modifications:
!  P. Wautelet 01/10/2020: bugfix: DEFAULT_FLYER: add missing default values
!  P. Wautelet    06/2022: reorganize flyers
!-----------------------------------------------------------------

!      #########################
MODULE MODI_INI_AIRCRAFT_BALLOON
!      #########################
!
INTERFACE
!
      SUBROUTINE INI_AIRCRAFT_BALLOON(TPINIFILE,                    &
                                      PTSTEP, TPDTSEG, PSEGLEN,     &
                                      KRR, KSV, KKU, OUSETKE,       &
                                      PLATOR, PLONOR                )
!
USE MODD_IO, ONLY: TFILEDATA
USE MODD_TYPE_DATE
!
TYPE(TFILEDATA),    INTENT(IN) :: TPINIFILE !Initial file
REAL,               INTENT(IN) :: PTSTEP  ! time step
TYPE(DATE_TIME),    INTENT(IN) :: TPDTSEG ! segment date and time
REAL,               INTENT(IN) :: PSEGLEN ! segment length
INTEGER,            INTENT(IN) :: KRR     ! number of moist variables
INTEGER,            INTENT(IN) :: KSV     ! number of scalar variables
INTEGER,            INTENT(IN) :: KKU     ! number of vertical levels 
LOGICAL,            INTENT(IN) :: OUSETKE ! flag to use tke
REAL,               INTENT(IN) :: PLATOR  ! latitude of origine point
REAL,               INTENT(IN) :: PLONOR  ! longitude of origine point
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE INI_AIRCRAFT_BALLOON
!
END INTERFACE
!
END MODULE MODI_INI_AIRCRAFT_BALLOON
!
!     ###############################################################
      SUBROUTINE INI_AIRCRAFT_BALLOON(TPINIFILE,                    &
                                      PTSTEP, TPDTSEG, PSEGLEN,     &
                                      KRR, KSV, KKU, OUSETKE,       &
                                      PLATOR, PLONOR                )
!     ###############################################################
!
!
!!****  *INI_AIRCRAFT_BALLOON* -
!!
!!    PURPOSE
!!    -------
!
!
!!**  METHOD
!!    ------
!!
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!      Valery Masson             * Meteo-France *
!!
!!    MODIFICATIONS
!!    -------------
!!     Original 15/05/2000
!!               Apr, 20 2001: G.Jaubert: use in diag  with stationnary fields
!!               March, 2013 : O.Caumont, C.Lac : add vertical profiles
!!               OCT,2016 : G.Delautier LIMA
!!  Philippe Wautelet: 05/2016-04/2018: new data structures and calls for I/O
!  P. Wautelet 13/09/2019: budget: simplify and modernize date/time management
!!
!! --------------------------------------------------------------------------
!
!*      0. DECLARATIONS
!          ------------
!
USE MODD_AIRCRAFT_BALLOON
USE MODD_CONF
USE MODD_DIAG_FLAG
USE MODD_DYN_n
use modd_field,      only: tfieldmetadata, TYPEREAL
USE MODD_GRID
USE MODD_IO,         ONLY: TFILEDATA
USE MODD_LUNIT_n,    ONLY: TLUOUT
USE MODD_PARAM_n,    ONLY: CCLOUD
USE MODD_PARAMETERS
!
USE MODE_GRIDPROJ
USE MODE_ll
USE MODE_MODELN_HANDLER
USE MODE_MSG
!
USE MODI_INI_BALLOON
USE MODI_INI_AIRCRAFT
!
IMPLICIT NONE
!
!*      0.1  declarations of arguments
!
TYPE(TFILEDATA),    INTENT(IN) :: TPINIFILE !Initial file
REAL,               INTENT(IN) :: PTSTEP  ! time step
TYPE(DATE_TIME),    INTENT(IN) :: TPDTSEG ! segment date and time
REAL,               INTENT(IN) :: PSEGLEN ! segment length
INTEGER,            INTENT(IN) :: KRR     ! number of moist variables
INTEGER,            INTENT(IN) :: KSV     ! number of scalar variables
INTEGER,            INTENT(IN) :: KKU     ! number of vertical levels 
LOGICAL,            INTENT(IN) :: OUSETKE ! flag to use tke
REAL,               INTENT(IN) :: PLATOR  ! latitude of origine point
REAL,               INTENT(IN) :: PLONOR  ! longitude of origine point
!
!-------------------------------------------------------------------------------
!
!       0.2  declaration of local variables
!
INTEGER :: IMI    ! current model index
INTEGER :: ISTORE ! number of storage instants
INTEGER :: ILUOUT ! logical unit
INTEGER :: IRESP  ! return code
INTEGER :: JI
INTEGER :: JSEG   ! loop counter
TYPE(TFIELDMETADATA) :: TZFIELD
!
!----------------------------------------------------------------------------
!
IMI=GET_CURRENT_MODEL_INDEX()
ILUOUT = TLUOUT%NLU
!----------------------------------------------------------------------------
!
!*      1.   Default values
!            --------------
!
IF ( CPROGRAM == 'DIAG  ') THEN
  IF ( .NOT. LAIRCRAFT_BALLOON ) RETURN
  IF (NTIME_AIRCRAFT_BALLOON == NUNDEF .OR. XSTEP_AIRCRAFT_BALLOON == XUNDEF) THEN
    WRITE(ILUOUT,*) "NTIME_AIRCRAFT_BALLOON and/or  XSTEP_AIRCRAFT_BALLOON not initialized in DIAG "
    WRITE(ILUOUT,*) "No calculations for Balloons and Aircraft"
    LAIRCRAFT_BALLOON=.FALSE.
    RETURN
  ENDIF
ENDIF
!
!
IF ( IMI == 1 ) THEN
  LFLYER=.FALSE.
END IF
!
!----------------------------------------------------------------------------
!
!*      2.   Balloon initialization
!            ----------------------
IF (IMI == 1) CALL INI_BALLOON
!
DO JI = 1, NBALLOONS
  CALL INI_LAUNCH( JI, TBALLOONS(JI) )
END DO
!
!----------------------------------------------------------------------------
!
!*      3.   Aircraft initialization
!            -----------------------
!
IF (IMI == 1) CALL INI_AIRCRAFT
!
DO JI = 1, NAIRCRAFTS
  CALL INI_FLIGHT( JI, TAIRCRAFTS(JI) )
END DO
!
!----------------------------------------------------------------------------
!
!*      4.   Allocations of storage arrays
!            -----------------------------
!
IF (.NOT. LFLYER) RETURN
!
DO JI = 1, NBALLOONS
  CALL ALLOCATE_FLYER( TBALLOONS(JI) )
END DO
!
DO JI = 1, NAIRCRAFTS
  CALL ALLOCATE_FLYER( TAIRCRAFTS(JI) )
END DO
!
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!
CONTAINS
!
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE ALLOCATE_FLYER(TPFLYER)
!
!
CLASS(TFLYERDATA), INTENT(INOUT) :: TPFLYER
!
IF (TPFLYER%NMODEL > NMODEL) TPFLYER%NMODEL=0
IF (IMI /= TPFLYER%NMODEL .AND. .NOT. (IMI==1 .AND. TPFLYER%NMODEL==0) ) RETURN
!
IF ( CPROGRAM == 'DIAG  ' ) THEN
  ISTORE = INT ( NTIME_AIRCRAFT_BALLOON / TPFLYER%TFLYER_TIME%XTSTEP ) + 1
ELSE
  ISTORE = NINT ( ( PSEGLEN - DYN_MODEL(1)%XTSTEP ) / TPFLYER%TFLYER_TIME%XTSTEP ) + 1
ENDIF
!
IF (TPFLYER%NMODEL == 0) ISTORE=0
IF (TPFLYER%NMODEL > 0) THEN
  WRITE(ILUOUT,*) 'Aircraft or Balloon:',TPFLYER%TITLE,' nmodel=',TPFLYER%NMODEL
ENDIF
!
!
allocate( tpflyer%tflyer_time%tpdates(istore) )
ALLOCATE(TPFLYER%X   (ISTORE))
ALLOCATE(TPFLYER%Y   (ISTORE))
ALLOCATE(TPFLYER%Z   (ISTORE))
ALLOCATE(TPFLYER%XLON(ISTORE))
ALLOCATE(TPFLYER%YLAT(ISTORE))
ALLOCATE(TPFLYER%ZON (ISTORE))
ALLOCATE(TPFLYER%MER (ISTORE))
ALLOCATE(TPFLYER%W   (ISTORE))
ALLOCATE(TPFLYER%P   (ISTORE))
ALLOCATE(TPFLYER%TH  (ISTORE))
ALLOCATE(TPFLYER%R   (ISTORE,KRR))
ALLOCATE(TPFLYER%SV  (ISTORE,KSV))
ALLOCATE(TPFLYER%RTZ (ISTORE,KKU))
ALLOCATE(TPFLYER%RZ (ISTORE,KKU,KRR))
ALLOCATE(TPFLYER%FFZ (ISTORE,KKU))
ALLOCATE(TPFLYER%IWCZ (ISTORE,KKU))
ALLOCATE(TPFLYER%LWCZ (ISTORE,KKU))
ALLOCATE(TPFLYER%CIZ (ISTORE,KKU))
IF (CCLOUD=='LIMA') THEN
  ALLOCATE(TPFLYER%CCZ  (ISTORE,KKU))
  ALLOCATE(TPFLYER%CRZ  (ISTORE,KKU))
ENDIF
ALLOCATE(TPFLYER%CRARE(ISTORE,KKU))
ALLOCATE(TPFLYER%CRARE_ATT(ISTORE,KKU))
ALLOCATE(TPFLYER%WZ(ISTORE,KKU))
ALLOCATE(TPFLYER%ZZ(ISTORE,KKU))
IF (OUSETKE) THEN
  ALLOCATE(TPFLYER%TKE (ISTORE))
ELSE
  ALLOCATE(TPFLYER%TKE (0))
END IF
ALLOCATE(TPFLYER%TKE_DISS(ISTORE))
ALLOCATE(TPFLYER%TSRAD (ISTORE))
ALLOCATE(TPFLYER%ZS  (ISTORE))
!
ALLOCATE(TPFLYER%THW_FLUX  (ISTORE))
ALLOCATE(TPFLYER%RCW_FLUX  (ISTORE))
ALLOCATE(TPFLYER%SVW_FLUX  (ISTORE,KSV))
!
TPFLYER%X        = XUNDEF
TPFLYER%Y        = XUNDEF
TPFLYER%Z        = XUNDEF
TPFLYER%XLON     = XUNDEF
TPFLYER%YLAT     = XUNDEF
TPFLYER%ZON      = XUNDEF
TPFLYER%MER      = XUNDEF
TPFLYER%W        = XUNDEF
TPFLYER%P        = XUNDEF
TPFLYER%TH       = XUNDEF
TPFLYER%R        = XUNDEF
TPFLYER%SV       = XUNDEF
TPFLYER%RTZ      = XUNDEF
TPFLYER%RZ       = XUNDEF
TPFLYER%FFZ      = XUNDEF
TPFLYER%CIZ      = XUNDEF
IF (CCLOUD=='LIMA') THEN
  TPFLYER%CRZ      = XUNDEF
  TPFLYER%CCZ      = XUNDEF
ENDIF
TPFLYER%IWCZ     = XUNDEF
TPFLYER%LWCZ     = XUNDEF
TPFLYER%CRARE    = XUNDEF
TPFLYER%CRARE_ATT= XUNDEF
TPFLYER%WZ= XUNDEF
TPFLYER%ZZ= XUNDEF
TPFLYER%TKE      = XUNDEF
TPFLYER%TSRAD    = XUNDEF
TPFLYER%ZS       = XUNDEF
TPFLYER%TKE_DISS = XUNDEF
!
TPFLYER%THW_FLUX        = XUNDEF
TPFLYER%RCW_FLUX        = XUNDEF
TPFLYER%SVW_FLUX        = XUNDEF
END SUBROUTINE ALLOCATE_FLYER
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE INI_LAUNCH(KNBR,TPFLYER)
!
use MODE_IO_FIELD_READ, only: IO_Field_read
!
INTEGER,             INTENT(IN)    :: KNBR
CLASS(TBALLOONDATA), INTENT(INOUT) :: TPFLYER
!
!
!
!*      0.2  declaration of local variables
!
REAL :: ZLAT ! latitude of the balloon
REAL :: ZLON ! longitude of the balloon
!
IF (TPFLYER%MODEL == 'MOB' .AND. TPFLYER%NMODEL /= 0) TPFLYER%NMODEL=1
IF (TPFLYER%NMODEL > NMODEL) TPFLYER%NMODEL=0
IF ( IMI /= TPFLYER%NMODEL ) RETURN
!
LFLYER=.TRUE.
!
IF (TPFLYER%TITLE=='          ') THEN
  WRITE(TPFLYER%TITLE,FMT='(A6,I2.2)') TPFLYER%TYPE,KNBR
END IF
!
IF ( CPROGRAM == 'MESONH' .OR. CPROGRAM == 'SPAWN ' .OR. CPROGRAM == 'REAL  ' ) THEN
  ! read the current location in the FM_FILE
  !
  TZFIELD = TFIELDMETADATA(                  &
    CMNHNAME   = TRIM(TPFLYER%TITLE)//'LAT', &
    CSTDNAME   = '',                         &
    CLONGNAME  = TRIM(TPFLYER%TITLE)//'LAT', &
    CUNITS     = 'degree',                   &
    CDIR       = '--',                       &
    CCOMMENT   = '',                         &
    NGRID      = 0,                          &
    NTYPE      = TYPEREAL,                   &
    NDIMS      = 0,                          &
    LTIMEDEP   = .TRUE.                      )
  CALL IO_Field_read(TPINIFILE,TZFIELD,ZLAT,IRESP)
  !
  IF ( IRESP /= 0 ) THEN
    WRITE(ILUOUT,*) "INI_LAUNCH: Initial location take for ",TPFLYER%TITLE
  ELSE
    TZFIELD = TFIELDMETADATA(                  &
      CMNHNAME   = TRIM(TPFLYER%TITLE)//'LON', &
      CSTDNAME   = '',                         &
      CLONGNAME  = TRIM(TPFLYER%TITLE)//'LON', &
      CUNITS     = 'degree',                   &
      CDIR       = '--',                       &
      CCOMMENT   = '',                         &
      NGRID      = 0,                          &
      NTYPE      = TYPEREAL,                   &
      NDIMS      = 0,                          &
      LTIMEDEP   = .TRUE.                      )
    CALL IO_Field_read(TPINIFILE,TZFIELD,ZLON)
    !
    TZFIELD = TFIELDMETADATA(                  &
      CMNHNAME   = TRIM(TPFLYER%TITLE)//'ALT', &
      CSTDNAME   = '',                         &
      CLONGNAME  = TRIM(TPFLYER%TITLE)//'ALT', &
      CUNITS     = 'm',                        &
      CDIR       = '--',                       &
      CCOMMENT   = '',                         &
      NGRID      = 0,                          &
      NTYPE      = TYPEREAL,                   &
      NDIMS      = 0,                          &
      LTIMEDEP   = .TRUE.                      )
    CALL IO_Field_read(TPINIFILE,TZFIELD,TPFLYER%Z_CUR)
    !
    TPFLYER%P_CUR   = XUNDEF
    !
    TZFIELD = TFIELDMETADATA(                      &
      CMNHNAME   = TRIM(TPFLYER%TITLE)//'WASCENT', &
      CSTDNAME   = '',                             &
      CLONGNAME  = TRIM(TPFLYER%TITLE)//'WASCENT', &
      CUNITS     = 'm s-1',                        &
      CDIR       = '--',                           &
      CCOMMENT   = '',                             &
      NGRID      = 0,                              &
      NTYPE      = TYPEREAL,                       &
      NDIMS      = 0,                              &
      LTIMEDEP   = .TRUE.                          )
    CALL IO_Field_read(TPINIFILE,TZFIELD,TPFLYER%WASCENT)
    !
    TZFIELD = TFIELDMETADATA(                  &
      CMNHNAME   = TRIM(TPFLYER%TITLE)//'RHO', &
      CSTDNAME   = '',                         &
      CLONGNAME  = TRIM(TPFLYER%TITLE)//'RHO', &
      CUNITS     = 'kg m-3',                   &
      CDIR       = '--',                       &
      CCOMMENT   = '',                         &
      NGRID      = 0,                          &
      NTYPE      = TYPEREAL,                   &
      NDIMS      = 0,                          &
      LTIMEDEP   = .TRUE.                      )
    CALL IO_Field_read(TPINIFILE,TZFIELD,TPFLYER%RHO)
    !
    CALL SM_XYHAT(PLATOR,PLONOR,&
              ZLAT,ZLON,        &
              TPFLYER%X_CUR, TPFLYER%Y_CUR )
    TPFLYER%FLY = .TRUE.
    WRITE(ILUOUT,*) &
    "INI_LAUNCH: Current location read in FM file for ",TPFLYER%TITLE
    IF (TPFLYER%TYPE== 'CVBALL') THEN
      WRITE(ILUOUT,*) &
       " Lat=",ZLAT," Lon=",ZLON," Alt=",TPFLYER%Z_CUR," Wasc=",TPFLYER%WASCENT
    ELSE IF (TPFLYER%TYPE== 'ISODEN') THEN
      WRITE(ILUOUT,*) &
       " Lat=",ZLAT," Lon=",ZLON," Rho=",TPFLYER%RHO
    END IF
    !
    TPFLYER%TFLYER_TIME%XTSTEP  = MAX ( PTSTEP, TPFLYER%TFLYER_TIME%XTSTEP )
  END IF
  !
ELSE IF (CPROGRAM == 'DIAG  ' ) THEN
  IF ( LAIRCRAFT_BALLOON ) THEN
    ! read the current location in MODD_DIAG_FLAG
    !
    ZLAT=XLAT_BALLOON(KNBR)
    ZLON=XLON_BALLOON(KNBR)
    TPFLYER%Z_CUR=XALT_BALLOON(KNBR)
    IF (TPFLYER%Z_CUR /= XUNDEF .AND. ZLAT /= XUNDEF .AND. ZLON /= XUNDEF ) THEN
      CALL SM_XYHAT(PLATOR,PLONOR,       &
              ZLAT,ZLON,        &
              TPFLYER%X_CUR, TPFLYER%Y_CUR )
      TPFLYER%FLY = .TRUE.
      WRITE(ILUOUT,*) &
      "INI_LAUNCH: Current location read in MODD_DIAG_FLAG for ",TPFLYER%TITLE
      WRITE(ILUOUT,*) &
            " Lat=",ZLAT," Lon=",ZLON," Alt=",TPFLYER%Z_CUR
    END IF
    !
    TPFLYER%TFLYER_TIME%XTSTEP  = MAX (XSTEP_AIRCRAFT_BALLOON , TPFLYER%TFLYER_TIME%XTSTEP )
  END IF
END IF
!
IF (TPFLYER%LAT==XUNDEF .OR.TPFLYER%LON==XUNDEF) THEN
  WRITE(ILUOUT,*) 'Error in balloon initial position (balloon number ',KNBR,' )'
  WRITE(ILUOUT,*) 'either LATitude or LONgitude is not given'
  WRITE(ILUOUT,*) 'TPBALLOON%LAT=',TPFLYER%LAT
  WRITE(ILUOUT,*) 'TPBALLOON%LON=',TPFLYER%LON
  WRITE(ILUOUT,*) 'Check your INI_BALLOON routine'
!callabortstop
  CALL PRINT_MSG(NVERB_FATAL,'GEN','INI_AIRCRAFT_BALLOON','')
END IF
!
CALL SM_XYHAT(PLATOR,PLONOR,       &
              TPFLYER%LAT, TPFLYER%LON,        &
              TPFLYER%XLAUNCH, TPFLYER%YLAUNCH )
!
END SUBROUTINE INI_LAUNCH
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE INI_FLIGHT(KNBR,TPFLYER)
!
INTEGER,              INTENT(IN)    :: KNBR
CLASS(TAIRCRAFTDATA), INTENT(INOUT) :: TPFLYER
!
IF (TPFLYER%MODEL == 'MOB' .AND. TPFLYER%NMODEL /= 0) TPFLYER%NMODEL=1
IF (TPFLYER%NMODEL > NMODEL) TPFLYER%NMODEL=0
IF ( IMI /= TPFLYER%NMODEL ) RETURN
!
LFLYER=.TRUE.
!
TPFLYER%TFLYER_TIME%XTSTEP  = MAX ( PTSTEP, TPFLYER%TFLYER_TIME%XTSTEP )
!
IF (TPFLYER%SEG==0) THEN
  WRITE(ILUOUT,*) 'Error in aircraft flight path (aircraft number ',KNBR,' )'
  WRITE(ILUOUT,*) 'There is ZERO flight segment defined.'
  WRITE(ILUOUT,*) 'TPAIRCRAFT%SEG=',TPFLYER%SEG
  WRITE(ILUOUT,*) 'Check your INI_AIRCRAFT routine'
!callabortstop
  CALL PRINT_MSG(NVERB_FATAL,'GEN','INI_FLIGHT','')
END IF
!
IF ( ANY(TPFLYER%SEGLAT(:)==XUNDEF) .OR. ANY(TPFLYER%SEGLON(:)==XUNDEF) ) THEN
  WRITE(ILUOUT,*) 'Error in aircraft flight path (aircraft number ',KNBR,' )'
  WRITE(ILUOUT,*) 'either LATitude or LONgitude segment'
  WRITE(ILUOUT,*) 'definiton is not complete.'
  WRITE(ILUOUT,*) 'TPAIRCRAFT%SEGLAT=',TPFLYER%SEGLAT
  WRITE(ILUOUT,*) 'TPAIRCRAFT%SEGLON=',TPFLYER%SEGLON
  WRITE(ILUOUT,*) 'Check your INI_AIRCRAFT routine'
!callabortstop
  CALL PRINT_MSG(NVERB_FATAL,'GEN','INI_AIRCRAFT_BALLOON','')
END IF
!
ALLOCATE(TPFLYER%SEGX(TPFLYER%SEG+1))
ALLOCATE(TPFLYER%SEGY(TPFLYER%SEG+1))
!
DO JSEG=1,TPFLYER%SEG+1
  CALL SM_XYHAT(PLATOR,PLONOR,                              &
                TPFLYER%SEGLAT(JSEG), TPFLYER%SEGLON(JSEG), &
                TPFLYER%SEGX(JSEG),   TPFLYER%SEGY(JSEG)    )
END DO
!
IF ( ANY(TPFLYER%SEGTIME(:)==XUNDEF) ) THEN
  WRITE(ILUOUT,*) 'Error in aircraft flight path (aircraft number ',KNBR,' )'
  WRITE(ILUOUT,*) 'definiton of segment duration is not complete.'
  WRITE(ILUOUT,*) 'TPAIRCRAFT%SEGTIME=',TPFLYER%SEGTIME
  WRITE(ILUOUT,*) 'Check your INI_AIRCRAFT routine'
!callabortstop
  CALL PRINT_MSG(NVERB_FATAL,'GEN','INI_AIRCRAFT_BALLOON','')
END IF
!
!
IF (TPFLYER%TITLE=='          ') THEN
  WRITE(TPFLYER%TITLE,FMT='(A6,I2.2)') TPFLYER%TYPE,KNBR
END IF
!
END SUBROUTINE INI_FLIGHT
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
!
END SUBROUTINE INI_AIRCRAFT_BALLOON

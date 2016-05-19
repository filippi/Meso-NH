!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$ $Date$
!-----------------------------------------------------------------
!     ##########################
      MODULE MODI_OPEN_PRC_FILES
!     ##########################
!
INTERFACE
      SUBROUTINE OPEN_PRC_FILES(HPRE_REAL1,HATMFILE,HATMFILETYPE           &
                                          ,HCHEMFILE,HCHEMFILETYPE         &
                                          ,HSURFFILE,HSURFFILETYPE,HPGDFILE)
!
CHARACTER(LEN=28), INTENT(OUT) :: HPRE_REAL1   ! name of the PRE_REAL1 file
CHARACTER(LEN=28), INTENT(OUT) :: HATMFILE     ! name of the input atmospheric file
CHARACTER(LEN=6),  INTENT(OUT) :: HATMFILETYPE ! type of the input atmospheric file
CHARACTER(LEN=28), INTENT(OUT) :: HCHEMFILE    ! name of the input chemical file
CHARACTER(LEN=6),  INTENT(OUT) :: HCHEMFILETYPE! type of the input chemical file
CHARACTER(LEN=28), INTENT(OUT) :: HSURFFILE    ! name of the input surface file
CHARACTER(LEN=6),  INTENT(OUT) :: HSURFFILETYPE! type of the input surface file
CHARACTER(LEN=28), INTENT(OUT) :: HPGDFILE     ! name of the physiographic data file
END SUBROUTINE OPEN_PRC_FILES
END INTERFACE
END MODULE MODI_OPEN_PRC_FILES
!
!     ######################################################################
      SUBROUTINE OPEN_PRC_FILES(HPRE_REAL1,HATMFILE,HATMFILETYPE           &
                                          ,HCHEMFILE,HCHEMFILETYPE         &
                                          ,HSURFFILE,HSURFFILETYPE,HPGDFILE)
!     ######################################################################
!
!!****  *OPEN_PRC_FILES* - openning of the files used in PREP_REAL_CASE
!!
!!
!!    PURPOSE
!!    -------
!!
!!    This routine set the default name of CLUOUT0
!!    This routine read in 'PRE_REAL1.nam' the names of the files used in
!!    PREP_REAL_CASE: Aladin or Mesonh input file, physiographic data file,
!!    output listing file and MESO-NH output file.
!!    This routine opens these files (except the Aladin file) and reads the
!!    control variable of verbosity level NVERB.
!!
!!**  METHOD
!!    ------
!!
!!    CAUTION:
!!    This routine supposes the name of the namelist file is 'PRE_REAL1.nam'.
!!
!!    EXTERNAL
!!    --------
!!
!!    Routine FMATTR
!!    Routine FMOPEN
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!      Module MODD_CONF      : contains configuration variables for all models.
!!         NVERB    : verbosity level for output-listing
!!      Module MODD_LUNIT     :  contains logical unit names for all models
!!         CLUOUT0  : name of output-listing
!!      Module MODD_LUNIT1    :
!!         CINIFILE : name of MESO-NH file
!!
!!    REFERENCE
!!    ---------
!!
!!      Book 2
!!
!!    AUTHOR
!!    ------
!!
!!      V.Masson  Meteo-France
!!
!!    MODIFICATIONS
!!    -------------
!!      Original     31/12/94
!!      Modification 31/01/96 Possibility to initialize the atmospheric fields
!!                            with a FM file (V. Masson)
!!      Modification 01/08/97 opening of CINIFILE at the end of PREP_REAL_CASE
!!                            (V. Masson)
!!      Modification 15/10/01 allow namelists in different orders (I. Mallet)
!!      J.ESCOBAR    12/11/2008  Improve checking --> add STATUS=OLD in open_ll(PRE_REAL1.nam,...
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_CONF  ! declaration modules
USE MODD_CONF_n
!JUAN Z_SPLITTING
USE MODD_CONFZ
!JUAN Z_SPLITTING
USE MODD_LUNIT
USE MODD_LUNIT_n, CINIFILE_n=>CINIFILE , CINIFILEPGD_n=>CINIFILEPGD
!
!JUAN Z_SPLITTING
USE MODN_CONFZ
!JUAN Z_SPLITTING
!
USE MODE_POS
USE MODE_FM
USE MODE_IO_ll
!
IMPLICIT NONE
!
!*       0.1   Declaration of arguments
!              ------------------------
!
CHARACTER(LEN=28), INTENT(OUT) :: HPRE_REAL1   ! name of the PRE_REAL1 file
CHARACTER(LEN=28), INTENT(OUT) :: HATMFILE     ! name of the input atmospheric file
CHARACTER(LEN=6),  INTENT(OUT) :: HATMFILETYPE ! type of the input atmospheric file
CHARACTER(LEN=28), INTENT(OUT) :: HCHEMFILE    ! name of the input chemical file
CHARACTER(LEN=6),  INTENT(OUT) :: HCHEMFILETYPE! type of the input chemical file
CHARACTER(LEN=28), INTENT(OUT) :: HSURFFILE    ! name of the input surface file
CHARACTER(LEN=6),  INTENT(OUT) :: HSURFFILETYPE! type of the input surface file
CHARACTER(LEN=28), INTENT(OUT) :: HPGDFILE     ! name of the physiographic data file
!
!*       0.2   Declaration of local variables
!              ------------------------------
!
INTEGER :: IRESP      ! return-code if problems eraised
INTEGER :: IPRE_REAL1 ! logical unit for file HPRE_REAL1
INTEGER :: ILUOUT0    ! logical unit for listing file
INTEGER :: ININAR     ! number of articles initially present in a FM file
LOGICAL :: GFOUND     ! Return code when searching namelist
INTEGER :: ILEN
CHARACTER(LEN=28) :: YFILE
!
CHARACTER(LEN=28) :: CINIFILE ! re-declaration of this model variable for namelist
!
!*       0.3   Declaration of namelists
!              ------------------------
!
NAMELIST/NAM_FILE_NAMES/ HATMFILE,HATMFILETYPE,HCHEMFILE,HCHEMFILETYPE, &
                         HSURFFILE,HSURFFILETYPE,HPGDFILE,CINIFILE
!-------------------------------------------------------------------------------
!
!*       1.    SET DEFAULT NAMES
!              -----------------
!
HATMFILE='                            '
HATMFILETYPE='MESONH'
HCHEMFILE='                            '
HCHEMFILETYPE='MESONH'
HSURFFILE='                            '
HSURFFILETYPE='MESONH'
HPRE_REAL1='PRE_REAL1.nam               '
CLUOUT0   ='OUTPUT_LISTING0             '
CLUOUT = CLUOUT0
!
!-------------------------------------------------------------------------------
!
!*       2.    OPENNING OF THE OUTPUT LISTING FILE
!              -----------------------------------
!
CALL OPEN_ll(UNIT=ILUOUT0,FILE=CLUOUT0,IOSTAT=IRESP,FORM='FORMATTED',ACTION='WRITE', &
     MODE=GLOBAL)
!
IF (NVERB>=5) WRITE(ILUOUT0,*) 'Routine OPEN_PRC_FILES started'
!-------------------------------------------------------------------------------
!
!*       3.    OPENNING OF PRE_REAL1.nam
!              -------------------------
!
CALL OPEN_ll(UNIT=IPRE_REAL1,FILE=HPRE_REAL1,IOSTAT=IRESP,ACTION='READ', &
     DELIM='QUOTE',MODE=GLOBAL,STATUS='OLD')
IF (IRESP.NE.0 ) THEN
   PRINT "(' STOP :: Routine OPEN_PRC_FILES :: IRESP=',I6,' --> file PRE_REAL1.nam not found ')", IRESP
   !callabortstop
   CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
   CALL ABORT
   STOP
ENDIF
!
!-------------------------------------------------------------------------------
!
!*       4.    READING THE OTHER FILE NAMES
!              ----------------------------
!
!JUANZ
CALL POSNAM(IPRE_REAL1,'NAM_CONFZ',GFOUND,ILUOUT0)
IF (GFOUND) READ(UNIT=IPRE_REAL1,NML=NAM_CONFZ)
!JUANZ

CINIFILE = CINIFILE_n
CALL POSNAM(IPRE_REAL1,'NAM_FILE_NAMES',GFOUND,ILUOUT0)
IF (GFOUND) READ(UNIT=IPRE_REAL1,NML=NAM_FILE_NAMES)
CINIFILE_n = CINIFILE
!
ILEN = LEN_TRIM(HATMFILE)
IF (ILEN>0) THEN
  YFILE='                            '
  YFILE(1:ILEN) = HATMFILE(1:ILEN)
  HATMFILE = '                            '
  HATMFILE(1:ILEN) = YFILE(1:ILEN)
END IF
WRITE(ILUOUT0,*) 'HATMFILE= ', HATMFILE
!
ILEN = LEN_TRIM(HCHEMFILE)
IF (ILEN>0) THEN
  YFILE='                            '
  YFILE(1:ILEN) = HCHEMFILE(1:ILEN)
  HCHEMFILE = '                            '
  HCHEMFILE(1:ILEN) = YFILE(1:ILEN)
  IF (HCHEMFILE==HATMFILE) HCHEMFILE=''
END IF
IF (LEN_TRIM(HCHEMFILE)>0 .AND. HATMFILETYPE/='GRIBEX') THEN
  WRITE(ILUOUT0,*) 'Additional CHEMical file is only possible when ATMospheric file is of GRIBEX type'
!callabortstop
  CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
  CALL ABORT
  STOP
END IF
WRITE(ILUOUT0,*) 'HCHEMFILE=', HCHEMFILE
!
ILEN = LEN_TRIM(HSURFFILE)
IF (ILEN>0) THEN
  YFILE='                            '
  YFILE(1:ILEN) = HSURFFILE(1:ILEN)
  HSURFFILE = '                            '
  HSURFFILE(1:ILEN) = YFILE(1:ILEN)
ELSE
  HSURFFILE = HATMFILE
  HSURFFILETYPE = HATMFILETYPE
END IF
WRITE(ILUOUT0,*) 'HSURFFILE=', HSURFFILE
!
ILEN = LEN_TRIM(HPGDFILE)
IF (ILEN>0) THEN
  YFILE='                            '
  YFILE(1:ILEN) = HPGDFILE(1:ILEN)
  HPGDFILE = '                            '
  HPGDFILE(1:ILEN) = YFILE(1:ILEN)
END IF
!
CINIFILEPGD_n = HPGDFILE
IF (LEN_TRIM(HPGDFILE)==0) THEN
!  IF (HATMFILETYPE=='MESONH') THEN
!    HPGDFILE = HATMFILE
!    WRITE(ILUOUT0,*) 'HPGDFILE set to ', HPGDFILE
!  ELSE
    WRITE(ILUOUT0,*) 'You need the HPGDFILE file when starting from a large-scale file'
    CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
    CALL ABORT
    STOP
!  END IF
ELSE
!-------------------------------------------------------------------------------
!
!*       5.    OPENNING THE PHYSIOGRAPHIC DATA FILE
!              ------------------------------------
!
  CALL FMOPEN_ll(HPGDFILE,'READ',CLUOUT0,0,2,NVERB,ININAR,IRESP)
  IF (IRESP/=0) THEN
    WRITE(ILUOUT0,*) 'STOP: problem during opening of PGD file ',HPGDFILE
!callabortstop
    CALL CLOSE_ll(CLUOUT0,IOSTAT=IRESP)
    CALL ABORT
    STOP
  END IF
END IF
!
WRITE(ILUOUT0,*) 'HPGDFILE= ', HPGDFILE
!-------------------------------------------------------------------------------
!
!*       6.    INPUT ATMOSPHERIC FILE
!              ----------------------
!
!*       6.1   ATTRIBUTION OF LOGICAL UNITS TO ALADIN FILES
!              --------------------------------------------
!
!  because of new parallel IO, FMATTR must be called just before opening the Aladin file
!
!*       6.2   OPENNING INPUT MESONH FILE
!              --------------------------
!
!  done during INIT
!
!-------------------------------------------------------------------------------
!
WRITE(ILUOUT0,*) 'Routine OPEN_PRC_FILES completed'
!
END SUBROUTINE OPEN_PRC_FILES

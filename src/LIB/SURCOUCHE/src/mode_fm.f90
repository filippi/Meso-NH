!MNH_LIC Copyright 1994-2018 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Modifications:
!  D.Gazen   : avril 2016 change error message
!  P. Wautelet : may 2016: use NetCDF Fortran module
!  Philippe Wautelet: 05/2016-04/2018: new data structures and calls for I/O
!-----------------------------------------------------------------

MODULE MODE_FM
USE MODD_ERRCODES
USE MODD_MPIF

USE MODE_MSG

IMPLICIT NONE 

PRIVATE 

PUBLIC SET_FMPACK_ll
PUBLIC IO_FILE_OPEN_ll, IO_FILE_CLOSE_ll

CONTAINS 

SUBROUTINE SET_FMPACK_ll(O1D,O2D,OPACK)
USE MODD_IO_ll, ONLY : LPACK,L1D,L2D
!JUAN
USE MODD_VAR_ll, ONLY : IP
!JUAN

IMPLICIT NONE 

LOGICAL, INTENT(IN) :: O1D,O2D,OPACK

LPACK = OPACK
L1D   = O1D
L2D   = O2D

IF ( IP .EQ. 1 ) PRINT *,'INIT L1D,L2D,LPACK = ',L1D,L2D,LPACK

END SUBROUTINE SET_FMPACK_ll

SUBROUTINE IO_FILE_OPEN_ll(TPFILE,KRESP,OPARALLELIO,HPOSITION,HSTATUS,HPROGRAM_ORIG)
!
USE MODD_CONF,  ONLY: CPROGRAM, NMNHVERSION
USE MODD_IO_ll, ONLY: TFILEDATA
USE MODE_FIELD, ONLY: TFIELDDATA,TYPEINT
USE MODE_FMREAD
USE MODE_IO_ll, ONLY : OPEN_ll
USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_ADD2LIST,IO_FILE_FIND_BYNAME
!
TYPE(TFILEDATA),POINTER,INTENT(INOUT)         :: TPFILE ! File structure
INTEGER,                INTENT(OUT), OPTIONAL :: KRESP  ! Return code
LOGICAL,                INTENT(IN),  OPTIONAL :: OPARALLELIO
CHARACTER(LEN=*),       INTENT(IN),  OPTIONAL :: HPOSITION
CHARACTER(LEN=*),       INTENT(IN),  OPTIONAL :: HSTATUS
CHARACTER(LEN=*),       INTENT(IN),  OPTIONAL :: HPROGRAM_ORIG !To emulate a file coming from this program
!
INTEGER :: IRESP,IRESP2
INTEGER :: IMASDEV,IBUGFIX
INTEGER,DIMENSION(3)    :: IMNHVERSION
CHARACTER(LEN=12)       :: YMNHVERSION_FILE,YMNHVERSION_CURR
TYPE(TFIELDDATA)        :: TZFIELD
TYPE(TFILEDATA),POINTER :: TZFILE_DES
TYPE(TFILEDATA),POINTER :: TZFILE_DUMMY
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_OPEN_ll','opening '//TRIM(TPFILE%CNAME)//' for '//TRIM(TPFILE%CMODE)// &
               ' (filetype='//TRIM(TPFILE%CTYPE)//')')
!
IF (.NOT.ASSOCIATED(TPFILE)) CALL PRINT_MSG(NVERB_FATAL,'IO','IO_FILE_OPEN_ll','TPFILE is not associated')
!
TZFILE_DES   => NULL()
TZFILE_DUMMY => NULL()
!
TPFILE%NOPEN         = TPFILE%NOPEN + 1
TPFILE%NOPEN_CURRENT = TPFILE%NOPEN_CURRENT + 1
!
IF (TPFILE%LOPENED) THEN
  CALL PRINT_MSG(NVERB_INFO,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//' is already in open state')
  RETURN
END IF
!
TPFILE%LOPENED       = .TRUE.
!
!Check if file is in filelist
CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME),TZFILE_DUMMY,IRESP)
IF (IRESP/=0) CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//' not in filelist')
!
SELECT CASE(TPFILE%CTYPE)
  !Chemistry input files
  CASE('CHEMINPUT')
    CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',POSITION='REWIND',STATUS='OLD',MODE='GLOBAL')


  !Chemistry tabulation files
  CASE('CHEMTAB')
    CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',MODE='GLOBAL')


  !GPS files
  CASE('GPS')
    CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',MODE='SPECIFIC')


  !Meteo files
  CASE('METEO')
   CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='UNFORMATTED',MODE='GLOBAL',RECL=100000000)


  !Namelist files
  CASE('NML')
    CALL OPEN_ll(TPFILE,IOSTAT=IRESP,DELIM='QUOTE',MODE='GLOBAL')


  !OUTPUTLISTING files
  CASE('OUTPUTLISTING')
    CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',MODE='GLOBAL')


  !SURFACE_DATA files
  CASE('SURFACE_DATA')
    IF (TPFILE%CFORM=='FORMATTED') THEN
      CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM=TPFILE%CFORM,MODE='GLOBAL')
    ELSE IF (TPFILE%CACCESS=='DIRECT') THEN
      CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM=TPFILE%CFORM,ACCESS=TPFILE%CACCESS,RECL=TPFILE%NRECL,MODE='GLOBAL')
    ELSE
      CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM=TPFILE%CFORM,MODE='GLOBAL')
    END IF


  !Text files
  CASE('TXT')
    IF(TPFILE%NRECL>0) THEN
      CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',POSITION=HPOSITION,STATUS=HSTATUS,RECL=TPFILE%NRECL,MODE='GLOBAL')
    ELSE
      CALL OPEN_ll(TPFILE,IOSTAT=IRESP,FORM='FORMATTED',POSITION=HPOSITION,STATUS=HSTATUS,MODE='GLOBAL')
    END IF


  CASE DEFAULT
    !Do not open '.des' file if OUTPUT
    IF(TPFILE%CTYPE/='OUTPUT' .AND. CPROGRAM/='LFICDF') THEN
      CALL IO_FILE_ADD2LIST(TZFILE_DES,TRIM(TPFILE%CNAME)//'.des','DES',TPFILE%CMODE,TPDATAFILE=TPFILE,OOLD=.TRUE.) !OOLD=T because the file may already be in the list
      CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_OPEN_ll','OPEN_ll for '//TRIM(TPFILE%CNAME)//'.des')
      CALL OPEN_ll(TZFILE_DES,FORM='FORMATTED',DELIM='QUOTE',IOSTAT=IRESP,RECL=1024*8,OPARALLELIO=OPARALLELIO)
      TZFILE_DES%LOPENED       = .TRUE.
      TZFILE_DES%NOPEN_CURRENT = TZFILE_DES%NOPEN_CURRENT + 1
      TZFILE_DES%NOPEN         = TZFILE_DES%NOPEN + 1
    ENDIF
    !
    CALL FMOPEN_ll(TPFILE,IRESP,OPARALLELIO=OPARALLELIO,HPROGRAM_ORIG=HPROGRAM_ORIG)
    !
    !Compare MNHVERSION of file with current version
    IF (TRIM(TPFILE%CMODE) == 'READ') THEN
      IMNHVERSION(:) = 0
      !Use TZFIELD because TFIELDLIST could be not initialised
      TZFIELD%CMNHNAME   = 'MNHVERSION'
      TZFIELD%CSTDNAME   = ''
      TZFIELD%CLONGNAME  = 'MesoNH version'
      TZFIELD%CUNITS     = ''
      TZFIELD%CDIR       = '--'
      TZFIELD%CCOMMENT   = ''
      TZFIELD%NGRID      = 0
      TZFIELD%NTYPE      = TYPEINT
      TZFIELD%NDIMS      = 1
      TZFIELD%LTIMEDEP   = .FALSE.
      CALL IO_READ_FIELD(TPFILE,TZFIELD,IMNHVERSION,IRESP2)
      IF (IRESP2/=0) THEN
        TZFIELD%CMNHNAME   = 'MASDEV'
        TZFIELD%CLONGNAME  = 'MesoNH version (without bugfix)'
        TZFIELD%NDIMS      = 0
        CALL IO_READ_FIELD(TPFILE,TZFIELD,IMASDEV,IRESP2)
        IF (IRESP2/=0) THEN
          CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_OPEN_ll','unknown MASDEV version for '//TRIM(TPFILE%CNAME))
        ELSE
          IMNHVERSION(1)=IMASDEV/10
          IMNHVERSION(2)=MOD(IMASDEV,10)
        END IF
        !
        TZFIELD%CMNHNAME   = 'BUGFIX'
        TZFIELD%CLONGNAME  = 'MesoNH bugfix number'
        CALL IO_READ_FIELD(TPFILE,TZFIELD,IBUGFIX,IRESP2)
        IF (IRESP2/=0) THEN
          CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_OPEN_ll','unknown BUGFIX version for '//TRIM(TPFILE%CNAME))
        ELSE
          IMNHVERSION(3)=IBUGFIX
        END IF
      END IF
      !
      WRITE(YMNHVERSION_FILE,"( I0,'.',I0,'.',I0 )" ) IMNHVERSION(1),IMNHVERSION(2),IMNHVERSION(3)
      WRITE(YMNHVERSION_CURR,"( I0,'.',I0,'.',I0 )" ) NMNHVERSION(1),NMNHVERSION(2),NMNHVERSION(3)
      !
      IF ( IMNHVERSION(1)==0 .AND. IMNHVERSION(2)==0 .AND. IMNHVERSION(3)==0 ) THEN
        CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//&
                      ' was written with an unknown version of MesoNH')
      ELSE IF (  IMNHVERSION(1)< NMNHVERSION(1) .OR. &
                (IMNHVERSION(1)==NMNHVERSION(1) .AND. IMNHVERSION(2)< NMNHVERSION(2)) .OR. &
                (IMNHVERSION(1)==NMNHVERSION(1) .AND. IMNHVERSION(2)==NMNHVERSION(2) .AND. IMNHVERSION(3)<NMNHVERSION(3)) ) THEN
        CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//&
                      ' was written with an older version of MesoNH ('//TRIM(YMNHVERSION_FILE)//&
                      ' instead of '//TRIM(YMNHVERSION_CURR)//')')
      ELSE IF (  IMNHVERSION(1)> NMNHVERSION(1) .OR. &
                (IMNHVERSION(1)==NMNHVERSION(1) .AND. IMNHVERSION(2)> NMNHVERSION(2)) .OR. &
                (IMNHVERSION(1)==NMNHVERSION(1) .AND. IMNHVERSION(2)==NMNHVERSION(2) .AND. IMNHVERSION(3)>NMNHVERSION(3)) ) THEN
        CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//&
                      ' was written with a more recent version of MesoNH ('//TRIM(YMNHVERSION_FILE)//&
                      ' instead of '//TRIM(YMNHVERSION_CURR)//')')
      ELSE
        CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//&
                      ' was written with the same version of MesoNH ('//TRIM(YMNHVERSION_CURR)//')')
      END IF
    END IF
END SELECT
!
IF (PRESENT(KRESP)) KRESP = IRESP
!
END SUBROUTINE IO_FILE_OPEN_ll

SUBROUTINE FMOPEN_ll(TPFILE,KRESP,OPARALLELIO,HPROGRAM_ORIG)
USE MODD_IO_ll, ONLY : ISTDOUT,TFILEDATA
USE MODE_IO_ll, ONLY : OPEN_ll,GCONFIO
!JUANZ
USE MODD_CONFZ,ONLY  : NB_PROCIO_R,NB_PROCIO_W
!JUANZ
#if defined(MNH_IOCDF4)
USE MODD_NETCDF, ONLY:IDCDF_KIND
USE MODE_NETCDF
#endif
TYPE(TFILEDATA), INTENT(INOUT) :: TPFILE ! File structure
INTEGER,         INTENT(OUT)   :: KRESP  ! return-code
LOGICAL,         INTENT(IN),  OPTIONAL :: OPARALLELIO
CHARACTER(LEN=*),INTENT(IN),  OPTIONAL :: HPROGRAM_ORIG !To emulate a file coming from this program
!
!   Local variables
!
INTEGER                 :: IFTYPE  ! type of FM-file
INTEGER                 :: IROWF,IRESP
CHARACTER(LEN=7)        :: YACTION ! Action upon the file ('READ' or 'WRITE')
CHARACTER(LEN=:),ALLOCATABLE :: YFILEM  ! name of the file
CHARACTER(LEN=8)        :: YRESP
LOGICAL                 :: GSTATS
LOGICAL :: GNAMFI,GFATER,GNEWFI
INTEGER :: IERR
!JUAN
INTEGER(KIND=LFI_INT) :: IRESOU,INUMBR8
INTEGER(KIND=LFI_INT) :: IMELEV,INPRAR
INTEGER(KIND=LFI_INT) :: ININAR ! Number of articles present in LFI file
LOGICAL               :: GNAMFI8,GFATER8,GSTATS8
INTEGER               :: INB_PROCIO
!JUAN
LOGICAL               :: GPARALLELIO
#if defined(MNH_IOCDF4)
INTEGER(KIND=IDCDF_KIND) :: INCERR
#endif

YACTION = TPFILE%CMODE

CALL PRINT_MSG(NVERB_DEBUG,'IO','FMOPEN_ll','opening '//TRIM(TPFILE%CNAME)//' for '//TRIM(YACTION))

IF (ALLOCATED(TPFILE%CDIRNAME)) THEN
  IF(LEN_TRIM(TPFILE%CDIRNAME)>0) THEN
    YFILEM = TRIM(TPFILE%CDIRNAME)//'/'//TRIM(TPFILE%CNAME)
  ELSE
    YFILEM = TRIM(TPFILE%CNAME)
  END IF
ELSE
  YFILEM = TRIM(TPFILE%CNAME)
END IF

IF ( PRESENT(OPARALLELIO) ) THEN
  GPARALLELIO = OPARALLELIO
ELSE  !par defaut on active les IO paralleles en Z si possible
  GPARALLELIO = .TRUE.
ENDIF

IF (.NOT. GCONFIO) THEN
   PRINT *, 'FMOPEN_ll Aborting... Please, ensure to call SET_CONFIO_ll before &
        &the first FMOPEN_ll call.'
   STOP
END IF

ININAR = 0
INPRAR = TPFILE%NLFINPRAR
IROWF  = 0
IRESP  = 0

SELECT CASE (TPFILE%NLFIVERB)
CASE(:2)
  GSTATS = .FALSE.
  IMELEV=0
CASE(3:6)
  GSTATS = .FALSE.
  IMELEV=1
CASE(7:9)
  GSTATS = .FALSE.
  IMELEV=2
CASE(10:)
  GSTATS = .TRUE.
  IMELEV=2
END SELECT

IROWF=LEN_TRIM(TPFILE%CNAME)

IF (IROWF.EQ.0) THEN
  IRESP=-45
  GOTO 1000
ENDIF

 SELECT CASE (YACTION)
 CASE('READ')
    INB_PROCIO = NB_PROCIO_R
 CASE('WRITE')
    INB_PROCIO = NB_PROCIO_W
 END SELECT
CALL OPEN_ll(TPFILE,STATUS="UNKNOWN",MODE='IO_ZSPLIT',IOSTAT=IRESP,     &
             KNB_PROCIO=INB_PROCIO,KMELEV=IMELEV,OPARALLELIO=GPARALLELIO,HPROGRAM_ORIG=HPROGRAM_ORIG)

IF (IRESP /= 0) GOTO 1000

IF (TPFILE%LMASTER) THEN
  ! Proc I/O case
#if defined(MNH_IOCDF4)
  IF (TPFILE%CFORMAT=='NETCDF4' .OR. TPFILE%CFORMAT=='LFICDF4') THEN
     IF (YACTION == 'READ') THEN
        !! Open NetCDF File for reading
        TPFILE%TNCDIMS => NEWIOCDF()
        CALL PRINT_MSG(NVERB_DEBUG,'IO','FMOPEN_ll','NF90_OPEN for '//TRIM(YFILEM)//'.nc')
        INCERR = NF90_OPEN(ADJUSTL(TRIM(YFILEM))//".nc", NF90_NOWRITE, TPFILE%NNCID)
        IF (INCERR /= NF90_NOERR) THEN
          CALL PRINT_MSG(NVERB_FATAL,'IO','FMOPEN_ll','NF90_OPEN for '//TRIM(YFILEM)//'.nc: '//NF90_STRERROR(INCERR))
        END IF
        INCERR = NF90_INQUIRE(TPFILE%NNCID,NVARIABLES=TPFILE%NNCNAR)
        IF (INCERR /= NF90_NOERR) THEN
          CALL PRINT_MSG(NVERB_FATAL,'IO','FMOPEN_ll','NF90_INQUIRE for '//TRIM(YFILEM)//'.nc: '//NF90_STRERROR(INCERR))
        END IF
     END IF
     
     IF (YACTION == 'WRITE') THEN
        TPFILE%TNCDIMS => NEWIOCDF()
        CALL PRINT_MSG(NVERB_DEBUG,'IO','FMOPEN_ll','NF90_CREATE for '//TRIM(YFILEM)//'.nc')
        INCERR = NF90_CREATE(ADJUSTL(TRIM(YFILEM))//".nc", &
             &IOR(NF90_CLOBBER,NF90_NETCDF4), TPFILE%NNCID)
        IF (INCERR /= NF90_NOERR) THEN
          CALL PRINT_MSG(NVERB_FATAL,'IO','FMOPEN_ll','NF90_CREATE for '//TRIM(YFILEM)//'.nc: '//NF90_STRERROR(INCERR))
        END IF
        CALL IO_SET_KNOWNDIMS_NC4(TPFILE,HPROGRAM_ORIG=HPROGRAM_ORIG)
     END IF
  END IF
#endif
  
  IF (TPFILE%CFORMAT=='LFI' .OR. TPFILE%CFORMAT=='LFICDF4') THEN
     ! LFI Case
     IRESOU = 0
     GNAMFI = .TRUE.
     GFATER = .TRUE.
     !
     INUMBR8 = TPFILE%NLFIFLU
     GNAMFI8 = GNAMFI
     GFATER8 = GFATER
     GSTATS8 = GSTATS
     !
     CALL LFIOUV(IRESOU,     &
          INUMBR8,           &
          GNAMFI8,           &
          TRIM(YFILEM)//'.lfi',  &
          "UNKNOWN",         &
          GFATER8,           &
          GSTATS8,           &
          IMELEV,            &
          INPRAR,            &
          ININAR)
     TPFILE%NLFININAR = ININAR
  IF (IRESOU /= 0 ) THEN
        IRESP = IRESOU
     ENDIF
  END IF

  !
  !*      6.    TEST IF FILE IS NEWLY DEFINED
  !
  
  GNEWFI=(ININAR==0).OR.(IMELEV<2)
  IF (.NOT.GNEWFI) THEN
    WRITE (ISTDOUT,*) ' file ',TRIM(YFILEM)//'.lfi',' previously created with LFI'
  ENDIF
END IF

! Broadcast ERROR
CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TPFILE%NMASTER_RANK-1,TPFILE%NMPICOMM,IERR)
IF (IRESP /= 0) GOTO 1000


1000 CONTINUE

IF (IRESP.NE.0)  THEN
  WRITE(YRESP,"( I0 )") IRESP
  CALL PRINT_MSG(NVERB_ERROR,'IO','FMOPEN_ll',TRIM(YFILEM)//': exit with IRESP='//TRIM(YRESP))
END IF

KRESP=IRESP

END SUBROUTINE FMOPEN_ll
  
SUBROUTINE IO_FILE_CLOSE_ll(TPFILE,KRESP,OPARALLELIO,HPROGRAM_ORIG)
!
USE MODD_CONF,  ONLY: CPROGRAM
USE MODD_IO_ll, ONLY: TFILEDATA
USE MODE_IO_ll, ONLY : CLOSE_ll
USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
!
TYPE(TFILEDATA),  INTENT(INOUT)         :: TPFILE ! File structure
INTEGER,          INTENT(OUT), OPTIONAL :: KRESP  ! Return code
LOGICAL,          INTENT(IN),  OPTIONAL :: OPARALLELIO
CHARACTER(LEN=*), INTENT(IN),  OPTIONAL :: HPROGRAM_ORIG !To emulate a file coming from this program
!
INTEGER                 :: IRESP, JI
TYPE(TFILEDATA),POINTER :: TZFILE_DES
TYPE(TFILEDATA),POINTER :: TZFILE_IOZ
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_CLOSE_ll','closing '//TRIM(TPFILE%CNAME))
!
IF (.NOT.TPFILE%LOPENED) THEN
  CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_CLOSE_ll','trying to close a file not opened: '//TRIM(TPFILE%CNAME))
  RETURN
ENDIF
!
IF (TPFILE%NOPEN_CURRENT>1) THEN
  CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_CLOSE_ll',TRIM(TPFILE%CNAME)// &
                 ': decrementing NOPEN_CURRENT (still opened after this call)')
  TPFILE%NOPEN_CURRENT = TPFILE%NOPEN_CURRENT - 1
  TPFILE%NCLOSE        = TPFILE%NCLOSE        + 1
  !
  DO JI = 1,TPFILE%NSUBFILES_IOZ
    TZFILE_IOZ => TPFILE%TFILES_IOZ(JI)%TFILE
    TZFILE_IOZ%NOPEN_CURRENT = TZFILE_IOZ%NOPEN_CURRENT - 1
    TZFILE_IOZ%NCLOSE        = TZFILE_IOZ%NCLOSE        + 1
  END DO
  !
  RETURN
END IF
!
SELECT CASE(TPFILE%CTYPE)
  !Chemistry input files
  CASE('CHEMINPUT')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !Chemistry tabulation files
  CASE('CHEMTAB')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !GPS files
  CASE('GPS')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !Meteo files
  CASE('METEO')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !Namelist files
  CASE('NML')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !OUTPUTLISTING files
  CASE('OUTPUTLISTING')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP,OPARALLELIO=.FALSE.)
    !
    TPFILE%NLU = -1


  !SURFACE_DATA files
  CASE('SURFACE_DATA')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  !Text files
  CASE('TXT')
    CALL CLOSE_ll(TPFILE,IOSTAT=IRESP)
    !
    TPFILE%NLU = -1


  CASE DEFAULT
    !Do not close (non-existing) '.des' file if OUTPUT
    IF(TPFILE%CTYPE/='OUTPUT' .AND. CPROGRAM/='LFICDF') THEN
      CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//'.des',TZFILE_DES,IRESP)
      IF (IRESP/=0) CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_CLOSE_ll','file '//TRIM(TPFILE%CNAME)//'.des not in filelist')
      !
      TZFILE_DES%NOPEN_CURRENT = TZFILE_DES%NOPEN_CURRENT - 1
      TZFILE_DES%NCLOSE        = TZFILE_DES%NCLOSE + 1
      !
      IF (TZFILE_DES%NOPEN_CURRENT==0) THEN
        CALL CLOSE_ll(TZFILE_DES,IOSTAT=IRESP,STATUS='KEEP')
        TZFILE_DES%LOPENED = .FALSE.
        TZFILE_DES%NLU     = -1
      END IF
    ENDIF
    !
    CALL FMCLOS_ll(TPFILE,'KEEP',KRESP=IRESP,OPARALLELIO=OPARALLELIO,HPROGRAM_ORIG=HPROGRAM_ORIG)
    !
    TPFILE%NLFIFLU = -1
    TPFILE%NNCID   = -1
    !
    DO JI = 1,TPFILE%NSUBFILES_IOZ
      TZFILE_IOZ => TPFILE%TFILES_IOZ(JI)%TFILE
      IF (.NOT.TZFILE_IOZ%LOPENED) &
        CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_CLOSE_ll','file '//TRIM(TZFILE_IOZ%CNAME)//' is not opened')
      IF (TZFILE_IOZ%NOPEN_CURRENT/=1) &
        CALL PRINT_MSG(NVERB_WARNING,'IO','IO_FILE_CLOSE_ll','file '//TRIM(TZFILE_IOZ%CNAME)//&
                       ' is currently opened 0 or several times (expected only 1)')
      TZFILE_IOZ%LOPENED       = .FALSE.
      TZFILE_IOZ%NOPEN_CURRENT = 0
      TZFILE_IOZ%NCLOSE        = TZFILE_IOZ%NCLOSE + 1
      TZFILE_IOZ%NLFIFLU       = -1
      TZFILE_IOZ%NNCID         = -1
    END DO
END SELECT
!
TPFILE%LOPENED       = .FALSE.
TPFILE%NOPEN_CURRENT = 0
TPFILE%NCLOSE        = TPFILE%NCLOSE + 1
!
IF (PRESENT(KRESP)) KRESP=IRESP
!
END SUBROUTINE IO_FILE_CLOSE_ll

SUBROUTINE FMCLOS_ll(TPFILE,HSTATU,KRESP,OPARALLELIO,HPROGRAM_ORIG)
!
!!    MODIFICATIONS
!!    -------------
!
!!      J.Escobar   18/10/10   bug with PGI compiler on ADJUSTL
!-------------------------------------------------------------------------------
USE MODD_CONF,  ONLY : CPROGRAM
USE MODD_IO_ll, ONLY : TFILEDATA
USE MODE_IO_ll, ONLY : CLOSE_ll,UPCASE
#if !defined(MNH_SGI)
USE MODI_SYSTEM_MNH
#endif
#if defined(MNH_IOCDF4)
USE MODE_NETCDF
#endif
TYPE(TFILEDATA),      INTENT(IN) :: TPFILE ! File structure
CHARACTER(LEN=*),     INTENT(IN) :: HSTATU ! status for the closed file
INTEGER,              INTENT(OUT), OPTIONAL :: KRESP   ! return-code if problems araised
LOGICAL,              INTENT(IN),  OPTIONAL :: OPARALLELIO
CHARACTER(LEN=*),     INTENT(IN),  OPTIONAL :: HPROGRAM_ORIG !To emulate a file coming from this program

INTEGER              ::IRESP,IROWF
CHARACTER(LEN=28)    :: YFILEM  ! name of the file
CHARACTER(LEN=7)     ::YSTATU
LOGICAL              ::GSTATU
CHARACTER(LEN=8)        :: YRESP
CHARACTER(LEN=10)       ::YCPIO
CHARACTER(LEN=14)       ::YTRANS
CHARACTER(LEN=100)      ::YCOMMAND
INTEGER                 :: IERR, IFITYP
INTEGER, SAVE           :: ICPT=0
INTEGER(KIND=LFI_INT) :: IRESP8
LOGICAL :: GPARALLELIO

YFILEM  = TPFILE%CNAME

CALL PRINT_MSG(NVERB_DEBUG,'IO','FMCLOS_ll','closing '//TRIM(YFILEM))

IF ( PRESENT(OPARALLELIO) ) THEN
  GPARALLELIO = OPARALLELIO
ELSE
  GPARALLELIO = .TRUE.  !par defaut on active les IO paralleles en Z si possible
ENDIF

IRESP  = 0
IROWF  = 0

IROWF=LEN_TRIM(YFILEM)

IF (IROWF.EQ.0) THEN
  IRESP=-59
  GOTO 1000
ENDIF

IF (LEN(HSTATU).LE.0) THEN
  IRESP=-41
  GOTO 1000
ELSE
  YSTATU = HSTATU
  YSTATU = UPCASE(TRIM(ADJUSTL(YSTATU)))
  GSTATU=YSTATU=='KEEP'.OR.YSTATU=='DELETE'
  IF (.NOT. GSTATU) THEN
    YSTATU='DEFAULT'
  ENDIF
ENDIF

#if defined(MNH_IOCDF4)
!Write coordinates variables in NetCDF file
IF (TPFILE%CMODE == 'WRITE' .AND. (TPFILE%CFORMAT=='NETCDF4' .OR. TPFILE%CFORMAT=='LFICDF4')) THEN
  CALL IO_WRITE_COORDVAR_NC4(TPFILE,HPROGRAM_ORIG=HPROGRAM_ORIG)
END IF
#endif

IF (TPFILE%LMASTER) THEN
  IF (TPFILE%NLFIFLU > 0) THEN
     CALL LFIFER(IRESP8,TPFILE%NLFIFLU,YSTATU)
     IRESP = IRESP8
  END IF
#if defined(MNH_IOCDF4)
  IF (TPFILE%NNCID/=-1) THEN
    ! Close Netcdf File
    IRESP = NF90_CLOSE(TPFILE%NNCID)
    IF (IRESP /= NF90_NOERR) THEN
      CALL PRINT_MSG(NVERB_WARNING,'IO','FMCLOS_ll','NF90_CLOSE error: '//TRIM(NF90_STRERROR(IRESP)))
    END IF
    IF (ASSOCIATED(TPFILE%TNCDIMS)) CALL CLEANIOCDF(TPFILE%TNCDIMS)
  END IF
#endif
  IF (IRESP == 0 .AND. CPROGRAM/='LFICDF') THEN
    !! Write in pipe
#if defined(MNH_LINUX) || defined(MNH_SP4)
    YTRANS='xtransfer.x'
#elif defined(MNH_SX5)
    YTRANS='nectransfer.x'
#else
    YTRANS='fujitransfer.x'
#endif
    IFITYP = TPFILE%NLFITYPE
    
    SELECT CASE (IFITYP)
    CASE(:-1)
      IRESP=-66
      GOTO 500
    CASE(0)
      YCPIO='NIL'
    CASE(1)
      YCPIO='MESONH'
    CASE(2)
      PRINT *,'FILE ',YFILEM,' NOT TRANSFERED'
      GOTO 500
    CASE(3:)
      IRESP=-66
      GOTO 500
    END SELECT
!   WRITE (YCOMMAND,*) YTRANS,' ',YCPIO,' ',YFILEM
#if defined(MNH_LINUX) || defined(MNH_VPP) || defined(MNH_SX5) ||  defined(MNH_SP4)
    ICPT=ICPT+1
    WRITE (YCOMMAND,'(A," ",A," ",A," >> OUTPUT_TRANSFER",I3.3,"  2>&1 &")') TRIM(YTRANS),TRIM(YCPIO),TRIM(YFILEM),ICPT
!JUAN jusqu'a MASDEV4_4    WRITE (YCOMMAND,'(A," ",A," ",A,"  ")') TRIM(YTRANS),TRIM(YCPIO),TRIM(YFILEM)
#endif
#if defined(MNH_SGI)
    WRITE (YCOMMAND,'(A," ",A," ",A," &")') TRIM(YTRANS),TRIM(YCPIO),TRIM(YFILEM)
#endif

    PRINT *,'YCOMMAND =',YCOMMAND
#if !defined(MNH_SGI)
    CALL SYSTEM_MNH(YCOMMAND)
#endif
  END IF
END IF

500 CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TPFILE%NMASTER_RANK-1,TPFILE%NMPICOMM,IERR)
IF (IRESP /= 0) GOTO 1000

CALL CLOSE_ll(TPFILE,IOSTAT=IRESP,STATUS=YSTATU,OPARALLELIO=GPARALLELIO)

1000 CONTINUE

IF (IRESP.NE.0)  THEN
  WRITE(YRESP,"( I0 )") IRESP
  CALL PRINT_MSG(NVERB_ERROR,'IO','FMCLOS_ll',TRIM(YFILEM)//': exit with IRESP='//TRIM(YRESP))
END IF

IF (PRESENT(KRESP)) KRESP=IRESP

! format: 14c for fujitransfer.x and mesonh/nil
!         32c for file name
! if you have to change this format one day, don't forget the blank after 1H
! 20 FORMAT(A14,1H ,A10,1H ,A32,1H ,A1)
!
END SUBROUTINE FMCLOS_ll

END MODULE MODE_FM

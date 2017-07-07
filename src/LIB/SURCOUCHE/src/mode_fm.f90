!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for CVS information
!-----------------------------------------------------------------
! $Source$
! $Name$ 
! $Revision$ 
! $Date$
!Correction :
!  D.Gazen   : avril 2016 change error message
!  P. Wautelet : may 2016: use NetCDF Fortran module
!-----------------------------------------------------------------
!-----------------------------------------------------------------

MODULE MODE_FM
USE MODD_ERRCODES
USE MODD_MPIF

USE MODE_MSG

IMPLICIT NONE 

PRIVATE 

INTEGER, PARAMETER :: JPPIPE = 10
!INCLUDE 'mpif.h'

PUBLIC SET_FMPACK_ll,FMATTR_ll,FMLOOK_ll,FMOPEN_ll,FMCLOS_ll
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

SUBROUTINE FMATTR_ll(HFILEM,HFIPRI,KNUMBR,KRESP)
!JUANZ
USE MODD_VAR_ll, ONLY : NMNH_COMM_WORLD
!JUANZ
USE MODD_IO_ll, ONLY : GSMONOPROC, ISIOP, ISTDOUT
USE MODE_FD_ll, ONLY : FD_ll,GETFD,NEWFD
USE MODE_IO_ll, ONLY : IONEWFLU
CHARACTER(LEN=*), INTENT(IN)  :: HFILEM
CHARACTER(LEN=*), INTENT(IN)  :: HFIPRI
INTEGER,          INTENT(OUT) :: KNUMBR
INTEGER,          INTENT(OUT) :: KRESP

TYPE(FD_ll), POINTER :: TZFD, TZFIPRI
TYPE(FD_ll), POINTER :: TZJUAN

IF (GSMONOPROC) THEN ! sequential execution
   TZJUAN=>GETFD(HFILEM)
   IF (.NOT. ASSOCIATED(TZJUAN)) THEN
    !! File is not already opened : GOOD
    !! Add a new FD element
    TZFD=>NEWFD()
    TZFD%NAME = HFILEM
    TZFD%MODE = 'GLOBAL'
    NULLIFY(TZFD%PARAM)
    TZFD%OWNER = ISIOP
    TZFD%FLU   = IONEWFLU()
    TZFD%COMM  = NMNH_COMM_WORLD
    !
    KNUMBR = TZFD%FLU
    KRESP  = NOERROR
  ELSE 
    !! Error : File already associated to a fortran logical unit
    TZFIPRI=>GETFD(HFIPRI)
    IF (ASSOCIATED(TZFIPRI)) THEN
      WRITE(TZFIPRI%FLU,*) 'Error FMATTR_ll : file '&
           & ,TRIM(HFILEM),' already opened'
    ELSE 
      WRITE(ISTDOUT,*) 'Error FMLOOK_ll : file ',TRIM(HFILEM)&
           & ,' already opened'
    END IF
    KRESP   = IOERROR
    KNUMBR  = -1  
  END IF
END IF

END SUBROUTINE FMATTR_ll

SUBROUTINE FMLOOK_ll(HFILEM,HFIPRI,KNUMBR,KRESP)
USE MODD_IO_ll, ONLY : ISTDOUT
USE MODE_FD_ll, ONLY : FD_ll,GETFD
CHARACTER(LEN=*), INTENT(IN)  :: HFILEM
CHARACTER(LEN=*), INTENT(IN)  :: HFIPRI
INTEGER,          INTENT(OUT) :: KNUMBR
INTEGER,          INTENT(OUT) :: KRESP

TYPE(FD_ll), POINTER :: TZFD, TZFIPRI

TZFD=>GETFD(HFILEM)
IF (ASSOCIATED(TZFD)) THEN
  KNUMBR = TZFD%FLU
  KRESP  = NOERROR
ELSE 
  IF (HFILEM == HFIPRI) THEN
    KNUMBR = ISTDOUT
    KRESP  = NOERROR
  ELSE
    TZFIPRI=>GETFD(HFIPRI)
    IF (ASSOCIATED(TZFIPRI)) THEN
      WRITE(TZFIPRI%FLU,*) 'Error FMLOOK_ll : file '&
           & ,TRIM(HFILEM),' not found'
    ELSE 
      WRITE(ISTDOUT,*) 'Error FMLOOK_ll : file ',TRIM(HFILEM)&
           & ,' not found'
    END IF
    KRESP   = IOERROR
    KNUMBR  = -1
  END IF
END IF

END SUBROUTINE FMLOOK_ll

SUBROUTINE IO_FILE_OPEN_ll(TPFILE,HFIPRI,KRESP,OPARALLELIO)
!
USE MODD_IO_ll, ONLY: ISP,LIOCDF4,TFILEDATA
USE MODE_FD_ll, ONLY: FD_ll,GETFD
USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
!
TYPE(TFILEDATA),  INTENT(INOUT) :: TPFILE ! File structure
CHARACTER(LEN=*), INTENT(IN)    :: HFIPRI ! File for prints in FM
INTEGER,          INTENT(OUT)   :: KRESP  ! Return code
LOGICAL,          INTENT(IN),  OPTIONAL :: OPARALLELIO
!
INTEGER :: ININAR ! Number of articles present in LFI file (unused here)
INTEGER :: JI,IRESP
CHARACTER (LEN=3) :: YNUMBER  ! Character string for Z-level
TYPE(FD_ll), POINTER  :: TZFDLFI,TZFD_IOZ
TYPE(TFILEDATA),POINTER :: TZFILE_IOZ
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_OPEN_ll','opening '//TRIM(TPFILE%CNAME)//' for '//TRIM(TPFILE%CMODE))
!
IF (TPFILE%LOPENED) THEN
  CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_OPEN_ll','file '//TRIM(TPFILE%CNAME)//' already opened')
  RETURN
END IF
!
IF (.NOT.PRESENT(OPARALLELIO)) THEN 
  CALL FMOPEN_ll(TPFILE%CNAME,TPFILE%CMODE,HFIPRI,TPFILE%NLFINPRAR,TPFILE%NLFITYPE,TPFILE%NLFIVERB,ININAR,KRESP,TPFILE=TPFILE)
ELSE
  CALL FMOPEN_ll(TPFILE%CNAME,TPFILE%CMODE,HFIPRI,TPFILE%NLFINPRAR,TPFILE%NLFITYPE,TPFILE%NLFIVERB,ININAR,KRESP,&
                 TPFILE=TPFILE,OPARALLELIO=OPARALLELIO)
END IF
!
TPFILE%LOPENED = .TRUE.
TPFILE%NOPEN   = TPFILE%NOPEN + 1
!
TZFDLFI=>GETFD(ADJUSTL(TRIM(TPFILE%CNAME)//'.lfi'))
!TZFDLFI%CDF exists only if ISP == TZFDLFI%OWNER
IF (ISP == TZFDLFI%OWNER .AND. LIOCDF4) TPFILE%NNCID = TZFDLFI%CDF%NCID
!
IF (TZFDLFI%NB_PROCIO>1) THEN
  DO JI = 1,TZFDLFI%NB_PROCIO
    WRITE (YNUMBER,FMT="(I3.3)") JI
    TZFD_IOZ => GETFD(TRIM(TPFILE%CNAME)//'.Z'//YNUMBER//'.lfi')
    IF (ISP == TZFD_IOZ%OWNER .AND. LIOCDF4) THEN
      CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//'.Z'//YNUMBER,TZFILE_IOZ,IRESP)
      IF (IRESP/=0) &
        CALL PRINT_MSG(NVERB_FATAL,'IO','IO_FILE_OPEN_ll','file '//TRIM(TRIM(TPFILE%CNAME)//'.Z'//YNUMBER)//' not found in list')
      TZFILE_IOZ%NNCID   = TZFD_IOZ%CDF%NCID
      TZFILE_IOZ%LOPENED = .TRUE.
      TZFILE_IOZ%NOPEN   = TZFILE_IOZ%NOPEN + 1
    END IF
  END DO
END IF
!
END SUBROUTINE IO_FILE_OPEN_ll

SUBROUTINE FMOPEN_ll(HFILEM,HACTION,HFIPRI,KNPRAR,KFTYPE,KVERB,KNINAR&
     & ,KRESP,OPARALLELIO,TPFILE)
USE MODD_IO_ll, ONLY : ISP,ISTDOUT,LFIPARAM,LIOCDF4,LLFIOUT,LLFIREAD,TFILEDATA
USE MODE_FD_ll, ONLY : FD_ll,GETFD,JPFINL
USE MODE_IO_ll, ONLY : OPEN_ll,GCONFIO
!JUANZ
USE MODD_CONFZ,ONLY  : NB_PROCIO_R,NB_PROCIO_W
!JUANZ
#if defined(MNH_IOCDF4)
USE MODD_NETCDF, ONLY:IDCDF_KIND
USE MODE_NETCDF
#endif
CHARACTER(LEN=*),INTENT(IN) ::HFILEM  ! name of the file.
CHARACTER(LEN=*),INTENT(IN) ::HACTION ! Action upon the file
! 'READ' or 'WRITE'
CHARACTER(LEN=*),INTENT(IN) ::HFIPRI  ! file for prints in FM.
INTEGER,         INTENT(IN) ::KNPRAR  ! number of predicted
! articles  (not vital).
INTEGER,         INTENT(IN) ::KFTYPE  ! type of FM-file.
INTEGER,         INTENT(IN) ::KVERB   ! level of verbose.
INTEGER,         INTENT(OUT)::KNINAR  ! number of articles
! initially
! present in the file.
INTEGER,         INTENT(OUT)::KRESP   ! return-code if a problem
! araised.
LOGICAL,         INTENT(IN),  OPTIONAL :: OPARALLELIO
TYPE(TFILEDATA), INTENT(IN),  OPTIONAL :: TPFILE ! File structure
!
!   Local variable
!
INTEGER                 :: IROWF,IRESP,INUMBR,IFMFNL
CHARACTER(LEN=JPFINL)   :: YFNDES,YFNLFI
LOGICAL                 :: GSTATS
LOGICAL, SAVE           :: GSFIRST=.TRUE.
TYPE(LFIPARAM), POINTER :: TZPARA
LOGICAL :: GNAMFI,GFATER,GNEWFI
INTEGER :: IERR
TYPE(FD_ll), POINTER    :: TZFDLFI
!JUAN
INTEGER(KIND=LFI_INT) :: IRESOU,INUMBR8
INTEGER(KIND=LFI_INT) :: IMELEV,INPRAR, ININAR8
LOGICAL               :: GNAMFI8,GFATER8,GSTATS8
INTEGER               :: INB_PROCIO
!JUAN
LOGICAL               :: GPARALLELIO
#if defined(MNH_IOCDF4)
INTEGER(KIND=IDCDF_KIND) :: INCERR
#endif
CHARACTER(LEN=13) :: YTYPE

CALL PRINT_MSG(NVERB_DEBUG,'IO','FMOPEN_ll','opening '//TRIM(HFILEM)//' for '//TRIM(HACTION))
IF ( PRESENT(TPFILE) ) THEN
  YTYPE = TPFILE%CTYPE
ELSE
  YTYPE = 'UNKNOWN'
ENDIF

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

INPRAR = KNPRAR+0 
KNINAR = 0
IROWF  = 0
IRESP  = 0

SELECT CASE (KVERB)
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

IFMFNL=JPFINL-4
IROWF=LEN_TRIM(HFILEM)

IF (IROWF.EQ.0) THEN
  IRESP=-45
  GOTO 1000
ELSEIF (IROWF.GT.IFMFNL) THEN
  IRESP=-49
  GOTO 1000
ENDIF

!Do not open '.des' file if OUTPUT
IF(YTYPE/='OUTPUT') THEN
  YFNDES=ADJUSTL(TRIM(HFILEM)//'.des')
  CALL OPEN_ll(UNIT=INUMBR,FILE=YFNDES,FORM='FORMATTED',ACTION=HACTION,DELIM&
       & ='QUOTE',IOSTAT=IRESP,RECL=1024*8,OPARALLELIO=GPARALLELIO,TPFILE=TPFILE)
ENDIF

IF (IRESP /= 0) GOTO 1000


YFNLFI=ADJUSTL(TRIM(HFILEM)//'.lfi')
ALLOCATE(TZPARA)
TZPARA%FITYP = KFTYPE

!!$CALL OPEN_ll(UNIT=INUMBR,FILE=YFNLFI,STATUS="UNKNOWN",MODE&
!!$     & ='DISTRIBUTED', LFIPAR=TZPARA, ACTION=HACTION, IOSTAT=IRESP)

 SELECT CASE (HACTION)
 CASE('READ')
    INB_PROCIO = NB_PROCIO_R
 CASE('WRITE')
    INB_PROCIO = NB_PROCIO_W
 END SELECT
CALL OPEN_ll(UNIT=INUMBR,FILE=HFILEM,STATUS="UNKNOWN",MODE&
     & ='IO_ZSPLIT', LFIPAR=TZPARA, ACTION=HACTION, IOSTAT=IRESP,KNB_PROCIO=INB_PROCIO,KMELEV=IMELEV,OPARALLELIO=GPARALLELIO,&
     TPFILE=TPFILE)

IF (IRESP /= 0) GOTO 1000

TZFDLFI=>GETFD(YFNLFI)
IF (ISP == TZFDLFI%OWNER) THEN
  ! Proc I/O case
  IF (GSFIRST) THEN
    GSFIRST = .FALSE.
    OPEN(UNIT=JPPIPE,FILE='pipe_name',FORM='FORMATTED')
  END IF

#if defined(MNH_IOCDF4)
  IF (LIOCDF4) THEN
     IF (HACTION == 'READ' .AND. .NOT. LLFIREAD) THEN
        !! Open NetCDF File for reading
        TZFDLFI%CDF => NEWIOCDF()
        INCERR = NF90_OPEN(ADJUSTL(TRIM(HFILEM))//".nc", NF90_NOWRITE, TZFDLFI%CDF%NCID)
        IF (INCERR /= NF90_NOERR) THEN
           !PRINT *, 'FMOPEN_ll, NF90_OPEN error : ', NF90_STRERROR(INCERR)
           PRINT *, 'Error in opening (FMOPEN_ll/NF90_OPEN) ', TRIM(HFILEM)//'.nc', ' : ', NF90_STRERROR(INCERR)
           STOP
        END IF
        PRINT *, 'NF90_OPEN: ', TRIM(HFILEM)//'.nc'
     END IF
     
     IF (HACTION == 'WRITE') THEN
        ! HACTION == 'WRITE'
        TZFDLFI%CDF => NEWIOCDF()
        INCERR = NF90_CREATE(ADJUSTL(TRIM(HFILEM))//".nc", &
             &IOR(NF90_CLOBBER,NF90_NETCDF4), TZFDLFI%CDF%NCID)
        IF (INCERR /= NF90_NOERR) THEN
           !PRINT *, 'FMOPEN_ll, NF90_CREATE error : ', NF90_STRERROR(INCERR)
           PRINT *, 'Error in opening (FMOPEN_ll/NF90_CREATE) ', TRIM(HFILEM)//'.nc', ' : ', NF90_STRERROR(INCERR)
           STOP
        END IF
        PRINT *, 'NF90_CREATE: ', TRIM(HFILEM)//'.nc'
     END IF
  END IF
#endif
  
  IF (.NOT. LIOCDF4 .OR. (HACTION=='WRITE' .AND. LLFIOUT) &
       &            .OR. (HACTION=='READ'  .AND. LLFIREAD)) THEN
     ! LFI Case
     IRESOU = 0
     GNAMFI = .TRUE.
     GFATER = .TRUE.
     !
     INUMBR8 = INUMBR
     GNAMFI8 = GNAMFI
     GFATER8 = GFATER
     GSTATS8 = GSTATS
     !
     CALL LFIOUV(IRESOU,     &
          INUMBR8,           &
          GNAMFI8,           &
          YFNLFI,            &
          "UNKNOWN",         &
          GFATER8,           &
          GSTATS8,           &
          IMELEV,            &
          INPRAR,            &
          ININAR8)
     KNINAR = ININAR8
     
!!$     IF (IRESOU /= 0 .AND. IRESOU /= -11) THEN
  IF (IRESOU /= 0 ) THEN
        IRESP = IRESOU
     ENDIF
  END IF

  !
  !*      6.    TEST IF FILE IS NEWLY DEFINED
  !
  
  GNEWFI=(KNINAR==0).OR.(IMELEV<2)
  IF (.NOT.GNEWFI) THEN
    WRITE (ISTDOUT,*) ' file ',YFNLFI,' previously&
         & created with LFI'
  ENDIF
END IF
! Broadcast ERROR
CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFDLFI%OWNER-1,TZFDLFI%COMM&
     & ,IERR)
IF (IRESP /= 0) GOTO 1000

! Broadcast KNINAR
CALL MPI_BCAST(KNINAR,1,MPI_INTEGER,TZFDLFI%OWNER-1,TZFDLFI%COMM,IERR)


1000 CONTINUE

IF (IRESP.NE.0) CALL FM_ERR('FMOPEN_ll',HFIPRI,HFILEM,IRESP)

KRESP=IRESP

RETURN
END SUBROUTINE FMOPEN_ll
  
SUBROUTINE IO_FILE_CLOSE_ll(TPFILE,HFIPRI,KRESP,OPARALLELIO)
!
USE MODD_IO_ll, ONLY: TFILEDATA
USE MODE_FD_ll, ONLY: FD_ll,GETFD
USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
!
TYPE(TFILEDATA),  INTENT(INOUT) :: TPFILE ! File structure
CHARACTER(LEN=*), INTENT(IN)    :: HFIPRI ! File for prints in FM
INTEGER,          INTENT(OUT)   :: KRESP  ! Return code
LOGICAL,          INTENT(IN),  OPTIONAL :: OPARALLELIO
!
INTEGER                 :: INB_PROCIO, IRESP, JI
CHARACTER (LEN=3)       :: YNUMBER  ! Character string for Z-level
TYPE(FD_ll), POINTER    :: TZFDLFI
TYPE(TFILEDATA),POINTER :: TZFILE_IOZ
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_FILE_CLOSE_ll','closing '//TRIM(TPFILE%CNAME))
!
IF (.NOT.TPFILE%LOPENED) THEN
  CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_CLOSE_ll','trying to close a file not opened: '//TRIM(TPFILE%CNAME))
  RETURN
ENDIF
!
!Next lines done before the close to be sure the FD_ll still exists
TZFDLFI=>GETFD(ADJUSTL(TRIM(TPFILE%CNAME)//'.lfi'))
INB_PROCIO=TZFDLFI%NB_PROCIO
!
IF (.NOT.PRESENT(OPARALLELIO)) THEN 
  CALL FMCLOS_ll(TPFILE%CNAME,'KEEP',HFIPRI,KRESP,TPFILE=TPFILE)
ELSE
  CALL FMCLOS_ll(TPFILE%CNAME,'KEEP',HFIPRI,KRESP,OPARALLELIO=OPARALLELIO,TPFILE=TPFILE)
END IF
!
TPFILE%LOPENED = .FALSE.
TPFILE%NCLOSE  = TPFILE%NCLOSE + 1
TPFILE%NNCID   = -1
!
IF (INB_PROCIO>1) THEN
  DO JI = 1,TZFDLFI%NB_PROCIO
    WRITE (YNUMBER,FMT="(I3.3)") JI
    CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//'.Z'//YNUMBER,TZFILE_IOZ,IRESP)
    IF (IRESP/=0) &
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_FILE_CLOSE_ll','file '//TRIM(TRIM(TPFILE%CNAME)//'.Z'//YNUMBER)//' not found in list')
    IF (TZFILE_IOZ%LOPENED) THEN
      TZFILE_IOZ%LOPENED = .FALSE.
      TZFILE_IOZ%NCLOSE  = TZFILE_IOZ%NCLOSE + 1
      TZFILE_IOZ%NNCID   = -1
    END IF
  END DO
END IF
!
END SUBROUTINE IO_FILE_CLOSE_ll

SUBROUTINE FMCLOS_ll(HFILEM,HSTATU,HFIPRI,KRESP,OPARALLELIO,TPFILE)
!
!!    MODIFICATIONS
!!    -------------
!
!!      J.Escobar   18/10/10   bug with PGI compiler on ADJUSTL
!-------------------------------------------------------------------------------
USE MODD_IO_ll, ONLY : ISP,TFILEDATA
!USE MODE_FD_ll, ONLY : FD_ll,GETFD,JPFINL
USE MODE_FD_ll
USE MODE_IO_ll, ONLY : CLOSE_ll,UPCASE
#if !defined(MNH_SGI)
USE MODI_SYSTEM_MNH
#endif
#if defined(MNH_IOCDF4)
USE MODE_NETCDF
#endif
CHARACTER(LEN=*),     INTENT(IN) ::HFILEM  ! file name
CHARACTER(LEN=*),     INTENT(IN) ::HSTATU  ! status for the closed file
CHARACTER(LEN=*),     INTENT(IN) ::HFIPRI  ! file for prints in FM
INTEGER,              INTENT(OUT)::KRESP   ! return-code if problems araised
LOGICAL,              INTENT(IN),  OPTIONAL :: OPARALLELIO
TYPE(TFILEDATA),      INTENT(IN),  OPTIONAL :: TPFILE ! File structure

INTEGER              ::IRESP,IROWF,IFMFNL
CHARACTER(LEN=7)     ::YSTATU
CHARACTER(LEN=JPFINL)::YFNDES,YFNLFI
LOGICAL              ::GSTATU
CHARACTER(LEN=10)       ::YCPIO
CHARACTER(LEN=14)       ::YTRANS
CHARACTER(LEN=100)      ::YCOMMAND
INTEGER                 :: IERR, IFITYP
INTEGER, SAVE           :: ICPT=0
TYPE(FD_ll), POINTER :: TZFDLFI
!JUAN
INTEGER(KIND=LFI_INT) :: IRESP8,INUM8
!JUAN
LOGICAL :: GPARALLELIO
CHARACTER(LEN=13) :: YTYPE

CALL PRINT_MSG(NVERB_DEBUG,'IO','FMCLOS_ll','closing '//TRIM(HFILEM))
IF ( PRESENT(TPFILE) ) THEN
  YTYPE = TPFILE%CTYPE
ELSE
  YTYPE = 'UNKNOWN'
ENDIF

IF ( PRESENT(OPARALLELIO) ) THEN
  GPARALLELIO = OPARALLELIO
ELSE
  GPARALLELIO = .TRUE.  !par defaut on active les IO paralleles en Z si possible
ENDIF

IRESP  = 0
IROWF  = 0

IFMFNL=JPFINL-4

IROWF=LEN_TRIM(HFILEM)

IF (IROWF.EQ.0) THEN
  IRESP=-59
  GOTO 1000
ELSEIF (IROWF.GT.IFMFNL) THEN
  IRESP=-60
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

!Do not close (non-existing) '.des' file if OUTPUT
IF(YTYPE/='OUTPUT') THEN
  YFNDES=ADJUSTL(TRIM(HFILEM)//'.des')
  CALL CLOSE_ll(YFNDES,IOSTAT=IRESP,STATUS=YSTATU)
ENDIF

IF (IRESP /= 0) GOTO 1000

YFNLFI=ADJUSTL(TRIM(HFILEM)//'.lfi')

TZFDLFI=>GETFD(YFNLFI)

IF (ISP == TZFDLFI%OWNER) THEN
  IF (TZFDLFI%FLU > 0) THEN
     INUM8=TZFDLFI%FLU
     CALL LFIFER(IRESP8,INUM8,YSTATU)
     IRESP = IRESP8
  END IF
  IF (ASSOCIATED(TZFDLFI%CDF)) CALL CLEANIOCDF(TZFDLFI%CDF)
  IF (IRESP == 0) THEN
    !! Write in pipe
#if defined(MNH_LINUX) || defined(MNH_SP4)
    YTRANS='xtransfer.x'
#elif defined(MNH_SX5)
    YTRANS='nectransfer.x'
#else
    YTRANS='fujitransfer.x'
#endif
    IFITYP = TZFDLFI%PARAM%FITYP
    
    SELECT CASE (IFITYP)
    CASE(:-1)
      IRESP=-66
      GOTO 500
    CASE(0)
      YCPIO='NIL'
    CASE(1)
      YCPIO='MESONH'
    CASE(2)
      PRINT *,'FILE ',HFILEM,' NOT TRANSFERED'
      GOTO 500
    CASE(3:)
      IRESP=-66
      GOTO 500
    END SELECT
!   WRITE (YCOMMAND,*) YTRANS,' ',YCPIO,' ',HFILEM
#if defined(MNH_LINUX) || defined(MNH_VPP) || defined(MNH_SX5) ||  defined(MNH_SP4)
    ICPT=ICPT+1
    WRITE (YCOMMAND,'(A," ",A," ",A," >> OUTPUT_TRANSFER",I3.3,"  2>&1 &")') TRIM(YTRANS),TRIM(YCPIO),TRIM(HFILEM),ICPT
!JUAN jusqu'a MASDEV4_4    WRITE (YCOMMAND,'(A," ",A," ",A,"  ")') TRIM(YTRANS),TRIM(YCPIO),TRIM(HFILEM)
#endif
#if defined(MNH_SGI)
    WRITE (YCOMMAND,'(A," ",A," ",A," &")') TRIM(YTRANS),TRIM(YCPIO),TRIM(HFILEM)
#endif

    PRINT *,'YCOMMAND =',YCOMMAND
#if !defined(MNH_SGI)
    CALL SYSTEM_MNH(YCOMMAND)
#endif
  END IF
END IF

500 CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFDLFI%OWNER-1,TZFDLFI%COMM&
     & ,IERR)
IF (IRESP /= 0) GOTO 1000

DEALLOCATE(TZFDLFI%PARAM)
CALL CLOSE_ll(YFNLFI,IOSTAT=IRESP,STATUS=YSTATU,OPARALLELIO=GPARALLELIO)

1000 CONTINUE
IF (IRESP.NE.0) CALL FM_ERR('FMCLOS_ll',HFIPRI,HFILEM,IRESP)

KRESP=IRESP

! format: 14c for fujitransfer.x and mesonh/nil
!         32c for file name
! if you have to change this format one day, don't forget the blank after 1H
! 20 FORMAT(A14,1H ,A10,1H ,A32,1H ,A1)
!
END SUBROUTINE FMCLOS_ll

SUBROUTINE FM_ERR(HROUTINE,HFIPRI,HFILEM,KRESP)
CHARACTER(LEN=*), INTENT(IN) :: HROUTINE
CHARACTER(LEN=*), INTENT(IN) :: HFIPRI
CHARACTER(LEN=*), INTENT(IN) :: HFILEM
INTEGER         , INTENT(IN) :: KRESP

INTEGER :: IRESP
INTEGER :: ILUPRI

CALL FMLOOK_ll(HFIPRI,HFIPRI,ILUPRI,IRESP)

WRITE (ILUPRI,*) ' exit from ',HROUTINE,' with RESP:',KRESP
WRITE (ILUPRI,*) '   | HFILEM  = ',HFILEM

END SUBROUTINE FM_ERR

END MODULE MODE_FM

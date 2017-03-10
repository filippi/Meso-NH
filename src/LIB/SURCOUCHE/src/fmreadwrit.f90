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
!-----------------------------------------------------------------
!-----------------------------------------------------------------

MODULE MODD_FM
USE MODE_FIELD, ONLY : TFIELDDATA
IMPLICIT NONE 

INTEGER, PARAMETER :: JPXKRK = 100
INTEGER, PARAMETER :: JPXFIE = 1.5E8

TYPE FMHEADER
  INTEGER               :: GRID
  INTEGER               :: COMLEN
  CHARACTER(LEN=JPXKRK) :: COMMENT 
END TYPE FMHEADER

END MODULE MODD_FM

SUBROUTINE FM_READ_ll(KFLU,HRECFM,OREAL,KLENG,KFIELD,TPFMH,KRESP)
USE MODD_FM
USE MODD_CONFZ, ONLY : NZ_VERB
USE MODE_MSG
!
!*      0.    DECLARATIONS
!             ------------
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
CHARACTER(LEN=*),        INTENT(IN) :: HRECFM ! name of the desired article
LOGICAL,                 INTENT(IN) :: OREAL  ! TRUE IF TRANSMITTED KFIELD IS REAL 
INTEGER,                 INTENT(IN) :: KLENG  ! length of the data field
INTEGER,DIMENSION(KLENG),INTENT(OUT):: KFIELD ! array containing the data field
TYPE(FMHEADER),          INTENT(OUT):: TPFMH  ! FM-File Header
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems occured
!
!*      0.2   Declarations of local variables
!
!JUAN
INTEGER(KIND=LFI_INT) :: IRESP,ILENGA,IPOSEX,ITOTAL,INUMBR
INTEGER               :: J,IROW
!JUAN
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE::IWORK
INTEGER,DIMENSION(1:JPXKRK)             ::ICOMMENT
!
!*      0.3   Taskcommon for logical units
!
!
!------------------------------------------------------------------

CALL PRINT_MSG(NVERB_DEBUG,'IO','FM_READ_ll','reading '//TRIM(HRECFM))

!
!*      1.2   WE LOOK FOR THE FILE'S LOGICAL UNIT
!

INUMBR = KFLU

!
!*      2.a   LET'S GET SOME INFORMATION ON THE DESIRED ARTICLE
!
CALL LFINFO(IRESP,INUMBR,HRECFM,ILENGA,IPOSEX)
IF (IRESP.NE.0) THEN
  GOTO 1000
ELSEIF (ILENGA.EQ.0) THEN
  IRESP=-47
  GOTO 1000
ELSEIF (ILENGA.GT.JPXFIE) THEN
  IRESP=-48
  GOTO 1000
ENDIF

!
!*      2.b   UNFORMATTED DIRECT ACCESS READ OPERATION
!
ITOTAL=ILENGA
IF ( NZ_VERB .GE. 5 ) print *," fmreadwrit.f90:: FM_READ_ll ILENGA=",ILENGA," HRECFM=",HRECFM
ALLOCATE(IWORK(ITOTAL))

CALL LFILEC(IRESP,INUMBR,HRECFM,IWORK,ITOTAL)
IF (IRESP.NE.0) GOTO 1000
!
!*      2.c   THE GRID INDICATOR AND THE COMMENT STRING
!*            ARE SEPARATED FROM THE DATA
!
TPFMH%GRID   = IWORK(1)
TPFMH%COMLEN = IWORK(2)

IROW=KLENG+TPFMH%COMLEN+2
IF (ITOTAL.NE.IROW) THEN
  PRINT *,'KLENG =',KLENG
  PRINT *,'diff = ',ITOTAL-(TPFMH%COMLEN+2)
  IRESP=-63
  GOTO 1000
ENDIF

SELECT CASE (TPFMH%COMLEN)
CASE(:-1)
  IRESP=-58
  GOTO 1000
CASE(0)
  IRESP = 0
CASE(1:JPXKRK)
  ICOMMENT(1:TPFMH%COMLEN)=IWORK(3:TPFMH%COMLEN+2)
  DO J=1,TPFMH%COMLEN
    TPFMH%COMMENT(J:J)=CHAR(ICOMMENT(J))
  ENDDO
CASE(JPXKRK+1:)
  IRESP=-56
  GOTO 1000
END SELECT

IF (OREAL) THEN
  CALL TRANSFR(KFIELD,IWORK(TPFMH%COMLEN+3),KLENG) 
ELSE 
  KFIELD(1:KLENG) = IWORK(TPFMH%COMLEN+3:ITOTAL)
END IF
!
!  this is a pure binary field: no uncompressing of any kind
!
!*      3.    MESSAGE PRINTING WHATEVER THE ISSUE WAS
!
1000 CONTINUE

KRESP=IRESP

IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)

RETURN
END SUBROUTINE FM_READ_ll

SUBROUTINE FM_WRIT_ll(KFLU,HRECFM,OREAL,KLENG,KFIELD,TPFMH,KRESP)

USE MODD_FM
USE MODE_MSG

IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
CHARACTER(LEN=*),        INTENT(IN) :: HRECFM ! name of the article to be written     
LOGICAL,                 INTENT(IN) :: OREAL  ! TRUE IF TRANSMITTED KFIELD IS REAL 
INTEGER,                 INTENT(IN) :: KLENG  ! length of the data field
INTEGER,DIMENSION(KLENG),INTENT(IN) :: KFIELD ! array containing the data field
TYPE(FMHEADER),          INTENT(IN) :: TPFMH  ! FM-File Header
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
!JUAN
INTEGER(kind=LFI_INT) :: IRESP,ITOTAL,INUMBR
INTEGER         :: J
!JUAN
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE::IWORK
INTEGER,DIMENSION(1:JPXKRK)             ::ICOMMENT

CALL PRINT_MSG(NVERB_DEBUG,'IO','FM_WRIT_ll','writing '//TRIM(HRECFM))

!
!*      1.2   WE LOOK FOR THE FILE'S LOGICAL UNIT
!

INUMBR = KFLU

!
!*      2.    GRID INDICATOR, COMMENT AND DATA ARE PUT TOGETHER
!

IF (KLENG.LE.0) THEN
  IRESP=-40
  GOTO 1000
ELSEIF (KLENG.GT.JPXFIE) THEN
  IRESP=-43
  GOTO 1000
ELSEIF ((TPFMH%GRID.LT.0).OR.(TPFMH%GRID.GT.8)) THEN
  IRESP=-46
  GOTO 1000
ENDIF

ITOTAL=KLENG+1+TPFMH%COMLEN+1
ALLOCATE(IWORK(ITOTAL))

IWORK(1)=TPFMH%GRID

SELECT CASE (TPFMH%COMLEN)
CASE(:-1)
  IRESP=-55
  GOTO 1000
CASE(0)
  IWORK(2)=TPFMH%COMLEN
CASE(1:JPXKRK)
  DO J=1,TPFMH%COMLEN
    ICOMMENT(J)=ICHAR(TPFMH%COMMENT(J:J))
  ENDDO
  IWORK(2)=TPFMH%COMLEN
  IWORK(3:TPFMH%COMLEN+2)=ICOMMENT(1:TPFMH%COMLEN)
CASE(JPXKRK+1:)
  IRESP=-57
  GOTO 1000
END SELECT

IF (OREAL) THEN
  CALL TRANSFW(IWORK(TPFMH%COMLEN+3),KFIELD,KLENG)
ELSE
  IWORK(TPFMH%COMLEN+3:ITOTAL)=KFIELD(1:KLENG)
END IF

!
!  no compressing of any kind: the data is pure binary
!
!*      3.    UNFORMATTED, DIRECT ACCESS WRITE OPERATION
!
CALL LFIECR(IRESP,INUMBR,HRECFM,IWORK,ITOTAL)


!
!*      4.    MESSAGE PRINTING WHATEVER THE ISSUE WAS
!
1000 CONTINUE

KRESP=IRESP

IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)  

RETURN
END SUBROUTINE FM_WRIT_ll

SUBROUTINE TRANSFR(KDEST,KSOURCE,KSIZE)
IMPLICIT NONE 
INTEGER                          :: KSIZE
REAL(KIND=8)   , DIMENSION(KSIZE):: KSOURCE
REAL           , DIMENSION(KSIZE):: KDEST

KDEST(:) = KSOURCE(:)

END SUBROUTINE TRANSFR

SUBROUTINE TRANSFW(KDEST,KSOURCE,KSIZE)
IMPLICIT NONE 
INTEGER                          :: KSIZE
REAL(KIND=8)   , DIMENSION(KSIZE):: KDEST
REAL           , DIMENSION(KSIZE):: KSOURCE

KDEST(:) = KSOURCE(:)

END SUBROUTINE TRANSFW


MODULE MODE_READWRITE_LFI
!
USE MODD_FM
USE MODD_IO_ll
USE MODE_FIELD, ONLY : TFIELDDATA
USE MODE_MSG
!
IMPLICIT NONE
!
PRIVATE
!
INTERFACE IO_WRITE_FIELD_LFI
   MODULE PROCEDURE IO_WRITE_FIELD_LFI_X0,IO_WRITE_FIELD_LFI_X1, &
                    IO_WRITE_FIELD_LFI_X2,IO_WRITE_FIELD_LFI_X3, &
                    IO_WRITE_FIELD_LFI_N0,IO_WRITE_FIELD_LFI_N1, &
                    IO_WRITE_FIELD_LFI_N2,                       &
                    IO_WRITE_FIELD_LFI_C0,                       &
                    IO_WRITE_FIELD_LFI_T0
END INTERFACE IO_WRITE_FIELD_LFI
!
PUBLIC IO_WRITE_FIELD_LFI
!
CONTAINS
!
SUBROUTINE IO_WRITE_FIELD_LFI_X0(TPFIELD,KFLU,PFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),      INTENT(IN) :: TPFIELD
INTEGER,               INTENT(IN) :: KFLU   ! Fortran Logical Unit
REAL,                  INTENT(IN) :: PFIELD ! array containing the data field
INTEGER,               INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(KIND=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_X0','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = 1
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  CALL TRANSFW(IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3),PFIELD,ILENG)
  CALL LFIECR(IRESP,KFLU,TRIM(TPFIELD%CMNHNAME),IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_X0
!
SUBROUTINE IO_WRITE_FIELD_LFI_X1(TPFIELD,KFLU,PFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),      INTENT(IN) :: TPFIELD
INTEGER,               INTENT(IN) :: KFLU   ! Fortran Logical Unit
REAL,DIMENSION(:),     INTENT(IN) :: PFIELD ! array containing the data field
INTEGER,               INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_X1','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = SIZE(PFIELD)
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  CALL TRANSFW(IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3),PFIELD,ILENG)
  CALL LFIECR(IRESP,KFLU,TRIM(TPFIELD%CMNHNAME),IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_X1
!
SUBROUTINE IO_WRITE_FIELD_LFI_X2(TPFIELD,KFLU,PFIELD,KRESP,KVERTLEVEL)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),      INTENT(IN) :: TPFIELD
INTEGER,               INTENT(IN) :: KFLU   ! Fortran Logical Unit
REAL,DIMENSION(:,:),   INTENT(IN) :: PFIELD ! array containing the data field
INTEGER,               INTENT(OUT):: KRESP  ! return-code if problems araised
INTEGER,OPTIONAL,      INTENT(IN) :: KVERTLEVEL ! Number of the vertical level (needed for Z-level splitted files)
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
CHARACTER(LEN=4)                         :: YSUFFIX
CHARACTER(LEN=LEN(TPFIELD%CMNHNAME)+4)   :: YVARNAME
!
ILENG = SIZE(PFIELD)
IF (PRESENT(KVERTLEVEL)) THEN
  WRITE(YSUFFIX,'(I4.4)') KVERTLEVEL
  YVARNAME = TRIM(TPFIELD%CMNHNAME)//YSUFFIX
ELSE
  YVARNAME = TRIM(TPFIELD%CMNHNAME)
ENDIF
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_X2','writing '//TRIM(YVARNAME))
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  CALL TRANSFW(IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3),PFIELD,ILENG)
  CALL LFIECR(IRESP,KFLU,YVARNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_X2
!
SUBROUTINE IO_WRITE_FIELD_LFI_X3(TPFIELD,KFLU,PFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),        INTENT(IN) :: TPFIELD
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
REAL,DIMENSION(:,:,:),   INTENT(IN) :: PFIELD ! array containing the data field
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_X3','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = SIZE(PFIELD)
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  CALL TRANSFW(IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3),PFIELD,ILENG)
  CALL LFIECR(IRESP,KFLU,TPFIELD%CMNHNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_X3
!
SUBROUTINE IO_WRITE_FIELD_LFI_N0(TPFIELD,KFLU,KFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),        INTENT(IN) :: TPFIELD
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
INTEGER,                 INTENT(IN) :: KFIELD ! array containing the data field
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_N0','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = 1
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3)=KFIELD
  CALL LFIECR(IRESP,KFLU,TPFIELD%CMNHNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_N0
!
SUBROUTINE IO_WRITE_FIELD_LFI_N1(TPFIELD,KFLU,KFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),        INTENT(IN) :: TPFIELD
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
INTEGER,DIMENSION(:),    INTENT(IN) :: KFIELD ! array containing the data field
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_N1','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = SIZE(KFIELD)
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3:) = KFIELD(:)
  CALL LFIECR(IRESP,KFLU,TPFIELD%CMNHNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_N1
!
SUBROUTINE IO_WRITE_FIELD_LFI_N2(TPFIELD,KFLU,KFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),      INTENT(IN) :: TPFIELD
INTEGER,               INTENT(IN) :: KFLU   ! Fortran Logical Unit
INTEGER,DIMENSION(:,:),INTENT(IN) :: KFIELD ! array containing the data field
INTEGER,               INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_N2','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG = SIZE(KFIELD)
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3:) = RESHAPE( KFIELD(:,:) , (/ SIZE(KFIELD) /) )
  CALL LFIECR(IRESP,KFLU,TPFIELD%CMNHNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_N2
!
SUBROUTINE IO_WRITE_FIELD_LFI_C0(TPFIELD,KFLU,HFIELD,KRESP)
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),        INTENT(IN) :: TPFIELD
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
CHARACTER(LEN=*),        INTENT(IN) :: HFIELD ! array containing the data field
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG, JLOOP
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_C0','writing '//TRIM(TPFIELD%CMNHNAME))
!
ILENG=LEN_TRIM(HFIELD)
IF (ILENG==0) ILENG=1
!
CALL WRITE_PREPARE(TPFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  IF (ILENG==0) THEN
    IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+3)=IACHAR(' ')
  ELSE
    DO JLOOP=1,ILENG
      IWORK(LEN_TRIM(TPFIELD%CCOMMENT)+2+JLOOP)=IACHAR(HFIELD(JLOOP:JLOOP))
    END DO
  END IF
  CALL LFIECR(IRESP,KFLU,TPFIELD%CMNHNAME,IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_C0
!
SUBROUTINE IO_WRITE_FIELD_LFI_T0(TPFIELD,KFLU,TPDATA,KRESP)
!
USE MODD_TYPE_DATE
!
IMPLICIT NONE
!
!*      0.1   Declarations of arguments
!
TYPE(TFIELDDATA),        INTENT(IN) :: TPFIELD
INTEGER,                 INTENT(IN) :: KFLU   ! Fortran Logical Unit
TYPE (DATE_TIME),        INTENT(IN) :: TPDATA ! array containing the data field
INTEGER,                 INTENT(OUT):: KRESP  ! return-code if problems araised
!
!*      0.2   Declarations of local variables
!
INTEGER                                  :: ILENG
INTEGER(kind=LFI_INT)                    :: IRESP, ITOTAL
TYPE(TFIELDDATA)                         :: TZFIELD
INTEGER, DIMENSION(3)                    :: ITDATE    ! date array
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE :: IWORK
!
CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_LFI_T0','writing '//TRIM(TPFIELD%CMNHNAME))
!
TZFIELD = TPFIELD
!
! Write date
!
TZFIELD%CMNHNAME = TRIM(TPFIELD%CMNHNAME)//'%TDATE'
TZFIELD%CCOMMENT = 'YYYYMMDD'
ITDATE(1)=TPDATA%TDATE%YEAR
ITDATE(2)=TPDATA%TDATE%MONTH
ITDATE(3)=TPDATA%TDATE%DAY
ILENG=SIZE(ITDATE)
!
CALL WRITE_PREPARE(TZFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  IWORK(LEN_TRIM(TZFIELD%CCOMMENT)+3:)=ITDATE(:)
  CALL LFIECR(IRESP,KFLU,TRIM(TZFIELD%CMNHNAME),IWORK,ITOTAL)
ENDIF
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
IF (IRESP/=0) THEN
  KRESP = IRESP
  RETURN
END IF
!
! Write time
!
TZFIELD%CMNHNAME = TRIM(TPFIELD%CMNHNAME)//'%TIME'
TZFIELD%CCOMMENT = 'SECONDS'
ILENG=1
!
CALL WRITE_PREPARE(TZFIELD,ILENG,IWORK,ITOTAL,IRESP)
!
IF (IRESP==0) THEN
  CALL TRANSFW(IWORK(LEN_TRIM(TZFIELD%CCOMMENT)+3),TPDATA%TIME,ILENG)
  CALL LFIECR(IRESP,KFLU,TRIM(TZFIELD%CMNHNAME),IWORK,ITOTAL)
ENDIF
!
KRESP=IRESP
!
IF (ALLOCATED(IWORK)) DEALLOCATE(IWORK)
!
END SUBROUTINE IO_WRITE_FIELD_LFI_T0
!
SUBROUTINE WRITE_PREPARE(TPFIELD,KLENG,KWORK,KTOTAL,KRESP)
!
TYPE(TFIELDDATA),                        INTENT(IN)    :: TPFIELD
INTEGER,                                 INTENT(IN)    :: KLENG
INTEGER(KIND=8),DIMENSION(:),ALLOCATABLE,INTENT(INOUT) :: KWORK
INTEGER(kind=LFI_INT),                   INTENT(OUT)   :: KTOTAL
INTEGER(kind=LFI_INT),                   INTENT(OUT)   :: KRESP
!
INTEGER                   :: ICOMLEN
INTEGER                   :: J
INTEGER,DIMENSION(JPXKRK) :: ICOMMENT
!
ICOMLEN = LEN_TRIM(TPFIELD%CCOMMENT)
KRESP = 0
!
IF (KLENG.LE.0) THEN
  KRESP=-40
  RETURN
ELSEIF (KLENG.GT.JPXFIE) THEN
  KRESP=-43
  RETURN
ELSEIF ((TPFIELD%NGRID.LT.0).OR.(TPFIELD%NGRID.GT.8)) THEN
  KRESP=-46
  RETURN
ENDIF
!
KTOTAL=KLENG+1+ICOMLEN+1
ALLOCATE(KWORK(KTOTAL))
!
KWORK(1)=TPFIELD%NGRID
!
SELECT CASE (ICOMLEN)
CASE(:-1)
  KRESP=-55
CASE(0)
  KWORK(2)=ICOMLEN
CASE(1:JPXKRK)
  DO J=1,ICOMLEN
    ICOMMENT(J)=ICHAR(TPFIELD%CCOMMENT(J:J))
  ENDDO
  KWORK(2)=ICOMLEN
  KWORK(3:ICOMLEN+2)=ICOMMENT(1:ICOMLEN)
CASE(JPXKRK+1:)
  CALL PRINT_MSG(NVERB_WARNING,'IO','WRITE_PREPARE','comment is too long')
  KRESP = -9999
END SELECT
!
END SUBROUTINE WRITE_PREPARE
!
END MODULE MODE_READWRITE_LFI

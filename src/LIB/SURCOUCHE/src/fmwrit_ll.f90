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
!Correction :
!  J.Escobar : 15/09/2015 : WENO5 & JPHEXT <> 1 
!-----------------------------------------------------------------

#ifdef MNH_MPI_DOUBLE_PRECISION
#define MPI_FLOAT MPI_DOUBLE_PRECISION
#else
#define MPI_FLOAT MPI_REAL
#endif

#ifdef MNH_GA
MODULE MODE_GA 
#include "mafdecls.fh"
#include "global.fh"
    !
    !  Global Array Variables
    !
    INTEGER, PARAMETER                              :: jpix=1 , jpiy = 2 , jpiz = 3
    !
    INTEGER                                         :: NIMAX_ll,NJMAX_ll, IIU_ll,IJU_ll,IKU_ll
    integer                                         :: heap=5*10**6, stack
    logical                                         :: gstatus_ga
    INTEGER, PARAMETER                              :: ndim_GA = 3
    INTEGER, DIMENSION(ndim_GA)                     :: dims_GA , chunk_GA 
    INTEGER,PARAMETER                               :: CI=1 ,CJ=-1 ,CK=-1
    INTEGER                                         :: g_a
    integer, DIMENSION(ndim_GA)                     :: lo_col, hi_col , ld_col
    integer, DIMENSION(ndim_GA)                     :: lo_zplan , hi_zplan , ld_zplan   
    INTEGER                                         :: NIXO_L,NIXE_L,NIYO_L,NIYE_L
    INTEGER                                         :: NIXO_G,NIXE_G,NIYO_G,NIYE_G
 
    LOGICAL,SAVE                                    :: GFIRST_GA  = .TRUE.
    INTEGER                                         :: IIU_ll_MAX = -1, IJU_ll_MAX = -1, IKU_ll_MAX = -1

  CONTAINS 
    
    SUBROUTINE MNH_INIT_GA(MY_NI,MY_NJ,MY_NK,HRECFM,HRW_MODE)

!
!  Modification 
!  J.Escobar 5/02/2015 : use JPHEXT from MODD_PARAMETERS_ll

      USE MODE_TOOLS_ll,       ONLY : GET_GLOBALDIMS_ll
      USE MODD_PARAMETERS_ll,  ONLY : JPHEXT
      USE MODD_IO_ll,          ONLY : ISP
      USE MODE_GATHER_ll,      ONLY : GET_DOMWRITE_ll
      USE MODE_SCATTER_ll,     ONLY : GET_DOMREAD_ll

      IMPLICIT NONE

      INTEGER,          INTENT(IN) :: MY_NI,MY_NJ,MY_NK
      CHARACTER(LEN=*), INTENT(IN) :: HRECFM   ! name of the article to write
      CHARACTER(LEN=*), INTENT(IN) :: HRW_MODE 
      
      IF ( GFIRST_GA ) THEN
         GFIRST_GA = .FALSE.
         !
         !   Allocate memory for GA library
         !
         stack = heap
         !gstatus_ga = ma_init(MT_F_DBL, stack/ISNPROC, heap/ISNPROC)
         gstatus_ga = ma_init(MT_F_DBL, stack, heap)
         if ( .not. gstatus_ga ) STOP " MA_INIT FAILED "
         !
         !   Initialize GA library
         !
         !call ga_initialize_ltd(100000000)
         call ga_initialize()
      END IF
      
      CALL GET_GLOBALDIMS_ll (NIMAX_ll,NJMAX_ll)
      IIU_ll = NIMAX_ll + 2*JPHEXT
      IJU_ll = NJMAX_ll + 2*JPHEXT
      IKU_ll = MY_NK   
      !
      !   configure Global array dimensions
      !
      dims_GA(JPIX) = IIU_ll
      dims_GA(JPIY) = IJU_ll
      dims_GA(JPIZ) = IKU_ll
      chunk_GA(JPIX)   = CI
      chunk_GA(JPIY)   = CJ
      chunk_GA(JPIZ)   = CK 
      IF ( CI .EQ. 1 ) chunk_GA(JPIX)   = dims_GA(JPIX) ! 1 block in X direction
      IF ( CJ .EQ. 1 ) chunk_GA(JPIY)   = dims_GA(JPIY) ! 1 block in Y direction
      IF ( CK .EQ. 1 ) chunk_GA(JPIZ)   = dims_GA(JPIZ) ! 1 block in Z direction
      !
      !   (re)create global array g_a ( if to small create it ... )
      !
      IF ( ( IIU_ll .GT. IIU_ll_MAX ) .OR. ( IJU_ll .GT. IJU_ll_MAX ) .OR. ( IKU_ll .GT. IKU_ll_MAX ) ) THEN
         !
         ! reallocate the g_a , if need with bigger Z size 
         !
         IF ( IKU_ll_MAX .NE. -1 ) gstatus_ga =  ga_destroy(g_a)
         IIU_ll_MAX = IIU_ll
         IJU_ll_MAX = IJU_ll
         IKU_ll_MAX = IKU_ll
         gstatus_ga = nga_create(MT_F_DBL, ndim_GA, dims_GA, HRECFM ,chunk_GA, g_a)
         call ga_sync()
      END IF
      !----------------------------------------------------------------------!
      !                                                                      !
      ! Define/describe local column data owned by this processor to write   !
      !                                                                      !
      !----------------------------------------------------------------------!
      IF ( HRW_MODE .EQ. "WRITE" ) THEN
      CALL GET_DOMWRITE_ll(ISP,'local',NIXO_L,NIXE_L,NIYO_L,NIYE_L)
      CALL GET_DOMWRITE_ll(ISP,'global',NIXO_G,NIXE_G,NIYO_G,NIYE_G)
      ELSE
      CALL GET_DOMREAD_ll(ISP,NIXO_L,NIXE_L,NIYO_L,NIYE_L)
      CALL GET_DOMREAD_ll(ISP,NIXO_G,NIXE_G,NIYO_G,NIYE_G)
      END IF
      !
      ! portion of data to write/put | read/get by this proc
      !
      lo_col(JPIX) = NIXO_G
      hi_col(JPIX) = NIXE_G
      
      lo_col(JPIY) = NIYO_G
      hi_col(JPIY) = NIYE_G
      
      lo_col(JPIZ) = 1
      hi_col(JPIZ) = IKU_ll
      !
      ! declaration size of this local input column array
      !
      ld_col(JPIX) = MY_NI
      ld_col(JPIY) = MY_NJ
      ld_col(JPIZ) = MY_NK
      !
      !-----------------------------------------------------!
      !                                                     !
      !  Size of local ZSLIDE_ll Write buffer on I/O proc   !
      !                                                     !
      !-----------------------------------------------------!
      !
      ! declared dimension 
      !
      ld_zplan(JPIX) = IIU_ll
      ld_zplan(JPIY) = IJU_ll
      ld_zplan(JPIZ) = 1
      !
      ! write data by Z slide by I/O proc
      !
      lo_zplan(JPIX:JPIY) = 1
      hi_zplan(JPIX) = IIU_ll 
      hi_zplan(JPIY) = IJU_ll   
      !call ga_sync()
      !
    END SUBROUTINE MNH_INIT_GA
    
END MODULE MODE_GA

#endif

MODULE MODE_FMWRIT

  USE MODD_MPIF
  USE MODE_FIELD
#if defined(MNH_IOCDF4)
  USE MODE_NETCDF
#endif
  USE MODE_READWRITE_LFI

  IMPLICIT NONE 

  PRIVATE

  INTERFACE IO_WRITE_FIELD
     MODULE PROCEDURE IO_WRITE_FIELD_BYNAME_X0, IO_WRITE_FIELD_BYNAME_X1,  &
                      IO_WRITE_FIELD_BYNAME_X2, IO_WRITE_FIELD_BYNAME_X3,  &
                      IO_WRITE_FIELD_BYNAME_X4, IO_WRITE_FIELD_BYNAME_X5,  &
                      IO_WRITE_FIELD_BYNAME_X6,                            &
                      IO_WRITE_FIELD_BYNAME_N0, IO_WRITE_FIELD_BYNAME_N1,  &
                      IO_WRITE_FIELD_BYNAME_N2, IO_WRITE_FIELD_BYNAME_N3,  &
                      IO_WRITE_FIELD_BYNAME_L0, IO_WRITE_FIELD_BYNAME_L1,  &
                      IO_WRITE_FIELD_BYNAME_C0, IO_WRITE_FIELD_BYNAME_C1,  &
                      IO_WRITE_FIELD_BYNAME_T0,                            &
                      IO_WRITE_FIELD_BYFIELD_X0,IO_WRITE_FIELD_BYFIELD_X1, &
                      IO_WRITE_FIELD_BYFIELD_X2,IO_WRITE_FIELD_BYFIELD_X3, &
                      IO_WRITE_FIELD_BYFIELD_X4,IO_WRITE_FIELD_BYFIELD_X5, &
                      IO_WRITE_FIELD_BYFIELD_X6,                           &
                      IO_WRITE_FIELD_BYFIELD_N0,IO_WRITE_FIELD_BYFIELD_N1, &
                      IO_WRITE_FIELD_BYFIELD_N2,IO_WRITE_FIELD_BYFIELD_N3, &
                      IO_WRITE_FIELD_BYFIELD_L0,IO_WRITE_FIELD_BYFIELD_L1, &
                      IO_WRITE_FIELD_BYFIELD_C0,IO_WRITE_FIELD_BYFIELD_C1, &
                      IO_WRITE_FIELD_BYFIELD_T0
  END INTERFACE

  INTERFACE IO_WRITE_FIELD_BOX
     MODULE PROCEDURE IO_WRITE_FIELD_BOX_BYFIELD_X5
  END INTERFACE

  INTERFACE IO_WRITE_FIELD_LB
     MODULE PROCEDURE IO_WRITE_FIELD_BYNAME_LB, IO_WRITE_FIELD_BYFIELD_LB
  END INTERFACE

  PUBLIC IO_WRITE_FIELD, IO_WRITE_FIELD_BOX, IO_WRITE_FIELD_LB
  PUBLIC IO_WRITE_HEADER

CONTAINS 

  SUBROUTINE FIELD_METADATA_CHECK(TPFIELD,KTYPE,KDIMS,HCALLER)
    TYPE(TFIELDDATA), INTENT(IN) :: TPFIELD ! Field to check
    INTEGER,          INTENT(IN) :: KTYPE   ! Expected datatype
    INTEGER,          INTENT(IN) :: KDIMS   ! Expected number of dimensions
    CHARACTER(LEN=*), INTENT(IN) :: HCALLER ! name of the calling subroutine
    !
    CHARACTER(LEN=2) :: YDIMOK,YDIMKO
    CHARACTER(LEN=8) :: YTYPEOK,YTYPEKO
    !
    IF (TPFIELD%NGRID<0 .OR. TPFIELD%NGRID>4) THEN
      CALL PRINT_MSG(NVERB_WARNING,'IO',HCALLER,'TPFIELD%NGRID is invalid for '//TRIM(TPFIELD%CMNHNAME))
    END IF
    IF (TPFIELD%NTYPE/=KTYPE) THEN
      CALL TYPE_WRITE(KTYPE,YTYPEOK)
      CALL TYPE_WRITE(TPFIELD%NTYPE,YTYPEKO)
      CALL PRINT_MSG(NVERB_WARNING,'IO',HCALLER,&
                     'TPFIELD%NTYPE should be '//YTYPEOK//' instead of '//YTYPEKO//' for '//TRIM(TPFIELD%CMNHNAME))
    END IF
    IF (TPFIELD%NDIMS/=KDIMS) THEN
      WRITE (YDIMOK,'(I2)') KDIMS
      WRITE (YDIMKO,'(I2)') TPFIELD%NDIMS
      CALL PRINT_MSG(NVERB_WARNING,'IO',HCALLER,&
                     'TPFIELD%NDIMS should be '//YDIMOK//' instead of '//YDIMKO//' for '//TRIM(TPFIELD%CMNHNAME))
    END IF
    !
    CONTAINS
    SUBROUTINE TYPE_WRITE(KTYPEINT,HTYPE)
      INTEGER,         INTENT(IN)  :: KTYPEINT
      CHARACTER(LEN=8),INTENT(OUT) :: HTYPE
      !
      SELECT CASE(KTYPEINT)
        CASE(TYPEINT)
          HTYPE = 'TYPEINT'
        CASE(TYPELOG)
          HTYPE = 'TYPELOG'
        CASE(TYPEREAL)
          HTYPE = 'TYPEREAL'
        CASE(TYPECHAR)
          HTYPE = 'TYPECHAR'
        CASE(TYPEDATE)
          HTYPE = 'TYPEDATE'
        CASE DEFAULT
          HTYPE = 'UNKNOWN'
      END SELECT
      !
    END SUBROUTINE TYPE_WRITE
  END SUBROUTINE FIELD_METADATA_CHECK


  SUBROUTINE IO_WRITE_HEADER(TPFILE,HDAD_NAME)
    !
    USE MODD_CONF
    USE MODD_CONF_n, ONLY : CSTORAGE_TYPE
    USE MODD_IO_ll, ONLY: TFILEDATA
    !
    TYPE(TFILEDATA),          INTENT(IN)  :: TPFILE   ! File structure
    CHARACTER(LEN=*),OPTIONAL,INTENT(IN)  :: HDAD_NAME
    !
    CHARACTER(LEN=28) :: YDAD_NAME !Necessary to use a character string of the right length for LFI files
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_HEADER','called for file'//TRIM(TPFILE%CNAME))
    !
    IF ( ASSOCIATED(TPFILE%TDADFILE) .AND. PRESENT(HDAD_NAME) ) THEN
      IF ( TRIM(TPFILE%TDADFILE%CNAME) /= TRIM(HDAD_NAME) ) THEN
        CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_HEADER','TPFILE%TDADFILE%CNAME /= HDAD_NAME')
      END IF
    END IF
    !
    CALL IO_WRITE_HEADER_NC4(TPFILE)
    !
    CALL IO_WRITE_FIELD(TPFILE,'MNHVERSION',  NMNHVERSION)
    CALL IO_WRITE_FIELD(TPFILE,'MASDEV',      NMASDEV)
    CALL IO_WRITE_FIELD(TPFILE,'BUGFIX',      NBUGFIX)
    CALL IO_WRITE_FIELD(TPFILE,'BIBUSER',     CBIBUSER)
    CALL IO_WRITE_FIELD(TPFILE,'PROGRAM',     CPROGRAM)
    CALL IO_WRITE_FIELD(TPFILE,'STORAGE_TYPE',CSTORAGE_TYPE)
    CALL IO_WRITE_FIELD(TPFILE,'MY_NAME',     TPFILE%CNAME)
    IF ( ASSOCIATED(TPFILE%TDADFILE) ) THEN
      YDAD_NAME = TPFILE%TDADFILE%CNAME
    ELSE IF (PRESENT(HDAD_NAME)) THEN
      YDAD_NAME = HDAD_NAME
    ELSE
      CALL PRINT_MSG(NVERB_WARNING,'IO','IO_WRITE_HEADER','TPFILE%TDADFILE not associated and HDAD_NAME not provided')
      YDAD_NAME = ' '
    ENDIF
    CALL IO_WRITE_FIELD(TPFILE,'DAD_NAME',YDAD_NAME)
    !
  END SUBROUTINE IO_WRITE_HEADER


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X0(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),           INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),          INTENT(IN) :: HNAME    ! name of the field to write
    REAL,                      INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,          INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X0',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X0


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X0(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    REAL,TARGET,                 INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    !
    INTEGER                                  :: IK_FILE,IK_RANK
    CHARACTER(len=5)                         :: YK_FILE  
    CHARACTER(len=128)                       :: YFILE_IOZ  
    TYPE(FD_ll), POINTER                     :: TZFD_IOZ 
    TYPE(TFILEDATA),POINTER                  :: TZFILE
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X0',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,0,'IO_WRITE_FIELD_BYFIELD_X0')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
       ELSE ! multiprocessor execution
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
       IF (TZFD%nb_procio.gt.1) THEN
          ! write the data in all Z files
          DO IK_FILE=1,TZFD%nb_procio
             write(YK_FILE ,'(".Z",i3.3)')  IK_FILE
             YFILE_IOZ =  TRIM(YFILEM)//YK_FILE//".lfi"
             TZFD_IOZ => GETFD(YFILE_IOZ)   
             IK_RANK = TZFD_IOZ%OWNER
             IF ( ISP == IK_RANK )  THEN
                CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//YK_FILE,TZFILE,IRESP)
                IF (IRESP/=0) THEN
                  CALL PRINT_MSG(NVERB_FATAL,'IO','IO_WRITE_FIELD_BYFIELD_X0','file '//TRIM(TRIM(TPFILE%CNAME)//YK_FILE)//&
                                 ' not found in list')
                END IF
                IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TZFILE,TPFIELD,PFIELD,IRESP)
                IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TZFILE,TPFIELD,TZFD_IOZ%CDF,PFIELD,IRESP)
             END IF
          END DO
       ENDIF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X0','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X0',YMSG)
    END IF
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X0


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X1(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),           INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),          INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:),         INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,          INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return-code 
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X1',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X1


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X1(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:),TARGET,    INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    INTEGER                                  :: ISIZEMAX
    REAL,DIMENSION(:),POINTER                :: ZFIELDP
    LOGICAL                                  :: GALLOC
    !
    INTEGER                                  :: IK_FILE,IK_RANK
    CHARACTER(len=5)                         :: YK_FILE  
    CHARACTER(len=128)                       :: YFILE_IOZ  
    TYPE(FD_ll), POINTER                     :: TZFD_IOZ 
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X1',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,1,'IO_WRITE_FIELD_BYFIELD_X1')
    !
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
       ELSE ! multiprocessor execution
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X1','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X1','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X1',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X1


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X2(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),           INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),          INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:,:),       INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,          INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return-code 
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X2',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X2


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X2(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !JUANZ
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !JUANZ 
#ifdef MNH_GA
    USE MODE_GA
#endif 
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:,:),TARGET,  INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:),POINTER              :: ZFIELDP
    LOGICAL                                  :: GALLOC
    !
    !JUANZ
    REAL*8,DIMENSION(2) :: T0,T1,T2
    REAL*8,DIMENSION(2) :: T11,T22
    !JUANZ
#ifdef MNH_GA
    REAL,DIMENSION(:,:),POINTER            :: ZFIELDP_GA , ZFIELD_GA
    REAL                                   :: ERROR
    INTEGER                                :: JI
#endif
    INTEGER                                :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE           :: YMSG
    CHARACTER(LEN=6)                       :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X2',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,2,'IO_WRITE_FIELD_BYFIELD_X2')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    CALL SECOND_MNH2(T11)
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          !    IF (LPACK .AND. L1D .AND. YDIR=='XY') THEN 
          IF (LPACK .AND. L1D .AND. SIZE(PFIELD,1)==IHEXTOT .AND. SIZE(PFIELD,2)==IHEXTOT) THEN 
             ZFIELDP=>PFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(PFIELD,2)==IHEXTOT) THEN
             ZFIELDP=>PFIELD(:,JPHEXT+1:JPHEXT+1)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
          END IF
       ELSE ! multiprocessor execution
          CALL SECOND_MNH2(T0)
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X2','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             ! I/O processor case
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0,0))
             GALLOC = .TRUE.
          END IF
          !   
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',PFIELD(:,JPHEXT+1),ZFIELDP(:,1),TZFD%OWNER,TZFD%COMM)
             ELSE
#ifdef MNH_GA
          !
          ! init/create the ga , dim3 = 1
          !
          CALL MNH_INIT_GA(SIZE(PFIELD,1),SIZE(PFIELD,2),1,YRECFM,"WRITE")
         !
         !   copy columun data to global arrays g_a 
         !
         ALLOCATE (ZFIELD_GA (SIZE(PFIELD,1),SIZE(PFIELD,2)))
         ZFIELD_GA = PFIELD
         call nga_put(g_a, lo_col, hi_col,ZFIELD_GA(NIXO_L,NIYO_L) , ld_col)  
!!$         print*," nga_put =",YRECFM,g_a," lo_col=",lo_col," hi_col=",hi_col,ZFIELD_GA(NIXO_L,NIYO_L), &
!!$          " NIXO_L=",NIXO_L,"NIYO_L=",NIYO_L," ld_col=",ld_col," ISP=",ISP
         call ga_sync
         DEALLOCATE (ZFIELD_GA)
         IF (ISP == TZFD%OWNER)  THEN      
            !
            ! this proc get the  Z slide to write
            !
            lo_zplan(JPIZ) = 1
            hi_zplan(JPIZ) = 1
!!$            ALLOCATE (ZFIELDP_GA(IIU_ll,IJU_ll))
            call nga_get(g_a, lo_zplan, hi_zplan,ZFIELDP, ld_zplan)
!!$            print*,"nga_get=",YRECFM,g_a," lo_zplan=",lo_zplan," hi_zplan=",hi_zplan &
!!$                 ,ZFIELDP(1,1)," ld_zplan=",ld_zplan
         END IF
!!$         call ga_sync
#else
         CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
!!$         IF (ISP == TZFD%OWNER)  THEN   
!!$            print*,YRECFM, "ERR=", MAXVAL (ZFIELDP_GA - ZFIELDP)
!!$            DO JI=1,IJU_ll
!!$            !print*,YRECFM, "ERR=", ZFIELDP_GA(:,JI) - ZFIELDP(:,JI)
!!$            print*,YRECFM, "WX2::GA =", ZFIELDP_GA(:,JI) 
!!$            print*,YRECFM, "WX2::MNH=", ZFIELDP(:,JI)
!!$         END DO
!!$         END IF
#endif
             END IF
          END IF
          CALL SECOND_MNH2(T1)
          TIMEZ%T_WRIT2D_GATH=TIMEZ%T_WRIT2D_GATH + T1 - T0
          !
          IF (ISP == TZFD%OWNER)  THEN             
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
#ifdef MNH_GA
!!$         IF (ISP .EQ. 1 ) THEN
!!$         call ga_print_stats()
!!$         call ga_summarize(1) 
!!$         ENDIF
         call ga_sync
!!$         gstatus_ga =  ga_destroy(g_a)
#endif     
          CALL SECOND_MNH2(T2)
          TIMEZ%T_WRIT2D_WRIT=TIMEZ%T_WRIT2D_WRIT + T2 - T1
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD&
               & %COMM,IERR)
       END IF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X2','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X2',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    CALL SECOND_MNH2(T22)
    TIMEZ%T_WRIT2D_ALL=TIMEZ%T_WRIT2D_ALL + T22 - T11
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X2


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X3(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:,:,:),       INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X3',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X3


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X3(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !JUANZ
    USE MODE_IO_ll, ONLY : io_file,io_rank
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !JUANZ 
#ifdef MNH_GA
    USE MODE_GA
#endif
    USE MODD_VAR_ll, ONLY : MNH_STATUSES_IGNORE
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:,:,:),TARGET,INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:,:),POINTER            :: ZFIELDP
    LOGICAL                                  :: GALLOC
    !JUAN
    INTEGER                                  :: JK,JKK
    REAL,DIMENSION(:,:),POINTER              :: ZSLIDE_ll,ZSLIDE
    INTEGER                                  :: IK_FILE,IK_rank,inb_proc_real,JK_MAX
    CHARACTER(len=5)                         :: YK_FILE  
    CHARACTER(len=128)                       :: YFILE_IOZ  
    TYPE(FD_ll), POINTER                     :: TZFD_IOZ 
    INTEGER                                  :: JI,IXO,IXE,IYO,IYE
    REAL,DIMENSION(:,:),POINTER              :: TX2DP
    INTEGER, DIMENSION(MPI_STATUS_SIZE)      :: STATUS
    INTEGER, ALLOCATABLE,DIMENSION(:,:)      :: STATUSES
    LOGICAL                                  :: GALLOC_ll
    !JUANZIO
    !INTEGER,SAVE,DIMENSION(100000)    :: REQ_TAB
    INTEGER,ALLOCATABLE,DIMENSION(:)         :: REQ_TAB
    INTEGER                                  :: NB_REQ
    TYPE TX_2DP
       REAL,DIMENSION(:,:), POINTER    :: X
    END TYPE TX_2DP
    TYPE(TX_2DP),ALLOCATABLE,DIMENSION(:) :: T_TX2DP
    REAL*8,DIMENSION(2) :: T0,T1,T2
    REAL*8,DIMENSION(2) :: T11,T22
    !JUANZIO
    !JUAN
#ifdef MNH_GA
    REAL,DIMENSION(:,:,:),POINTER          :: ZFIELD_GA
#endif
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X3',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,3,'IO_WRITE_FIELD_BYFIELD_X3')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    CALL SECOND_MNH2(T11)
    IRESP = 0
    GALLOC    = .FALSE.
    GALLOC_ll = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
!
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC .AND.  (TZFD%nb_procio.eq.1) ) THEN ! sequential execution
          !    IF (LPACK .AND. L1D .AND. YDIR=='XY') THEN 
          IF (LPACK .AND. L1D .AND. SIZE(PFIELD,1)==IHEXTOT .AND. SIZE(PFIELD,2)==IHEXTOT) THEN 
             ZFIELDP=>PFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(PFIELD,2)==IHEXTOT) THEN
             ZFIELDP=>PFIELD(:,JPHEXT+1:JPHEXT+1,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
          END IF
       ELSEIF ( (TZFD%nb_procio .eq. 1 ) .OR. ( YDIR == '--' ) ) THEN  ! multiprocessor execution & 1 proc IO
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X3','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          ! write 3D field in 1 time = output for graphique
          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0,0,0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',PFIELD(:,JPHEXT+1,:),ZFIELDP(:,1,:),TZFD%OWNER,TZFD%COMM)
             ELSE
                CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
             END IF
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD&
               & %COMM,IERR)
          !
       ELSE ! multiprocessor execution & // IO
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X3','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF
          !
          !JUAN BG Z SLIDE 
          !
          !
#ifdef MNH_GA
          !
          ! init/create the ga
          !
          CALL SECOND_MNH2(T0)
          CALL MNH_INIT_GA(SIZE(PFIELD,1),SIZE(PFIELD,2),SIZE(PFIELD,3),YRECFM,"WRITE")
         !
         !   copy columun data to global arrays g_a 
         !
         ALLOCATE (ZFIELD_GA (SIZE(PFIELD,1),SIZE(PFIELD,2),SIZE(PFIELD,3)))
         ZFIELD_GA = PFIELD
         call nga_put(g_a, lo_col, hi_col,ZFIELD_GA(NIXO_L,NIYO_L,1) , ld_col)  
         DEALLOCATE(ZFIELD_GA)
!!$         print*," nga_put =",YRECFM,g_a," lo_col=",lo_col," hi_col=",hi_col,PFIELD(NIXO_L,NIYO_L,1) &
!!$          ," ld_col=",ld_col
         call ga_sync
         CALL SECOND_MNH2(T1)
         TIMEZ%T_WRIT3D_SEND=TIMEZ%T_WRIT3D_SEND + T1 - T0
         !
         ! write the data
         !
         ALLOCATE(ZSLIDE_ll(0,0)) ! to avoid bug on test of size
         GALLOC_ll = .TRUE.
         !
         DO JKK=1,IKU_ll
            !
            IK_FILE   =  io_file(JKK,TZFD%nb_procio)
            write(YK_FILE ,'(".Z",i3.3)') IK_FILE+1
            YFILE_IOZ =  TRIM(YFILEM)//YK_FILE//".lfi"
            TZFD_IOZ => GETFD(YFILE_IOZ)
            !
            IK_RANK   =  TZFD_IOZ%OWNER
            !IK_RANK   =  1 + io_rank(IK_FILE,ISNPROC,TZFD%nb_procio)
            !
            IF (ISP == IK_RANK )  THEN 
               CALL SECOND_MNH2(T0)
               !
               IF ( SIZE(ZSLIDE_ll) .EQ. 0 ) THEN
                  DEALLOCATE(ZSLIDE_ll)
                  CALL ALLOCBUFFER_ll(ZSLIDE_ll,ZSLIDE,YDIR,GALLOC_ll)
               END IF
               !
               ! this proc get this JKK slide
               !
               lo_zplan(JPIZ) = JKK
               hi_zplan(JPIZ) = JKK
               call nga_get(g_a, lo_zplan, hi_zplan,ZSLIDE_ll, ld_zplan)
               CALL SECOND_MNH2(T1)
               TIMEZ%T_WRIT3D_RECV=TIMEZ%T_WRIT3D_RECV + T1 - T0
               !
               IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZSLIDE_ll,IRESP,KVERTLEVEL=JKK)
               IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD_IOZ%CDF,ZSLIDE_ll,IRESP,KVERTLEVEL=JKK,KZFILE=IK_FILE+1)
               CALL SECOND_MNH2(T2)
               TIMEZ%T_WRIT3D_WRIT=TIMEZ%T_WRIT3D_WRIT + T2 - T1
            END IF
         END DO
         !call ga_sync
         !
         ! destroy the global array 
         !
!!$         IF (ISP .EQ. 1 ) THEN
!!$         call ga_print_stats()
!!$         call ga_summarize(1) 
!!$         ENDIF
         CALL SECOND_MNH2(T0) 
         call ga_sync
!!$         gstatus_ga =  ga_destroy(g_a)
         CALL SECOND_MNH2(T1) 
         TIMEZ%T_WRIT3D_WAIT=TIMEZ%T_WRIT3D_WAIT + T1 - T0     
#else
          !
          ALLOCATE(ZSLIDE_ll(0,0))
          GALLOC_ll = .TRUE.
          inb_proc_real = min(TZFD%nb_procio,ISNPROC)
          Z_SLIDE: DO JK=1,SIZE(PFIELD,3),inb_proc_real
             !
             ! collecte the data
             !
             JK_MAX=min(SIZE(PFIELD,3),JK+inb_proc_real-1)
             !
             NB_REQ=0
             ALLOCATE(REQ_TAB(inb_proc_real))
             ALLOCATE(T_TX2DP(inb_proc_real))
             DO JKK=JK,JK_MAX
                !
                ! get the file & rank to write this level
                !
                IF (TZFD%NB_PROCIO .GT. 1 ) THEN
                   IK_FILE   =  io_file(JKK,TZFD%nb_procio)
                   write(YK_FILE ,'(".Z",i3.3)') IK_FILE+1
                   YFILE_IOZ =  TRIM(YFILEM)//YK_FILE//".lfi"
                   TZFD_IOZ => GETFD(YFILE_IOZ)
                ELSE
                   TZFD_IOZ => TZFD
                END IF
                !
                !IK_RANK   =  1 + io_rank(IK_FILE,ISNPROC,TZFD%nb_procio)
                IK_RANK   =  TZFD_IOZ%OWNER
                !
                IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
                   STOP " XX NON PREVU SUR BG POUR LE MOMENT "
                   CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
                ELSEIF (YDIR == 'XY') THEN
                   IF (LPACK .AND. L2D) THEN
                      STOP " L2D NON PREVU SUR BG POUR LE MOMENT "
                      CALL GATHER_XXFIELD('XX',PFIELD(:,JPHEXT+1,:),ZFIELDP(:,1,:),TZFD%OWNER,TZFD%COMM)
                   ELSE
                      !CALL GATHER_XYFIELD(ZSLIDE,ZSLIDE_ll,TZFD_IOZ%OWNER,TZFD_IOZ%COMM)
                      !JUANIOZ
                      CALL SECOND_MNH2(T0)
                      IF ( ISP /= IK_RANK )  THEN
                         ! Other processors
                         CALL GET_DOMWRITE_ll(ISP,'local',IXO,IXE,IYO,IYE)
                         IF (IXO /= 0) THEN ! intersection is not empty
                            NB_REQ = NB_REQ + 1
                            ALLOCATE(T_TX2DP(NB_REQ)%X(IXO:IXE,IYO:IYE))
                            ZSLIDE => PFIELD(:,:,JKK)
                            TX2DP=>ZSLIDE(IXO:IXE,IYO:IYE)
                            T_TX2DP(NB_REQ)%X=ZSLIDE(IXO:IXE,IYO:IYE)
                            CALL MPI_ISEND(T_TX2DP(NB_REQ)%X,SIZE(TX2DP),MPI_FLOAT,IK_RANK-1,99+IK_RANK &
                                          & ,TZFD_IOZ%COMM,REQ_TAB(NB_REQ),IERR)
                            !CALL MPI_BSEND(TX2DP,SIZE(TX2DP),MPI_FLOAT,IK_RANK-1,99+IK_RANK,TZFD_IOZ%COMM,IERR)                       
                         END IF
                      END IF
                      CALL SECOND_MNH2(T1)
                      TIMEZ%T_WRIT3D_SEND=TIMEZ%T_WRIT3D_SEND + T1 - T0
                      !JUANIOZ
                   END IF
                END IF
             END DO
             !
             ! write the data
             !
             DO JKK=JK,JK_MAX
                IF (TZFD%NB_PROCIO .GT. 1 ) THEN
                   IK_FILE   =  io_file(JKK,TZFD%nb_procio)
                   write(YK_FILE ,'(".Z",i3.3)') IK_FILE+1
                   YFILE_IOZ =  TRIM(YFILEM)//YK_FILE//".lfi"
                   TZFD_IOZ => GETFD(YFILE_IOZ)
                ELSE
                   TZFD_IOZ => TZFD
                ENDIF
                IK_RANK   =  TZFD_IOZ%OWNER
                !IK_RANK   =  1 + io_rank(IK_FILE,ISNPROC,TZFD%nb_procio)
                !
                IF (ISP == IK_RANK )  THEN
                   !JUANIOZ
                   CALL SECOND_MNH2(T0)
                   ! I/O proc case
                   IF ( SIZE(ZSLIDE_ll) .EQ. 0 ) THEN
                      DEALLOCATE(ZSLIDE_ll)
                      CALL ALLOCBUFFER_ll(ZSLIDE_ll,ZSLIDE,YDIR,GALLOC_ll)
                   END IF
                   DO JI=1,ISNPROC
                      CALL GET_DOMWRITE_ll(JI,'global',IXO,IXE,IYO,IYE)
                      IF (IXO /= 0) THEN ! intersection is not empty
                         TX2DP=>ZSLIDE_ll(IXO:IXE,IYO:IYE)
                         IF (ISP == JI) THEN 
                            CALL GET_DOMWRITE_ll(JI,'local',IXO,IXE,IYO,IYE)
                            ZSLIDE => PFIELD(:,:,JKK)
                            TX2DP = ZSLIDE(IXO:IXE,IYO:IYE)
                         ELSE 
                            CALL MPI_RECV(TX2DP,SIZE(TX2DP),MPI_FLOAT,JI-1,99+IK_RANK,TZFD_IOZ%COMM,STATUS,IERR)
                         END IF
                      END IF
                   END DO
                   CALL SECOND_MNH2(T1)
                   TIMEZ%T_WRIT3D_RECV=TIMEZ%T_WRIT3D_RECV + T1 - T0
                   !JUANIOZ 
                   IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZSLIDE_ll,IRESP,KVERTLEVEL=JKK)
                   IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD_IOZ%CDF,ZSLIDE_ll,IRESP,KVERTLEVEL=JKK,KZFILE=IK_FILE+1)
                   CALL SECOND_MNH2(T2)
                   TIMEZ%T_WRIT3D_WRIT=TIMEZ%T_WRIT3D_WRIT + T2 - T1
                END IF
!!$           CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD_IOZ%OWNER-1,TZFD_IOZ%COMM,IERR)
             END DO
             !CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD_IOZ%OWNER-1,TZFD_IOZ%COMM,IERR)
             !CALL MPI_BARRIER(TZFD_IOZ%COMM,IERR)
             !
             CALL SECOND_MNH2(T0) 
             IF (NB_REQ .GT.0 ) THEN
                !ALLOCATE(STATUSES(MPI_STATUS_SIZE,NB_REQ))
                CALL MPI_WAITALL(NB_REQ,REQ_TAB,MNH_STATUSES_IGNORE,IERR)
                !CALL MPI_WAITALL(NB_REQ,REQ_TAB,STATUSES,IERR)
                !DEALLOCATE(STATUSES)
                DO JI=1,NB_REQ ;  DEALLOCATE(T_TX2DP(JI)%X) ; ENDDO
             END IF
             DEALLOCATE(T_TX2DP)
             DEALLOCATE(REQ_TAB)
             CALL SECOND_MNH2(T1) 
             TIMEZ%T_WRIT3D_WAIT=TIMEZ%T_WRIT3D_WAIT + T1 - T0
          END DO Z_SLIDE
          !JUAN BG Z SLIDE  
! end of MNH_GA
#endif
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X3','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X3',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (GALLOC_ll) DEALLOCATE(ZSLIDE_ll)
    !IF (Associated(ZSLIDE_ll)) DEALLOCATE(ZSLIDE_ll)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    CALL SECOND_MNH2(T22)
    TIMEZ%T_WRIT3D_ALL=TIMEZ%T_WRIT3D_ALL + T22 - T11
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X3


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X4(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:,:,:,:),     INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X4',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X4


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X4(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !JUANZ
    USE MODE_IO_ll, ONLY : io_file,io_rank
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !JUANZ 
    USE MODD_VAR_ll, ONLY : MNH_STATUSES_IGNORE
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),                 INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),                INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:,:,:,:),TARGET,  INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,                INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:,:,:),POINTER          :: ZFIELDP
    LOGICAL                                  :: GALLOC
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X4',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,4,'IO_WRITE_FIELD_BYFIELD_X4')
    !
    IRESP = 0
    GALLOC    = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
!
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          !    IF (LPACK .AND. L1D .AND. YDIR=='XY') THEN 
          IF (LPACK .AND. L1D .AND. SIZE(PFIELD,1)==IHEXTOT .AND. SIZE(PFIELD,2)==IHEXTOT) THEN 
             ZFIELDP=>PFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1,:,:)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(PFIELD,2)==IHEXTOT) THEN
             ZFIELDP=>PFIELD(:,JPHEXT+1:JPHEXT+1,:,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
          END IF
       ELSE
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X4','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0,0,0,0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',PFIELD(:,JPHEXT+1,:,:),ZFIELDP(:,1,:,:),TZFD%OWNER,TZFD%COMM)
             ELSE
                CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
             END IF
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X4','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X4',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X4


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X5(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:,:,:,:,:),   INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X5',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X5


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X5(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !JUANZ
    USE MODE_IO_ll, ONLY : io_file,io_rank
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !JUANZ 
    USE MODD_VAR_ll, ONLY : MNH_STATUSES_IGNORE
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),                 INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),                INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:,:,:,:,:),TARGET,INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,                INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:,:,:,:),POINTER        :: ZFIELDP
    LOGICAL                                  :: GALLOC
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X5',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,5,'IO_WRITE_FIELD_BYFIELD_X5')
    !
    IRESP = 0
    GALLOC    = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
!
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          !    IF (LPACK .AND. L1D .AND. YDIR=='XY') THEN 
          IF (LPACK .AND. L1D .AND. SIZE(PFIELD,1)==IHEXTOT .AND. SIZE(PFIELD,2)==IHEXTOT) THEN 
             ZFIELDP=>PFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1,:,:,:)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(PFIELD,2)==IHEXTOT) THEN
             ZFIELDP=>PFIELD(:,JPHEXT+1:JPHEXT+1,:,:,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
          END IF
       ELSE
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X5','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0,0,0,0,0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',PFIELD(:,JPHEXT+1,:,:,:),ZFIELDP(:,1,:,:,:),&
                     & TZFD%OWNER,TZFD%COMM)
             ELSE
                CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
             END IF
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X5','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X5',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X5


  SUBROUTINE IO_WRITE_FIELD_BYNAME_X6(TPFILE,HNAME,PFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    REAL,DIMENSION(:,:,:,:,:,:), INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_X6',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),PFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_X6

  SUBROUTINE IO_WRITE_FIELD_BYFIELD_X6(TPFILE,TPFIELD,PFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !JUANZ
    USE MODE_IO_ll, ONLY : io_file,io_rank
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !JUANZ 
    USE MODD_VAR_ll, ONLY : MNH_STATUSES_IGNORE
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),                   INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),                  INTENT(IN) :: TPFIELD
    REAL,DIMENSION(:,:,:,:,:,:),TARGET,INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,OPTIONAL,                  INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:,:,:,:,:),POINTER      :: ZFIELDP
    LOGICAL                                  :: GALLOC
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_X6',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEREAL,6,'IO_WRITE_FIELD_BYFIELD_X6')
    !
    IRESP = 0
    GALLOC    = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
!
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PFIELD,IRESP)
       ELSE
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(PFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_X6','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(ZFIELDP,PFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(ZFIELDP(0,0,0,0,0,0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM)
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X6','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_X6',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_X6


  SUBROUTINE IO_WRITE_FIELD_BYNAME_N0(TPFILE,HNAME,KFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    INTEGER,                     INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_N0',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),KFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_N0


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_N0(TPFILE,TPFIELD,KFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
    !*      0.    DECLARATIONS
    !             ------------
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    INTEGER,                     INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER                      :: IERR
    TYPE(FD_ll), POINTER         :: TZFD
    INTEGER                      :: IRESP
    !JUANZIO
    INTEGER                                  :: IK_FILE,IK_RANK
    CHARACTER(len=5)                         :: YK_FILE  
    CHARACTER(len=128)                       :: YFILE_IOZ  
    TYPE(FD_ll), POINTER                     :: TZFD_IOZ 
    TYPE(TFILEDATA),POINTER                  :: TZFILE
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_N0',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEINT,0,'IO_WRITE_FIELD_BYFIELD_N0')
    !
    IRESP = 0
    !------------------------------------------------------------------
    TZFD=>GETFD(TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi')
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,KFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,KFIELD,IRESP)
       ELSE 
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,KFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,KFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
       IF (TZFD%nb_procio.gt.1) THEN
          ! write the data in all Z files
          DO IK_FILE=1,TZFD%nb_procio
             write(YK_FILE ,'(".Z",i3.3)')  IK_FILE
             YFILE_IOZ =  TRIM(TPFILE%CNAME)//YK_FILE//".lfi"
             TZFD_IOZ => GETFD(YFILE_IOZ)   
             IK_RANK = TZFD_IOZ%OWNER
             IF ( ISP == IK_RANK )  THEN
                CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//YK_FILE,TZFILE,IRESP)
                IF (IRESP/=0) THEN
                  CALL PRINT_MSG(NVERB_FATAL,'IO','IO_WRITE_FIELD_BYFIELD_N0','file '//TRIM(TRIM(TPFILE%CNAME)//YK_FILE)//&
                                  ' not found in list')
                END IF
                IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TZFILE,TPFIELD,KFIELD,IRESP)
                IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TZFILE,TPFIELD,TZFD_IOZ%CDF,KFIELD,IRESP)
             END IF
          END DO
       ENDIF
    ELSE 
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N0','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N0',YMSG)
    END IF
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_N0


  SUBROUTINE IO_WRITE_FIELD_BYNAME_N1(TPFILE,HNAME,KFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    INTEGER,DIMENSION(:),        INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_N1',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),KFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_N1


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_N1(TPFILE,TPFIELD,KFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : ISP,GSMONOPROC,LIOCDF4,LLFIOUT,TFILEDATA
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),              INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),             INTENT(IN) :: TPFIELD
    INTEGER,DIMENSION(:),TARGET,  INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,             INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    INTEGER,DIMENSION(:),POINTER             :: IFIELDP
    LOGICAL                                  :: GALLOC
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_N1',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEINT,1,'IO_WRITE_FIELD_BYFIELD_N1')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,KFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,KFIELD,IRESP)
       ELSE ! multiprocessor execution
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_N1','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(IFIELDP,KFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(IFIELDP(0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,KFIELD,IFIELDP,TZFD%OWNER,TZFD%COMM)
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N1','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N1',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(IFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    !
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_N1

  
  SUBROUTINE IO_WRITE_FIELD_BYNAME_N2(TPFILE,HNAME,KFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    INTEGER,DIMENSION(:,:),      INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_N2',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),KFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_N2


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_N2(TPFILE,TPFIELD,KFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),              INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),             INTENT(IN) :: TPFIELD
    INTEGER,DIMENSION(:,:),TARGET,INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,             INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    INTEGER,DIMENSION(:,:),POINTER           :: IFIELDP
    LOGICAL                                  :: GALLOC
    !
    !JUANZ
    REAL*8,DIMENSION(2) :: T0,T1,T2
    REAL*8,DIMENSION(2) :: T11,T22
    !JUANZ
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_N2',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEINT,2,'IO_WRITE_FIELD_BYFIELD_N2')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    CALL SECOND_MNH2(T11)
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LPACK .AND. L1D .AND. SIZE(KFIELD,1)==IHEXTOT .AND. SIZE(KFIELD,2)==IHEXTOT) THEN 
             IFIELDP=>KFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(KFIELD,2)==IHEXTOT) THEN
             IFIELDP=>KFIELD(:,JPHEXT+1:JPHEXT+1)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,KFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,KFIELD,IRESP)
          END IF
       ELSE ! multiprocessor execution
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_N2','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          CALL SECOND_MNH2(T0)
          IF (ISP == TZFD%OWNER)  THEN
             ! I/O processor case
             CALL ALLOCBUFFER_ll(IFIELDP,KFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(IFIELDP(0,0))
             GALLOC = .TRUE.
          END IF
          !   
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,KFIELD,IFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',KFIELD(:,JPHEXT+1),IFIELDP(:,1),TZFD%OWNER,TZFD%COMM)
             ELSE
                CALL GATHER_XYFIELD(KFIELD,IFIELDP,TZFD%OWNER,TZFD%COMM)
             END IF
          END IF
          CALL SECOND_MNH2(T1)
          TIMEZ%T_WRIT2D_GATH=TIMEZ%T_WRIT2D_GATH + T1 - T0
          !
          IF (ISP == TZFD%OWNER)  THEN             
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
          END IF
          CALL SECOND_MNH2(T2)
          TIMEZ%T_WRIT2D_WRIT=TIMEZ%T_WRIT2D_WRIT + T2 - T1
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N2','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N2',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(IFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    CALL SECOND_MNH2(T22)
    TIMEZ%T_WRIT2D_ALL=TIMEZ%T_WRIT2D_ALL + T22 - T11
    !
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_N2


  SUBROUTINE IO_WRITE_FIELD_BYNAME_N3(TPFILE,HNAME,KFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    INTEGER,DIMENSION(:,:,:),    INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_N3',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),KFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_N3

  SUBROUTINE IO_WRITE_FIELD_BYFIELD_N3(TPFILE,TPFIELD,KFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    USE MODD_TIMEZ, ONLY : TIMEZ
    USE MODE_MNH_TIMING, ONLY : SECOND_MNH2
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),                INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),               INTENT(IN) :: TPFIELD
    INTEGER,DIMENSION(:,:,:),TARGET,INTENT(IN) :: KFIELD   ! array containing the data field
    INTEGER,OPTIONAL,               INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    INTEGER,DIMENSION(:,:,:),POINTER         :: IFIELDP
    LOGICAL                                  :: GALLOC
    !
    !JUANZ
    REAL*8,DIMENSION(2) :: T11,T22
    !JUANZ
    INTEGER                                  :: IHEXTOT
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_N3',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    !*      1.1   THE NAME OF LFIFM
    !
    CALL SECOND_MNH2(T11)
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    IHEXTOT = 2*JPHEXT+1
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LPACK .AND. L1D .AND. SIZE(KFIELD,1)==IHEXTOT .AND. SIZE(KFIELD,2)==IHEXTOT) THEN 
             IFIELDP=>KFIELD(JPHEXT+1:JPHEXT+1,JPHEXT+1:JPHEXT+1,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
             !    ELSE IF (LPACK .AND. L2D .AND. YDIR=='XY') THEN
          ELSEIF (LPACK .AND. L2D .AND. SIZE(KFIELD,2)==IHEXTOT) THEN
             IFIELDP=>KFIELD(:,JPHEXT+1:JPHEXT+1,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,KFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,KFIELD,IRESP)
          END IF
       ELSE ! multiprocessor execution
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(KFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_N3','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             ! I/O processor case
             CALL ALLOCBUFFER_ll(IFIELDP,KFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(IFIELDP(0,0,0))
             GALLOC = .TRUE.
          END IF
          !   
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,KFIELD,IFIELDP,TZFD%OWNER,TZFD%COMM)
          ELSEIF (YDIR == 'XY') THEN
             IF (LPACK .AND. L2D) THEN
                CALL GATHER_XXFIELD('XX',KFIELD(:,JPHEXT+1,:),IFIELDP(:,1,:),TZFD%OWNER,TZFD%COMM)
             ELSE
                CALL GATHER_XYFIELD(KFIELD,IFIELDP,TZFD%OWNER,TZFD%COMM)
             END IF
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN             
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,IFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N3','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_N3',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(IFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    CALL SECOND_MNH2(T22)
    TIMEZ%T_WRIT3D_ALL=TIMEZ%T_WRIT3D_ALL + T22 - T11
    !
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_N3


  SUBROUTINE IO_WRITE_FIELD_BYNAME_L0(TPFILE,HNAME,OFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    LOGICAL,                     INTENT(IN) :: OFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_L0',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),OFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_L0

  SUBROUTINE IO_WRITE_FIELD_BYFIELD_L0(TPFILE,TPFIELD,OFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_IO_MANAGE_STRUCT, ONLY: IO_FILE_FIND_BYNAME
    !*      0.    DECLARATIONS
    !             ------------
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    LOGICAL,                     INTENT(IN) :: OFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER                      :: IERR
    TYPE(FD_ll), POINTER         :: TZFD
    INTEGER                      :: IRESP
    !JUANZIO
    INTEGER                                  :: IK_FILE,IK_RANK
    CHARACTER(len=5)                         :: YK_FILE
    CHARACTER(len=128)                       :: YFILE_IOZ
    TYPE(FD_ll), POINTER                     :: TZFD_IOZ
    TYPE(TFILEDATA),POINTER                  :: TZFILE
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_L0',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPELOG,0,'IO_WRITE_FIELD_BYFIELD_L0')
    !
    IRESP = 0
    !------------------------------------------------------------------
    TZFD=>GETFD(TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi')
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,OFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,OFIELD,IRESP)
       ELSE
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,OFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,OFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
       IF (TZFD%nb_procio.gt.1) THEN
          ! write the data in all Z files
          DO IK_FILE=1,TZFD%nb_procio
             write(YK_FILE ,'(".Z",i3.3)')  IK_FILE
             YFILE_IOZ =  TRIM(TPFILE%CNAME)//YK_FILE//".lfi"
             TZFD_IOZ => GETFD(YFILE_IOZ)
             IK_RANK = TZFD_IOZ%OWNER
             IF ( ISP == IK_RANK )  THEN
                CALL IO_FILE_FIND_BYNAME(TRIM(TPFILE%CNAME)//YK_FILE,TZFILE,IRESP)
                IF (IRESP/=0) THEN
                  CALL PRINT_MSG(NVERB_FATAL,'IO','IO_WRITE_FIELD_BYFIELD_L0','file '//TRIM(TRIM(TPFILE%CNAME)//YK_FILE)//&
                                 ' not found in list')
                END IF
                IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TZFILE,TPFIELD,OFIELD,IRESP)
                IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TZFILE,TPFIELD,TZFD_IOZ%CDF,OFIELD,IRESP)
             END IF
          END DO
       ENDIF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_L0','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_L0',YMSG)
    END IF
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_L0


  SUBROUTINE IO_WRITE_FIELD_BYNAME_L1(TPFILE,HNAME,OFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    LOGICAL,DIMENSION(:),        INTENT(IN) :: OFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_L1',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),OFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_L1


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_L1(TPFILE,TPFIELD,OFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : ISP,GSMONOPROC,LIOCDF4,LLFIOUT,TFILEDATA
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_ALLOCBUFFER_ll
    USE MODE_GATHER_ll
    !
    IMPLICIT NONE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),              INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),             INTENT(IN) :: TPFIELD
    LOGICAL,DIMENSION(:),TARGET,  INTENT(IN) :: OFIELD   ! array containing the data field
    INTEGER,OPTIONAL,             INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=2)                         :: YDIR     ! field form
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IERR
    INTEGER                                  :: ISIZEMAX
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    LOGICAL,DIMENSION(:),POINTER             :: GFIELDP
    LOGICAL                                  :: GALLOC
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YDIR     = TPFIELD%CDIR
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_L1',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPELOG,1,'IO_WRITE_FIELD_BYFIELD_L1')
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !------------------------------------------------------------------
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,OFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,OFIELD,IRESP)
       ELSE ! multiprocessor execution
#ifndef MNH_INT8
          CALL MPI_ALLREDUCE(SIZE(OFIELD),ISIZEMAX,1,MPI_INTEGER,MPI_MAX,TZFD%COMM,IRESP)
#else
          CALL MPI_ALLREDUCE(SIZE(OFIELD),ISIZEMAX,1,MPI_INTEGER8,MPI_MAX,TZFD%COMM,IRESP)
#endif
          IF (ISIZEMAX==0) THEN
             CALL PRINT_MSG(NVERB_INFO,'IO','IO_WRITE_FIELD_BYFIELD_L1','ignoring variable with a zero size ('//TRIM(YRECFM)//')')
             IF (PRESENT(KRESP)) KRESP=0
             RETURN
          END IF

          IF (ISP == TZFD%OWNER)  THEN
             CALL ALLOCBUFFER_ll(GFIELDP,OFIELD,YDIR,GALLOC)
          ELSE
             ALLOCATE(GFIELDP(0))
             GALLOC = .TRUE.
          END IF
          !
          IF (YDIR == 'XX' .OR. YDIR =='YY') THEN
             CALL GATHER_XXFIELD(YDIR,OFIELD,GFIELDP,TZFD%OWNER,TZFD%COMM)
          END IF
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,GFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,GFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_L1','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_L1',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(GFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
    IF (ASSOCIATED(TZFD)) CALL MPI_BARRIER(TZFD%COMM,IERR)
    !
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_L1


  SUBROUTINE IO_WRITE_FIELD_BYNAME_C0(TPFILE,HNAME,HFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    CHARACTER(LEN=*),            INTENT(IN) :: HFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_C0',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),HFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_C0


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_C0(TPFILE,TPFIELD,HFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    !*      0.    DECLARATIONS
    !             ------------
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    CHARACTER(LEN=*),            INTENT(IN) :: HFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER                      :: IERR
    TYPE(FD_ll), POINTER         :: TZFD
    INTEGER                      :: IRESP
    CHARACTER(LEN=:),ALLOCATABLE :: YMSG
    CHARACTER(LEN=6)             :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_C0',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPECHAR,0,'IO_WRITE_FIELD_BYFIELD_C0')
    !
    IRESP = 0
    !
    IF (LEN(HFIELD)==0 .AND. LLFIOUT) THEN
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_C0',&
                     'zero-size string not allowed if LFI output for '//TRIM(TPFIELD%CMNHNAME))
    END IF
    !------------------------------------------------------------------
    TZFD=>GETFD(TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi')
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,HFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,HFIELD,IRESP)
       ELSE 
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,HFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,HFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE 
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_C0','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_C0',YMSG)
    END IF
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_C0


  SUBROUTINE IO_WRITE_FIELD_BYNAME_C1(TPFILE,HNAME,HFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),              INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),             INTENT(IN) :: HNAME    ! name of the field to write
    CHARACTER(LEN=*),DIMENSION(:),INTENT(IN) :: HFIELD   ! array containing the data field
    INTEGER,OPTIONAL,             INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_C1',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),HFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_C1


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_C1(TPFILE,TPFIELD,HFIELD,KRESP)
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    !*      0.    DECLARATIONS
    !             ------------
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),              INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),             INTENT(IN) :: TPFIELD
    CHARACTER(LEN=*),DIMENSION(:),INTENT(IN) :: HFIELD   ! array containing the data field
    INTEGER,OPTIONAL,             INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER                          :: IERR
    TYPE(FD_ll), POINTER             :: TZFD
    INTEGER                          :: IRESP
    INTEGER                          :: J,JJ
    INTEGER                          :: ILE, IP
    INTEGER,DIMENSION(:),ALLOCATABLE :: IFIELD
    INTEGER                          :: ILENG
    CHARACTER(LEN=:),ALLOCATABLE     :: YMSG
    CHARACTER(LEN=6)                 :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_C1',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPECHAR,1,'IO_WRITE_FIELD_BYFIELD_C1')
    !
    IRESP = 0
    !
    IF(LLFIOUT) THEN
      ILE=LEN(HFIELD)
      IP=SIZE(HFIELD)
      ILENG=ILE*IP
      !
      IF (ILENG==0) THEN
        IP=1
        ILE=1
        ILENG=1
        ALLOCATE(IFIELD(1))
        IFIELD(1)=IACHAR(' ')
      ELSE
        ALLOCATE(IFIELD(ILENG))
        DO JJ=1,IP
          DO J=1,ILE
            IFIELD(ILE*(JJ-1)+J)=IACHAR(HFIELD(JJ)(J:J))
          END DO
        END DO
      END IF
    END IF
    !------------------------------------------------------------------
    TZFD=>GETFD(TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi')
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,HFIELD,IRESP)
       ELSE 
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,IFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,HFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE 
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_C1','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_C1',YMSG)
    END IF
    IF (ALLOCATED(IFIELD)) DEALLOCATE(IFIELD)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_C1


  SUBROUTINE IO_WRITE_FIELD_BYNAME_T0(TPFILE,HNAME,TFIELD,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    TYPE (DATE_TIME),            INTENT(IN) :: TFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_T0',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD(TPFILE,TFIELDLIST(ID),TFIELD,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_T0


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_T0(TPFILE,TPFIELD,TFIELD,KRESP)
    USE MODD_IO_ll
    USE MODD_TYPE_DATE
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    !*      0.    DECLARATIONS
    !             ------------
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),            INTENT(IN) :: TPFIELD
    TYPE (DATE_TIME),            INTENT(IN) :: TFIELD   ! array containing the data field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER                      :: IERR
    TYPE(FD_ll), POINTER         :: TZFD
    INTEGER                      :: IRESP
    CHARACTER(LEN=:),ALLOCATABLE :: YMSG
    CHARACTER(LEN=6)             :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_T0',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    CALL FIELD_METADATA_CHECK(TPFIELD,TYPEDATE,0,'IO_WRITE_FIELD_BYFIELD_T0')
    !
    IRESP = 0
    !
    !------------------------------------------------------------------
    TZFD=>GETFD(TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi')
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,TFIELD,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,TFIELD,IRESP)
       ELSE 
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,TFIELD,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,TFIELD,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF
    ELSE 
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_T0','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_T0',YMSG)
    END IF
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_T0


  SUBROUTINE IO_WRITE_FIELD_BYNAME_LB(TPFILE,HNAME,KL3D,PLB,KRESP)
    !
    USE MODD_IO_ll, ONLY : TFILEDATA
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN) :: TPFILE
    CHARACTER(LEN=*),            INTENT(IN) :: HNAME    ! name of the field to write
    INTEGER,                     INTENT(IN) :: KL3D     ! size of the LB array in FM
    REAL,DIMENSION(:,:,:),       INTENT(IN) :: PLB      ! array containing the LB field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    INTEGER :: ID ! Index of the field
    INTEGER :: IRESP ! return_code
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYNAME_LB',TRIM(TPFILE%CNAME)//': writing '//TRIM(HNAME))
    !
    CALL FIND_FIELD_ID_FROM_MNHNAME(HNAME,ID,IRESP)
    !
    IF(IRESP==0) CALL IO_WRITE_FIELD_LB(TPFILE,TFIELDLIST(ID),KL3D,PLB,IRESP)
    !
    IF (PRESENT(KRESP)) KRESP = IRESP
    !
  END SUBROUTINE IO_WRITE_FIELD_BYNAME_LB


  SUBROUTINE IO_WRITE_FIELD_BYFIELD_LB(TPFILE,TPFIELD,KL3D,PLB,KRESP)
    !
    USE MODD_IO_ll
    USE MODD_PARAMETERS_ll,ONLY : JPHEXT
    USE MODE_DISTRIB_LB
    USE MODE_TOOLS_ll,     ONLY : GET_GLOBALDIMS_ll
    USE MODE_FD_ll,        ONLY : GETFD,JPFINL,FD_ll
    !
    USE MODD_VAR_ll, ONLY : MNH_STATUSES_IGNORE
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),             INTENT(IN)    :: TPFILE
    TYPE(TFIELDDATA),            INTENT(INOUT) :: TPFIELD
    INTEGER,                     INTENT(IN)    :: KL3D   ! size of the LB array in FM
    REAL,DIMENSION(:,:,:),TARGET,INTENT(IN)    :: PLB    ! array containing the LB field
    INTEGER,OPTIONAL,            INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=28)                        :: YFILEM   ! FM-file name
    CHARACTER(LEN=NMNHNAMELGTMAX)            :: YRECFM   ! name of the article to write
    CHARACTER(LEN=4)                         :: YLBTYPE  ! 'LBX','LBXU','LBY' or 'LBYV'
    CHARACTER(LEN=JPFINL)                    :: YFNLFI
    INTEGER                                  :: IRIM     ! size of the LB area
    INTEGER                                  :: IERR
    TYPE(FD_ll), POINTER                     :: TZFD
    INTEGER                                  :: IRESP
    REAL,DIMENSION(:,:,:),ALLOCATABLE,TARGET :: Z3D
    REAL,DIMENSION(:,:,:), POINTER           :: TX3DP
    INTEGER                                  :: IIMAX_ll,IJMAX_ll
    INTEGER                                  :: JI
    INTEGER :: IIB,IIE,IJB,IJE
    INTEGER, DIMENSION(MPI_STATUS_SIZE) :: STATUS
    INTEGER,ALLOCATABLE,DIMENSION(:)    :: REQ_TAB
    INTEGER                           :: NB_REQ,IKU
    TYPE TX_3DP
       REAL,DIMENSION(:,:,:), POINTER    :: X
    END TYPE TX_3DP
    TYPE(TX_3DP),ALLOCATABLE,DIMENSION(:) :: T_TX3DP
    CHARACTER(LEN=:),ALLOCATABLE             :: YMSG
    CHARACTER(LEN=6)                         :: YRESP
    !
    YFILEM   = TPFILE%CNAME
    YRECFM   = TPFIELD%CMNHNAME
    YLBTYPE  = TPFIELD%CLBTYPE
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BYFIELD_LB',TRIM(YFILEM)//': writing '//TRIM(YRECFM))
    !
    IF (YLBTYPE/='LBX' .AND. YLBTYPE/='LBXU' .AND. YLBTYPE/='LBY' .AND. YLBTYPE/='LBYV') THEN
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_LB','unknown LBTYPE ('//YLBTYPE//')')
      RETURN
    END IF
    !
    IF (TPFIELD%CDIR/='XY') THEN
      CALL PRINT_MSG(NVERB_WARNING,'IO','IO_WRITE_FIELD_BYFIELD_LB','CDIR was not set to "XY" for '//TRIM(YRECFM))
      TPFIELD%CDIR='XY'
    END IF
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    YFNLFI=TRIM(ADJUSTL(YFILEM))//'.lfi'
    !
    IRIM = (KL3D-2*JPHEXT)/2
    IF (KL3D /= 2*(IRIM+JPHEXT)) THEN
       IRESP = -30
       GOTO 1000
    END IF
    !
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN  ! sequential execution
          IF (LPACK .AND. L2D) THEN
             TX3DP=>PLB(:,JPHEXT+1:JPHEXT+1,:)
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,TX3DP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,TX3DP,IRESP)
          ELSE
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,PLB,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,PLB,IRESP)
          END IF
       ELSE
          IF (ISP == TZFD%OWNER)  THEN
             ! I/O proc case
             CALL GET_GLOBALDIMS_ll(IIMAX_ll,IJMAX_ll)
             IF (YLBTYPE == 'LBX' .OR. YLBTYPE == 'LBXU') THEN 
                ALLOCATE(Z3D((IRIM+JPHEXT)*2,IJMAX_ll+2*JPHEXT,SIZE(PLB,3)))
             ELSE ! YLBTYPE == 'LBY' .OR. YLBTYPE == 'LBYV' 
                ALLOCATE(Z3D(IIMAX_ll+2*JPHEXT,(IRIM+JPHEXT)*2,SIZE(PLB,3)))
             END IF
             DO JI = 1,ISNPROC
                CALL GET_DISTRIB_LB(YLBTYPE,JI,'FM','WRITE',IRIM,IIB,IIE,IJB,IJE)
                IF (IIB /= 0) THEN
                   TX3DP=>Z3D(IIB:IIE,IJB:IJE,:)
                   IF (ISP /= JI) THEN
                      CALL MPI_RECV(TX3DP,SIZE(TX3DP),MPI_FLOAT,JI-1,99,TZFD%COMM,STATUS,IERR) 
                   ELSE
                      CALL GET_DISTRIB_LB(YLBTYPE,JI,'LOC','WRITE',IRIM,IIB,IIE,IJB,IJE)
                      TX3DP = PLB(IIB:IIE,IJB:IJE,:)
                   END IF
                END IF
             END DO
             IF (LPACK .AND. L2D) THEN
                TX3DP=>Z3D(:,JPHEXT+1:JPHEXT+1,:)
             ELSE
                TX3DP=>Z3D
             END IF
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,TX3DP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,TX3DP,IRESP)
          ELSE
             NB_REQ=0
             ALLOCATE(REQ_TAB(1))
             ALLOCATE(T_TX3DP(1))
             IKU = SIZE(PLB,3)
             ! Other processors
             CALL GET_DISTRIB_LB(YLBTYPE,ISP,'LOC','WRITE',IRIM,IIB,IIE,IJB,IJE)
             IF (IIB /= 0) THEN
                TX3DP=>PLB(IIB:IIE,IJB:IJE,:)
                NB_REQ = NB_REQ + 1
                ALLOCATE(T_TX3DP(NB_REQ)%X(IIB:IIE,IJB:IJE,IKU))  
                T_TX3DP(NB_REQ)%X=PLB(IIB:IIE,IJB:IJE,:)
                CALL MPI_ISEND(T_TX3DP(NB_REQ)%X,SIZE(TX3DP),MPI_FLOAT,TZFD%OWNER-1,99,TZFD%COMM,REQ_TAB(NB_REQ),IERR)
                !CALL MPI_BSEND(TX3DP,SIZE(TX3DP),MPI_FLOAT,TZFD%OWNER-1,99,TZFD%COMM,IERR)
             END IF
             IF (NB_REQ .GT.0 ) THEN
                CALL MPI_WAITALL(NB_REQ,REQ_TAB,MNH_STATUSES_IGNORE,IERR)
                DEALLOCATE(T_TX3DP(1)%X) 
             END IF
             DEALLOCATE(T_TX3DP,REQ_TAB)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD&
               & %COMM,IERR)
       END IF !(GSMONOPROC)
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_LB','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
1000 CONTINUE
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(YRECFM)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BYFIELD_LB',YMSG)
    END IF
    !
    IF (ALLOCATED(Z3D)) DEALLOCATE(Z3D)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BYFIELD_LB


  SUBROUTINE IO_WRITE_FIELD_BOX_BYFIELD_X5(TPFILE,TPFIELD,HBUDGET,PFIELD,KXOBOX,KXEBOX,KYOBOX,KYEBOX,KRESP)
    !
    USE MODD_IO_ll
    USE MODE_FD_ll, ONLY : GETFD,JPFINL,FD_LL
    USE MODE_GATHER_ll
    !
    !
    !*      0.1   Declarations of arguments
    !
    TYPE(TFILEDATA),                 INTENT(IN) :: TPFILE
    TYPE(TFIELDDATA),                INTENT(IN) :: TPFIELD
    CHARACTER(LEN=*),                INTENT(IN) :: HBUDGET  ! 'BUDGET' (budget)  or 'OTHER' (MesoNH field)
    REAL,DIMENSION(:,:,:,:,:),TARGET,INTENT(IN) :: PFIELD   ! array containing the data field
    INTEGER,                         INTENT(IN) :: KXOBOX   ! 
    INTEGER,                         INTENT(IN) :: KXEBOX   ! Global coordinates of the box
    INTEGER,                         INTENT(IN) :: KYOBOX   ! 
    INTEGER,                         INTENT(IN) :: KYEBOX   ! 
    INTEGER,OPTIONAL,                INTENT(OUT):: KRESP    ! return-code 
    !
    !*      0.2   Declarations of local variables
    !
    CHARACTER(LEN=JPFINL)               :: YFNLFI
    INTEGER                             :: IERR
    TYPE(FD_ll), POINTER                :: TZFD
    INTEGER                             :: IRESP
    REAL,DIMENSION(:,:,:,:,:),POINTER   :: ZFIELDP
    LOGICAL                             :: GALLOC
    CHARACTER(LEN=:),ALLOCATABLE        :: YMSG
    CHARACTER(LEN=6)                    :: YRESP
    !
    CALL PRINT_MSG(NVERB_DEBUG,'IO','IO_WRITE_FIELD_BOX_BYFIELD_X5',TRIM(TPFILE%CNAME)//': writing '//TRIM(TPFIELD%CMNHNAME))
    !
    !*      1.1   THE NAME OF LFIFM
    !
    IRESP = 0
    GALLOC = .FALSE.
    YFNLFI=TRIM(ADJUSTL(TPFILE%CNAME))//'.lfi'
    !------------------------------------------------------------------
    TZFD=>GETFD(YFNLFI)
    IF (ASSOCIATED(TZFD)) THEN
       IF (GSMONOPROC) THEN ! sequential execution
          IF (HBUDGET /= 'BUDGET') THEN
             ! take the sub-section of PFIELD defined by the box
             ZFIELDP=>PFIELD(KXOBOX:KXEBOX,KYOBOX:KYEBOX,:,:,:)
          ELSE
             ! take the field as a budget
             ZFIELDP=>PFIELD
          END IF
          IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
          IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
       ELSE ! multiprocessor execution
          IF (ISP == TZFD%OWNER)  THEN
             ! Allocate the box
             ALLOCATE(ZFIELDP(KXEBOX-KXOBOX+1,KYEBOX-KYOBOX+1,SIZE(PFIELD,3),&
                  & SIZE(PFIELD,4),SIZE(PFIELD,5)))
             GALLOC = .TRUE.
          ELSE
             ALLOCATE(ZFIELDP(0,0,0,0,0))
             GALLOC = .TRUE.
          END IF
          !
          CALL GATHER_XYFIELD(PFIELD,ZFIELDP,TZFD%OWNER,TZFD%COMM,&
               & KXOBOX,KXEBOX,KYOBOX,KYEBOX,HBUDGET)
          !
          IF (ISP == TZFD%OWNER)  THEN
             IF (LLFIOUT) CALL IO_WRITE_FIELD_LFI(TPFILE,TPFIELD,ZFIELDP,IRESP)
             IF (LIOCDF4) CALL IO_WRITE_FIELD_NC4(TPFILE,TPFIELD,TZFD%CDF,ZFIELDP,IRESP)
          END IF
          !
          CALL MPI_BCAST(IRESP,1,MPI_INTEGER,TZFD%OWNER-1,TZFD%COMM,IERR)
       END IF ! multiprocessor execution
    ELSE
       IRESP = -61
       CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BOX_BYFIELD_X5','file '//TRIM(TPFILE%CNAME)//' not found')
    END IF
    !----------------------------------------------------------------
    IF (IRESP.NE.0) THEN
      WRITE(YRESP, '( I6 )') IRESP
      YMSG = 'RESP='//YRESP//' when writing '//TRIM(TPFIELD%CMNHNAME)//' in '//TRIM(TPFILE%CNAME)
      CALL PRINT_MSG(NVERB_ERROR,'IO','IO_WRITE_FIELD_BOX_BYFIELD_X5',YMSG)
    END IF
    IF (GALLOC) DEALLOCATE(ZFIELDP)
    IF (PRESENT(KRESP)) KRESP = IRESP
  END SUBROUTINE IO_WRITE_FIELD_BOX_BYFIELD_X5

END MODULE MODE_FMWRIT

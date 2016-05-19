!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 surfex 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     #########################
      MODULE MODI_MNHGET_DESFM_n
!     #########################
INTERFACE
      SUBROUTINE MNHGET_DESFM_n(HACTION,KLUDES)
!
CHARACTER(LEN=5), INTENT(IN)  :: HACTION ! 'READ ', 'WRITE'
INTEGER,          INTENT(OUT) :: KLUDES  ! logical unit of .des file
!
END SUBROUTINE MNHGET_DESFM_n
!
END INTERFACE
END MODULE MODI_MNHGET_DESFM_n
!
!     #######################################################
      SUBROUTINE MNHGET_DESFM_n(HACTION,KLUDES)
!     #######################################################
!
!!****  *MNHGET_DESFM* - routine to open .des file
!!
!!    PURPOSE
!!    -------
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!      S.Malardel   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    09/2003
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
!
USE MODD_CONF,           ONLY : CPROGRAM
USE MODD_LUNIT_n,        ONLY : CINIFILE
USE MODD_LUNIT,          ONLY : CLUOUT0, COUTFMFILE, CPGDFILE
!
USE MODE_FM
USE MODE_ll
USE MODE_MODELN_HANDLER
!
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!              -------------------------
!
CHARACTER(LEN=5), INTENT(IN)  :: HACTION ! 'READ ', 'WRITE'
INTEGER, INTENT(OUT) :: KLUDES ! logical unit of .des file
!
!*       0.2   Declarations of local variables
!              -------------------------------
!
INTEGER           :: ILUOUT         !
INTEGER           :: IRESP          ! IRESP  : return-code if a problem appears
                                    ! at the open of the file in LFI  routines
INTEGER           :: IMI            ! model index
!
CHARACTER(LEN=16) :: YLUOUT         ! output listing file name
CHARACTER(LEN=32) :: YDESFM         ! .des file name
!
!-------------------------------------------------------------------------------
!
!
!*       1.    initialisation of logical unit of output listing
!
SELECT CASE(CPROGRAM)
  CASE('REAL  ','IDEAL ','DIAG  ')
    YLUOUT = CLUOUT0
  CASE('MESONH','SPAWN ')
    IMI = GET_CURRENT_MODEL_INDEX() 
    WRITE(YLUOUT,FMT='(A14,I1,A1)') 'OUTPUT_LISTING',IMI,' '
END SELECT
!
CALL FMLOOK_ll(YLUOUT,YLUOUT,ILUOUT,IRESP)
!
!*       2.    initialisation of logical units of  .des files
!
YDESFM =' '
KLUDES=0
IF (HACTION=='READ ') THEN
  SELECT CASE(CPROGRAM)
    CASE('MESONH','DIAG  ')
      YDESFM=ADJUSTL(ADJUSTR(CINIFILE)//'.des')
      CALL FMLOOK_ll(YDESFM,YLUOUT,KLUDES,IRESP)
    CASE('REAL  ')
      YDESFM=ADJUSTL(ADJUSTR(CPGDFILE)//'.des')
      CALL FMLOOK_ll(YDESFM,YLUOUT,KLUDES,IRESP)
    CASE('IDEAL ')
      KLUDES = 0
  END SELECT
ELSE IF (HACTION=='WRITE') THEN
  IF (CPROGRAM == 'PGD   ' .OR. CPROGRAM =='NESPGD' .OR. &
      CPROGRAM == 'ZOOMPG' .OR. CPROGRAM =='DIAG  '      ) THEN
    KLUDES = 0
  ELSE
    YDESFM=ADJUSTL(ADJUSTR(COUTFMFILE)//'.des')
    CALL FMLOOK_ll(YDESFM,YLUOUT,KLUDES,IRESP)
  END IF
END IF
!
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE MNHGET_DESFM_n

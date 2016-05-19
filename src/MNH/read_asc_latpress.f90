
!     ########################
      MODULE MODI_READ_ASC_LATPRESS
!     ########################
INTERFACE
      SUBROUTINE READ_ASC_LATPRESS(HFILENAME,KLEV,PLAT,PLEV,PTHFRC,          &  
                                   PRVFRC)
      
!
CHARACTER(LEN=28), INTENT(IN) :: HFILENAME     ! Name of the field file.
INTEGER , INTENT(IN)      :: KLEV
REAL , DIMENSION(:)   , INTENT(OUT)      :: PLAT
REAL , DIMENSION(:)   , INTENT(OUT)      :: PLEV
REAL , DIMENSION(:,:) , INTENT(OUT)      :: PTHFRC
REAL , DIMENSION(:,:) , INTENT(OUT)      :: PRVFRC
!
!
END SUBROUTINE READ_ASC_LATPRESS
END INTERFACE
END MODULE MODI_READ_ASC_LATPRESS
!
!
!     ##############################################################
      SUBROUTINE READ_ASC_LATPRESS(HFILENAME, KLEV,PLAT,PLEV,PTHFRC,        &  
                                   PRVFRC)
!     ##############################################################
!
!!**** *READ_ASCLLV* reads a binary latlonvalue file and call treatment 
!!                   subroutine
!!
!!    PURPOSE
!!    -------
!!    Reads ascii files to set advective and relaxation forcing values.
!!    NB : Files must be lat,lev, th_frc, rv_frc
!!       
!!    AUTHOR
!!    ------
!!    P. Peyrille 
!!
!!    MODIFICATION
!!    ------------
!!
!!
!----------------------------------------------------------------------------
!
!*    0.     DECLARATION
!            -----------
!
!


!
IMPLICIT NONE
!
!*    0.1    Declaration of arguments
!            ------------------------
!
CHARACTER(LEN=28), INTENT(IN) :: HFILENAME     ! Name of the field file.
INTEGER , INTENT(IN)      :: KLEV
REAL , DIMENSION(:)   , INTENT(OUT)      :: PLAT
REAL , DIMENSION(:)   , INTENT(OUT)      :: PLEV
REAL , DIMENSION(:,:) , INTENT(OUT)      :: PTHFRC
REAL , DIMENSION(:,:) , INTENT(OUT)      :: PRVFRC
!
!*    0.2    Declaration of local variables
!            ------------------------------
!
INTEGER      :: KUNIT                       ! logical unit
!
INTEGER      :: ILUOUT                     ! output listing
INTEGER ::  JI,JK
INTEGER :: IIB,IIE,IJB,IJE
!----------------------------------------------------------------------------
!
!*    1.      Open the file
!             -------------
!
CALL GET_INDICE_ll(IIB,IJB,IIE,IJE)

!
!
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
KUNIT=221
OPEN(KUNIT,FILE=HFILENAME)
!
!*    3.     Reading of a data point
!            -----------------------
!
DO JI=IIB,IIE
  DO JK=1,KLEV
  READ(KUNIT,*,END=99) PLAT(JI),PLEV(JK),                                 & 
                      PTHFRC(JI,JK),PRVFRC(JI,JK)
  END DO
END DO
!
!----------------------------------------------------------------------------

!
!*    8.    Closing of the data file
!           ------------------------
!
99 CLOSE(KUNIT)
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE READ_ASC_LATPRESS

!###########################
MODULE MODI_WRITEDIR
!###########################
!
INTERFACE WRITEDIR
!
SUBROUTINE WRITEDIRX(KLU,PVAL)
INTEGER, INTENT(IN) :: KLU
REAL,    INTENT(IN) :: PVAL
END SUBROUTINE WRITEDIRX
!
SUBROUTINE WRITEDIRN(KLU,KVAL)
INTEGER, INTENT(IN) :: KLU
INTEGER, INTENT(IN) :: KVAL
END SUBROUTINE WRITEDIRN
!
SUBROUTINE WRITEDIRAN(KLU,KVAL)
INTEGER, INTENT(IN) :: KLU
INTEGER,DIMENSION(:), INTENT(IN) :: KVAL
END SUBROUTINE WRITEDIRAN
!
SUBROUTINE WRITEDIRC(KLU,HVAL)
INTEGER, INTENT(IN) :: KLU
CHARACTER(LEN=*), INTENT(IN) :: HVAL
END SUBROUTINE WRITEDIRC
!
END INTERFACE
END MODULE MODI_WRITEDIR
!
!     ###########################
      SUBROUTINE WRITEDIRX(KLU,PVAL)
!     ###########################
!
IMPLICIT NONE
INTEGER, INTENT(IN) :: KLU
REAL,    INTENT(IN) :: PVAL
!
CHARACTER(LEN=80) :: YCAR80      ! String for directive written
CHARACTER(LEN=7)  :: YFORMOUT    ! String for format of directive written
!
YCAR80(1:LEN(YCAR80))=' '
WRITE(YCAR80,*)PVAL
YCAR80=ADJUSTL(YCAR80)
YFORMOUT='(A  )'
WRITE(YFORMOUT(3:4),'(I2.2)') MAX(LEN_TRIM(YCAR80),3) 
WRITE(UNIT=KLU,FMT=YFORMOUT)YCAR80(1:LEN_TRIM(YCAR80))
END SUBROUTINE WRITEDIRX
!
!     ###########################
      SUBROUTINE WRITEDIRN(KLU,KVAL)
!     ###########################
!
IMPLICIT NONE
INTEGER, INTENT(IN) :: KLU
INTEGER, INTENT(IN) :: KVAL
!
CHARACTER(LEN=80) :: YCAR80      ! String for directive written
CHARACTER(LEN=7)  :: YFORMOUT    ! String for format of directive written
!
YCAR80(1:LEN(YCAR80))=' '
WRITE(YCAR80,*)KVAL
YCAR80=ADJUSTL(YCAR80)
YFORMOUT='(A  )'
WRITE(YFORMOUT(3:4),'(I2.2)') MAX(LEN_TRIM(YCAR80),3) 
WRITE(UNIT=KLU,FMT=YFORMOUT)YCAR80(1:LEN_TRIM(YCAR80))
!
END SUBROUTINE WRITEDIRN
!
!     ###########################
      SUBROUTINE WRITEDIRAN(KLU,KVAL)
!     ###########################
!
IMPLICIT NONE
INTEGER, INTENT(IN) :: KLU
INTEGER,DIMENSION(:), INTENT(IN) :: KVAL
!
CHARACTER(LEN=80) :: YCAR80      ! String for directive written
!CHARACTER(LEN=7)  :: YFORMOUT    ! String for format of directive written
!INTEGER :: ISIZE
CHARACTER(LEN=15)  :: YFORMSIZE    ! String for format of directive written

!
WRITE(YFORMSIZE,'("(",I2,"(I4))" )') SIZE(KVAL)
!ISIZE=SIZE(KVAL)
!YFORMSIZE='(  (I3,X))'
!WRITE(YFORMSIZE(2:3),'(I2)')  ISIZE
YCAR80(1:LEN(YCAR80))=' '
WRITE(YCAR80,FMT=YFORMSIZE) KVAL
YCAR80=ADJUSTL(YCAR80)
!YFORMOUT='(A  )'
!WRITE(YFORMOUT(3:4),'(I2.2)') MAX(LEN_TRIM(YCAR80),3) 
WRITE(UNIT=KLU,FMT='(A)')YCAR80(1:LEN_TRIM(YCAR80))
!
END SUBROUTINE WRITEDIRAN
!     ###########################
      SUBROUTINE WRITEDIRC(KLU,HVAL)
!     ###########################
!
IMPLICIT NONE
INTEGER, INTENT(IN) :: KLU
CHARACTER(LEN=*), INTENT(IN) :: HVAL
!
CHARACTER(LEN=80) :: YCAR80      ! String for directive written
CHARACTER(LEN=7)  :: YFORMOUT    ! String for format of directive written
!
YCAR80(1:LEN(YCAR80))=' '
WRITE(YCAR80,'(A80)')HVAL
YCAR80=ADJUSTL(YCAR80)
YFORMOUT='(A  )'
WRITE(YFORMOUT(3:4),'(I2.2)') MAX(LEN_TRIM(YCAR80),3) 
WRITE(UNIT=KLU,FMT=YFORMOUT)YCAR80(1:LEN_TRIM(YCAR80))
!
END SUBROUTINE WRITEDIRC

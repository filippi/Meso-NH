!MNH_LIC Copyright 1994-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Modifications:
!  Philippe Wautelet: 05/2016-04/2018: new data structures and calls for I/O
!  P. Wautelet 14/01/2021: add ALLOCBUFFER_N4 subroutine
!-----------------------------------------------------------------

MODULE MODE_ALLOCBUFFER_ll
USE MODE_TOOLS_ll,      ONLY: GET_GLOBALDIMS_ll
USE MODD_PARAMETERS_ll, ONLY: JPHEXT

IMPLICIT NONE 

PRIVATE

INTERFACE ALLOCBUFFER_ll
  MODULE PROCEDURE                                  &
    ALLOCBUFFER_X1, ALLOCBUFFER_X2, ALLOCBUFFER_X3, &
    ALLOCBUFFER_X4, ALLOCBUFFER_X5, ALLOCBUFFER_X6, &
    ALLOCBUFFER_N1, ALLOCBUFFER_N2, ALLOCBUFFER_N3, &
    ALLOCBUFFER_N4,                                 &
    ALLOCBUFFER_L1
END INTERFACE

PUBLIC ALLOCBUFFER_ll

CONTAINS
 
SUBROUTINE ALLOCBUFFER_N1(KTAB_P,KTAB,HDIR,OALLOC)
!
INTEGER,DIMENSION(:),POINTER           :: KTAB_P
INTEGER,DIMENSION(:),TARGET,INTENT(IN) :: KTAB
CHARACTER(LEN=*),           INTENT(IN) :: HDIR
LOGICAL,                    INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IIMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IJMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE default
  KTAB_P=>KTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_N1

SUBROUTINE ALLOCBUFFER_N2(KTAB_P,KTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
INTEGER,DIMENSION(:,:),POINTER           :: KTAB_P
INTEGER,DIMENSION(:,:),TARGET,INTENT(IN) :: KTAB
CHARACTER(LEN=*),             INTENT(IN) :: HDIR
LOGICAL,                      INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,SIZE(KTAB,2)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IJMAX+2*JPHEXT,SIZE(KTAB,2)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,1))
  ELSE
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT))
  END IF
  OALLOC = .TRUE.
CASE default
  KTAB_P=>KTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_N2

SUBROUTINE ALLOCBUFFER_N3(KTAB_P,KTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
INTEGER,DIMENSION(:,:,:),POINTER           :: KTAB_P
INTEGER,DIMENSION(:,:,:),TARGET,INTENT(IN) :: KTAB
CHARACTER(LEN=*),               INTENT(IN) :: HDIR
LOGICAL,                        INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,SIZE(KTAB,2),SIZE(KTAB,3)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IJMAX+2*JPHEXT,SIZE(KTAB,2),SIZE(KTAB,3)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,1,SIZE(KTAB,3)))
  ELSE
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(KTAB,3)))
  END IF
  OALLOC = .TRUE.
CASE default
  KTAB_P=>KTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_N3

SUBROUTINE ALLOCBUFFER_N4(KTAB_P,KTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
INTEGER, DIMENSION(:,:,:,:), POINTER, INTENT(OUT) :: KTAB_P
INTEGER, DIMENSION(:,:,:,:), TARGET,  INTENT(IN)  :: KTAB
CHARACTER(LEN=*),                     INTENT(IN)  :: HDIR
LOGICAL,                              INTENT(OUT) :: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,SIZE(KTAB,2),SIZE(KTAB,3)&
       & ,SIZE(KTAB,4)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(KTAB_P(IJMAX+2*JPHEXT,SIZE(KTAB,2),SIZE(KTAB,3)&
       & ,SIZE(KTAB,4)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,1,SIZE(KTAB,3),SIZE(KTAB,4)))
  ELSE
    ALLOCATE(KTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(KTAB,3),SIZE(KTAB,4)))
  END IF
  OALLOC = .TRUE.
CASE default
  KTAB_P=>KTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_N4

SUBROUTINE ALLOCBUFFER_L1(LTAB_P,LTAB,HDIR,OALLOC)
!
LOGICAL,DIMENSION(:),POINTER           :: LTAB_P
LOGICAL,DIMENSION(:),TARGET,INTENT(IN) :: LTAB
CHARACTER(LEN=*),           INTENT(IN) :: HDIR
LOGICAL,                    INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(LTAB_P(IIMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(LTAB_P(IJMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE default
  LTAB_P=>LTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_L1

SUBROUTINE ALLOCBUFFER_X1(PTAB_P,PTAB,HDIR,OALLOC, KIMAX_ll, KJMAX_ll)
!
REAL,DIMENSION(:),POINTER           :: PTAB_P
REAL,DIMENSION(:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),        INTENT(IN) :: HDIR
LOGICAL,                 INTENT(OUT):: OALLOC
INTEGER, OPTIONAL, INTENT(IN) ::KIMAX_ll
INTEGER, OPTIONAL, INTENT(IN) ::KJMAX_ll

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  IF( PRESENT(KIMAX_ll) .AND. PRESENT(KJMAX_ll) ) THEN
    IIMAX = KIMAX_ll
    IJMAX = KJMAX_ll
  ELSE
    CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ENDIF
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE('YY')
  IF( PRESENT(KIMAX_ll) .AND. PRESENT(KJMAX_ll) ) THEN
    IIMAX = KIMAX_ll
    IJMAX = KJMAX_ll
  ELSE
    CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ENDIF
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT))
  OALLOC = .TRUE.
CASE default
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X1

SUBROUTINE ALLOCBUFFER_X2(PTAB_P,PTAB,HDIR,OALLOC, KIMAX_ll, KJMAX_ll)
USE MODD_IO, ONLY: LPACK, L2D
!
REAL,DIMENSION(:,:),POINTER           :: PTAB_P
REAL,DIMENSION(:,:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),          INTENT(IN) :: HDIR
LOGICAL,                   INTENT(OUT):: OALLOC
INTEGER, OPTIONAL, INTENT(IN) ::KIMAX_ll
INTEGER, OPTIONAL, INTENT(IN) ::KJMAX_ll

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  IF( PRESENT(KIMAX_ll) .AND. PRESENT(KJMAX_ll) ) THEN
    IIMAX = KIMAX_ll
    IJMAX = KJMAX_ll
  ELSE
    CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ENDIF
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,SIZE(PTAB,2)))
  OALLOC = .TRUE.
CASE('YY')
  IF( PRESENT(KIMAX_ll) .AND. PRESENT(KJMAX_ll) ) THEN
    IIMAX = KIMAX_ll
    IJMAX = KJMAX_ll
  ELSE
    CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ENDIF
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT,SIZE(PTAB,2)))
  OALLOC = .TRUE.
CASE('XY')
  IF( PRESENT(KIMAX_ll) .AND. PRESENT(KJMAX_ll) ) THEN
    IIMAX = KIMAX_ll
    IJMAX = KJMAX_ll
  ELSE
    CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ENDIF
  IF (LPACK .AND. L2D) THEN ! 2D compact case
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,1))
  ELSE
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT))
  END IF
  OALLOC = .TRUE.
CASE default 
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X2

SUBROUTINE ALLOCBUFFER_X3(PTAB_P,PTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
REAL,DIMENSION(:,:,:),POINTER           :: PTAB_P
REAL,DIMENSION(:,:,:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),            INTENT(IN) :: HDIR
LOGICAL,                     INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,1,SIZE(PTAB,3)))
  ELSE
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(PTAB,3)))
  END IF
  OALLOC = .TRUE.
CASE default
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X3

SUBROUTINE ALLOCBUFFER_X4(PTAB_P,PTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
REAL,DIMENSION(:,:,:,:),POINTER           :: PTAB_P
REAL,DIMENSION(:,:,:,:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),              INTENT(IN) :: HDIR
LOGICAL,                       INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,1,SIZE(PTAB,3),SIZE(PTAB,4)))
  ELSE
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(PTAB,3),SIZE(PTAB,4)))
  END IF
  OALLOC = .TRUE.
CASE default
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X4

SUBROUTINE ALLOCBUFFER_X5(PTAB_P,PTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
REAL,DIMENSION(:,:,:,:,:),POINTER           :: PTAB_P
REAL,DIMENSION(:,:,:,:,:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),                INTENT(IN) :: HDIR
LOGICAL,                         INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4),SIZE(PTAB,5)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4),SIZE(PTAB,5)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,1,SIZE(PTAB,3),SIZE(PTAB,4),&
         & SIZE(PTAB,5)))
  ELSE
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(PTAB,3)&
         & ,SIZE(PTAB,4),SIZE(PTAB,5)))
  END IF
  OALLOC = .TRUE.
CASE default
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X5

SUBROUTINE ALLOCBUFFER_X6(PTAB_P,PTAB,HDIR,OALLOC)
USE MODD_IO, ONLY: LPACK, L2D
!
REAL,DIMENSION(:,:,:,:,:,:),POINTER           :: PTAB_P
REAL,DIMENSION(:,:,:,:,:,:),TARGET,INTENT(IN) :: PTAB
CHARACTER(LEN=*),                  INTENT(IN) :: HDIR
LOGICAL,                           INTENT(OUT):: OALLOC

INTEGER                   :: IIMAX,IJMAX

SELECT CASE(HDIR)
CASE('XX')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4),SIZE(PTAB,5),SIZE(PTAB,6)))
  OALLOC = .TRUE.
CASE('YY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  ALLOCATE(PTAB_P(IJMAX+2*JPHEXT,SIZE(PTAB,2),SIZE(PTAB,3)&
       & ,SIZE(PTAB,4),SIZE(PTAB,5),SIZE(PTAB,6)))
  OALLOC = .TRUE.
CASE('XY')
  CALL GET_GLOBALDIMS_ll(IIMAX,IJMAX)
  IF (LPACK .AND. L2D) THEN
    ! 2D compact case
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,1,SIZE(PTAB,3),SIZE(PTAB,4),&
         & SIZE(PTAB,5),SIZE(PTAB,6)))
  ELSE
    ALLOCATE(PTAB_P(IIMAX+2*JPHEXT,IJMAX+2*JPHEXT,SIZE(PTAB,3)&
         & ,SIZE(PTAB,4),SIZE(PTAB,5),SIZE(PTAB,6)))
  END IF
  OALLOC = .TRUE.
CASE default
  PTAB_P=>PTAB
  OALLOC = .FALSE.
END SELECT
END SUBROUTINE ALLOCBUFFER_X6

END MODULE MODE_ALLOCBUFFER_ll




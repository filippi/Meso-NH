!     ######spl
      MODULE MODI_REALLOC_AND_LOAD
!     #############################
!
INTERFACE
!
SUBROUTINE REALLOC_AND_LOAD(HGROUP)
CHARACTER(LEN=*) :: HGROUP
END SUBROUTINE  REALLOC_AND_LOAD
!
END INTERFACE
END MODULE MODI_REALLOC_AND_LOAD
!     ######spl
      SUBROUTINE REALLOC_AND_LOAD(HGROUP)
!     ###################################
!
!!****  *REALLOC_AND_LOAD* - 
!!
!!    PURPOSE
!!    -------
!      
!
!!**  METHOD
!!    ------
!!     
!!     N.A.
!!
!!    EXTERNAL
!!    --------
!!      None
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module
!!
!!      Module
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!      J. Duron    * Laboratoire d'Aerologie *
!!
!!
!!    MODIFICATIONS
!!    -------------
!!      Original       24/11/95
!!      Updated   PM   02/12/94
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_ALLOC_FORDIACHRO
USE MODD_FILES_DIACHRO
USE MODD_RESOLVCAR
USE MODD_TYPE_AND_LH
USE MODD_SEVERAL_RECORDS
USE MODI_VERIF_GROUP

IMPLICIT NONE
!
!*       0.1   Dummy arguments
!              ---------------
!
CHARACTER(LEN=*) :: HGROUP
!
!*       0.1   Local variables
!              ---------------

INTEGER          :: J,JME,JT
INTEGER          :: II, IJ, IK,IT, IN, IP, IT1, IT2, IL
INTEGER          :: IMODJ
INTEGER,DIMENSION(:),ALLOCATABLE,SAVE  :: IGRIDIA

REAL,DIMENSION(:,:,:,:,:,:),ALLOCATABLE  :: ZVAR, ZVAR2
REAL,DIMENSION(:,:,:),ALLOCATABLE  :: ZTRAJX, ZTRAJX2
REAL,DIMENSION(:,:,:),ALLOCATABLE  :: ZTRAJY, ZTRAJY2
REAL,DIMENSION(:,:,:),ALLOCATABLE  :: ZTRAJZ, ZTRAJZ2
REAL,DIMENSION(:,:),ALLOCATABLE    :: ZTRAJT, ZTRAJT2
REAL,DIMENSION(:,:),ALLOCATABLE    :: ZDATIME, ZDATIME2
REAL,DIMENSION(:,:,:,:,:,:),ALLOCATABLE  :: ZMASK, ZMASK2
CHARACTER(LEN=100),DIMENSION(:),ALLOCATABLE,SAVE  :: YTITRE
CHARACTER(LEN=100),DIMENSION(:),ALLOCATABLE,SAVE  :: YUNITE
CHARACTER(LEN=100),DIMENSION(:),ALLOCATABLE,SAVE  :: YCOMMENT

!------------------------------------------------------------------------------
IF(ALLOCATED(XVAR))THEN
  ALLOCATE(ZVAR(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
		SIZE(XVAR,5),SIZE(XVAR,6)))
  ZVAR(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
ENDIF
IF(ALLOCATED(XTRAJT))THEN
  ALLOCATE(ZTRAJT(SIZE(XTRAJT,1),SIZE(XTRAJT,2)))
  ZTRAJT(:,:)=XTRAJT(:,:)
ENDIF
IF(ALLOCATED(XTRAJX))THEN
  ALLOCATE(ZTRAJX(SIZE(XTRAJX,1),SIZE(XTRAJX,2),SIZE(XTRAJX,3)))
  ZTRAJX(:,:,:)=XTRAJX(:,:,:)
ENDIF
IF(ALLOCATED(XTRAJY))THEN
  ALLOCATE(ZTRAJY(SIZE(XTRAJY,1),SIZE(XTRAJY,2),SIZE(XTRAJY,3)))
  ZTRAJY(:,:,:)=XTRAJY(:,:,:)
ENDIF
IF(ALLOCATED(XTRAJZ))THEN
  ALLOCATE(ZTRAJZ(SIZE(XTRAJZ,1),SIZE(XTRAJZ,2),SIZE(XTRAJZ,3)))
  ZTRAJZ(:,:,:)=XTRAJZ(:,:,:)
ENDIF
IF(ALLOCATED(XMASK))THEN
  ALLOCATE(ZMASK(SIZE(XMASK,1),SIZE(XMASK,2),SIZE(XMASK,3),SIZE(XMASK,4), &
                 SIZE(XMASK,5),SIZE(XMASK,6)))
  ZMASK(:,:,:,:,:,:)=XMASK(:,:,:,:,:,:)
ENDIF
IF(ALLOCATED(NGRIDIA))THEN
  ALLOCATE(IGRIDIA(SIZE(NGRIDIA)))
  IGRIDIA(:)=NGRIDIA(:)
ENDIF
IF(ALLOCATED(CTITRE))THEN
  ALLOCATE(YTITRE(SIZE(CTITRE)))
  YTITRE=CTITRE
ENDIF
IF(ALLOCATED(CUNITE))THEN
  ALLOCATE(YUNITE(SIZE(CUNITE)))
  YUNITE=CUNITE
ENDIF
IF(ALLOCATED(CCOMMENT))THEN
  ALLOCATE(YCOMMENT(SIZE(CCOMMENT)))
  YCOMMENT=CCOMMENT
ENDIF
IF(ALLOCATED(XDATIME))THEN
  ALLOCATE(ZDATIME(SIZE(XDATIME,1),SIZE(XDATIME,2)))
  ZDATIME(:,:)=XDATIME(:,:)
ENDIF

CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)

DO J=2,NBSIMULT

  JME=NINDFILESIMULT(J)
  CALL READ_FILEHEAD(JME,CFILEDIAS(JME),CLUOUTDIAS(JME))
  CALL VERIF_GROUP(CFILEDIAS(JME),CLUOUTDIAS(JME),HGROUP)
  IF(LPBREAD)THEN
    EXIT
  ENDIF
  IF(LGROUP)THEN
  CALL READ_DIACHRO(CFILEDIAS(JME),CLUOUTDIAS(JME),HGROUP)
  ENDIF
  IMODJ=MOD(J,2)

  SELECT CASE(IMODJ)
    CASE(0)
      IF(ALLOCATED(XVAR))THEN
	IT1=SIZE(ZVAR,4);IT2=SIZE(XVAR,4)
	IT=IT1+IT2
        ALLOCATE(ZVAR2(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),IT, &
                       SIZE(XVAR,5),SIZE(XVAR,6)))
        ZVAR2(:,:,:,1:IT1,:,:)=ZVAR(:,:,:,1:IT1,:,:)
        ZVAR2(:,:,:,IT1+1:IT,:,:)=XVAR(:,:,:,:,:,:)
	DEALLOCATE(ZVAR)
      ENDIF
      IF(ALLOCATED(XTRAJT))THEN
        ALLOCATE(ZTRAJT2(IT,SIZE(XTRAJT,2)))
        ZTRAJT2(1:IT1,:)=ZTRAJT(1:IT1,:)
        ZTRAJT2(IT1+1:IT,:)=XTRAJT(:,:)
	DEALLOCATE(ZTRAJT)
      ENDIF
      IF(ALLOCATED(XTRAJX))THEN
        ALLOCATE(ZTRAJX2(SIZE(XTRAJX,1),IT,SIZE(XTRAJX,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJX2(:,JT,:)=ZTRAJX(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJX2(:,JT,:)=XTRAJX(:,1,:)
          END DO
        ELSE
          ZTRAJX2(:,1:IT1,:)=ZTRAJX(:,1:IT1,:)
          ZTRAJX2(:,IT1+1:IT,:)=XTRAJX(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJX)
      ENDIF
      IF(ALLOCATED(XTRAJY))THEN
        ALLOCATE(ZTRAJY2(SIZE(XTRAJY,1),IT,SIZE(XTRAJY,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJY2(:,JT,:)=ZTRAJY(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJY2(:,JT,:)=XTRAJY(:,1,:)
          END DO
        ELSE
          ZTRAJY2(:,1:IT1,:)=ZTRAJY(:,1:IT1,:)
          ZTRAJY2(:,IT1+1:IT,:)=XTRAJY(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJY)
      ENDIF
      IF(ALLOCATED(XTRAJZ))THEN
        ALLOCATE(ZTRAJZ2(SIZE(XTRAJZ,1),IT,SIZE(XTRAJZ,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJZ2(:,JT,:)=ZTRAJZ(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJZ2(:,JT,:)=XTRAJZ(:,1,:)
          END DO
        ELSE
          ZTRAJZ2(:,1:IT1,:)=ZTRAJZ(:,1:IT1,:)
          ZTRAJZ2(:,IT1+1:IT,:)=XTRAJZ(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJZ)
      ENDIF
      IF(ALLOCATED(XMASK))THEN
        ALLOCATE(ZMASK2(SIZE(XMASK,1),SIZE(XMASK,2),SIZE(XMASK,3),IT, &
      		SIZE(XMASK,5),SIZE(XMASK,6)))
        ZMASK2(:,:,:,1:IT1,:,:)=ZMASK(:,:,:,1:IT1,:,:)
        ZMASK2(:,:,:,IT1+1:IT,:,:)=XMASK(:,:,:,:,:,:)
	DEALLOCATE(ZMASK)
      ENDIF
      IF(ALLOCATED(XDATIME))THEN
        ALLOCATE(ZDATIME2(SIZE(XDATIME,1),IT))
        ZDATIME2(:,1:IT1)=ZDATIME(:,1:IT1)
        ZDATIME2(:,IT1+1:IT)=XDATIME(:,:)
	DEALLOCATE(ZDATIME)
      ENDIF
!     IF(ALLOCATED(CTITRE))THEN
!       ALLOCATE(YTITRE(SIZE(CTITRE)))
!       YTITRE=CTITRE
!     ENDIF
!     IF(ALLOCATED(CUNITE))THEN
!       ALLOCATE(YUNITE(SIZE(CUNITE)))
!       YUNITE=CUNITE
!     ENDIF
!     IF(ALLOCATED(CCOMMENT))THEN
!       ALLOCATE(YCOMMENT(SIZE(CCOMMENT)))
!       YCOMMENT=CCOMMENT
!     ENDIF

    CASE DEFAULT

      IF(ALLOCATED(XVAR))THEN
	IT1=SIZE(ZVAR2,4);IT2=SIZE(XVAR,4)
	IT=IT1+IT2

        ALLOCATE(ZVAR(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),IT, &
      		SIZE(XVAR,5),SIZE(XVAR,6)))
        ZVAR(:,:,:,1:IT1,:,:)=ZVAR2(:,:,:,1:IT1,:,:)
        ZVAR(:,:,:,IT1+1:IT,:,:)=XVAR(:,:,:,:,:,:)
	DEALLOCATE(ZVAR2)
      ENDIF
      IF(ALLOCATED(XTRAJT))THEN
        ALLOCATE(ZTRAJT(IT,SIZE(XTRAJT,2)))
        ZTRAJT(1:IT1,:)=ZTRAJT2(1:IT1,:)
        ZTRAJT(IT1+1:IT,:)=XTRAJT(:,:)
	DEALLOCATE(ZTRAJT2)
      ENDIF
      IF(ALLOCATED(XTRAJX))THEN
        ALLOCATE(ZTRAJX(SIZE(XTRAJX,1),IT,SIZE(XTRAJX,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJX(:,JT,:)=ZTRAJX2(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJX(:,JT,:)=XTRAJX(:,1,:)
          END DO
        ELSE
          ZTRAJX(:,1:IT1,:)=ZTRAJX2(:,1:IT1,:)
          ZTRAJX(:,IT1+1:IT,:)=XTRAJX(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJX2)
      ENDIF
      IF(ALLOCATED(XTRAJY))THEN
        ALLOCATE(ZTRAJY(SIZE(XTRAJY,1),IT,SIZE(XTRAJY,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJY(:,JT,:)=ZTRAJY2(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJY(:,JT,:)=XTRAJY(:,1,:)
          END DO
        ELSE
          ZTRAJY(:,1:IT1,:)=ZTRAJY2(:,1:IT1,:)
          ZTRAJY(:,IT1+1:IT,:)=XTRAJY(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJY2)
      ENDIF
      IF(ALLOCATED(XTRAJZ))THEN
        ALLOCATE(ZTRAJZ(SIZE(XTRAJZ,1),IT,SIZE(XTRAJZ,3)))
        IF (CTYPE=='SSOL') THEN
          DO JT=1,IT1
            ZTRAJZ(:,JT,:)=ZTRAJZ2(:,1,:)
          END DO
          DO JT=IT1+1,IT
            ZTRAJZ(:,JT,:)=XTRAJZ(:,1,:)
          END DO
        ELSE
          ZTRAJZ(:,1:IT1,:)=ZTRAJZ2(:,1:IT1,:)
          ZTRAJZ(:,IT1+1:IT,:)=XTRAJZ(:,:,:)
        ENDIF
        DEALLOCATE(ZTRAJZ2)
      ENDIF
      IF(ALLOCATED(XDATIME))THEN
        ALLOCATE(ZDATIME(SIZE(XDATIME,1),IT))
        ZDATIME(:,1:IT1)=ZDATIME2(:,1:IT1)
        ZDATIME(:,IT1+1:IT)=XDATIME(:,:)
	DEALLOCATE(ZDATIME2)
      ENDIF
      IF(ALLOCATED(XMASK))THEN
        ALLOCATE(ZMASK(SIZE(XMASK,1),SIZE(XMASK,2),SIZE(XMASK,3),IT, &
      		SIZE(XMASK,5),SIZE(XMASK,6)))
        ZMASK(:,:,:,1:IT1,:,:)=ZMASK2(:,:,:,1:IT1,:,:)
        ZMASK(:,:,:,IT1+1:IT,:,:)=XMASK(:,:,:,:,:,:)
	DEALLOCATE(ZMASK2)
      ENDIF

  END SELECT

  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)

ENDDO

IF(MOD(NBSIMULT,2) == 0)THEN
  II=SIZE(ZVAR2,1); IJ=SIZE(ZVAR2,2); IK=SIZE(ZVAR2,3)
! IF(ALLOCATED(XMASK))THEN
  IF(CTYPE == 'MASK')THEN
    II=SIZE(ZMASK2,1); IJ=SIZE(ZMASK2,2)
  ENDIF
  IT=SIZE(ZVAR2,4); IN=SIZE(ZVAR2,5); IP=SIZE(ZVAR2,6)
ELSE
  II=SIZE(ZVAR,1); IJ=SIZE(ZVAR,2); IK=SIZE(ZVAR,3)
! IF(ALLOCATED(XMASK))THEN
  IF(CTYPE == 'MASK')THEN
    II=SIZE(ZMASK,1); IJ=SIZE(ZMASK,2)
  ENDIF
  IT=SIZE(ZVAR,4); IN=SIZE(ZVAR,5); IP=SIZE(ZVAR,6)
ENDIF

CALL ALLOC_FORDIACHRO(II,IJ,IK,IT,IN,IP,1)

IF(MOD(NBSIMULT,2) == 0)THEN

  IF(ALLOCATED(XVAR))THEN
    XVAR(:,:,:,:,:,:)=ZVAR2(:,:,:,:,:,:)
    DEALLOCATE(ZVAR2)
  ENDIF
  IF(ALLOCATED(XTRAJT))THEN
    XTRAJT(:,:)=ZTRAJT2(:,:)
    DEALLOCATE(ZTRAJT2)
  ENDIF
  IF(ALLOCATED(XTRAJX))THEN
    IF (CTYPE=='SSOL') THEN
      !SIZE(XTRAJX,2)=1
      XTRAJX(:,1,:)=ZTRAJX2(:,1,:)
    ELSE
      XTRAJX(:,:,:)=ZTRAJX2(:,:,:)
    ENDIF
    DEALLOCATE(ZTRAJX2)
  ENDIF
  IF(ALLOCATED(XTRAJY))THEN
    IF (CTYPE=='SSOL') THEN
      XTRAJY(:,1,:)=ZTRAJY2(:,1,:)
    ELSE
      XTRAJY(:,:,:)=ZTRAJY2(:,:,:)
    ENDIF
    DEALLOCATE(ZTRAJY2)
  ENDIF
  IF(ALLOCATED(XTRAJZ))THEN
   IF (CTYPE=='SSOL') THEN
     XTRAJZ(:,1,:)=ZTRAJZ2(:,1,:)
   ELSE
     XTRAJZ(:,:,:)=ZTRAJZ2(:,:,:)
   ENDIF
   DEALLOCATE(ZTRAJZ2)
  ENDIF
  IF(ALLOCATED(XMASK))THEN
    XMASK(:,:,:,:,:,:)=ZMASK2(:,:,:,:,:,:)
    DEALLOCATE(ZMASK2)
  ENDIF
  IF(ALLOCATED(XDATIME))THEN
    XDATIME(:,:)=ZDATIME2(:,:)
    DEALLOCATE(ZDATIME2)
  ENDIF

ELSE

  IF(ALLOCATED(XVAR))THEN
    XVAR(:,:,:,:,:,:)=ZVAR(:,:,:,:,:,:)
    DEALLOCATE(ZVAR)
  ENDIF
  IF(ALLOCATED(XTRAJT))THEN
    XTRAJT(:,:)=ZTRAJT(:,:)
    DEALLOCATE(ZTRAJT)
  ENDIF
  IF(ALLOCATED(XTRAJX))THEN
    IF (CTYPE=='SSOL') THEN
      !SIZE(XTRAJX,2)=1
      XTRAJX(:,1,:)=ZTRAJX(:,1,:)
    ELSE
      XTRAJX(:,:,:)=ZTRAJX(:,:,:)
    ENDIF
    DEALLOCATE(ZTRAJX)
  ENDIF
  IF(ALLOCATED(XTRAJY))THEN
    IF (CTYPE=='SSOL') THEN
      XTRAJY(:,1,:)=ZTRAJY(:,1,:)
    ELSE
      XTRAJY(:,:,:)=ZTRAJY(:,:,:)
    ENDIF
    DEALLOCATE(ZTRAJY)
  ENDIF
  IF(ALLOCATED(XTRAJZ))THEN
    IF (CTYPE=='SSOL') THEN
      XTRAJZ(:,1,:)=ZTRAJZ(:,1,:)
    ELSE
      XTRAJZ(:,:,:)=ZTRAJZ(:,:,:)
    ENDIF
    DEALLOCATE(ZTRAJZ)
  ENDIF
  IF(ALLOCATED(XMASK))THEN
    XMASK(:,:,:,:,:,:)=ZMASK(:,:,:,:,:,:)
    DEALLOCATE(ZMASK)
  ENDIF
  IF(ALLOCATED(XDATIME))THEN
    XDATIME(:,:)=ZDATIME(:,:)
    DEALLOCATE(ZDATIME)
  ENDIF

ENDIF

! Traitement du recouvrement
!
NBRECOUV=1
NRECOUV(1)=1
IL=1
DO J=2,SIZE(XTRAJT,1)
  IF(XTRAJT(J,1) <= XTRAJT(J-1,1))THEN
    NBRECOUV=NBRECOUV+1
    IL=IL+1
    NRECOUV(IL)=J-1
    IL=IL+1
    NRECOUV(IL)=J
  ENDIF
ENDDO
IL=IL+1
NRECOUV(IL)=SIZE(XTRAJT,1)


IF(ALLOCATED(NGRIDIA))THEN
  NGRIDIA(:)=IGRIDIA(:)
  DEALLOCATE(IGRIDIA)
ENDIF
IF(ALLOCATED(CTITRE))THEN
  CTITRE=YTITRE
  DEALLOCATE(YTITRE)
ENDIF
IF(ALLOCATED(CUNITE))THEN
  CUNITE=YUNITE
  DEALLOCATE(YUNITE)
ENDIF
IF(ALLOCATED(CCOMMENT))THEN
  CCOMMENT=YCOMMENT
  DEALLOCATE(YCOMMENT)
ENDIF

RETURN
END SUBROUTINE REALLOC_AND_LOAD  

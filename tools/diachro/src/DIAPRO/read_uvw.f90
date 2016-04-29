!     ######spl
      MODULE MODI_READ_UVW
!     #####################
!
INTERFACE
!
SUBROUTINE READ_UVW(HFILEDIA,HLUOUTDIA,HGROUP)
CHARACTER(LEN=*) :: HFILEDIA, HLUOUTDIA, HGROUP
END SUBROUTINE READ_UVW
!
END INTERFACE
END MODULE MODI_READ_UVW
!     ######spl
      SUBROUTINE READ_UVW(HFILEDIA,HLUOUTDIA,HGROUP)
!     ###############################################
!
!!****  *READ_UVW* - 
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
!!      Original       08/01/97
!!      Updated   PM 
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_TYPE_AND_LH
USE MODD_SEVERAL_RECORDS
USE MODD_RESOLVCAR
USE MODD_ALLOC_FORDIACHRO
USE MODD_PT_FOR_CH_FORDIACHRO
USE MODD_FILES_DIACHRO
USE MODD_MEMGRIUV

IMPLICIT NONE
!
!*       0.1   Dummy arguments
!              ---------------

CHARACTER(LEN=*) :: HFILEDIA, HLUOUTDIA, HGROUP
!
!*       0.1   Local variables
!              ---------------

!
INTEGER :: IL
CHARACTER(LEN=LEN(HGROUP)) :: YGROUP
!------------------------------------------------------------------------------
!
YGROUP=HGROUP
IL=LEN_TRIM(HGROUP)
!print *,' ENTREE uvw  HGROUP ',HGROUP
IF(NSUFWIND == 1)THEN
  HGROUP(IL:IL)=' '
ELSE IF(NSUFWIND == 2)THEN
  HGROUP(IL-1:IL)='  '
ENDIF
!
! Chargement des composantes du vent
! On met toujours U dans XU
! On laisse V dans XVAR qd on n'utilise que 2 composantes et on la met
! dans XV ad on utilise les 3 composantes
! On laisse toujours W dans XVAR
!
SELECT CASE(HGROUP)

  CASE('UMVM','MUMVM','ULM','VTM','ULMWM','LSUMVM','MLSUMVM','DIRUMVM','DDUMVM')

    IF(LSUMVM .OR. LMLSUMVM)THEN
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'LSUM')
    ELSE
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'UM'//CSUFWIND)
    ENDIF
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE UM'//CSUFWIND,' ou LSUM N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      IF(LSUMVM .OR. LMLSUMVM)THEN
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'LSUM')
      ELSE
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'UM'//CSUFWIND)
      ENDIF
    ENDIF
    IF(.NOT.LFIC1)THEN
      IF(LSUMVM .OR. LMLSUMVM)THEN
        CALL REALLOC_AND_LOAD('LSUM')
      ELSE
        CALL REALLOC_AND_LOAD('UM'//CSUFWIND)
      ENDIF
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . UM ou LSUM  N''EXISTE PAS DANS',&
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
        HGROUP=YGROUP
	RETURN
      ENDIF
    ELSE
      NBRECOUV=1
      NRECOUV(1)=1
      NRECOUV(2)=SIZE(XTRAJT,1)
    ENDIF
    ALLOCATE(XU(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
		SIZE(XVAR,5),SIZE(XVAR,6)))
    XU(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!! Nov 2001
    NGRIU=NGRIDIA(1)
!! Nov 2001
    CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)

    IF(LSUMVM .OR. LMLSUMVM)THEN
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'LSVM')
    ELSE
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'VM'//CSUFWIND)
    ENDIF
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE VM'//CSUFWIND,' ou LSVM N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      IF(LSUMVM .OR. LMLSUMVM)THEN
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'LSVM')
      ELSE
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'VM'//CSUFWIND)
      ENDIF
    ENDIF
    IF(.NOT.LFIC1)THEN
      IF(LSUMVM .OR. LMLSUMVM)THEN
        CALL REALLOC_AND_LOAD('LSVM')
      ELSE
        CALL REALLOC_AND_LOAD('VM'//CSUFWIND)
      ENDIF
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . VM ou LSVM N''EXISTE PAS DANS', &
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
	RETURN
      ENDIF
    ENDIF
!! Nov 2001
    NGRIV=NGRIDIA(1)
!! Nov 2001
    IF(LULMWM .OR. LULTWT)THEN
      ALLOCATE(XV(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
        	  SIZE(XVAR,5),SIZE(XVAR,6)))
      XV(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!! Nov 2001
    NGRIV=NGRIDIA(1)
!! Nov 2001
    CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
    ENDIF

  CASE('UTVT','MUTVT','ULT','VTT','ULTWT','LSUTVT','MLSUTVT','DIRUTVT','DDUTVT')

    IF(LSUTVT .OR. LMLSUTVT)THEN
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'LSUT')
    ELSE
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'UT'//CSUFWIND)
    ENDIF
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE UT'//CSUFWIND,' ou LSUT N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      IF(LSUTVT .OR. LMLSUTVT)THEN
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'LSUT')
      ELSE
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'UT'//CSUFWIND)
      ENDIF
    ENDIF
    IF(.NOT.LFIC1)THEN
      IF(LSUTVT .OR. LMLSUTVT)THEN
        CALL REALLOC_AND_LOAD('LSUT')
      ELSE
        CALL REALLOC_AND_LOAD('UT'//CSUFWIND)
      ENDIF
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . UT ou LSUT N''EXISTE PAS DANS', &
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
        HGROUP=YGROUP
	RETURN
      ENDIF
    ENDIF
    ALLOCATE(XU(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
		SIZE(XVAR,5),SIZE(XVAR,6)))
    XU(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!! Nov 2001
    NGRIU=NGRIDIA(1)
!! Nov 2001
    CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)

    IF(LSUTVT .OR. LMLSUTVT)THEN
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'LSVT')
    ELSE
      CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'VT'//CSUFWIND)
    ENDIF
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE VT'//CSUFWIND,' ou LSVT N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      IF(LSUTVT .OR. LMLSUTVT)THEN
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'LSVT')
      ELSE
        CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'VT'//CSUFWIND)
      ENDIF
    ENDIF
    IF(.NOT.LFIC1)THEN
      IF(LSUTVT .OR. LMLSUTVT)THEN
        CALL REALLOC_AND_LOAD('LSVT')
      ELSE
        CALL REALLOC_AND_LOAD('VT'//CSUFWIND)
      ENDIF
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . VT ou LSVT N''EXISTE PAS DANS', &
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
        HGROUP=YGROUP
	RETURN
      ENDIF
    ENDIF
!! Nov 2001
    NGRIV=NGRIDIA(1)
!! Nov 2001
    IF(LULMWM .OR. LULTWT)THEN
      ALLOCATE(XV(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
		  SIZE(XVAR,5),SIZE(XVAR,6)))
      XV(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!! Nov 2001
    NGRIV=NGRIDIA(1)
!! Nov 2001
    CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
    ENDIF


END SELECT

SELECT CASE(HGROUP)

  CASE('ULMWM')
    CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'WM'//CSUFWIND)
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE WM'//CSUFWIND,' N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'WM'//CSUFWIND)
    ENDIF
    IF(.NOT.LFIC1)THEN
      CALL REALLOC_AND_LOAD('WM'//CSUFWIND)
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . WM N''EXISTE PAS DANS', &
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
        HGROUP=YGROUP
	RETURN
      ENDIF
    ENDIF
!   ALLOCATE(XW(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
!	        SIZE(XVAR,5),SIZE(XVAR,6)))
!   XW(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!   CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)


  CASE('ULTWT')
    CALL VERIF_GROUP(HFILEDIA,HLUOUTDIA,'WT'//CSUFWIND)
    IF(LPBREAD)THEN
      print *,' GROUPE DEMANDE: ',YGROUP,' REQUETE IMPOSSIBLE '
      print *,' LA COMPOSANTE WT'//CSUFWIND,' N''EXISTE PAS '
      HGROUP=YGROUP
      RETURN
    ENDIF
    IF(LGROUP)THEN
      CALL READ_DIACHRO(HFILEDIA,HLUOUTDIA,'WT'//CSUFWIND)
    ENDIF
    IF(.NOT.LFIC1)THEN
      CALL REALLOC_AND_LOAD('WT'//CSUFWIND)
      IF(LPBREAD)THEN
	print *,' REQUETE IMPOSSIBLE . WT N''EXISTE PAS DANS', &
	' L''UN DES FICHIERS '
	IF(ALLOCATED(XVAR))THEN
	  CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)
	ENDIF
        HGROUP=YGROUP
	RETURN
      ENDIF
    ENDIF
!   ALLOCATE(XW(SIZE(XVAR,1),SIZE(XVAR,2),SIZE(XVAR,3),SIZE(XVAR,4), &
!	        SIZE(XVAR,5),SIZE(XVAR,6)))
!   XW(:,:,:,:,:,:)=XVAR(:,:,:,:,:,:)
!   CALL ALLOC_FORDIACHRO(1,1,1,1,1,1,3)


END SELECT
!
!-----------------------------------------------------------------------------
!
!*       2.       EXITS
!                 -----
! 
HGROUP=YGROUP
!print *,' uvw YGROUP CSUFWIND NSUFWIND ',YGROUP,CSUFWIND,NSUFWIND
RETURN
END SUBROUTINE READ_UVW

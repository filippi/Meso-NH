!     ######spl
      MODULE MODI_WRITE_LFIFM1_FORDIACHRO_CV
!     ########################################
!
INTERFACE
!
SUBROUTINE WRITE_LFIFM1_FORDIACHRO_CV(HFMFILE)
CHARACTER(LEN=28), INTENT(IN) :: HFMFILE      ! Name of FM-file to write
END SUBROUTINE WRITE_LFIFM1_FORDIACHRO_CV
!
END INTERFACE
!
END MODULE MODI_WRITE_LFIFM1_FORDIACHRO_CV
!     ##############################################
      SUBROUTINE WRITE_LFIFM1_FORDIACHRO_CV(HFMFILE)
!     ##############################################
!
!!****  *WRITE_LFIFM1_FORDIACHRO_CV* - routine  pour l'ecriture dans un
!!           fichier diachronique des dimensions, parametres de grille
!!           et etat de ref. lus dans les fichiers d'entree
!!
!!    PURPOSE
!!    -------
!        Voir la routine write_lfifmn_fordiachron de mesonh.
!        Ici (_CV pour conv) ecriture en plus de MY_NAME, DAD_NAME,
!      DXRATIO, DYRATIO, XOR, YOR, XEND, YEND, 
!      ainsi que traitement special pour ZS dans le cas 2D (recopie sur pts de
!      garde).
!
!!**  METHOD
!!    ------
!!      The data written in the LFIFM file are :
!!        - dimensions
!!        - grid variables
!!        - configuration variables
!!        - 1D anelastic reference state
!!
!!
!!    EXTERNAL
!!    --------
!!      FMWRIT : FM-routine to write a record
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_DIM1   : contains dimensions
!!      Module MODD_TIME1   : contains time variables and uses MODD_TIME
!!      Module MODD_GRID    : contains spatial grid variables for all models
!!      Module MODD_GRID1 : contains spatial grid variables
!!      Module MODD_REF     : contains reference state variables
!!      Module MODD_LUNIT1: contains logical unit variables.
!!      Module MODD_CONF    : contains configuration variables for all models
!!      Module MODD_CONF1  : contains configuration variables
!!      Module MODD_PARAM1    : contains parameterization options
!!
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!	V. Ducrocq   *Meteo France* 
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    06/05/94 
!!       V. Ducrocq    27/06/94                  
!!       J.Stein       20/10/94 (name of the FMFILE)
!!       I. Mallet        09/04 for conv2dia: write MASDEV (for masdev4_6)
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_CONF, ONLY: CPROGRAM,CSTORAGE_TYPE,LCARTESIAN,LTHINSHELL, &
                     NMASDEV,NBUGFIX,L1D,L2D,LPACK 
USE MODD_DIM1, ONLY: NIMAX,NJMAX,NKMAX
USE MODD_GRID, ONLY: XRPK,XLON0,XLAT0,XBETA,XLONORI,XLATORI
USE MODD_GRID1, ONLY: XXHAT,XYHAT,XZHAT,XZS,XZSMT,LSLEVE,XLEN1,XLEN2
USE MODD_LUNIT1, ONLY: CLUOUT
USE MODD_PARAM1, ONLY: CSURF
USE MODD_TIME, ONLY: TDTEXP,TDTSEG
USE MODD_TIME1, ONLY: TDTCUR,TDTMOD
USE MODD_NESTING, ONLY: NDXRATIO_ALL,NDYRATIO_ALL, &
                        NXOR_ALL,NYOR_ALL,NXEND_ALL,NYEND_ALL
USE MODD_PARAMETERS, ONLY: JPHEXT
!
USE MODD_DIACHRO, ONLY: CMY_NAME_DIA,CDAD_NAME_DIA
USE MODD_DIMGRID_FORDIACHRO
USE MODD_OUT_DIA
!
USE MODI_FMREAD 
USE MODI_FMWRIT 
!
USE MODE_GRIDPROJ
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!
CHARACTER(LEN=28), INTENT(IN) :: HFMFILE      ! Name of FM-file to write
!
!*       0.2   Declarations of local variables
!
INTEGER           :: IRESP          ! IRESP  : return-code if a problem appears 
                                    !  at the open of the file                                                                      !  LFI  routines 
INTEGER           :: IGRID,ILENG    ! IGRID : grid indicator
                                    ! ILENG : length of the data field  
INTEGER           :: ILENCH         ! ILENCH : length of comment string 
INTEGER           :: JT,JLOOP       ! loop index
INTEGER           :: J              ! loop index
!
CHARACTER(LEN=16) :: YRECFM         ! Name of the article to be written
CHARACTER(LEN=20) :: YCOMMENT       ! Comment string
CHARACTER(LEN=100) :: YCOMM       ! Comment string
!
REAL                              :: ZLATOR, ZLONOR ! geographical coordinates of 1st mass point
REAL                              :: ZXHATM, ZYHATM ! conformal    coordinates of 1st mass point
REAL, DIMENSION(:), ALLOCATABLE   :: ZXHAT_ll    !  Position x in the conformal
                                                 ! plane (array on the complete domain)
REAL, DIMENSION(:), ALLOCATABLE   :: ZYHAT_ll    !   Position y in the conformal
                                                 ! plane (array on the complete domain)
!
INTEGER, DIMENSION(3)  :: ITDATE      ! date array
INTEGER,DIMENSION(2)   :: ISTORAGE_TYPE
INTEGER, DIMENSION(28) :: INAME  ! name array for HFMFILE
                                 ! and HDADFILE writing
REAL,DIMENSION(:),ALLOCATABLE,SAVE   :: ZXZS
REAL  :: ZTDATE      ! seconds
!
LOGICAL :: GPACK
!-------------------------------------------------------------------------------
!
!*       1.     WRITES IN THE LFI FILE
!	        -----------------------
!
GPACK=LPACK
IF(L1D .OR. L2D) THEN
  print*,'** Warning PACK forced to FALSE because of duplication **'
  ! cf IMULT dans write_othersfields.f90
  LPACK=.FALSE.
ENDIF
!*       1.0    Version :
!
YRECFM='MASDEV'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,NMASDEV,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='BUGFIX'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,NBUGFIX,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='L1D'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,L1D,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='L2D'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,L2D,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='PACK'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,LPACK,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='SURF'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=4
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,CSURF,IGRID,ILENCH,YCOMMENT,IRESP)
!
!*       1.1    Dimensions :
!
YRECFM='MY_NAME'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=28
IGRID=0
ILENCH=LEN(YCOMMENT)
DO JLOOP=1,28
 INAME(JLOOP)=IACHAR(CMY_NAME_DIA(JLOOP:JLOOP))
!INAME(JLOOP)=IACHAR(HFMFILE(JLOOP:JLOOP))
END DO
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,INAME,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='DAD_NAME'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=28
IGRID=0
ILENCH=LEN(YCOMMENT)
DO JLOOP=1,28
 INAME(JLOOP)=IACHAR(CDAD_NAME_DIA(JLOOP:JLOOP))
END DO
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,INAME,IGRID,ILENCH,YCOMMENT,IRESP)
!
IF (LEN_TRIM(CDAD_NAME_DIA)>0) THEN
  CALL FMWRIT(HFMFILE,'DXRATIO',CLUOUT,1,NDXRATIO_ALL(1),0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('DXRATIO')
  CALL FMWRIT(HFMFILE,'DYRATIO',CLUOUT,1,NDYRATIO_ALL(1),0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('DYRATIO')
  CALL FMWRIT(HFMFILE,'XOR' ,CLUOUT,1,NXOR_ALL(1) ,0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('XOR')
  CALL FMWRIT(HFMFILE,'YOR' ,CLUOUT,1,NYOR_ALL(1) ,0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('YOR')
  CALL FMWRIT(HFMFILE,'XEND',CLUOUT,1,NXEND_ALL(1),0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('XEND')
  CALL FMWRIT(HFMFILE,'YEND',CLUOUT,1,NYEND_ALL(1),0,ILENCH,YCOMMENT,IRESP)
  CALL ELIM('YEND')
END IF

YRECFM='STORAGE_TYPE'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=2
IGRID=0
ILENCH=LEN(YCOMMENT)
ISTORAGE_TYPE(1)=IACHAR(CSTORAGE_TYPE(1:1))
ISTORAGE_TYPE(2)=IACHAR(CSTORAGE_TYPE(2:2))
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ISTORAGE_TYPE,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='IMAX'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,NIMAX,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='JMAX'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,NJMAX,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='KMAX'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,NKMAX,IGRID,ILENCH,YCOMMENT,IRESP)
!
!*       1.2    Grid variables :
!
IF (.NOT.LCARTESIAN) THEN
! 
  YRECFM='RPK'
  CALL ELIM(YRECFM)
  YCOMMENT=' '
  ILENG=1
  IGRID=0
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XRPK,IGRID,ILENCH,YCOMMENT,IRESP)
! 
  YRECFM='LONORI'
  CALL ELIM(YRECFM)
  YCOMMENT='DEGREES'
  ILENG=1
  IGRID=0
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLONORI,IGRID,ILENCH,YCOMMENT,IRESP)
!
  YRECFM='LATORI'
  CALL ELIM(YRECFM)
  YCOMMENT='DEGREES'
  ILENG=1
  IGRID=0
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLATORI,IGRID,ILENCH,YCOMMENT,IRESP)
!
!* diagnostic of 1st mass point
!
  !ALLOCATE(ZXHAT_ll(NIMAX_ll+ 2 * JPHEXT),ZYHAT_ll(NJMAX_ll+2 * JPHEXT))
  !CALL GATHERALL_FIELD_ll('XX',XXHAT,ZXHAT_ll,IRESP) !//
  !CALL GATHERALL_FIELD_ll('YY',XYHAT,ZYHAT_ll,IRESP) !//
  !ZXHATM = 0.5 * (ZXHAT_ll(1)+ZXHAT_ll(2))
  !ZYHATM = 0.5 * (ZYHAT_ll(1)+ZYHAT_ll(2))
  ZXHATM = 0.5 * (XXHAT(1)+XXHAT(2))
  ZYHATM = 0.5 * (XYHAT(1)+XYHAT(2))
  CALL SM_LATLON(XLATORI,XLONORI,ZXHATM,ZYHATM,ZLATOR,ZLONOR)
  !DEALLOCATE(ZXHAT_ll,ZYHAT_ll)
!
  YRECFM='LONOR'
  CALL ELIM(YRECFM)
  YCOMMENT='DEGREES'
  ILENG=1
  IGRID=0
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ZLONOR,IGRID,ILENCH,YCOMMENT,IRESP)
!
  YRECFM='LATOR'
  CALL ELIM(YRECFM)
  YCOMMENT='DEGREES'
  ILENG=1
  IGRID=0
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ZLATOR,IGRID,ILENCH,YCOMMENT,IRESP)
END IF 
!
YRECFM='THINSHELL'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,LTHINSHELL,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='LAT0'
CALL ELIM(YRECFM)
YCOMMENT='DEGREES'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLAT0,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='LON0'
CALL ELIM(YRECFM)
YCOMMENT='DEGREES'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLON0,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='BETA'
CALL ELIM(YRECFM)
YCOMMENT='DEGREES'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XBETA,IGRID,ILENCH,YCOMMENT,IRESP)
! 
YRECFM='XHAT'
CALL ELIM(YRECFM)
YCOMMENT='METERS'
ILENG=SIZE(XXHAT)
IGRID=2
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XXHAT,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='YHAT'
CALL ELIM(YRECFM)
YCOMMENT='METERS'
ILENG=SIZE(XYHAT)
IGRID=3
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XYHAT,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='ZHAT'
CALL ELIM(YRECFM)
YCOMMENT='METERS'
ILENG=SIZE(XZHAT)
IGRID=4
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XZHAT,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='ZS'
! 051296 Non elimine . Pour l'enregister avec le nom ZSBIS
!CALL ELIM(YRECFM)
YCOMMENT='METERS'
!print *,' NIMAX JPHEXT SIZE(XZS) ',NIMAX,JPHEXT,SIZE(XZS)
JT=0
DO J=1,NNB
  IF(CRECFM2T(J,1) == 'ZS')THEN
    JT=J
    EXIT
  ENDIF
ENDDO
!IF(JT /= 0 .AND.NSIZT(JT,1) == NIMAX+2*JPHEXT)THEN
! expression evaluee l autre apres l autre
IF(JT /= 0 )THEN
IF(NSIZT(JT,1) == NIMAX+2*JPHEXT)THEN
  ALLOCATE(ZXZS(NIMAX+2*JPHEXT))
  ILENG=NIMAX+2*JPHEXT
! Test sur la longueur du champ commentaire
! Ajout le 4 Mai 2001 pour la prise en compte des commentaires >= 20 et <= 100
! Cf instruction suivante apres .OR. -> Je charge dans un commentaire len=100
  IF(NLENC(JT,1) == LEN(YCOMM) .OR. &
    (NLENC(JT,1) > LEN(YCOMMENT).AND. NLENC(JT,1) <= LEN(YCOMM)))THEN
    !IM!ILENCH=LEN(YCOMM) (output arg.)
    CALL FMREAD(CNAMFILED(1),YRECFM,CLUOUT,ILENG,ZXZS,IGRID,ILENCH,YCOMM,IRESP)
  ELSE IF(NLENC(JT,1) == LEN(YCOMMENT))THEN
    !IM!ILENCH=LEN(YCOMMENT) (output arg.)
    CALL FMREAD(CNAMFILED(1),YRECFM,CLUOUT,ILENG,ZXZS,IGRID,ILENCH,YCOMMENT,IRESP)
  ELSE
    print *,' Longueur du champ commentaire differente de 20 ou 100 . Imprevue ! ',NLENC(JT,1)
  ENDIF
print *,' Size ZXZS ',SIZE(ZXZS)
print *,' Size XZS 1 2 ',SIZE(XZS,1),SIZE(XZS,2)
  DO J=1,NJMAX+2*JPHEXT
    XZS(1:SIZE(XZS,1),J)=ZXZS(:)
  ENDDO
!print *,' XZS(60,:) ',XZS(60,:),XZS(150,:)
  ILENG=SIZE(XZS)
! print *,' XZS',XZS(:,1)
! print *,' XZS',XZS(:,2)
! print *,' XZS',XZS(:,3)
ELSE
  ILENG=SIZE(XZS)
ENDIF
ENDIF
IF (JT==0 )THEN
  ILENG=SIZE(XZS)
ENDIF
IGRID=4
ILENCH=LEN(YCOMMENT)
IF(ALLOCATED(ZXZS))THEN
  DEALLOCATE(ZXZS)
ENDIF
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XZS,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='ZSMT'
! 120106 Non elimine . Pour l'enregister avec le nom ZSMTBIS
!CALL ELIM(YRECFM)
YCOMMENT='METERS'
ILENG=SIZE(XZSMT)
IGRID=4
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XZSMT,IGRID,ILENCH,YCOMMENT,IRESP)
!
YRECFM='SLEVE'
CALL ELIM(YRECFM)
YCOMMENT=' '
ILENG=1
IGRID=4
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,LSLEVE,IGRID,ILENCH,YCOMMENT,IRESP)
!
IF (LSLEVE) THEN
  YRECFM='LEN1'
  CALL ELIM(YRECFM)
  YCOMMENT='METERS'
  ILENG=1
  IGRID=4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLEN1,IGRID,ILENCH,YCOMMENT,IRESP)
  YRECFM='LEN2'
  CALL ELIM(YRECFM)
  YCOMMENT='METERS'
  ILENG=1
  IGRID=4
  ILENCH=LEN(YCOMMENT)
  CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XLEN2,IGRID,ILENCH,YCOMMENT,IRESP)
END IF
!
YRECFM='DTCUR%TDATE'   ! array of rank 3 for date is written in file
CALL ELIM(YRECFM)
YCOMMENT='YYYYMMDD'
ITDATE(1)=TDTCUR%TDATE%YEAR
ITDATE(2)=TDTCUR%TDATE%MONTH
ITDATE(3)=TDTCUR%TDATE%DAY
ILENG=3
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ITDATE,IGRID,ILENCH,YCOMMENT,IRESP)
YRECFM='DTCUR%TIME'
CALL ELIM(YRECFM)
YCOMMENT='SECONDS'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,TDTCUR%TIME,IGRID,ILENCH,           &
             YCOMMENT,IRESP)
!
YRECFM='DTEXP%TDATE'   ! array of rank 3 for date is written in file
CALL ELIM(YRECFM)
YCOMMENT='YYYYMMDD'
IF (CSTORAGE_TYPE=='SU') THEN
  ITDATE(1)=TDTCUR%TDATE%YEAR
  ITDATE(2)=TDTCUR%TDATE%MONTH
  ITDATE(3)=TDTCUR%TDATE%DAY
  ZTDATE   =TDTCUR%TIME
ELSE
  ITDATE(1)=TDTEXP%TDATE%YEAR
  ITDATE(2)=TDTEXP%TDATE%MONTH
  ITDATE(3)=TDTEXP%TDATE%DAY
  ZTDATE   =TDTEXP%TIME
ENDIF
ILENG=3
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ITDATE,IGRID,ILENCH,YCOMMENT,IRESP)
YRECFM='DTEXP%TIME'
CALL ELIM(YRECFM)
YCOMMENT='SECONDS'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ZTDATE,IGRID,ILENCH,           &
             YCOMMENT,IRESP)
!
YRECFM='DTMOD%TDATE'    ! array of rank 3 for date is written in file
CALL ELIM(YRECFM)
YCOMMENT='YYYYMMDD'
IF (CSTORAGE_TYPE=='SU') THEN
  ITDATE(1)=TDTCUR%TDATE%YEAR
  ITDATE(2)=TDTCUR%TDATE%MONTH
  ITDATE(3)=TDTCUR%TDATE%DAY
  ZTDATE   =TDTCUR%TIME
ELSE
  ITDATE(1)=TDTMOD%TDATE%YEAR
  ITDATE(2)=TDTMOD%TDATE%MONTH
  ITDATE(3)=TDTMOD%TDATE%DAY
  ZTDATE   =TDTMOD%TIME
ENDIF
ILENG=3
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ITDATE,IGRID,ILENCH,YCOMMENT,IRESP)
YRECFM='DTMOD%TIME'
CALL ELIM(YRECFM)
YCOMMENT='SECONDS'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ZTDATE,IGRID,ILENCH,           &
             YCOMMENT,IRESP)
!
YRECFM='DTSEG%TDATE'    ! array of rank 3 for date is written in file
CALL ELIM(YRECFM)
YCOMMENT='YYYYMMDD'
IF (CSTORAGE_TYPE=='SU') THEN
  ITDATE(1)=TDTCUR%TDATE%YEAR
  ITDATE(2)=TDTCUR%TDATE%MONTH
  ITDATE(3)=TDTCUR%TDATE%DAY
  ZTDATE   =TDTCUR%TIME
ELSE
  ITDATE(1)=TDTSEG%TDATE%YEAR
  ITDATE(2)=TDTSEG%TDATE%MONTH
  ITDATE(3)=TDTSEG%TDATE%DAY
  ZTDATE   =TDTSEG%TIME
ENDIF
ILENG=3
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ITDATE,IGRID,ILENCH,YCOMMENT,IRESP)
YRECFM='DTSEG%TIME'
CALL ELIM(YRECFM)
YCOMMENT='SECONDS'
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,ZTDATE,IGRID,ILENCH,           &
             YCOMMENT,IRESP)
!
!*       1.3    Configuration  variables :
!
YRECFM='CARTESIAN'
CALL ELIM(YRECFM)
YCOMMENT='  '
ILENG=1
IGRID=0
ILENCH=LEN(YCOMMENT)
CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,LCARTESIAN,IGRID,ILENCH,YCOMMENT,IRESP)
!
!*       1.6    Reference state variables :
!
!YRECFM='RHOREFZ'
!CALL ELIM(YRECFM)
!IF (CPROGRAM(4:6)/='DIA') THEN 
  !YCOMMENT='  '
  !ILENG=SIZE(XRHODREFZ)
  !IGRID=4
  !ILENCH=LEN(YCOMMENT)
  !CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XRHODREFZ,IGRID,ILENCH,YCOMMENT,IRESP)
!END IF
!
!YRECFM='THVREFZ'
!CALL ELIM(YRECFM)
!IF (CPROGRAM(4:6)/='DIA') THEN 
  !YCOMMENT='  '
  !ILENG=SIZE(XTHVREFZ)
  !IGRID=4
  !ILENCH=LEN(YCOMMENT)
  !CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XTHVREFZ,IGRID,ILENCH,YCOMMENT,IRESP)
!END IF
!
!YRECFM='EXNTOP'
!CALL ELIM(YRECFM)
!IF (CPROGRAM(4:6)/='DIA') THEN 
  !YCOMMENT='  '
  !ILENG=1
  !IGRID=4
  !ILENCH=LEN(YCOMMENT)
  !CALL FMWRIT(HFMFILE,YRECFM,CLUOUT,ILENG,XEXNTOP,IGRID,ILENCH,YCOMMENT,IRESP)
!END IF
!
!print *,' SORTIE  WRITE_LFIFM1_FORDIACHRO_CV'
!-------------------------------------------------------------------------------
LPACK=GPACK
!
END SUBROUTINE WRITE_LFIFM1_FORDIACHRO_CV 

!     #############################
      MODULE MODI_FLASH_GEOM_ELEC_n
!     #############################
!
INTERFACE
    SUBROUTINE FLASH_GEOM_ELEC_n (KTCOUNT, KRR, PTSTEP, PRHODJ, PRHODREF, &
                                  PRT, PCIT, PRSVS, PRS, PTHT, PPABST,    &
                                  PEFIELDU, PEFIELDV, PEFIELDW,           &
                                  PZZ, PTOWN, PSEA)
!
INTEGER,                  INTENT(IN)    :: KTCOUNT  ! Temporal loop counter
INTEGER,                  INTENT(IN)    :: KRR      ! number of moist variables
REAL,                     INTENT(IN)    :: PTSTEP   ! Double time step except for
                                                    ! cold start
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODREF ! Reference dry air density
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODJ   ! Dry density * Jacobian
REAL, DIMENSION(:,:,:,:), INTENT(IN)    :: PRT      ! Moist variables at time t
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PCIT     ! Pristine ice n.c. at t
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRSVS    ! Scalar variables source term
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDU ! x-component of the electric field
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDV ! y-component of the electric field
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDW ! z-component of the electric field
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRS      ! Moist variables vol. source
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PTHT     ! Theta (K) at time t
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PPABST   ! Absolute pressure at t
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ      ! height
REAL, DIMENSION(:,:), OPTIONAL, INTENT(IN) :: PTOWN ! town fraction
REAL, DIMENSION(:,:), OPTIONAL, INTENT(IN) :: PSEA  ! Land-sea mask
!
END SUBROUTINE FLASH_GEOM_ELEC_n
END INTERFACE
END MODULE MODI_FLASH_GEOM_ELEC_n
!
!
!       #######################################################################
        SUBROUTINE FLASH_GEOM_ELEC_n (KTCOUNT, KRR, PTSTEP, PRHODJ, PRHODREF, &
                                      PRT, PCIT, PRSVS, PRS, PTHT, PPABST,    &
                                      PEFIELDU, PEFIELDV, PEFIELDW,           &
                                      PZZ, PTOWN, PSEA)
!       #######################################################################
!
!!****  * -
!!
!!    PURPOSE
!!    -------
!!      The purpose of this routine is to compute the lightning flash path,
!!    and to neutralize the electric charge along the lightning channel.
!!
!!
!!    METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!      C. Barthe   * LACy * 
!!
!!    MODIFICATIONS
!!    -------------
!!      Original : Jan. 2010
!!      Modifications:
!!      M. Chong  * LA *  Juin 2010 : add small ions
!!
!-------------------------------------------------------------------------------
!
!*      0.      DECLARATIONS
!               ------------
!
USE MODD_CONF, ONLY : CEXP
USE MODD_PARAMETERS, ONLY : JPHEXT, JPVEXT
USE MODD_GRID_n, ONLY : XXHAT, XYHAT, XZHAT
USE MODD_DYN_n, ONLY : XDXHATM, XDYHATM, NSTOP
USE MODD_ELEC_DESCR 
USE MODD_ELEC_PARAM, ONLY : XFQLIGHTR, XEXQLIGHTR, &
                            XFQLIGHTI, XEXQLIGHTI, &
                            XFQLIGHTS, XEXQLIGHTS, &
                            XFQLIGHTG, XEXQLIGHTG, &
                            XFQLIGHTC
USE MODD_RAIN_ICE_DESCR, ONLY : XLBR, XLBEXR, XLBS, XLBEXS, &
                                XLBG, XLBEXG, XLBDAS_MAX, XRTMIN, &
                                XLBDAR_MAX, XLBDAG_MAX
USE MODD_NSV, ONLY : NSV_ELECBEG, NSV_ELECEND, NSV_ELEC
USE MODD_VAR_ll, ONLY : NPROC
!
USE MODI_SHUMAN
USE MODI_TO_ELEC_FIELD_n
USE MODI_ION_ATTACH_ELEC
USE MODI_IO_ll
!
#ifdef MNH_PGI
USE MODE_PACK_PGI
#endif
!
USE MODE_ll
USE MODE_ELEC_ll
USE MODD_ARGSLIST_ll, ONLY : LIST_ll
USE MODD_PRINT_ELEC,  ONLY : NLU_fgeom_diag, NLU_fgeom_coord, &
                             NIOSTAT_fgeom_diag, NIOSTAT_fgeom_coord
USE MODD_SUB_ELEC_n
!
IMPLICIT NONE
!
!
!       0.1     Declaration of arguments
!
INTEGER,                  INTENT(IN)    :: KTCOUNT  ! Temporal loop counter
INTEGER,                  INTENT(IN)    :: KRR      ! number of moist variables
REAL,                     INTENT(IN)    :: PTSTEP   ! Double time step except for
                                                    ! cold start
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODREF ! Reference dry air density
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODJ   ! Dry density * Jacobian
REAL, DIMENSION(:,:,:,:), INTENT(IN)    :: PRT      ! Moist variables at time t
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PCIT     ! Pristine ice n.c. at t
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRSVS    ! Scalar variables source term
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDU ! x-component of the electric field
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDV ! y-component of the electric field
REAL, DIMENSION(:,:,:),   INTENT(INOUT) :: PEFIELDW ! z-component of the electric field
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRS      ! Moist variables vol. source
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PTHT     ! Theta (K) at time t
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PPABST   ! Absolute pressure at t
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PZZ      ! height
REAL, DIMENSION(:,:), OPTIONAL, INTENT(IN) :: PTOWN ! town fraction
REAL, DIMENSION(:,:), OPTIONAL, INTENT(IN) :: PSEA  ! Land-sea mask
!
!
!       0.2     Declaration of local variables
!
INTEGER :: IIB, IIE  ! index values of the first and last inner mass points along x
INTEGER :: IJB, IJE  ! index values of the first and last inner mass points along y
INTEGER :: IKB, IKE  ! index values of the first and last inner mass points along z
INTEGER :: IKU
INTEGER :: II, IJ, IK, IL, IM, IPOINT  ! loop indexes
INTEGER :: IXOR, IYOR  ! origin of the extended subdomain
INTEGER :: INB_CELL    ! Number of detected electrified cells
INTEGER :: IPROC_CELL  ! Proc with the center of the cell
INTEGER :: IICOORD, IJCOORD, IKCOORD ! local indexes of the cell center / max electric field
INTEGER :: IPROC       ! my proc number
INTEGER :: IINFO_ll    ! return code of parallel routine
INTEGER :: COUNT_BEF   ! nb of pts in zcell before testing neighbour pts
INTEGER :: COUNT_AFT   ! nb of pts in zcell after testing neighbour pts
INTEGER :: INBFTS_MAX  ! Max number of flashes per time step / cell 
INTEGER :: IIBL_LOC    ! local i index of the ongoing bi-leader segment
INTEGER :: IJBL_LOC    ! local j index of the ongoing bi-leader segment
INTEGER :: IKBL        ! k index of the ongoing bi-leader segment
INTEGER :: II_TRIG_LOC  ! local i index of the triggering point
INTEGER :: IJ_TRIG_LOC  ! local j index of the triggering point
INTEGER :: II_TRIG_GLOB ! global i index of the potential triggering pt
INTEGER :: IJ_TRIG_GLOB ! global j index of the potential triggering pt
INTEGER :: IK_TRIG      ! k index of the triggering point
INTEGER :: ISIGN_LEADER ! sign of the leader
INTEGER :: IPROC_AUX    ! proc number for max_ll and min_ll
INTEGER :: IIND_MAX   ! max nb of indexes between the trig. pt and the possible branches
INTEGER :: IIND_MIN   ! min nb of indexes between the trig. pt and the possible branches
INTEGER :: IDELTA_IND   ! number of indexes between iind_max and iind_min
INTEGER :: IPT_DIST     ! nb of possible pts for branching on each proc
INTEGER :: IPT_DIST_GLOB  ! global nb of possible pts for branching
INTEGER :: IFOUND         ! if =1, then the random selection is successful 
INTEGER :: ICHOICE_LOCX   ! local i indice for random choice
INTEGER :: ICHOICE_LOCY   ! local j indice for random choice
INTEGER :: ICHOICE_Z      !       k indice for random choice
INTEGER :: INB_PROP       ! nb of pts where the flash can propagate
INTEGER :: INB_NEUT       ! nb of pts to neutralize
INTEGER :: INB_NEUT_OK    ! nb of effective flash neutralization
INTEGER :: ISTOP
INTEGER :: IERR         ! error status
INTEGER :: IWORK
INTEGER :: ICHOICE
INTEGER :: IIMIN, IIMAX, IJMIN, IJMAX, IKMIN, IKMAX
INTEGER :: IPOS_LEADER, INEG_LEADER
INTEGER :: INBSEG_GLOB     ! global number of segments
INTEGER :: INBLIGHT
INTEGER, DIMENSION(:), ALLOCATABLE, SAVE :: ITYPE   ! flash type (IC, CGN or CGP)
INTEGER, DIMENSION(:), ALLOCATABLE :: INBSEG_LEADER ! number of segments in the leader
INTEGER, DIMENSION(:), ALLOCATABLE :: ISIGNE_EZ     ! sign of the vertical electric field 
                                                    ! component at the trig. pt
INTEGER, DIMENSION(:), ALLOCATABLE :: IPROC_TRIG    ! proc that contains the triggering point
INTEGER, DIMENSION(:), ALLOCATABLE :: INBSEG      ! Number of segments per flash
INTEGER, DIMENSION(:), ALLOCATABLE :: INB_FLASH     ! Number of flashes per time step / cell
INTEGER, DIMENSION(:), ALLOCATABLE :: INB_FL_REAL   ! Effective Number of flashes per timestep/cell
INTEGER, DIMENSION(:), ALLOCATABLE :: IHIST_LOC     ! local nb of possible branches at [r,r+dr]
INTEGER, DIMENSION(:), ALLOCATABLE :: IHIST_GLOB    ! global nb of possible branches at [r,r+dr]
                                                    ! at [r,r+dr] on each proc
INTEGER, DIMENSION(:), ALLOCATABLE :: IMAX_BRANCH   ! max nb of branches at [r,r+dr]
                                                    ! proportional to the percentage of 
                                                    ! available pts / proc at this distance
INTEGER, DIMENSION(:,:), ALLOCATABLE :: ISEG_LOC    ! Local indexes of the flash segments
INTEGER, DIMENSION(:,:), ALLOCATABLE :: ICELL_LOC   ! local indexes + proc of the cell 'center'
INTEGER, DIMENSION(:,:,:), ALLOCATABLE :: IMASKQ_DIST ! contains the distance/indice 
                                                      ! from the triggering pt
!
LOGICAL :: GPOSITIVE    ! if T, positive charge regions where the negative part 
                        ! of the leader propagates
LOGICAL :: GEND_DOMAIN  ! no more points with E > E_threshold
LOGICAL :: GEND_CELL    ! if T, end of the cell
LOGICAL :: GCG          ! if true, the flash is a CG
LOGICAL :: GCG_POS      ! if true, the flash is a +CG
LOGICAL :: GNEUTRALIZATION
LOGICAL :: GNEW_FLASH_GLOB
LOGICAL, DIMENSION(:), ALLOCATABLE :: GNEW_FLASH
LOGICAL, DIMENSION(:,:,:),   ALLOCATABLE :: GATTACH  ! if T, ion recombination and
                                                     ! attachment
LOGICAL, DIMENSION(:,:,:),   ALLOCATABLE :: GPOSS    ! if T, new cell possible at this pt
LOGICAL, DIMENSION(:,:,:,:), ALLOCATABLE :: GPROP    ! if T, propagation possible at this pt
!
REAL :: ZE_TRIG_THRES ! Triggering Electric field threshold corrected for
                      !  pressure   
REAL :: ZMAXE         ! Max electric field module (V/m)
REAL :: ZEMOD_BL      ! E module at the tip of the last segment of the leader (V/m)
REAL :: IICOORD_GLOB  ! global i index of the cell point
REAL :: IJCOORD_GLOB  ! global j index of the cell point
REAL :: ZMEAN_GRID    ! mean grid size
REAL :: ZMAX_DIST     ! max distance between the triggering pt and the possible branches
REAL :: ZMIN_DIST     ! min distance between the triggering pt and the possible branches
REAL :: ZRAD_INF      ! minimum radius from which to build the histograms
REAL :: ZRAD_SUP      ! maximum radius up to which the histograms are build
REAL :: ZRANDOM       ! random number
REAL :: ZQNET         ! net charge carried by the flash (C/kg)
REAL :: ZCLOUDLIM     ! cloud limit
REAL :: ZSIGMIN       ! min efficient cross section
!
!
REAL, DIMENSION(:,:,:,:), ALLOCATABLE :: ZQMT   ! mass charge density (C/kg)
REAL, DIMENSION(:,:,:,:), ALLOCATABLE :: ZCELL  ! define the electrified cells
REAL, DIMENSION(:,:,:,:), ALLOCATABLE :: ZSIGMA ! efficient cross section of hydrometeors
REAL, DIMENSION(:,:,:,:), ALLOCATABLE :: ZDQDT  ! charge to neutralize at each pt (C/kg)
REAL, DIMENSION(:,:,:,:), ALLOCATABLE :: ZFLASH ! = 1 if the flash leader reaches this pt
                                                ! = 2 if the flash branch is concerned
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZQTRANSFER ! Charge distributed on ions
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZLBDAR   ! Lambda for rain
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZLBDAS   ! Lambda for snow
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZLBDAG   ! Lambda for graupel
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZQMTOT   ! total mass charge density (C/kg)
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZCLOUD   ! total mixing ratio (kg/kg)
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZEMODULE ! Electric field module (V/m)
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZDIST    ! distance between the trig. pt and the cell pts (m)
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZSIGLOB  ! sum of the cross sections
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZQFLASH  ! total charge in excess of xqexcess (C/kg)
REAL, DIMENSION(:,:,:), ALLOCATABLE :: ZWORK
REAL, DIMENSION(:,:), ALLOCATABLE :: ZCOORD_SEG ! Global coordinates of segments
REAL, DIMENSION(:,:), ALLOCATABLE :: ZCELL_GLOB ! coordinates of the cell 'center' (m)
REAL, DIMENSION(:), ALLOCATABLE :: ZEM_TRIG     ! Electric field module at the triggering pt
REAL, DIMENSION(:), ALLOCATABLE :: ZNEUT_POS    ! Positive charge neutralized at each segment
REAL, DIMENSION(:), ALLOCATABLE :: ZNEUT_NEG    ! Negative charge neutralized at each segment
REAL, DIMENSION(:), ALLOCATABLE :: ZEMAX        ! Max electric field in each cell
REAL, DIMENSION(:), ALLOCATABLE :: ZHIST_PERCENT ! percentage of possible branches at [r,r+dr] on each proc
REAL, DIMENSION(:), ALLOCATABLE :: ZMAX_BRANCH  ! max nb of branches at [r,r+dr]
REAL, DIMENSION(:), ALLOCATABLE :: ZVECT
!
! Storage for nflash_write flashes before writing output files (denoted xSxxx)
INTEGER, SAVE :: ISAVE_STATUS ! 0: print and save
                              ! 1: save only
                              ! 2: print only
!
TYPE(LIST_ll), POINTER :: TZFIELDS_ll=> NULL()   ! list of fields to exchange
!
!-------------------------------------------------------------------------------
!
!*      1.      INITIALIZATION
!               --------------
CALL MYPROC_ELEC_ll(IPROC)
!
!*      1.1     subdomains indexes
!
! beginning and end indexes of the physical subdomain
IIB = 1 + JPHEXT
IIE = SIZE(PRT,1) - JPHEXT
IJB = 1 + JPHEXT
IJE = SIZE(PRT,2) - JPHEXT
IKB = 1 + JPVEXT
IKE = SIZE(PRT,3) - JPVEXT
IKU = SIZE(PRT,3)
!
! global indexes of the local subdomains origin
CALL GET_OR_ll('B',IXOR,IYOR)
!
!
!*      1.2     allocations and initializations
!
!
! from the litterature, the max number of flash per minute is ~ 1000
! this value is used here as the max number of flash per minute per cell
INBFTS_MAX = ANINT(1000 * PTSTEP / 60)
!
IF (GEFIRSTCALL) THEN
  GEFIRSTCALL = .FALSE.
  ALLOCATE (ZXMASS(SIZE(XXHAT)))
  ALLOCATE (ZYMASS(SIZE(XYHAT)))
  ALLOCATE (ZZMASS(SIZE(PZZ,1), SIZE(PZZ,2), SIZE(PZZ,3)))
  ALLOCATE (ZPRES_COEF(SIZE(PZZ,1), SIZE(PZZ,2), SIZE(PZZ,3)))
  ALLOCATE (ZSCOORD_SEG(NFLASH_WRITE, NBRANCH_MAX, 3))  ! NFLASH_WRITE nb of flash to be stored
                                            ! before writing in files
                                            ! NBRANCH_MAX=5000 default
  ALLOCATE (ISFLASH_NUMBER(0:NFLASH_WRITE))
  ALLOCATE (ISNB_FLASH(NFLASH_WRITE))
  ALLOCATE (ISCELL_NUMBER(NFLASH_WRITE))
  ALLOCATE (ISNBSEG(NFLASH_WRITE))
  ALLOCATE (ISTCOUNT_NUMBER(NFLASH_WRITE))
  ALLOCATE (ISTYPE(NFLASH_WRITE))
  ALLOCATE (ZSEM_TRIG(NFLASH_WRITE))
  ALLOCATE (ZSNEUT_POS(NFLASH_WRITE))
  ALLOCATE (ZSNEUT_NEG(NFLASH_WRITE))
!
  ZXMASS(IIB:IIE) = 0.5 * (XXHAT(IIB:IIE) + XXHAT(IIB+1:IIE+1))
  ZYMASS(IJB:IJE) = 0.5 * (XYHAT(IJB:IJE) + XYHAT(IJB+1:IJE+1))
  ZZMASS = MZF(1,IKU,1,PZZ)
  ZPRES_COEF = EXP(ZZMASS/8400.)
  ZSCOORD_SEG(:,:,:) = 0.0
  ISAVE_STATUS = 1
  ISFLASH_NUMBER(:) = 0
END IF
!
ALLOCATE (ZQMT(SIZE(PRSVS,1),SIZE(PRSVS,2),SIZE(PRSVS,3),SIZE(PRSVS,4)))
ALLOCATE (ZQMTOT(SIZE(PRSVS,1),SIZE(PRSVS,2),SIZE(PRSVS,3)))
ALLOCATE (ZCLOUD(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
ALLOCATE (GPOSS(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
ALLOCATE (ZEMODULE(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
ALLOCATE (ZCELL(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),NMAX_CELL))
ALLOCATE (ZQTRANSFER(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
!
ZQMT(:,:,:,:) = 0.
ZQMTOT(:,:,:) = 0.
ZCLOUD(:,:,:) = 0.
GPOSS(:,:,:) = .FALSE.
GPOSS(IIB:IIE,IJB:IJE,IKB:IKE) = .TRUE.
ZEMODULE(:,:,:) = 0.
ZCELL(:,:,:,:) = 0.
!
!
!*      1.3     point discharge (Corona)
!
PRSVS(:,:,:,1) = XECHARGE * PRSVS(:,:,:,1)             ! C /(m3 s)
PRSVS(:,:,:,NSV_ELEC) = -1. * XECHARGE * PRSVS(:,:,:,NSV_ELEC)  ! C /(m3 s)
CALL PT_DISCHARGE
!
!
!*      1.4     total charge density and mixing ratio
!
DO II = 1, NSV_ELEC
! transform the source term (C/s) into the updated charge density (C/kg)
  ZQMT(:,:,:,II) = PRSVS(:,:,:,II) * PTSTEP / PRHODJ(:,:,:)
!
! total mass charge density (C/kg)
  ZQMTOT(:,:,:)  = ZQMTOT(:,:,:)  + PRSVS(:,:,:,II) * PTSTEP / PRHODJ(:,:,:)
END DO
!
! total mixing ratio (g/kg)
DO II = 2, KRR
  ZCLOUD(:,:,:) = ZCLOUD(:,:,:) + PRT(:,:,:,II)
END DO
!
!
!*      1.5     constants
!
ZCLOUDLIM = 1.E-5 
ZSIGMIN   = 1.E-12
!
!
!-------------------------------------------------------------------------------
!
!*      2.      FIND AND COUNT THE ELECTRIFIED CELLS
!               ------------------------------------
!
ALLOCATE (ZEMAX(NMAX_CELL))
ALLOCATE (ICELL_LOC(NMAX_CELL,4))
ALLOCATE (ZCELL_GLOB(NMAX_CELL,3))
!
ZEMAX(:) = 0.
ICELL_LOC(:,:) = 0
ZCELL_GLOB(:,:) = 0.
!
WHERE (ZCLOUD(IIB:IIE,IJB:IJE,IKB:IKE) .LE. ZCLOUDLIM)
  GPOSS(IIB:IIE,IJB:IJE,IKB:IKE) = .FALSE.
END WHERE
!
!
!*      2.1     find the maximum electric field
!
GEND_DOMAIN = .FALSE.
GEND_CELL = .FALSE.
INB_CELL = 0
ZE_TRIG_THRES = XETRIG * (1. - XEBALANCE)
!
CALL TO_ELEC_FIELD_n (PRT, ZQMT, PRHODJ, KTCOUNT, KRR, &
                      PEFIELDU, PEFIELDV, PEFIELDW)
!
! electric field module including pressure effect
ZEMODULE(IIB:IIE,IJB:IJE,IKB:IKE) = ZPRES_COEF(IIB:IIE,IJB:IJE,IKB:IKE)*    &
                                    (PEFIELDU(IIB:IIE,IJB:IJE,IKB:IKE)**2 + &
                                     PEFIELDV(IIB:IIE,IJB:IJE,IKB:IKE)**2 + &
                                     PEFIELDW(IIB:IIE,IJB:IJE,IKB:IKE)**2)**0.5 
!
!
DO WHILE (.NOT. GEND_DOMAIN .AND. INB_CELL .LT. NMAX_CELL)  
!
! find the maximum electric field on each proc
  IF (COUNT(GPOSS(IIB:IIE,IJB:IJE,IKB:IKE)) .GT. 0) THEN
    ZMAXE = MAXVAL(ZEMODULE(IIB:IIE,IJB:IJE,IKB:IKE), MASK=GPOSS(IIB:IIE,IJB:IJE,IKB:IKE))
  ELSE
    ZMAXE = 0.
  END IF
!
! find the max electric field on the whole domain + the proc that contains this value
  CALL MAX_ELEC_ll (ZMAXE, IPROC_CELL)
!
  IF (ZMAXE .GT. ZE_TRIG_THRES) THEN
    INB_CELL = INB_CELL + 1  ! one cell is detected
!
    ZEMAX(INB_CELL) = ZMAXE
! local coordinates of the maximum electric field
!   ICELL_LOC(INB_CELL,1:3) = MAXLOC(ZEMODULE(:,:,:),MASK=GPOSS(:,:,:))
    ICELL_LOC(INB_CELL,1:3) = MAXLOC(ZEMODULE(IIB:IIE,IJB:IJE,IKB:IKE), &
                              MASK=GPOSS(IIB:IIE,IJB:IJE,IKB:IKE))
    IICOORD = ICELL_LOC(INB_CELL,1)
    IJCOORD = ICELL_LOC(INB_CELL,2)
    IKCOORD = ICELL_LOC(INB_CELL,3)
    ICELL_LOC(INB_CELL,4) = IPROC_CELL
! 
! Broadcast the center of the cell to all procs
    CALL MPI_BCAST (ICELL_LOC(INB_CELL,:), 4, MPI_INTEGER, IPROC_CELL, &
                    MPI_COMM_WORLD, IERR)
!
!
!*      2.2     horizontal extension of the cell 
!
    DO IK = IKB, IKE 
      IF (IPROC_CELL .EQ. IPROC) THEN
        IF (GPOSS(IICOORD,IJCOORD,IK)) THEN
          ZCELL(IICOORD,IJCOORD,IK,INB_CELL) = 1.
          GPOSS(IICOORD,IJCOORD,IK) = .FALSE.
        END IF
      END IF
!
!*      2.2.1   do the neighbour points have q_tot > q_thresh?
!
      GEND_CELL = .FALSE.
      DO WHILE (.NOT. GEND_CELL)
!
        CALL ADD2DFIELD_ll  (TZFIELDS_ll, ZCELL(:,:,IK,INB_CELL))
        CALL UPDATE_HALO_ll (TZFIELDS_ll, IINFO_ll)
        CALL CLEANLIST_ll   (TZFIELDS_ll)
!
        COUNT_BEF = COUNT(ZCELL(IIB:IIE,IJB:IJE,IK,INB_CELL) .EQ. 1.)
        CALL SUM_ELEC_ll (COUNT_BEF)
!
        DO II = IIB, IIE
          DO IJ = IJB, IJE
             IF ((ZCELL(II,IJ,IK,INB_CELL) .EQ. 0.) .AND.  &
                 (GPOSS(II,IJ,IK)) .AND.                   &
                 (ZCLOUD(II,IJ,IK) .GT. 1.E-5) .AND.       &
                 ((ABS(ZQMT(II,IJ,IK,2)) * PRHODREF(II,IJ,IK) .GT. XQEXCES).OR. &
                  (ABS(ZQMT(II,IJ,IK,3)) * PRHODREF(II,IJ,IK) .GT. XQEXCES).OR. &
                  (ABS(ZQMT(II,IJ,IK,4)) * PRHODREF(II,IJ,IK) .GT. XQEXCES).OR. &
                  (ABS(ZQMT(II,IJ,IK,5)) * PRHODREF(II,IJ,IK) .GT. XQEXCES).OR. &
                  (ABS(ZQMT(II,IJ,IK,6)) * PRHODREF(II,IJ,IK) .GT. XQEXCES)) )THEN

                IF ((ZCELL(II-1,IJ,  IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II+1,IJ,  IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II,  IJ-1,IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II,  IJ+1,IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II-1,IJ-1,IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II-1,IJ+1,IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II+1,IJ+1,IK,INB_CELL) .EQ. 1.) .OR. &
                    (ZCELL(II+1,IJ-1,IK,INB_CELL) .EQ. 1.)) THEN
                  ZCELL(II,IJ,IK,INB_CELL) = 1.
                  GPOSS(II,IJ,IK) = .FALSE.
                END IF
             END IF
          END DO
        END DO
!
        COUNT_AFT = COUNT(ZCELL(IIB:IIE,IJB:IJE,IK,INB_CELL) .EQ. 1.)
        CALL SUM_ELEC_ll(COUNT_AFT)
!
        IF (COUNT_BEF .EQ. COUNT_AFT) THEN
          GEND_CELL = .TRUE.  ! no more point in the cell at this level
        ELSE
          GEND_CELL = .FALSE.
        END IF
      END DO  ! end loop gend_cell
    END DO  ! end loop ik
!
! avoid cell detection in the colums where a previous cell is already present 
    DO II = IIB, IIE
      DO IJ = IJB, IJE
        DO IK = IKB, IKE
          IF (ZCELL(II,IJ,IK,INB_CELL) .EQ. 1.) GPOSS(II,IJ,:) = .FALSE.
        END DO
      END DO
    END DO
  ELSE  
    GEND_DOMAIN = .TRUE.    ! no more points with E > E_threshold
  END IF  ! max E
END DO  ! end loop gend_domain
!
DEALLOCATE (GPOSS)
DEALLOCATE (ZEMAX)
!
!
!*      2.3     if at least 1 cell, allocate arrays
!
IF (INB_CELL .GE. 1) THEN
!
! mean mesh size
  ZMEAN_GRID = (XDXHATM**2 + XDYHATM**2 +                            &
               (SUM(XZHAT(2:SIZE(PRT,3)) - XZHAT(1:SIZE(PRT,3)-1)) / &
               (SIZE(PRT,3)-1.))**2)**0.5
! chaque proc calcule son propre zmean_grid
! mais cette valeur peut etre differente sur chaque proc (ex: relief)
! laisse tel quel pour le moment
!
  ALLOCATE (ISEG_LOC(3*SIZE(PRT,3), INB_CELL)) ! 3 coord indices of the leader
  ALLOCATE (ZCOORD_SEG(NBRANCH_MAX*3, INB_CELL))
                                         ! NBRANCH_MAX=5000 default
                                         ! 3= 3 coord index
  ALLOCATE (ZEM_TRIG(INB_CELL))
  ALLOCATE (INB_FLASH(INB_CELL))
  ALLOCATE (INB_FL_REAL(INB_CELL))
  ALLOCATE (INBSEG(INB_CELL)) 
  ALLOCATE (ITYPE(INB_CELL)) 
  ALLOCATE (INBSEG_LEADER(INB_CELL))
  ALLOCATE (ZDQDT(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),SIZE(PRT,4)+1))
  ALLOCATE (ZSIGMA(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),SIZE(PRT,4)-1))
  ALLOCATE (ZLBDAR(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (ZLBDAS(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (ZLBDAG(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (ZSIGLOB(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (ZFLASH(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),INB_CELL))
  ALLOCATE (ZDIST(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (ZQFLASH(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
  ALLOCATE (GATTACH(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
!
  ISEG_LOC(:,:) = 0
  ZCOORD_SEG(:,:) = 0.
  ZDQDT(:,:,:,:) = 0.
  ZSIGMA(:,:,:,:) = 0.
  ZLBDAR(:,:,:) = 0.
  ZLBDAS(:,:,:) = 0.
  ZLBDAG(:,:,:) = 0. 
  ZSIGLOB(:,:,:) = 0.
  ZFLASH(:,:,:,:) = 0.
  ZDIST(:,:,:) = 0.
  ZQFLASH(:,:,:) = 0.
  ZEM_TRIG(:) = 0.
  INB_FLASH(:) = 0
  INB_FL_REAL(:) = 0
  INBSEG(:) = 0
  INBSEG_LEADER(:) = 0
  ITYPE(:) = 1  ! default = IC
!
!
!-------------------------------------------------------------------------------
!
!*      3.      COMPUTE THE EFFICIENT CROSS SECTIONS OF HYDROMETEORS
!               ----------------------------------------------------
!
!*      3.1     for cloud droplets
!
  WHERE (PRT(:,:,:,2) > ZCLOUDLIM)
    ZSIGMA(:,:,:,1) = XFQLIGHTC * PRHODREF(:,:,:) * PRT(:,:,:,2)
  ENDWHERE
!
!
!*      3.2     for raindrops
!
  WHERE (PRT(:,:,:,3) > 0.0)
    ZLBDAR(:,:,:) = XLBR * (PRHODREF(:,:,:) * &
                            MAX(PRT(:,:,:,3),XRTMIN(3)))**XLBEXR
  END WHERE
!
  WHERE (PRT(:,:,:,3) > ZCLOUDLIM .AND. ZLBDAR(:,:,:) < XLBDAR_MAX .AND. &
                                        ZLBDAR(:,:,:) > 0.)
    ZSIGMA(:,:,:,2) = XFQLIGHTR * ZLBDAR(:,:,:)**XEXQLIGHTR
  END WHERE
!
!
!*      3.3     for ice crystals
!
  WHERE (PRT(:,:,:,4) > ZCLOUDLIM .AND. PCIT(:,:,:) > 1.E4)
    ZSIGMA(:,:,:,3) = XFQLIGHTI * PCIT(:,:,:)**(1.-XEXQLIGHTI) * &
                     ((PRHODREF(:,:,:) * PRT(:,:,:,4))**XEXQLIGHTI)
  ENDWHERE
!
!
!*      3.4     for snow
!
  WHERE (PRT(:,:,:,5) > 0.0)
    ZLBDAS(:,:,:) = MIN(XLBDAS_MAX,                &
                        XLBS * (PRHODREF(:,:,:) *  &
                        MAX(PRT(:,:,:,5),XRTMIN(5)))**XLBEXS)
  END WHERE
!
  WHERE (PRT(:,:,:,5) > ZCLOUDLIM .AND. ZLBDAS(:,:,:) < XLBDAS_MAX .AND. &
                                        ZLBDAS(:,:,:) > 0.)
    ZSIGMA(:,:,:,4) = XFQLIGHTS * ZLBDAS(:,:,:)**XEXQLIGHTS
  ENDWHERE
!
!
!*      3.5     for graupel
!
  WHERE (PRT(:,:,:,6) > 0.0)
    ZLBDAG(:,:,:) = XLBG * (PRHODREF(:,:,:) * MAX(PRT(:,:,:,6),XRTMIN(6)))**XLBEXG
  END WHERE
!
  WHERE (PRT(:,:,:,6) > ZCLOUDLIM .AND. ZLBDAG(:,:,:) < XLBDAG_MAX .AND. &
                                        ZLBDAG(:,:,:) > 0.)
    ZSIGMA(:,:,:,5) = XFQLIGHTG * ZLBDAG(:,:,:)**XEXQLIGHTG
  ENDWHERE
!
!
!*      3.6     for hail
!
!
!
!*      3.7     sum of the efficient cross sections
!
  ZSIGLOB(:,:,:) = ZSIGMA(:,:,:,1) + ZSIGMA(:,:,:,2) + ZSIGMA(:,:,:,3) + &
                   ZSIGMA(:,:,:,4) + ZSIGMA(:,:,:,5)
!
!
!-------------------------------------------------------------------------------
!
!*      4.      FIND THE TRIGGERING POINT IN EACH CELL
!               --------------------------------------
!
  ALLOCATE (IPROC_TRIG(INB_CELL))
  ALLOCATE (ISIGNE_EZ(INB_CELL))
  ALLOCATE (GNEW_FLASH(INB_CELL))
  ALLOCATE (ZNEUT_POS(INB_CELL))
  ALLOCATE (ZNEUT_NEG(INB_CELL))
!
  IPROC_TRIG(:) = 0
  ISIGNE_EZ(:) = 0
  GNEW_FLASH(:) = .FALSE.
  ZNEUT_POS(:) = 0.
  ZNEUT_NEG(:) = 0.
!
  CALL TRIG_POINT
!
!
!-------------------------------------------------------------------------------
!
!*      4.      FLASH TRIGGERING
!               ----------------
!
  DO WHILE (GNEW_FLASH_GLOB)
!
    GATTACH(:,:,:) = .FALSE.
!
    DO IL = 1, INB_CELL
      IF (GNEW_FLASH(IL)) THEN
        ZFLASH(:,:,:,IL) = 0.
! update lightning informations
        INB_FLASH(IL) = INB_FLASH(IL) + 1   ! nb of flashes / cell / time step
        INB_FL_REAL(IL) = INB_FL_REAL(IL) + 1   ! nb of flashes / cell / time step
        INBSEG(IL) = 1        ! nb of segments / flash
        ITYPE(IL) = 1
!
        IF (IPROC .EQ. IPROC_TRIG(IL)) THEN 
           ZEMOD_BL = ZEM_TRIG(IL)
           IIBL_LOC = ISEG_LOC(1,IL)    
           IJBL_LOC = ISEG_LOC(2,IL)
           IKBL     = ISEG_LOC(3,IL) 
!
           ZFLASH(IIBL_LOC,IJBL_LOC,IKBL,IL)  = 1.
        ENDIF
!
        GCG = .FALSE.
        GCG_POS = .FALSE.
!
!
!-------------------------------------------------------------------------------
!
!*      5.      PROPAGATE THE BIDIRECTIONAL LEADER
!               ----------------------------------
!
! it is assumed that the leader propagates only along the vertical
!
!*      5.1     positive segments
!
! the positive leader propagates parallel to the electric field
        ISIGN_LEADER = 1
        CALL ONE_LEADER
        IPOS_LEADER = INBSEG(IL) -1
!
!
!*      5.2     negative segments
!
! the negative leader propagates anti-parallel to the electric field
        ZEMOD_BL = ZEM_TRIG(IL)
        IKBL     = ISEG_LOC(3,IL)
        ISIGN_LEADER = -1
        CALL ONE_LEADER
!
        INBSEG_LEADER(IL) = INBSEG(IL)
        INEG_LEADER = INBSEG_LEADER(IL) - IPOS_LEADER -1
!
! Eliminate this flash if only positive or negative leader exists        

        IF (IPROC .EQ. IPROC_TRIG(IL)) THEN 
          IF (IPOS_LEADER .EQ. 0 .OR. INEG_LEADER .EQ. 0) THEN
            ZFLASH(IIBL_LOC,IJBL_LOC,IKB:IKE,IL)=0.
            INB_FL_REAL(IL) = INB_FL_REAL(IL) - 1
            GNEW_FLASH(IL) = .FALSE.
          ELSE    ! return to actual Triggering electrical field
            IIBL_LOC = ISEG_LOC(1,IL)
            IJBL_LOC = ISEG_LOC(2,IL)
            IKBL     = ISEG_LOC(3,IL)
            ZEM_TRIG(IL) = ZEM_TRIG(IL)/ZPRES_COEF(IIBL_LOC,IJBL_LOC,IKBL)
          ENDIF
        ENDIF
!
        CALL MPI_BCAST (GNEW_FLASH(IL),1, MPI_LOGICAL, IPROC_TRIG(IL), &
                        MPI_COMM_WORLD, IERR)
        CALL MPI_BCAST (ZEM_TRIG(IL), 1, MPI_PRECISION, IPROC_TRIG(IL), &
                        MPI_COMM_WORLD, IERR)
        CALL MPI_BCAST (INB_FL_REAL(IL), 1, MPI_INTEGER, IPROC_TRIG(IL), &
                        MPI_COMM_WORLD, IERR)
      END IF
    END DO  ! end loop il
!
!
!-------------------------------------------------------------------------------
!
!*      6.      POSITIVE AND NEGATIVE REGIONS WHERE THE FLASH CAN PROPAGATE
!               -----------------------------------------------------------
!
! Note: this is done to avoid branching in a third charge region:
! the branches 'stay' in the 2 charge regions where the bileader started to propagate
!
!*      6.1     positive charge region associated to the negative leader
!
    ALLOCATE (GPROP(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),INB_CELL))
    GPROP(:,:,:,:) = .FALSE.
!
    GPOSITIVE = .TRUE.
    CALL CHARGE_POCKET
!
!
!*      6.2     negative charge region associated to the positive leader
!
    GPOSITIVE = .FALSE.
    CALL CHARGE_POCKET
!
! => a point can be added to the flash only if gprop = true
!
!
!-------------------------------------------------------------------------------
!
!*      7.      NUMBER OF POINTS TO REDISTRIBUTE AT DISTANCE D
!               ----------------------------------------------
!
!*      7.1     distance between the triggering point and each point of the mask
!*              global coordinates: only points possibly contributing to branches
!
    INB_NEUT_OK = 0
!
    DO IL = 1, INB_CELL
      IF (GNEW_FLASH(IL)) THEN
        INB_PROP = COUNT(GPROP(IIB:IIE,IJB:IJE,IKB:IKE,IL))
        CALL SUM_ELEC_ll(INB_PROP)
!
        IF (INB_PROP .GT. 0) THEN
          ZDIST(:,:,:) = 0.
          DO II = IIB, IIE
            DO IJ = IJB, IJE
              DO IK = IKB, IKE
                IF (GPROP(II,IJ,IK,IL)) THEN
                  ZDIST(II,IJ,IK) = ((ZXMASS(II) - ZCOORD_SEG(1,IL))**2 + &
                                     (ZYMASS(IJ) - ZCOORD_SEG(2,IL))**2 + &
                                     (ZZMASS(II,IJ,IK) - ZCOORD_SEG(3,IL))**2)**0.5
                END IF
              END DO
            END DO
          END DO
!
!
!*      7.3     compute the min and max distance from the triggering point - global
!
          ZMIN_DIST = 0.0
          ZMAX_DIST = MAX_ll(ZDIST,IPROC_AUX)
!
! transform the min and max distances into min and max increments 
          IIND_MIN = 1
          IIND_MAX = MAX(1, INT((ZMAX_DIST-ZMIN_DIST)/ZMEAN_GRID +1.))
          IDELTA_IND = IIND_MAX +1
!
          ALLOCATE (IHIST_LOC(IDELTA_IND))
          ALLOCATE (ZHIST_PERCENT(IDELTA_IND))
          ALLOCATE (IHIST_GLOB(IDELTA_IND))
          ALLOCATE (ZMAX_BRANCH(IDELTA_IND))
          ALLOCATE (IMAX_BRANCH(IDELTA_IND))
          ALLOCATE (IMASKQ_DIST(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
!
          IHIST_LOC(:) = 0
          ZHIST_PERCENT(:) = 0.
          IHIST_GLOB(:) = 0
          ZMAX_BRANCH(:) = 0.
          IMAX_BRANCH(:) = 0
          IMASKQ_DIST(:,:,:) = 0
!
!
!*      7.4     histogram: number of points between r and r+dr
!*              for each proc
!
! build an array with the possible points: IMASKQ_DIST contains the distance 
! rank of points contributing to branches, excluding the leader points
!
          DO II = IIB, IIE 
            DO IJ = IJB, IJE
              DO IK = IKB, IKE
                IF (ZDIST(II,IJ,IK) .NE. 0.) THEN
                  IM = INT( (ZDIST(II,IJ,IK)-ZMIN_DIST)/ZMEAN_GRID + 1.)
                  IHIST_LOC(IM) = IHIST_LOC(IM) + 1
                  IMASKQ_DIST(II,IJ,IK) = IM
                ENDIF
              END DO
            END DO
          END DO
!
!
!*      7.5     global histogram
!
          IHIST_GLOB(:) = IHIST_LOC(:) 
          CALL SUM_ELEC_ll(IHIST_GLOB)
!
!
!*      7.6     normalization
!
          ZHIST_PERCENT(:) = 0.
          ZMAX_BRANCH(:) = 0.
          IMAX_BRANCH(:) = 0
!
          DO IM = 1, IDELTA_IND
            IF (IHIST_GLOB(IM) .GT. 0) THEN
              ZHIST_PERCENT(IM) = FLOAT(IHIST_LOC(IM)) / FLOAT(IHIST_GLOB(IM))
            END IF
!
!
!-------------------------------------------------------------------------------
!
!*      8.      BRANCHES
!               --------
!
!*      8.1     max number of branches at distance d from the triggering point
!
            ZMAX_BRANCH(IM) = (XDFRAC_L / ZMEAN_GRID) * &
                              FLOAT(IIND_MIN+IM-1)**(XDFRAC_ECLAIR - 1.)
            ZMAX_BRANCH(IM) = ANINT(ZMAX_BRANCH(IM))
! all procs know the max total number of branches at distance d
! => the max number of branches / proc is proportional to the percentage of 
! available points / proc at this distance
!
! this line must be commented if branch_geom is called once
!            IMAX_BRANCH(IM) = INT(ANINT(ZMAX_BRANCH(IM) * ZHIST_PERCENT(IM) / 2.))
! this line must be commented if branch_geom is called twice
            IMAX_BRANCH(IM) = INT(ANINT(ZMAX_BRANCH(IM)))
          END DO
!
          DEALLOCATE (IHIST_LOC)
          DEALLOCATE (ZHIST_PERCENT)
          DEALLOCATE (IHIST_GLOB)
          DEALLOCATE (ZMAX_BRANCH)
!
!
!*      8.3     distribute the branches
!
          ALLOCATE (ZWORK(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)))
!
! upper branches
!          CALL BRANCH_GEOM(IK_TRIG+1, IKE)
!
! lower branches
!          CALL BRANCH_GEOM(IKB, IK_TRIG-1)
!
          CALL BRANCH_GEOM(IKB, IKE)
!
          DEALLOCATE (ZWORK)
          DEALLOCATE (IMAX_BRANCH)
          DEALLOCATE (IMASKQ_DIST)
        END IF   ! end if count(gprop)
!
!
!-------------------------------------------------------------------------------
!
!*      9.      NEUTRALIZATION
!               --------------
!
!*      9.1     charge carried by the lightning flash
!
        ZQFLASH(:,:,:) = 0.
        WHERE (ZFLASH(IIB:IIE,IJB:IJE,IKB:IKE,IL) .GT. 0. .AND.          &
               ABS(ZQMTOT(IIB:IIE,IJB:IJE,IKB:IKE) *                     &
                   PRHODREF(IIB:IIE,IJB:IJE,IKB:IKE)) .GT. XQNEUT .AND. &
               ZSIGLOB(IIB:IIE,IJB:IJE,IKB:IKE) .GE. ZSIGMIN)
          ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) = -1. *               &             
                         (ABS(ZQMTOT(IIB:IIE,IJB:IJE,IKB:IKE)) / &
                              ZQMTOT(IIB:IIE,IJB:IJE,IKB:IKE)) * &
                         (ABS(ZQMTOT(IIB:IIE,IJB:IJE,IKB:IKE)) - &
                         (XQNEUT / PRHODREF(IIB:IIE,IJB:IJE,IKB:IKE)))
          GATTACH(IIB:IIE,IJB:IJE,IKB:IKE) = .TRUE.

        END WHERE
!
! net charge carried by the flash (for charge conservation / IC)
        ZQNET = SUM3D_ll(ZQFLASH*PRHODJ, IINFO_ll)
!
!
!*      9.2     number of points to neutralize
!
        INB_NEUT = COUNT(ZSIGLOB(IIB:IIE,IJB:IJE,IKB:IKE) .GE. ZSIGMIN .AND. &
                         ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) .NE. 0.)
        CALL SUM_ELEC_ll(INB_NEUT)

!
!
!*      9.3     ensure total charge conservation for IC
!
        IF (INB_NEUT .GE. 3) THEN
          GNEUTRALIZATION = .TRUE.
        ELSE
          GNEUTRALIZATION = .FALSE.
          GNEW_FLASH(IL) = .FALSE. 
          INB_FL_REAL(IL) = INB_FL_REAL(IL) - 1
        END IF
!
        IF (GNEUTRALIZATION .AND. (.NOT. GCG) .AND. ZQNET .NE. 0.) THEN
          ZQNET = ZQNET / FLOAT(INB_NEUT) 
          WHERE (ZSIGLOB(IIB:IIE,IJB:IJE,IKB:IKE) .GE. ZSIGMIN .AND. &
                 ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) .NE. 0.)
            ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) = ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) - &
                                       ZQNET / PRHODJ(IIB:IIE,IJB:IJE,IKB:IKE) 
          ENDWHERE
        END IF
!
!
!*      9.4     charge neutralization 
!
        ZDQDT(:,:,:,:) = 0.
!  
        IF (GNEUTRALIZATION) THEN
          IF (ITYPE(IL) .EQ. 1.) THEN         
            WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) < 0.)
                       !  increase negative ion charge
              ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,NSV_ELEC) =         &
                          ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,NSV_ELEC) +  &
                          ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)
            ENDWHERE
!
            WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) > 0.)
                     ! Increase positive ion charge
              ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,1) =         &
                          ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,1) +  &
                          ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)
            ENDWHERE
!
!
!*      9.4.2   cloud-to-ground flashes
!
          ELSE   
!
! Neutralization of the charge on positive CG flashes
            IF (ITYPE(IL) .EQ. 3) THEN   
              DO II = 1, NSV_ELEC
                WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) > 0.)
                    ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,II) =    &
                       ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,II) - &
                       ZQMT(IIB:IIE,IJB:IJE,IKB:IKE,II)
                END WHERE
              ENDDO
!
              WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) > 0.) 
                  ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)=0.
              END WHERE
!
              WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) < 0.)
! Increase negative ion charge
                   ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,NSV_ELEC) =         &
                          ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,NSV_ELEC) +  &
                          ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)
              ENDWHERE
            ELSE
!
! Neutralization of the charge on negative CG flashes
!
              DO II = 1, NSV_ELEC
                WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) < 0.)
                    ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,II) =    &
                       ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,II) - &
                       ZQMT(IIB:IIE,IJB:IJE,IKB:IKE,II)
                END WHERE
              ENDDO
!
              WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) < 0.)
                  ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)=0.
              END WHERE
!
              WHERE (ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE) > 0.)
                        ! Increase positive ion charge
                   ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,1) =         &
                          ZDQDT(IIB:IIE,IJB:IJE,IKB:IKE,1) +  &
                          ZQFLASH(IIB:IIE,IJB:IJE,IKB:IKE)
              ENDWHERE
            END IF        ! GCG_POS
          END IF          ! NOT(GCG)
!
! Counting the total number of points neutralized in the cell
          IF (IPROC .EQ. IPROC_TRIG(IL)) THEN
             INB_NEUT_OK = INB_NEUT_OK + INB_NEUT
          END IF
!
          CALL MPI_BCAST (INB_NEUT_OK,1, MPI_INTEGER, IPROC_TRIG(IL), &
                    MPI_COMM_WORLD, IERR)
        END IF            !  GNEUTRALIZATION
!
!
!*      9.5     update the source term
!
        DO II = IIB, IIE
          DO IJ = IJB, IJE
            DO IK = IKB, IKE
              DO IM = 1, NSV_ELEC
                IF (ZDQDT(II,IJ,IK,IM) .NE. 0.) THEN
                  PRSVS(II,IJ,IK,IM) = PRSVS(II,IJ,IK,IM) + &
                                       ZDQDT(II,IJ,IK,IM) * &
                                       PRHODJ(II,IJ,IK) / PTSTEP
                END IF
!
!
!*      9.6     update the positive and negative charge neutralized
!
                IF (ZDQDT(II,IJ,IK,IM) .LT. 0.) THEN
                  ZNEUT_NEG(IL) = ZNEUT_NEG(IL) + ZDQDT(II,IJ,IK,IM)*  &
                                                  PRHODJ(II,IJ,IK) 
                ELSE IF (ZDQDT(II,IJ,IK,IM) .GT. 0.) THEN
                  ZNEUT_POS(IL) = ZNEUT_POS(IL) + ZDQDT(II,IJ,IK,IM)*  &
                                                  PRHODJ(II,IJ,IK) 
                END IF
              END DO
            END DO
          END DO
        END DO
!
        CALL SUM_ELEC_ll(ZNEUT_POS(IL))
        CALL SUM_ELEC_ll(ZNEUT_NEG(IL))
!
      END IF    ! end if gnew_flash
    END DO    ! end loop il
!
    DEALLOCATE (GPROP)
!
!
!----------------------------------------------------------------------------
!
!*      10.     PRINT OR SAVE (before print) LIGHTNING INFORMATIONS
!               ---------------------------------------------------
!
! Synchronizing all processes
    IF (IPROC .EQ. 0) THEN
      INBLIGHT = COUNT(GNEW_FLASH(1:INB_CELL))
      IF (INBLIGHT .NE. 0) THEN
        IF ((NNBLIGHT+INBLIGHT) .LE. NFLASH_WRITE) THEN       ! SAVE
          ISAVE_STATUS = 1
          DO IL = 1, INB_CELL
            IF (GNEW_FLASH(IL)) THEN
              NNBLIGHT = NNBLIGHT + 1
              ISFLASH_NUMBER(NNBLIGHT) = ISFLASH_NUMBER(NNBLIGHT-1) +1
              ISNB_FLASH(NNBLIGHT) = INB_FL_REAL(IL)
              ISNBSEG(NNBLIGHT) = INBSEG(IL)
              ISCELL_NUMBER(NNBLIGHT) = IL
              ISTCOUNT_NUMBER(NNBLIGHT) = KTCOUNT
              ISTYPE(NNBLIGHT) = ITYPE(IL)
              ZSEM_TRIG(NNBLIGHT) = ZEM_TRIG(IL) / 1000.
              ZSNEUT_POS(NNBLIGHT) = ZNEUT_POS(IL) 
              ZSNEUT_NEG(NNBLIGHT) = ZNEUT_NEG(IL)
!
              DO II = 1, INBSEG(IL)
                DO IJ = 1,3
                  ZSCOORD_SEG(NNBLIGHT, II, IJ) = ZCOORD_SEG(3*(II-1)+IJ, IL)
                END DO
              ENDDO
            END IF
          ENDDO
!
          IF (NNBLIGHT .EQ. NFLASH_WRITE) ISAVE_STATUS = 0
!
        ELSE    ! Print in output files
          ISAVE_STATUS = 2
        END IF
!      
        IF (ISAVE_STATUS.EQ. 0 .OR. ISAVE_STATUS.EQ. 2) THEN
          CALL WRITE_OUT_ASCII
          ISFLASH_NUMBER(0) = ISFLASH_NUMBER(NNBLIGHT)
        END IF
!
        IF (ISAVE_STATUS .EQ. 2) THEN   ! Save flashes of the temporal loop
          NNBLIGHT = 0
          DO IL = 1, INB_CELL
            IF (GNEW_FLASH(IL)) THEN
               NNBLIGHT = NNBLIGHT + 1
              ISFLASH_NUMBER(NNBLIGHT) = ISFLASH_NUMBER(NNBLIGHT-1) +1
              ISNB_FLASH(NNBLIGHT) = INB_FL_REAL(IL)
              ISNBSEG(NNBLIGHT) = INBSEG(IL)
              ISCELL_NUMBER(NNBLIGHT) = IL
              ISTCOUNT_NUMBER(NNBLIGHT) = KTCOUNT
              ISTYPE(NNBLIGHT) = ITYPE(IL)
              ZSEM_TRIG(NNBLIGHT) = ZEM_TRIG(IL) / 1000.
              ZSNEUT_POS(NNBLIGHT) = ZNEUT_POS(IL) 
              ZSNEUT_NEG(NNBLIGHT) = ZNEUT_NEG(IL)
!
              DO II = 1, INBSEG(IL)
                DO IJ = 1,3
                  ZSCOORD_SEG(NNBLIGHT, II, IJ)=ZCOORD_SEG(3*(II-1)+IJ, IL)
                ENDDO
              ENDDO
            END IF
          ENDDO
        END IF
!
        IF (ISAVE_STATUS .EQ. 0) THEN
          NNBLIGHT = 0
        END IF
      END IF   ! INBLIGHT
    END IF   ! IPROC
!
!
!------------------------------------------------------------------------------
!
!*    11.      ATTACHMENT AFTER CHARGE NEUTRALIZATION
!              --------------------------------------
!
!*    11.1     ion attachment
!
    IF (INB_NEUT_OK .NE. 0) THEN
      PRSVS(:,:,:,1) = PRSVS(:,:,:,1) / XECHARGE
      PRSVS(:,:,:,NSV_ELEC) = - PRSVS(:,:,:,NSV_ELEC) / XECHARGE
!
      IF (PRESENT(PSEA)) THEN
        CALL ION_ATTACH_ELEC(KTCOUNT, KRR, PTSTEP, PRHODREF,                   &
                             PRHODJ, PRSVS, PRS, PTHT, PCIT, PPABST, PEFIELDU, &
                             PEFIELDV, PEFIELDW, GATTACH, PTOWN, PSEA          )
      ELSE
        CALL ION_ATTACH_ELEC(KTCOUNT, KRR, PTSTEP, PRHODREF,                   &
                             PRHODJ, PRSVS, PRS, PTHT, PCIT, PPABST, PEFIELDU, & 
                             PEFIELDV, PEFIELDW, GATTACH                       )
      ENDIF
!
      PRSVS(:,:,:,1) = PRSVS(:,:,:,1) * XECHARGE
      PRSVS(:,:,:,NSV_ELEC) = - PRSVS(:,:,:,NSV_ELEC) * XECHARGE
    ENDIF
!
!
!*    11.2    update the charge density to check if another flash can be triggered
!
    ZQMTOT(:,:,:) = 0.  
    DO II = 1, NSV_ELEC
! transform the source term (C/s) into the updated charge density (C/kg)
      ZQMT(:,:,:,II) = PRSVS(:,:,:,II) * PTSTEP / PRHODJ(:,:,:)
!
! total charge density (C/kg)
      ZQMTOT(:,:,:)  = ZQMTOT(:,:,:) + PRSVS(:,:,:,II) * PTSTEP / PRHODJ(:,:,:)
    END DO
!
!
!-------------------------------------------------------------------------------
!
!*      12.     CHECK IF ANOTHER FLASH CAN BE TRIGGERED
!               ---------------------------------------
!

    IF ((MAXVAL(INB_FLASH(:))+1) < INBFTS_MAX) THEN
      IF (INB_NEUT_OK .NE. 0) THEN
        CALL TO_ELEC_FIELD_n (PRT, ZQMT, PRHODJ, KTCOUNT, KRR, &
                              PEFIELDU, PEFIELDV, PEFIELDW)
! electric field module including pressure effect
        ZEMODULE(IIB:IIE,IJB:IJE,IKB:IKE) = ZPRES_COEF(IIB:IIE,IJB:IJE,IKB:IKE)*    &
                                            (PEFIELDU(IIB:IIE,IJB:IJE,IKB:IKE)**2 + &
                                             PEFIELDV(IIB:IIE,IJB:IJE,IKB:IKE)**2 + &
                                             PEFIELDW(IIB:IIE,IJB:IJE,IKB:IKE)**2)**0.5
      ENDIF
      CALL TRIG_POINT
    ELSE
      GNEW_FLASH_GLOB = .FALSE.
    END IF
!
    ZNEUT_POS(:) = 0.
    ZNEUT_NEG(:) = 0.
  END DO   ! end loop do while
!
  DEALLOCATE (ZNEUT_POS)
  DEALLOCATE (ZNEUT_NEG)
  DEALLOCATE (ZSIGMA)
  DEALLOCATE (ZLBDAR)
  DEALLOCATE (ZLBDAS)
  DEALLOCATE (ZLBDAG)
  DEALLOCATE (ZSIGLOB)
  DEALLOCATE (ZDQDT)
  DEALLOCATE (ZDIST)
  DEALLOCATE (ZFLASH)
  DEALLOCATE (ZQFLASH)
  DEALLOCATE (IPROC_TRIG)
  DEALLOCATE (ISIGNE_EZ)
  DEALLOCATE (GNEW_FLASH)
  DEALLOCATE (INBSEG)
  DEALLOCATE (INBSEG_LEADER)
  DEALLOCATE (INB_FLASH)
  DEALLOCATE (INB_FL_REAL)
  DEALLOCATE (ZEM_TRIG)
  DEALLOCATE (ITYPE)
  DEALLOCATE (ISEG_LOC)
  DEALLOCATE (ZCOORD_SEG)
  DEALLOCATE (GATTACH)
END IF   ! (inb_cell .ge. 1)
!
!
!-------------------------------------------------------------------------------
!
!*      13.     PRINT LIGHTNING INFORMATIONS FOR THE LAST TIMESTEP
!               --------------------------------------------------

IF (NNBLIGHT .NE. 0 .AND. IPROC .EQ. 0 .AND. KTCOUNT .EQ. NSTOP) THEN
  CALL WRITE_OUT_ASCII
END IF
!
!
!-------------------------------------------------------------------------------
!
!*      14.     DEALLOCATE
!               ----------
!
DEALLOCATE (ZCELL_GLOB)
DEALLOCATE (ICELL_LOC)
DEALLOCATE (ZQMT)
DEALLOCATE (ZQMTOT)
DEALLOCATE (ZCLOUD)
DEALLOCATE (ZCELL)
DEALLOCATE (ZEMODULE)
DEALLOCATE (ZQTRANSFER)
!
!
!-------------------------------------------------------------------------------
!
!*      14.     BACK TO INPUT UNITS (per kg and per (m3 s)) FOR IONS
!               ----------------------------------------------------
!
PRSVS(:,:,:,1) = PRSVS(:,:,:,1) / XECHARGE          ! 1 /(m3 s)
PRSVS(:,:,:,NSV_ELEC) = -PRSVS(:,:,:,NSV_ELEC) / XECHARGE    ! 1 /(m3 s)
!
!
!-------------------------------------------------------------------------------
!
CONTAINS
!
!-------------------------------------------------------------------------------
!
  SUBROUTINE TRIG_POINT ()
!
! Goal : find randomly a triggering point where E > E_trig
!
!*      0.      DECLARATIONS
!               ------------
!
IMPLICIT NONE
!
!*      0.1     declaration of dummy arguments
!
!*      0.2     declaration of local variables
!
LOGICAL, DIMENSION(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3),INB_CELL) :: &
           GTRIG  ! mask for the triggering pts
INTEGER :: INB_TRIG  ! Nb of pts where triggering is possible
INTEGER :: IWEST_GLOB_TRIG   ! western  global limit of possible triggering
INTEGER :: IEAST_GLOB_TRIG   ! eastern  global limit of possible triggering
INTEGER :: ISOUTH_GLOB_TRIG  ! southern global limit of possible triggering
INTEGER :: INORTH_GLOB_TRIG  ! northern global limit of possible triggering
INTEGER :: IUP_TRIG          ! upper limit of possible triggering
INTEGER :: IDOWN_TRIG        ! down limit of possible triggering
!
!
!*      1.      INITIALIZATIONS 
!               -----------
!
GTRIG(:,:,:,:) = .FALSE.
GNEW_FLASH(:) = .FALSE.
GNEW_FLASH_GLOB = .FALSE.
!
!
!*      2.      FIND THE POSSIBLE TRIGGERING POINTS 
!               -----------------------------------
!
DO IL = 1, INB_CELL
  WHERE (ZEMODULE(IIB:IIE,IJB:IJE,IKB:IKE) > ZE_TRIG_THRES .AND. &
         ZCELL(IIB:IIE,IJB:IJE,IKB:IKE,IL) .GT. 0.)
    GTRIG(IIB:IIE,IJB:IJE,IKB:IKE,IL) = .TRUE.
  ENDWHERE
END DO
!
!
!*      3.     CHOICE OF THE TRIGGERING POINT 
!              ------------------------------
!
!*      3.1    number and coordinates of the possible triggering points
!
INB_TRIG = 0
DO IL = 1, INB_CELL
  INB_TRIG = COUNT(GTRIG(IIB:IIE,IJB:IJE,IKB:IKE,IL))
  CALL SUM_ELEC_ll(INB_TRIG)
!
!
!*      3.2    random choice of the triggering point
!
 IF (INB_TRIG .GT. 0) THEN
    IFOUND = 0
!
! find the global limits where GTRIG = T
    CALL EXTREMA_ELEC_ll(GTRIG(:,:,:,IL), IWEST_GLOB_TRIG,  IEAST_GLOB_TRIG,  &
                                          ISOUTH_GLOB_TRIG, INORTH_GLOB_TRIG, &
                                          IDOWN_TRIG, IUP_TRIG)
!
    DO WHILE (IFOUND .NE. 1)
!
! random choice of the 3 global ind.
      CALL RANDOM_NUMBER(ZRANDOM)
      II_TRIG_GLOB = IWEST_GLOB_TRIG + &
                      INT(ANINT(ZRANDOM * (IEAST_GLOB_TRIG - IWEST_GLOB_TRIG)))
      CALL RANDOM_NUMBER(ZRANDOM)
      IJ_TRIG_GLOB = ISOUTH_GLOB_TRIG + &
                      INT(ANINT(ZRANDOM * (INORTH_GLOB_TRIG - ISOUTH_GLOB_TRIG)))
      CALL RANDOM_NUMBER(ZRANDOM)
      IK_TRIG = IDOWN_TRIG + INT(ANINT(ZRANDOM * (IUP_TRIG - IDOWN_TRIG)))
!
! global ind. --> local ind. of the potential triggering pt
      II_TRIG_LOC = II_TRIG_GLOB - IXOR + 1
      IJ_TRIG_LOC = IJ_TRIG_GLOB - IYOR + 1
!
! test if the randomly chosen pt meets all conditions for triggering
      IF ((II_TRIG_LOC .LE. IIE) .AND. (II_TRIG_LOC .GE. IIB) .AND. &
          (IJ_TRIG_LOC .LE. IJE) .AND. (IJ_TRIG_LOC .GE. IJB) .AND. &
          (IK_TRIG     .LE. IKE) .AND. (IK_TRIG     .GE. IKB)) THEN
        IF (GTRIG(II_TRIG_LOC,IJ_TRIG_LOC,IK_TRIG,IL)) THEN
          IFOUND = 1
!
! update the local coordinates of the flash segments
          ISEG_LOC(1,IL) = II_TRIG_LOC
          ISEG_LOC(2,IL) = IJ_TRIG_LOC
          ISEG_LOC(3,IL) = IK_TRIG
          ZCOORD_SEG(1,IL) = ZXMASS(II_TRIG_LOC)
          ZCOORD_SEG(2,IL) = ZYMASS(IJ_TRIG_LOC)
          ZCOORD_SEG(3,IL) = ZZMASS(II_TRIG_LOC, IJ_TRIG_LOC, IK_TRIG)
!
! electric field module at the triggering point
          ZEM_TRIG(IL) = ZEMODULE(II_TRIG_LOC,IJ_TRIG_LOC,IK_TRIG)
!
! sign of Ez at the triggering point
!
          ISIGNE_EZ(IL) = 0
          IF (PEFIELDW(II_TRIG_LOC,IJ_TRIG_LOC,IK_TRIG) .GT. 0.) THEN
            ISIGNE_EZ(IL) = 1
          ELSE IF (PEFIELDW(II_TRIG_LOC,IJ_TRIG_LOC,IK_TRIG) .LT. 0.) THEN
            ISIGNE_EZ(IL) = -1
          END IF
        END IF
      END IF
!
! broadcast IFOUND and find the proc where IFOUND = 1
      CALL MAX_ELEC_ll (IFOUND, IPROC_TRIG(IL))

    END DO
!
!
!
!*      4.      BROADCAST USEFULL PARAMETERS
!               ----------------------------
!
    CALL MPI_BCAST (ZEM_TRIG(IL), 1,&
                    MPI_PRECISION, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
    CALL MPI_BCAST (ISEG_LOC(:,IL), 3*SIZE(PRT,3),   &     
                    MPI_INTEGER, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
    CALL MPI_BCAST (ZCOORD_SEG(:,IL), NBRANCH_MAX*3, & 
                    MPI_PRECISION, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
    CALL MPI_BCAST (ISIGNE_EZ(IL), 1,&
                    MPI_INTEGER, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
!
!
!*      5.      CHECK IF THE FLASH CAN DEVELOP
!               ------------------------------
!
    IF (INB_FLASH(IL) < INBFTS_MAX) THEN
      IF (IPROC.EQ.IPROC_TRIG(IL)) THEN  
        ZCELL(II_TRIG_LOC,IJ_TRIG_LOC,IK_TRIG,IL) = 0.
      END IF
!
      GNEW_FLASH(IL) = .TRUE.
      GNEW_FLASH_GLOB = .TRUE.
      CALL MPI_BCAST (GNEW_FLASH(IL),1, MPI_LOGICAL, IPROC_TRIG(IL), &
                      MPI_COMM_WORLD, IERR)
      CALL MPI_BCAST (GNEW_FLASH_GLOB,1, MPI_LOGICAL, IPROC_TRIG(IL), &
                      MPI_COMM_WORLD, IERR)
    END IF
  END IF 
END DO
!
!
END SUBROUTINE TRIG_POINT
!
!-------------------------------------------------------------------------------
!
  SUBROUTINE ONE_LEADER ()
!
!! Purpose: propagates the bidirectional leader along the vertical
!
!*      0.      DECLARATIONS
!               ------------
!
IMPLICIT NONE
!
INTEGER :: IKSTEP, IIDECAL         
!
!*      1.      BUILD THE POSITIVE/NEGATIVE LEADER
!               ----------------------------------
!
IKSTEP = ISIGN_LEADER * ISIGNE_EZ(IL)
    ! the positive leader propagates parallel to the electric field
    ! while the negative leader propagates anti// to the electric field
ISTOP = 0
!
!
IF (IPROC .EQ. IPROC_TRIG(IL)) THEN

  DO WHILE (ZEMOD_BL > XEPROP .AND. IKBL > IKB .AND. &
            IKBL < IKE .AND. ISTOP .EQ. 0 .AND.      &
            INBSEG(IL) .LE. (NLEADER_MAX-1))  
!
!    local coordinates of the new segment
!
    IIBL_LOC = ISEG_LOC(1,IL)
    IJBL_LOC = ISEG_LOC(2,IL)
    IKBL     = IKBL + IKSTEP
    IIDECAL = INBSEG(IL)*3
    ISEG_LOC(IIDECAL+1,IL) = IIBL_LOC
    ISEG_LOC(IIDECAL+2,IL) = IJBL_LOC
    ISEG_LOC(IIDECAL+3,IL) = IKBL
    ZCOORD_SEG(IIDECAL+1,IL) = ZXMASS(IIBL_LOC)
    ZCOORD_SEG(IIDECAL+2,IL) = ZYMASS(IJBL_LOC)
    ZCOORD_SEG(IIDECAL+3,IL) = ZZMASS(IIBL_LOC, IJBL_LOC, IKBL)
    INBSEG(IL) = INBSEG(IL) + 1
!
!
!*      1.3     test if Ez keeps the same sign
!
    IF (PEFIELDW(IIBL_LOC,IJBL_LOC,IKBL) .EQ. 0. .OR. &
        INT(ABS(PEFIELDW(IIBL_LOC,IJBL_LOC,IKBL)) / &
                PEFIELDW(IIBL_LOC,IJBL_LOC,IKBL)) /= ISIGNE_EZ(IL) .OR. &
                ZCELL(IIBL_LOC,IJBL_LOC,IKBL,IL) .EQ. 0.) THEN
      ISTOP = 1
! then this segment is not part of the leader
      INBSEG(IL) = INBSEG(IL) - 1
    END IF
!
!
!*      1.4     sign of the induced charge
!
    IF (ISTOP .EQ. 0) THEN
      ZFLASH(IIBL_LOC,IJBL_LOC,IKBL,IL) = 1.
      ZCELL(IIBL_LOC,IJBL_LOC,IKBL,IL) = 0.   
!
!
!*      1.6     electric field module at the tip of the leader
!
      ZEMOD_BL = ZEMODULE(IIBL_LOC,IJBL_LOC,IKBL)
!
!
!*      1.7     test if the domain boundaries are reached
!
      IF ((IIBL_LOC < IIB .AND. LWEST_ll())  .OR. &
          (IIBL_LOC > IIE .AND. LEAST_ll())  .OR. &
          (IJBL_LOC < IJB .AND. LSOUTH_ll()) .OR. &
          (IJBL_LOC > IJE .AND. LNORTH_ll())) THEN
        PRINT*,'DOMAIN BOUNDARIES REACHED BY THE LIGHTNING ' 
        ISTOP = 1
      ENDIF
!
      IF (IKBL .LE. IKB) THEN
        PRINT*,'THE LIGHTNING FLASH HAS REACHED THE GROUND ' 
        ISTOP = 1
        GCG = .TRUE.
        IF (ISIGN_LEADER > 0) THEN
          GCG_POS = .TRUE.
          ITYPE(IL) = 3 ! CGP
        ELSE
          ITYPE(IL) = 2 ! CGN
        END IF
      ENDIF
!
      IF (IKBL .GE. IKE) THEN
        PRINT*,'THE LIGHTNING FLASH HAS REACHED THE TOP OF THE DOMAIN ' 
        ISTOP = 1
      ENDIF
!
!
!*      2.      TEST IF THE FLASH IS A CG
!               -------------------------
!
      IF (.NOT. GCG) THEN
!       IF ((0.0005*(XZHAT(IKBL)+XZHAT(IKBL+1))) <= XALT_CG .AND. &
        IF ( (ZZMASS(IIBL_LOC,IJBL_LOC,IKBL)-PZZ(IIBL_LOC,IJBL_LOC,IKB)) <=   &
             XALT_CG .AND. ZCLOUD(IIBL_LOC,IJBL_LOC,IKBL) <= ZCLOUDLIM .AND.  &
             INBSEG(IL) .GT. 1  .AND. IKSTEP .LT. 0) THEN
!
!
!*      2.1    the channel is prolongated to the ground if 
!*             one segment reaches the altitude XALT_CG
!
          DO WHILE (IKBL > IKB)
            IKBL = IKBL - 1

! local coordinates of the new segment
            IIDECAL = INBSEG(IL)*3
            ISEG_LOC(IIDECAL+1,IL) = IIBL_LOC
            ISEG_LOC(IIDECAL+2,IL) = IJBL_LOC
            ISEG_LOC(IIDECAL+3,IL) = IKBL
            ZCOORD_SEG(IIDECAL+1:IIDECAL+2,IL) = ZCOORD_SEG(IIDECAL-2:IIDECAL-1,IL)
            ZCOORD_SEG(IIDECAL+3,IL) = ZZMASS(IIBL_LOC, IJBL_LOC, IKBL)

!  Increment number of segments
            INBSEG(IL) = INBSEG(IL) + 1 ! Nb of segments
            ZFLASH(IIBL_LOC,IJBL_LOC,IKBL,IL) = 1.
            ZCELL(IIBL_LOC,IJBL_LOC,IKBL,IL) = 0.   
          END DO
!
          GCG = .TRUE.
          ISTOP = 1
!
          IF (ISIGN_LEADER > 0) THEN
            GCG_POS = .TRUE.
            ITYPE(IL) = 3
          ELSE
            ITYPE(IL) = 2
          END IF
        END IF
!
!
!*      2.2    update the number of CG flashes
!
        IF (GCG) THEN
          NNB_CG = NNB_CG + 1
          IF (GCG_POS) THEN
            NNB_CG_POS = NNB_CG_POS + 1
          END IF
        END IF
      END IF
    END IF     ! end if ISTOP=0
  END DO   ! end loop leader
END IF  ! only iproc_trig was working
!
!
!*      3.     BROADCAST THE INFORMATIONS TO ALL PROCS
!              ---------------------------------------
!
CALL MPI_BCAST (INBSEG(IL), 1,          &
                MPI_INTEGER, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
CALL MPI_BCAST (ISEG_LOC(:,IL), 3*SIZE(PRT,3),   &  
                MPI_INTEGER, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
CALL MPI_BCAST (ZCOORD_SEG(:,IL), NBRANCH_MAX*3,    &       
                MPI_PRECISION, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
CALL MPI_BCAST (ITYPE(IL), 1,&
                MPI_INTEGER, IPROC_TRIG(IL), MPI_COMM_WORLD, IERR)
!
!
END SUBROUTINE ONE_LEADER
!
!-------------------------------------------------------------------------------
!
  SUBROUTINE CHARGE_POCKET
!
!!
!! Purpose: limit flash propagation into the positive and negative charge layers
!!          located immediatly above and below the triggering point
!!
!*       0.      DECLARATIONS
!                ------------
!
IMPLICIT NONE
!
REAL, DIMENSION(SIZE(PRT,1),SIZE(PRT,2),SIZE(PRT,3)) :: ZSIGN_AREA
REAL, DIMENSION(INB_CELL) :: ZSIGN  ! sign of the charge immediatly below/above the triggering pt 
!
INTEGER, DIMENSION(INB_CELL) :: IEND  ! if 1, no more neighbour pts meeting the conditions
INTEGER, DIMENSION(INB_CELL) :: COUNT_BEF2
INTEGER, DIMENSION(INB_CELL) :: COUNT_AFT2
INTEGER :: IPROC_END
INTEGER :: IEND_GLOB
INTEGER :: IIDECAL, IKMIN, IKMAX
REAL :: ZFACT
!
!
!*       1.      SEARCH THE POINTS BELONGING TO THE LAYERS 
!                -----------------------------------------
!
ZFACT = -1.
IF(GPOSITIVE) ZFACT = 1.

ZSIGN_AREA(:,:,:) = 0.
ZSIGN(:) = 0.
IEND(:) = 0
IEND_GLOB = 0
!
!
DO IL = 1, INB_CELL
  IF (.NOT. GNEW_FLASH(IL)) THEN
    IEND(IL) = 1
    IEND_GLOB = IEND_GLOB + IEND(IL)
  END IF
  IF (GNEW_FLASH(IL) .AND. IPROC .EQ. IPROC_TRIG(IL)) THEN
    DO II = 1, INBSEG(IL)
      IIDECAL = 3*(II-1)
      IIBL_LOC = ISEG_LOC(IIDECAL+1,IL)
      IJBL_LOC = ISEG_LOC(IIDECAL+2,IL)
      IKBL     = ISEG_LOC(IIDECAL+3,IL)
!
      IF (ZQMTOT(IIBL_LOC,IJBL_LOC,IKBL) .GT. 0. .AND. GPOSITIVE) THEN
        ZSIGN_AREA(IIBL_LOC,IJBL_LOC,IKBL) = 1. * FLOAT(IL)
        ZSIGN(IL) = ZSIGN_AREA(IIBL_LOC,IJBL_LOC,IKBL)
      ELSE IF (ZQMTOT(IIBL_LOC,IJBL_LOC,IKBL) .LT. 0. .AND. .NOT.GPOSITIVE) THEN
        ZSIGN_AREA(IIBL_LOC,IJBL_LOC,IKBL) = -1. * FLOAT(IL)
        ZSIGN(IL) = ZSIGN_AREA(IIBL_LOC,IJBL_LOC,IKBL)
      END IF
    END DO
  END IF
!
  CALL MPI_BCAST (ZSIGN(IL), 1, MPI_PRECISION, IPROC_TRIG(IL), &
                  MPI_COMM_WORLD, IERR)
END DO
!
DO WHILE (IEND_GLOB .NE. INB_CELL)
  DO IL = 1, INB_CELL
    CALL ADD3DFIELD_ll  (TZFIELDS_ll, ZSIGN_AREA)
    CALL UPDATE_HALO_ll (TZFIELDS_ll, IINFO_ll)
    CALL CLEANLIST_ll   (TZFIELDS_ll)
!
    IF (GNEW_FLASH(IL) .AND. (IEND(IL) .NE. 1)) THEN
      COUNT_BEF2(IL) = COUNT(ZSIGN_AREA(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. ZSIGN(IL))
      CALL SUM_ELEC_ll (COUNT_BEF2(IL))
!
      IF (ISIGNE_EZ(IL).EQ.1) THEN
        IF (GPOSITIVE) THEN
          IKMIN = IKB
          IKMAX = ISEG_LOC(3, IL)
        ELSE
          IKMIN = ISEG_LOC(3, IL)
          IKMAX = IKE
        ENDIF
      ENDIF
!
      IF (ISIGNE_EZ(IL).EQ.-1) THEN
        IF (GPOSITIVE) THEN
          IKMIN = ISEG_LOC(3, IL)
          IKMAX = IKE
        ELSE
          IKMIN = IKB
          IKMAX = ISEG_LOC(3, IL)
        ENDIF
      ENDIF
!
      DO II = IIB, IIE
        DO IJ = IJB, IJE
          DO IK = IKMIN, IKMAX
            IF ((ZSIGN_AREA(II,  IJ,  IK)   .EQ. 0.) .AND.   &
                (ZCELL(II,IJ,IK,IL) .EQ. 1.) .AND.           &
                (.NOT. GPROP(II,IJ,IK,IL)) .AND.             &
                (ZQMTOT(II,IJ,IK)*ZFACT .GT. 0.) .AND.       &
                (ABS(ZQMTOT(II,IJ,IK) *                      &
                     PRHODREF(II,IJ,IK)) .GT. XQNEUT)) THEN
!
              IF ((ZSIGN_AREA(II-1,IJ,  IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ,  IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ-1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ+1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ-1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ+1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ+1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ-1,IK)   .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ,  IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ,  IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ,  IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ-1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ+1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ-1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ+1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ+1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ-1,IK+1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ,  IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ,  IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ,  IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ-1,IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II,  IJ+1,IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ-1,IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II-1,IJ+1,IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ+1,IK-1) .EQ. ZSIGN(IL)) .OR. &
                  (ZSIGN_AREA(II+1,IJ-1,IK-1) .EQ. ZSIGN(IL))) THEN
                ZSIGN_AREA(II,IJ,IK) = ZSIGN(IL)
                GPROP(II,IJ,IK,IL) = .TRUE.
              END IF
            END IF
          END DO
        END DO
      END DO
!
      COUNT_AFT2(IL) = COUNT(ZSIGN_AREA(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. ZSIGN(IL))
      CALL SUM_ELEC_ll(COUNT_AFT2(IL))
!
      IF (COUNT_BEF2(IL) .EQ. COUNT_AFT2(IL)) THEN
        IEND(IL) = 1
      ELSE
        IEND(IL) = 0
      END IF

! broadcast IEND and find the proc where IEND = 1
      CALL MAX_ELEC_ll (IEND(IL), IPROC_END)
      IEND_GLOB = IEND_GLOB + IEND(IL)
    END IF
  END DO
END DO  ! end do while
!
END SUBROUTINE CHARGE_POCKET
!
!-------------------------------------------------------------------------------
!
  SUBROUTINE BRANCH_GEOM (IKMIN, IKMAX)
!
! Goal : find randomly flash branch points
!
!*      0.      DECLARATIONS
!               ------------
!
IMPLICIT NONE
!
!*      0.1     declaration of dummy arguments
!
INTEGER, INTENT(IN) :: IKMIN, IKMAX
!
!*      0.2     declaration of local variables
!
INTEGER :: IIDECALB
INTEGER :: IPLOOP  ! loop index for the proc number
INTEGER :: IMIN, IMAX
INTEGER :: IAUX
INTEGER :: INB_SEG_BEF  ! nb of segments before branching
INTEGER :: INB_SEG_AFT  ! nb of segments after branching
INTEGER :: INB_SEG_TO_BRANCH ! = NBRANCH_MAX-INB_SEG_BEF
LOGICAL :: GRANDOM           ! T = the gridpoints are chosen randomly
INTEGER, DIMENSION(NPROC) :: INBPT_PROC
REAL, DIMENSION(:), ALLOCATABLE :: ZAUX
!
!
!*      1.      ON EACH PROC, COUNT THE NUMBER OF POINTS AT DISTANCE D 
!*              THAT CAN RECEIVE A BRANCH
!               ------------------------------------------------------
!
IM = 1
ISTOP = 0
INB_SEG_BEF = COUNT(ZFLASH(IIB:IIE,IJB:IJE,IKB:IKE,IL) .NE. 0.)
CALL SUM_ELEC_ll(INB_SEG_BEF)
!
INB_SEG_TO_BRANCH = NBRANCH_MAX - INB_SEG_BEF
!
DO WHILE (IM .LE. IDELTA_IND .AND. ISTOP .NE. 1)
! number of points that can receive a branch in each proc
  IPT_DIST = COUNT(IMASKQ_DIST(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. IM)
! global number of points that can receive a branch
  IPT_DIST_GLOB = IPT_DIST
  CALL SUM_ELEC_ll (IPT_DIST_GLOB)
!
  IF (IPT_DIST_GLOB .LE. INB_SEG_TO_BRANCH) THEN
     IF (IPT_DIST_GLOB .LE. IMAX_BRANCH(IM)) THEN
       GRANDOM = .FALSE.
     ELSE
       GRANDOM = .TRUE.
     END IF
  ELSE
     GRANDOM = .TRUE.
  END IF
!
!
!*      2.      DISTRIBUTE THE BRANCHES
!               -----------------------
!
  IF (IPT_DIST_GLOB .GT. 0 .AND. INB_SEG_TO_BRANCH .NE. 0) THEN
    IF (.NOT. GRANDOM) THEN

     INB_SEG_TO_BRANCH = INB_SEG_TO_BRANCH - IPT_DIST_GLOB
!
!*      2.1     all points are selected
!
     IF(IPT_DIST .GT. 0) THEN 
      WHERE (IMASKQ_DIST(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. IM)
        ZFLASH(IIB:IIE,IJB:IJE,IKB:IKE,IL) = 2.
        ZCELL(IIB:IIE,IJB:IJE,IKB:IKE,IL) = 0.
      END WHERE
     END IF

    ELSE
!
!*      2.2      the gridpoints are chosen randomly
!
      IF (IMAX_BRANCH(IM) .GT. 0) THEN
        INBPT_PROC(:) = 0
        CALL MPI_ALLGATHER(IPT_DIST, 1, MPI_INTEGER, &
                   INBPT_PROC, 1, MPI_INTEGER, MPI_COMM_WORLD, IERR)
!
        IF (IPROC .EQ. 0) THEN
          IF (INBPT_PROC(1) .NE. 0) THEN
            IMIN = 1
            IMAX = INBPT_PROC(1)
          ELSE 
            IMIN = 0
            IMAX = 0
          END IF
        ELSE
          IF (INBPT_PROC(IPROC+1) .NE. 0) THEN
            IMIN = SUM(INBPT_PROC(1:IPROC)) + 1
            IMAX = SUM(INBPT_PROC(1:IPROC+1))
          ELSE
            IMIN = 0
            IMAX = 0
          END IF
        END IF
!
        ZWORK(:,:,:) = 0.
        IF (IPT_DIST .GT. 0) THEN 
          WHERE (IMASKQ_DIST(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. IM)
            ZWORK(IIB:IIE,IJB:IJE,IKB:IKE) = 1.
          END WHERE
!
          ALLOCATE (ZVECT(IPT_DIST))
          ALLOCATE (ZAUX(IPT_DIST))
          ZVECT(:) = PACK(ZWORK(:,:,:), MASK=(IMASKQ_DIST(:,:,:).EQ.IM))
          ZVECT(:) = 0.
          ZAUX(:) = 0.
          DO II = 1, IPT_DIST
            ZVECT(II) = REAL(IMIN + II - 1)
          END DO
        END IF
!
        DO IPOINT = 1, MIN(IMAX_BRANCH(IM), INB_SEG_TO_BRANCH)
          IFOUND = 0
          DO WHILE (IFOUND .NE. 1)
! randomly chose points in zvect
            CALL RANDOM_NUMBER(ZRANDOM)
            ICHOICE = INT(ANINT(ZRANDOM * IPT_DIST_GLOB))
            IF (ICHOICE .EQ. 0) ICHOICE = 1
            DO II = 1, IPT_DIST
              IF (ZVECT(II) .EQ. ICHOICE) THEN
                ZVECT(II) = 0.
                IFOUND = 1
              END IF  
            END DO
            CALL SUM_ELEC_ll(IFOUND)
          END DO
        END DO
!
        INB_SEG_TO_BRANCH = INB_SEG_TO_BRANCH - MIN(IMAX_BRANCH(IM), INB_SEG_TO_BRANCH)
!
        IF (IPT_DIST .GT. 0) THEN
          WHERE (ZVECT(:) .EQ. 0.)
            ZAUX(:) = 1.
          END WHERE
!
          ZWORK(:,:,:) = 0.
          ZWORK(:,:,:) = UNPACK(ZAUX(:), MASK=(IMASKQ_DIST(:,:,:).EQ.IM), FIELD=0.0)
          WHERE (ZWORK(IIB:IIE,IJB:IJE,IKB:IKE) .EQ. 1.) 
            ZFLASH(IIB:IIE,IJB:IJE,IKB:IKE,IL)  = 2.
            ZCELL(IIB:IIE,IJB:IJE,IKB:IKE,IL) = 0.
          END WHERE
          DEALLOCATE (ZVECT)
          DEALLOCATE (ZAUX)
        ENDIF
      END IF
    END IF                   !IPT_DIST .LE. IMAX_BRANCH(IM)
  ELSE
! if no pt available at r, then no branching possible at r+dr !
      ISTOP = 1
  END IF  ! end if ipt_dist > 0
!
! next distance
  IM = IM + 1
END DO   ! end loop / do while / radius IM

INB_SEG_AFT = COUNT (ZFLASH(IIB:IIE,IJB:IJE,IKB:IKE,IL) .NE. 0.)
CALL SUM_ELEC_ll(INB_SEG_AFT)
IF (INB_SEG_AFT .GT. INB_SEG_BEF) THEN
  DO IPLOOP = 0, NPROC-1
    IF (IPROC .EQ. IPLOOP) THEN
      DO II = IIB, IIE
        DO IJ = IJB, IJE
          DO IK = IKB, IKE
            IF (ZFLASH(II,IJ,IK,IL) .EQ. 2.) THEN 
              IIDECALB = INBSEG(IL)*3
              ZCOORD_SEG(IIDECALB+1,IL) = ZXMASS(II)
              ZCOORD_SEG(IIDECALB+2,IL) = ZYMASS(IJ)
              ZCOORD_SEG(IIDECALB+3,IL) = ZZMASS(II, IJ, IK)
              INBSEG(IL) = INBSEG(IL) + 1
            END IF
          END DO
        END DO
      END DO
    END IF
    CALL MPI_BCAST (INBSEG(IL), 1,&
                    MPI_INTEGER, IPLOOP, MPI_COMM_WORLD, IERR)
    CALL MPI_BCAST (ZCOORD_SEG(:,IL), NBRANCH_MAX*3,   &
                    MPI_PRECISION, IPLOOP, MPI_COMM_WORLD, IERR)
  END DO
END IF
!
END SUBROUTINE BRANCH_GEOM
!
!------- ------------------------------------------------------------------------
!
  SUBROUTINE PT_DISCHARGE
!
!!
!! Purpose:
!!
!
!*      0.     DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!
WHERE (ABS(PEFIELDW(:,:,IKB)) > XECORONA .AND. PEFIELDW(:,:,IKB) > 0.)
  PRSVS(:,:,IKB,1) = PRSVS(:,:,IKB,1) +                                     &
                     XFCORONA * PEFIELDW(:,:,IKB) * (ABS(PEFIELDW(:,:,IKB)) - &
                     XECORONA)**2 / (PZZ(:,:,IKB+1) - PZZ(:,:,IKB))
ENDWHERE

WHERE (ABS(PEFIELDW(:,:,IKB)) > XECORONA .AND. PEFIELDW(:,:,IKB) < 0.)
  PRSVS(:,:,IKB,NSV_ELEC) = PRSVS(:,:,IKB,NSV_ELEC) +                         &
                     XFCORONA * PEFIELDW(:,:,IKB) * (ABS(PEFIELDW(:,:,IKB)) - &
                     XECORONA)**2 / (PZZ(:,:,IKB+1) - PZZ(:,:,IKB))
ENDWHERE

END SUBROUTINE PT_DISCHARGE
!

!-----------------------------------------------------------------------------------
!
  SUBROUTINE WRITE_OUT_ASCII

!!
!! Purpose:
!!
!
!*      0.     DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
INTEGER :: I1, I2
!
!
!*      1.     FLASH PARAMETERS
!              ---------------
OPEN (UNIT=NLU_fgeom_diag, FILE=CEXP//"_fgeom_diag.asc", ACTION="WRITE", &
      STATUS="OLD", FORM="FORMATTED", POSITION="APPEND")
!
! Ecriture ascii dans CEXP//'_fgeom_diag.asc" defini dans RESOLVED_ELEC
!
DO I1 = 1, NNBLIGHT
  WRITE (NLU_fgeom_diag,FMT='(I8,F9.1,I4,I6,I4,I6,F9.3,F9.3,F9.3,F7.3,F8.2,F9.2,f9.4)') &
        ISFLASH_NUMBER(I1),              &
        ISTCOUNT_NUMBER(I1) * PTSTEP,    &
        ISCELL_NUMBER(I1),               &
        ISNB_FLASH(I1),                  &
        ISTYPE(I1),                      &
        ISNBSEG(I1),                     &
        ZSEM_TRIG(I1),                   &
        ZSCOORD_SEG(I1,1,1)*1.E-3,       &
        ZSCOORD_SEG(I1,1,2)*1.E-3,       &
        ZSCOORD_SEG(I1,1,3)*1.E-3,       &
        ZSNEUT_POS(I1),                  &
        ZSNEUT_NEG(I1), ZSNEUT_POS(I1)+ZSNEUT_NEG(I1)
ENDDO
!
CLOSE (UNIT=NLU_fgeom_diag)
!
!
!*      2.     FLASH SEGMENT COORDINATES
!              -------------------------
!
IF (LSAVE_COORD) THEN
! Ecriture ascii dans CEXP//'_fgeom_coord.asc" defini dans RESOLVED_ELEC
!
  OPEN (UNIT=NLU_fgeom_coord, FILE=CEXP//"_fgeom_coord.asc", ACTION="WRITE", &
        STATUS="OLD", FORM="FORMATTED", POSITION="APPEND")
!
  DO I1 = 1, NNBLIGHT
    DO I2 = 1, ISNBSEG(I1)
      WRITE (NLU_fgeom_coord, FMT='(I4,F9.1,I4,F12.3,F12.3,F12.3)') &
                 ISFLASH_NUMBER(I1),           & 
                 ISTCOUNT_NUMBER(I1) * PTSTEP, & 
                 ISTYPE(I1),                   &
                 ZSCOORD_SEG(I1,I2,1)*1.E-3,   &
                 ZSCOORD_SEG(I1,I2,2)*1.E-3,   &
                 ZSCOORD_SEG(I1,I2,3)*1.E-3
    END DO
  END DO
!
  CLOSE (UNIT=NLU_fgeom_coord)
END IF
!
END SUBROUTINE WRITE_OUT_ASCII
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE FLASH_GEOM_ELEC_n
!
!-------------------------------------------------------------------------------

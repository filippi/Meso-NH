!MNH_LIC Copyright 2000-2023 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Author: Valery Masson (Meteo-France)
!     Original 15/05/2000
! Modifications:
!  P. Lacarrere   03/2008: add 3D fluxes
!  P. Wautelet 05/2016-04/2018: new data structures and calls for I/O
!  P. Wautelet 13/09/2019: budget: simplify and modernize date/time management
!  P. Wautelet    06/2022: reorganize flyers
!-----------------------------------------------------------------
!      #####################
MODULE MODE_AIRCRAFT_BALLOON
!      #####################

USE MODE_MSG

IMPLICIT NONE

PRIVATE

PUBLIC :: AIRCRAFT_BALLOON

PUBLIC :: AIRCRAFT_BALLOON_LONGTYPE_GET

PUBLIC :: FLYER_RECV_AND_ALLOCATE, FLYER_SEND

INTEGER, PARAMETER :: NTAG_NCUR = 145
INTEGER, PARAMETER :: NTAG_PACK = 245

INTEGER, PARAMETER :: NMODEL_FIX = 1
INTEGER, PARAMETER :: NMODEL_MOB = 2

INTEGER, PARAMETER :: NTYPE_AIRCRA = 0
INTEGER, PARAMETER :: NTYPE_CVBALL = 1
INTEGER, PARAMETER :: NTYPE_ISODEN = 2
INTEGER, PARAMETER :: NTYPE_RADIOS = 4


CONTAINS
!
!     #################################################################
      SUBROUTINE AIRCRAFT_BALLOON(PTSTEP, PZ,                         &
                                  PMAP, PLONOR, PLATOR,               &
                                  PU, PV, PW, PP, PTH, PR, PSV, PTKE, &
                                  PTS, PRHODREF, PCIT, PSEA           )
!     #################################################################
! *AIRCRAFT_BALLOON* - monitor for balloons and aircrafts

USE MODD_AIRCRAFT_BALLOON
USE MODD_TURB_FLUX_AIRCRAFT_BALLOON

USE MODE_AIRCRAFT_BALLOON_EVOL,      ONLY: AIRCRAFT_BALLOON_EVOL

IMPLICIT NONE
!
!*      0.1  declarations of arguments
!
!
REAL,                     INTENT(IN)     :: PTSTEP ! time step
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PZ     ! z array
REAL, DIMENSION(:,:),     INTENT(IN)     :: PMAP   ! map factor
REAL,                     INTENT(IN)     :: PLONOR ! origine longitude
REAL,                     INTENT(IN)     :: PLATOR ! origine latitude
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PU     ! horizontal wind X component
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PV     ! horizontal wind Y component
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PW     ! vertical wind
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PP     ! pressure
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PTH    ! potential temperature
REAL, DIMENSION(:,:,:,:), INTENT(IN)     :: PR     ! water mixing ratios
REAL, DIMENSION(:,:,:,:), INTENT(IN)     :: PSV    ! Scalar variables
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PTKE   ! turbulent kinetic energy
REAL, DIMENSION(:,:),     INTENT(IN)     :: PTS    ! surface temperature
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PRHODREF ! dry air density of the reference state
REAL, DIMENSION(:,:,:),   INTENT(IN)     :: PCIT     ! pristine ice concentration
REAL, DIMENSION(:,:), OPTIONAL, INTENT(IN) :: PSEA
!
!-------------------------------------------------------------------------------
!
!       0.2  declaration of local variables
!
INTEGER                      :: JI
LOGICAL, SAVE                :: GFIRSTCALL = .TRUE.
!----------------------------------------------------------------------------

CALL PRINT_MSG( NVERB_DEBUG, 'GEN', 'AIRCRAFT_BALLOON', 'called' )

IF(.NOT. ALLOCATED(XTHW_FLUX)) ALLOCATE(XTHW_FLUX(SIZE(PTH,1),SIZE(PTH,2),SIZE(PTH,3)))
IF(.NOT. ALLOCATED(XRCW_FLUX)) ALLOCATE(XRCW_FLUX(SIZE(PTH,1),SIZE(PTH,2),SIZE(PTH,3)))
IF(.NOT. ALLOCATED(XSVW_FLUX)) ALLOCATE(XSVW_FLUX(SIZE(PSV,1),SIZE(PSV,2),SIZE(PSV,3),SIZE(PSV,4)))

IF ( NBALLOONS > 0 ) THEN
  IF ( GFIRSTCALL ) CALL BALLOONS_INIT_POSITIONS()
  NRANKCUR_BALLOON(:) = NRANKNXT_BALLOON(:)
  NRANKNXT_BALLOON(:) = 0

  DO JI = 1, NBALLOONS
    IF ( ASSOCIATED( TBALLOONS(JI)%TBALLOON ) ) THEN
      CALL AIRCRAFT_BALLOON_EVOL( PTSTEP, PZ, PMAP, PLONOR, PLATOR,                                   &
                                  PU, PV, PW, PP, PTH, PR, PSV, PTKE, PTS, PRHODREF, PCIT,            &
                                  TBALLOONS(JI)%TBALLOON, NRANKCUR_BALLOON(JI), NRANKNXT_BALLOON(JI), &
                                  PSEA )
    END IF
  END DO

  CALL BALLOONS_MOVE_TO_NEW_RANKS()

END IF
!
IF ( NAIRCRAFTS > 0 ) THEN
  IF ( GFIRSTCALL ) CALL AIRCRAFTS_INIT_POSITIONS()
  NRANKCUR_AIRCRAFT(:) = NRANKNXT_AIRCRAFT(:)
  NRANKNXT_AIRCRAFT(:) = 0

  DO JI = 1, NAIRCRAFTS
    IF ( ASSOCIATED( TAIRCRAFTS(JI)%TAIRCRAFT ) ) THEN
      CALL AIRCRAFT_BALLOON_EVOL( PTSTEP, PZ, PMAP, PLONOR, PLATOR,                                       &
                                  PU, PV, PW, PP, PTH, PR, PSV, PTKE, PTS, PRHODREF, PCIT,                &
                                  TAIRCRAFTS(JI)%TAIRCRAFT, NRANKCUR_AIRCRAFT(JI), NRANKNXT_AIRCRAFT(JI), &
                                  PSEA )
    END IF
  END DO

  CALL AIRCRAFTS_MOVE_TO_NEW_RANKS()
END IF

GFIRSTCALL = .FALSE.

CONTAINS

!----------------------------------------------------------------------------
SUBROUTINE AIRCRAFTS_INIT_POSITIONS()

USE MODD_DYN_n,                      ONLY: DYN_MODEL
USE MODD_IO,                         ONLY: ISP
USE MODD_TIME_n,                     ONLY: TDTCUR

USE MODE_AIRCRAFT_BALLOON_EVOL,      ONLY: AIRCRAFT_COMPUTE_POSITION, FLYER_GET_RANK_MODEL_ISCRASHED
USE MODE_DATETIME

INTEGER                      :: IMODEL
REAL                         :: ZDELTATIME
TYPE(DATE_TIME)              :: TZDATE
TYPE(TAIRCRAFTDATA), POINTER :: TZAIRCRAFT

! Set next rank to 0 (necessary for MPI_ALLREDUCE)
NRANKNXT_AIRCRAFT(:) = 0

IF ( ISP == NFLYER_DEFAULT_RANK ) THEN
  DO JI = 1, NAIRCRAFTS
    IF ( .NOT. ASSOCIATED( TAIRCRAFTS(JI)%TAIRCRAFT ) ) &
      CALL PRINT_MSG( NVERB_FATAL, 'GEN', 'AIRCRAFT_BALLOON', 'aircraft structure not associated' )

    ! Compute position at take-off (or at first timestep in flight)
    TZAIRCRAFT => TAIRCRAFTS(JI)%TAIRCRAFT

    ! Determine moment of the first positioning
    ! This is done at first call of this subroutine and therefore not necessarily on the correct model
    IF ( TDTCUR < TZAIRCRAFT%TLAUNCH ) THEN
      ! Moment is the first timestep since launch date
      ZDELTATIME = TZAIRCRAFT%TLAUNCH - TDTCUR + 1.E-8
      IF ( TZAIRCRAFT%CMODEL == 'FIX' ) THEN
        IMODEL = TZAIRCRAFT%NMODEL
      ELSE ! 'MOB'
        IMODEL = 1
      END IF
      TZDATE = TDTCUR + INT( ZDELTATIME / DYN_MODEL(IMODEL)%XTSTEP ) * DYN_MODEL(IMODEL)%XTSTEP
    ELSE IF ( TDTCUR > TZAIRCRAFT%TLAND ) THEN
      ! Nothing to do
      ! Aircraft will never be in flight in this run. Data will remain on the initial process.
    ELSE
      ! Aircraft is already in flight at the beginning of the run
      TZDATE = TDTCUR
    END IF

    CALL AIRCRAFT_COMPUTE_POSITION( TZDATE, TZAIRCRAFT )

    ! Get rank of the process where the aircraft is at this moment and the model number
    CALL FLYER_GET_RANK_MODEL_ISCRASHED( TZAIRCRAFT )

    NRANKNXT_AIRCRAFT(JI) = TZAIRCRAFT%NRANK_CUR
  END DO
END IF

CALL AIRCRAFTS_MOVE_TO_NEW_RANKS()

END SUBROUTINE AIRCRAFTS_INIT_POSITIONS
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE AIRCRAFTS_MOVE_TO_NEW_RANKS()

USE MODD_IO,                         ONLY: ISP
USE MODD_MPIF
USE MODD_PRECISION,                  ONLY: MNHINT_MPI
USE MODD_VAR_ll,                     ONLY: NMNH_COMM_WORLD

INTEGER :: IERR
INTEGER, DIMENSION(:), ALLOCATABLE :: IRANKNXT_AIRCRAFT_TMP

#if 0
CALL MPI_ALLREDUCE( MPI_IN_PLACE, NRANKNXT_AIRCRAFT, NAIRCRAFTS, MNHINT_MPI, MPI_MAX, NMNH_COMM_WORLD, IERR )
#else
!Do this to not use MPI_IN_PLACE (not yet implemented in MPIVIDE)
ALLOCATE( IRANKNXT_AIRCRAFT_TMP, MOLD = NRANKNXT_AIRCRAFT )
CALL MPI_ALLREDUCE( NRANKNXT_AIRCRAFT, IRANKNXT_AIRCRAFT_TMP, NAIRCRAFTS, MNHINT_MPI, MPI_MAX, NMNH_COMM_WORLD, IERR )
NRANKNXT_AIRCRAFT = IRANKNXT_AIRCRAFT_TMP
DEALLOCATE( IRANKNXT_AIRCRAFT_TMP )
#endif

DO JI = 1, NAIRCRAFTS
  IF ( NRANKNXT_AIRCRAFT(JI) /= NRANKCUR_AIRCRAFT(JI) ) THEN
    IF ( ISP == NRANKCUR_AIRCRAFT(JI) ) THEN
      CALL FLYER_SEND_AND_DEALLOCATE( TAIRCRAFTS(JI)%TAIRCRAFT, NRANKNXT_AIRCRAFT(JI) )
      DEALLOCATE( TAIRCRAFTS(JI)%TAIRCRAFT )
    ELSE IF ( ISP == NRANKNXT_AIRCRAFT(JI) ) THEN
      IF ( ASSOCIATED( TAIRCRAFTS(JI)%TAIRCRAFT ) ) &
        call Print_msg( NVERB_FATAL, 'GEN', 'AIRCRAFT_BALLOON', 'aircraft already associated' )
      ALLOCATE( TAIRCRAFTS(JI)%TAIRCRAFT )
      CALL FLYER_RECV_AND_ALLOCATE( TAIRCRAFTS(JI)%TAIRCRAFT, NRANKCUR_AIRCRAFT(JI) )
    END IF
  END IF
END DO

END SUBROUTINE AIRCRAFTS_MOVE_TO_NEW_RANKS
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE BALLOONS_INIT_POSITIONS()

USE MODD_IO,                         ONLY: ISP

USE MODE_AIRCRAFT_BALLOON_EVOL,      ONLY: FLYER_GET_RANK_MODEL_ISCRASHED

TYPE(TBALLOONDATA),  POINTER :: TZBALLOON

! Set next rank to 0 (necessary for MPI_ALLREDUCE)
NRANKNXT_BALLOON(:) = 0

IF ( ISP == NFLYER_DEFAULT_RANK ) THEN
  DO JI = 1, NBALLOONS
    IF ( .NOT. ASSOCIATED( TBALLOONS(JI)%TBALLOON ) ) &
      CALL PRINT_MSG( NVERB_FATAL, 'GEN', 'AIRCRAFT_BALLOON', 'balloon structure not associated' )

    TZBALLOON => TBALLOONS(JI)%TBALLOON

    ! Initialize model number (and rank)
    ! This is not done in initialisation phase because some data is not yet available at this early stage
    ! (XXHAT_ll of all models are needed by FIND_PROCESS_AND_MODEL_FROM_XY_POS)
    IF ( .NOT. TZBALLOON%LPOSITION_INIT ) THEN
      TZBALLOON%LPOSITION_INIT = .TRUE.
      ! Get rank of the process where the balloon is and the model number
      IF ( TZBALLOON%LFLY ) THEN
        ! In this case, we are in a restart and the balloon position was read in the restart file
        CALL FLYER_GET_RANK_MODEL_ISCRASHED( TZBALLOON )
      ELSE
        CALL FLYER_GET_RANK_MODEL_ISCRASHED( TZBALLOON, PX = TZBALLOON%XXLAUNCH, PY = TZBALLOON%XYLAUNCH )
      END IF
      IF ( TZBALLOON%LCRASH ) THEN
        CALL PRINT_MSG( NVERB_WARNING, 'GEN', 'AIRCRAFT_BALLOON', 'balloon ' // TRIM( TZBALLOON%CNAME ) &
                        // ': launch coordinates are outside of horizontal physical domain' )
      END IF
    ELSE
      CALL PRINT_MSG( NVERB_ERROR, 'GEN', 'AIRCRAFT_BALLOON', 'balloon ' // TRIM( TZBALLOON%CNAME ) &
                      // ': position has already been initialized' )
    END IF

    NRANKNXT_BALLOON(JI) = TZBALLOON%NRANK_CUR
  END DO
END IF

CALL BALLOONS_MOVE_TO_NEW_RANKS()

END SUBROUTINE BALLOONS_INIT_POSITIONS
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE BALLOONS_MOVE_TO_NEW_RANKS()

USE MODD_IO,                         ONLY: ISP
USE MODD_MPIF
USE MODD_PRECISION,                  ONLY: MNHINT_MPI
USE MODD_VAR_ll,                     ONLY: NMNH_COMM_WORLD

INTEGER :: IERR
INTEGER, DIMENSION(:), ALLOCATABLE :: IRANKNXT_BALLOON_TMP

#if 0
CALL MPI_ALLREDUCE( MPI_IN_PLACE, NRANKNXT_BALLOON, NBALLOONS, MNHINT_MPI, MPI_MAX, NMNH_COMM_WORLD, IERR )
#else
!Do this to not use MPI_IN_PLACE (not yet implemented in MPIVIDE)
ALLOCATE( IRANKNXT_BALLOON_TMP, MOLD = NRANKNXT_BALLOON )
CALL MPI_ALLREDUCE( NRANKNXT_BALLOON, IRANKNXT_BALLOON_TMP, NBALLOONS, MNHINT_MPI, MPI_MAX, NMNH_COMM_WORLD, IERR )
NRANKNXT_BALLOON = IRANKNXT_BALLOON_TMP
DEALLOCATE( IRANKNXT_BALLOON_TMP )
#endif

DO JI = 1, NBALLOONS
  IF ( NRANKNXT_BALLOON(JI) /= NRANKCUR_BALLOON(JI) ) THEN
    IF ( ISP == NRANKCUR_BALLOON(JI) ) THEN
      CALL FLYER_SEND_AND_DEALLOCATE( TBALLOONS(JI)%TBALLOON, NRANKNXT_BALLOON(JI) )
      DEALLOCATE( TBALLOONS(JI)%TBALLOON )
    ELSE IF ( ISP == NRANKNXT_BALLOON(JI) ) THEN
      ALLOCATE( TBALLOONS(JI)%TBALLOON )
      CALL FLYER_RECV_AND_ALLOCATE( TBALLOONS(JI)%TBALLOON, NRANKCUR_BALLOON(JI) )
    END IF
  END IF
END DO

END SUBROUTINE BALLOONS_MOVE_TO_NEW_RANKS
!----------------------------------------------------------------------------
END SUBROUTINE AIRCRAFT_BALLOON
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE AIRCRAFT_BALLOON_LONGTYPE_GET( TPFLYER, HLONGTYPE )
USE MODD_AIRCRAFT_BALLOON, ONLY: taircraftdata, tballoondata, TFLYERDATA

IMPLICIT NONE

CLASS(TFLYERDATA), INTENT(IN)  :: TPFLYER
CHARACTER(LEN=*),  INTENT(OUT) :: HLONGTYPE

character(len=:), allocatable :: ytype

select type ( tpflyer )
  class is ( taircraftdata )
    ytype = 'Aircrafts'

  class is ( tballoondata )
    if ( Trim( TPFLYER%CTYPE ) == 'RADIOS' ) then
      ytype = 'Radiosonde_balloons'
    else if ( Trim( TPFLYER%CTYPE ) == 'ISODEN' ) then
      ytype = 'Isodensity_balloons'
    else if ( Trim( TPFLYER%CTYPE ) == 'CVBALL' ) then
      ytype = 'Constant_volume_balloons'
    else
      call Print_msg( NVERB_ERROR, 'GEN', 'AIRCRAFT_BALLOON_LONGTYPE_GET', 'unknown category for flyer ' // Trim( tpflyer%cname ) )
      ytype = 'Unknown'
    end if

  class default
    call Print_msg( NVERB_ERROR, 'GEN', 'AIRCRAFT_BALLOON_LONGTYPE_GET', 'unknown class for flyer ' // Trim( tpflyer%cname ) )
    ytype = 'Unknown'

end select

if ( Len_trim( ytype ) > Len( HLONGTYPE ) ) &
  call Print_msg( NVERB_WARNING, 'GEN', 'AIRCRAFT_BALLOON_LONGTYPE_GET', &
                  'HLONGTYPE truncated for flyer ' // Trim( tpflyer%cname ) )
HLONGTYPE = Trim( ytype )

END SUBROUTINE AIRCRAFT_BALLOON_LONGTYPE_GET
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------

SUBROUTINE FLYER_SEND( TPFLYER, KTO )

USE MODD_AIRCRAFT_BALLOON, ONLY: TAIRCRAFTDATA, TBALLOONDATA, TFLYERDATA
USE MODD_CONF_n,           ONLY: NRR
USE MODD_DIM_n,            ONLY: NKMAX
USE MODD_IO,               ONLY: ISP
USE MODD_MPIF
USE MODD_NSV,              ONLY: NSV
USE MODD_PARAMETERS,       ONLY: JPVEXT
USE MODD_PARAM_n,          ONLY: CCLOUD
USE MODD_PRECISION,        ONLY: MNHINT_MPI, MNHREAL_MPI
USE MODD_VAR_LL,           ONLY: NMNH_COMM_WORLD

USE MODE_DATETIME

IMPLICIT NONE

CLASS(TFLYERDATA), INTENT(INOUT) :: TPFLYER
INTEGER,           INTENT(IN)    :: KTO     ! Process to which to send flyer data

CHARACTER(LEN=10) :: YFROM, YTO
INTEGER :: IERR
INTEGER :: IKU       ! number of vertical levels
INTEGER :: IPACKSIZE ! Size of the ZPACK buffer
INTEGER :: IPOS      ! Position in the ZPACK buffer
INTEGER :: IPOSAIR
INTEGER :: ISTORE_CUR
INTEGER :: JI
INTEGER, DIMENSION(3)              :: ISTORES
REAL,    DIMENSION(:), ALLOCATABLE :: ZPACK        ! Buffer to store raw data of a profiler (used for MPI communication)

WRITE( YFROM, '( I10 )' ) ISP
WRITE( YTO,   '( I10 )' ) KTO
CALL PRINT_MSG( NVERB_DEBUG, 'GEN', 'FLYER_SEND', 'send flyer '//TRIM(TPFLYER%CNAME)//': '//TRIM(YFROM)//'->'//TRIM(YTO), &
                OLOCAL = .TRUE. )

IKU = NKMAX + 2 * JPVEXT

ISTORE_CUR = TPFLYER%TFLYER_TIME%N_CUR

! Prepare data to send

! Determine size of data to send
! Characters, integers and logicals will be converted to reals. CMODEL and CTYPE will be coded by 1 real
IPACKSIZE = 15 + LEN(TPFLYER%CNAME) + ISTORE_CUR * ( 18 + NRR + NSV * 2 + IKU * ( 9 + NRR ) )
IF (  CCLOUD == 'LIMA' ) IPACKSIZE = IPACKSIZE + ISTORE_CUR * IKU * 2

SELECT TYPE ( TPFLYER )
  CLASS IS ( TAIRCRAFTDATA )
    IPACKSIZE = IPACKSIZE + 6 + TPFLYER%NPOS * 6

  CLASS IS ( TBALLOONDATA )
    IPACKSIZE = IPACKSIZE + 15
END SELECT

! Communication is in 2 phases:
! 1) first send the ISTORE dimension (optimisation: only what has already been written = N_CUR)
! 2) send data
ISTORES(1) = ISTORE_CUR                 ! Number of currently used store positions
ISTORES(2) = SIZE( TPFLYER%NMODELHIST ) ! Total number of store positions
ISTORES(3) = IPACKSIZE
CALL MPI_SEND( ISTORES, 3, MNHINT_MPI, KTO-1, NTAG_NCUR, NMNH_COMM_WORLD, IERR )

ALLOCATE( ZPACK(IPACKSIZE) )

! Fill buffer / pack data
IPOS = 1
IF ( TPFLYER%CMODEL == 'FIX' ) THEN
  ZPACK(IPOS) = NMODEL_FIX
ELSE
  ZPACK(IPOS) = NMODEL_MOB
END IF
IPOS = IPOS + 1

ZPACK(IPOS) = TPFLYER%NMODEL; IPOS = IPOS + 1
ZPACK(IPOS) = TPFLYER%NID;    IPOS = IPOS + 1

SELECT CASE( TPFLYER%CTYPE )
  CASE( 'AIRCRA' )
    ZPACK(IPOS) = NTYPE_AIRCRA
  CASE( 'CVBALL' )
    ZPACK(IPOS) = NTYPE_CVBALL
  CASE( 'ISODEN' )
    ZPACK(IPOS) = NTYPE_ISODEN
  CASE( 'RADIOS' )
    ZPACK(IPOS) = NTYPE_RADIOS
  CASE DEFAULT
    CALL PRINT_MSG( NVERB_FATAL, 'FLYER_SEND', 'invalid CTYPE for flyer' )
END SELECT
IPOS = IPOS + 1

! Convert title characters to integers
DO JI = 1, LEN(TPFLYER%CNAME)
  ZPACK(IPOS) = ICHAR( TPFLYER%CNAME(JI:JI) )
  IPOS = IPOS + 1
END DO

ZPACK(IPOS) = TPFLYER%TLAUNCH - TPREFERENCE_DATE; IPOS = IPOS + 1
IF ( TPFLYER%LCRASH ) THEN
  ZPACK(IPOS) = 1.d0
ELSE
  ZPACK(IPOS) = 0.d0
END IF
IPOS = IPOS + 1

ZPACK(IPOS) = TPFLYER%NCRASH; IPOS = IPOS + 1

IF ( TPFLYER%LFLY ) THEN
  ZPACK(IPOS) = 1.d0
ELSE
  ZPACK(IPOS) = 0.d0
END IF
IPOS = IPOS + 1

IF ( TPFLYER%LSTORE ) THEN
  ZPACK(IPOS) = 1.d0
ELSE
  ZPACK(IPOS) = 0.d0
END IF
IPOS = IPOS + 1

ZPACK(IPOS) = TPFLYER%TFLYER_TIME%N_CUR;  IPOS = IPOS + 1
ZPACK(IPOS) = TPFLYER%TFLYER_TIME%XTSTEP; IPOS = IPOS + 1
DO JI = 1, ISTORE_CUR
  ZPACK(IPOS) = TPFLYER%TFLYER_TIME%TPDATES(JI) - TPREFERENCE_DATE; IPOS = IPOS + 1
END DO

ZPACK(IPOS) = TPFLYER%XX_CUR; IPOS = IPOS + 1
ZPACK(IPOS) = TPFLYER%XY_CUR; IPOS = IPOS + 1
ZPACK(IPOS) = TPFLYER%XZ_CUR; IPOS = IPOS + 1

ZPACK(IPOS) = TPFLYER%NRANK_CUR; IPOS = IPOS + 1

ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%NMODELHIST(1:ISTORE_CUR); IPOS = IPOS + ISTORE_CUR

ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XX(1:ISTORE_CUR)        ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XY(1:ISTORE_CUR)        ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XZ(1:ISTORE_CUR)        ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XLAT(1:ISTORE_CUR)      ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XLON(1:ISTORE_CUR)      ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XZON(1,1:ISTORE_CUR)    ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XMER(1,1:ISTORE_CUR)    ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XW(1,1:ISTORE_CUR)      ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XP(1,1:ISTORE_CUR)      ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XTKE(1,1:ISTORE_CUR)    ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XTKE_DISS(1:ISTORE_CUR) ; IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XTH(1,1:ISTORE_CUR)     ; IPOS = IPOS + ISTORE_CUR

ZPACK(IPOS:IPOS+ISTORE_CUR*NRR-1) = RESHAPE( TPFLYER%XR  (1,1:ISTORE_CUR,1:NRR), [ISTORE_CUR*NRR] ) ; IPOS = IPOS + ISTORE_CUR * NRR
ZPACK(IPOS:IPOS+ISTORE_CUR*NSV-1) = RESHAPE( TPFLYER%XSV (1,1:ISTORE_CUR,1:NSV), [ISTORE_CUR*NSV] ) ; IPOS = IPOS + ISTORE_CUR * NSV
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XRTZ(  1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ) ; IPOS = IPOS + ISTORE_CUR * IKU

ZPACK(IPOS:IPOS+ISTORE_CUR*IKU*NRR-1) = RESHAPE( TPFLYER%XRZ(1:IKU,1:ISTORE_CUR,1:NRR), [ISTORE_CUR*IKU*NRR] )
IPOS = IPOS + ISTORE_CUR * IKU * NRR

ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XFFZ (1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ); IPOS = IPOS + ISTORE_CUR * IKU
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XIWCZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ); IPOS = IPOS + ISTORE_CUR * IKU
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XLWCZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ); IPOS = IPOS + ISTORE_CUR * IKU
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XCIZ (1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ); IPOS = IPOS + ISTORE_CUR * IKU
IF ( CCLOUD == 'LIMA' ) THEN
  ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XCCZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] );IPOS = IPOS + ISTORE_CUR * IKU
  ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XCRZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] );IPOS = IPOS + ISTORE_CUR * IKU
END IF
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XCRARE(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] );IPOS = IPOS + ISTORE_CUR * IKU

ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XCRARE_ATT(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] )
IPOS = IPOS + ISTORE_CUR * IKU

ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XWZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ) ; IPOS = IPOS + ISTORE_CUR * IKU
ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1) = RESHAPE( TPFLYER%XZZ(1:IKU,1:ISTORE_CUR), [ISTORE_CUR*IKU] ) ; IPOS = IPOS + ISTORE_CUR * IKU

ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XZS(1:ISTORE_CUR); IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XTSRAD(1,1:ISTORE_CUR); IPOS = IPOS + ISTORE_CUR

ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XTHW_FLUX(1:ISTORE_CUR); IPOS = IPOS + ISTORE_CUR
ZPACK(IPOS:IPOS+ISTORE_CUR-1) = TPFLYER%XRCW_FLUX(1:ISTORE_CUR); IPOS = IPOS + ISTORE_CUR

ZPACK(IPOS:IPOS+ISTORE_CUR*NSV-1) = RESHAPE( TPFLYER%XSVW_FLUX(1:ISTORE_CUR,1:NSV), [ISTORE_CUR*NSV] )
IPOS = IPOS + ISTORE_CUR * NSV

SELECT TYPE ( TPFLYER )
  CLASS IS ( TAIRCRAFTDATA )
    IF ( TPFLYER%LTOOKOFF ) THEN
      ZPACK(IPOS) = 1.d0
    ELSE
      ZPACK(IPOS) = 0.d0
    END IF
    IPOS = IPOS + 1

    IF ( TPFLYER%LALTDEF ) THEN
      ZPACK(IPOS) = 1.d0
    ELSE
      ZPACK(IPOS) = 0.d0
    END IF
    IPOS = IPOS + 1

    ZPACK(IPOS) = TPFLYER%NPOS;    IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%NPOSCUR; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XP_CUR; IPOS = IPOS + 1

    IPOSAIR = TPFLYER%NPOS

    ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSLAT(1:IPOSAIR)  ; IPOS = IPOS + IPOSAIR
    ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSLON(1:IPOSAIR)  ; IPOS = IPOS + IPOSAIR
    ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSX(1:IPOSAIR)    ; IPOS = IPOS + IPOSAIR
    ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSY(1:IPOSAIR)    ; IPOS = IPOS + IPOSAIR
    IF ( TPFLYER%LALTDEF ) THEN
      ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSP(1:IPOSAIR)  ; IPOS = IPOS + IPOSAIR
    ELSE
      ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSZ(1:IPOSAIR)  ; IPOS = IPOS + IPOSAIR
    ENDIF
    ZPACK(IPOS:IPOS+IPOSAIR-1) = TPFLYER%XPOSTIME(1:IPOSAIR) ; IPOS = IPOS + IPOSAIR

    ZPACK(IPOS) = TPFLYER%TLAND - TPREFERENCE_DATE; IPOS = IPOS + 1

  CLASS IS ( TBALLOONDATA )
    IF ( TPFLYER%LPOSITION_INIT ) THEN
      ZPACK(IPOS) = 1.d0
    ELSE
      ZPACK(IPOS) = 0.d0
    END IF
    IPOS = IPOS + 1

    ZPACK(IPOS) = TPFLYER%XLATLAUNCH ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XLONLAUNCH ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XXLAUNCH   ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XYLAUNCH   ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XALTLAUNCH ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XWASCENT   ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XRHO       ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XPRES      ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XDIAMETER  ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XAERODRAG  ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XINDDRAG   ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XVOLUME    ; IPOS = IPOS + 1
    ZPACK(IPOS) = TPFLYER%XMASS      ; IPOS = IPOS + 1

    ZPACK(IPOS) = TPFLYER%TPOS_CUR - TPREFERENCE_DATE; IPOS = IPOS + 1

END SELECT

IF ( IPOS-1 /= IPACKSIZE ) &
  call Print_msg( NVERB_WARNING, 'IO', 'FLYER_SEND', 'IPOS-1 /= IPACKSIZE (sender side)', OLOCAL = .TRUE. )

! Send packed data
CALL MPI_SEND( ZPACK, IPACKSIZE, MNHREAL_MPI, KTO-1, NTAG_PACK, NMNH_COMM_WORLD, IERR )

END SUBROUTINE FLYER_SEND
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE FLYER_SEND_AND_DEALLOCATE( TPFLYER, KTO )

USE MODD_AIRCRAFT_BALLOON,     ONLY: TFLYERDATA
USE MODD_IO,               ONLY: ISP

IMPLICIT NONE

CLASS(TFLYERDATA), INTENT(INOUT) :: TPFLYER
INTEGER,           INTENT(IN)    :: KTO     ! Process to which to send flyer data

CHARACTER(LEN=10) :: YFROM, YTO

WRITE( YFROM, '( I10 )' ) ISP
WRITE( YTO,   '( I10 )' ) KTO
CALL PRINT_MSG( NVERB_DEBUG, 'GEN', 'FLYER_SEND_AND_DEALLOCATE', &
                'send flyer '//TRIM(TPFLYER%CNAME)//': '//TRIM(YFROM)//'->'//TRIM(YTO), OLOCAL = .TRUE. )

CALL FLYER_SEND( TPFLYER, KTO )

! Free flyer data (dynamically allocated), scalar data has to be freed outside this subroutine
CALL TPFLYER%DATA_ARRAYS_DEALLOCATE()

END SUBROUTINE FLYER_SEND_AND_DEALLOCATE
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------
SUBROUTINE FLYER_RECV_AND_ALLOCATE( TPFLYER, KFROM )

USE MODD_AIRCRAFT_BALLOON, ONLY: TAIRCRAFTDATA, TBALLOONDATA, TFLYERDATA
USE MODD_CONF_n,           ONLY: NRR
USE MODD_DIM_n,            ONLY: NKMAX
USE MODD_IO,               ONLY: ISP
USE MODD_MPIF
USE MODD_NSV,              ONLY: NSV
USE MODD_PARAMETERS,       ONLY: JPVEXT
USE MODD_PARAM_n,          ONLY: CCLOUD
USE MODD_PRECISION,        ONLY: MNHINT_MPI, MNHREAL_MPI
USE MODD_VAR_LL,           ONLY: NMNH_COMM_WORLD

USE MODE_DATETIME

IMPLICIT NONE

CLASS(TFLYERDATA), INTENT(INOUT) :: TPFLYER
INTEGER,           INTENT(IN)    :: KFROM   ! Process from which to receive flyer data

CHARACTER(LEN=10) :: YFROM, YTO
INTEGER :: IERR
INTEGER :: IKU       ! number of vertical levels
INTEGER :: IPOSAIR
INTEGER :: ISTORE_CUR
INTEGER :: ISTORE_TOT
INTEGER :: IPACKSIZE ! Size of the ZPACK buffer
INTEGER :: IPOS      ! Position in the ZPACK buffer
INTEGER :: JI
INTEGER, DIMENSION(3)              :: ISTORES
REAL,    DIMENSION(:), ALLOCATABLE :: ZPACK        ! Buffer to store raw data of a profiler (used for MPI communication)

WRITE( YFROM, '( I10 )' ) KFROM
WRITE( YTO,   '( I10 )' ) ISP
! CALL PRINT_MSG( NVERB_DEBUG, 'GEN', 'FLYER_RECV_AND_ALLOCATE', &
!                 'receive flyer (name not yet known): '//TRIM(YFROM)//'->'//TRIM(YTO), OLOCAL = .TRUE. )

IKU = NKMAX + 2 * JPVEXT

! Receive data (useful dimensions)
CALL MPI_RECV( ISTORES, 3, MNHINT_MPI, KFROM-1, NTAG_NCUR, NMNH_COMM_WORLD, MPI_STATUS_IGNORE, IERR )

ISTORE_CUR = ISTORES(1)
ISTORE_TOT = ISTORES(2)
IPACKSIZE  = ISTORES(3)

! Allocate receive buffer
ALLOCATE( ZPACK(IPACKSIZE) )

! Receive packed data
CALL MPI_RECV( ZPACK, IPACKSIZE, MNHREAL_MPI, KFROM-1, NTAG_PACK, NMNH_COMM_WORLD, MPI_STATUS_IGNORE, IERR )

! Allocation of flyer must be done only once number of stores is known
CALL TPFLYER%DATA_ARRAYS_ALLOCATE( ISTORE_TOT )

! Unpack data
IPOS = 1

IF ( NINT( ZPACK(IPOS) ) == NMODEL_FIX ) THEN
  TPFLYER%CMODEL = 'FIX'
ELSE
  TPFLYER%CMODEL = 'MOB'
END IF
IPOS = IPOS + 1

TPFLYER%NMODEL = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1
TPFLYER%NID    = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1

SELECT CASE( NINT( ZPACK(IPOS) ) )
  CASE(NTYPE_AIRCRA )
    TPFLYER%CTYPE = 'AIRCRA'
  CASE( NTYPE_CVBALL )
    TPFLYER%CTYPE = 'CVBALL'
  CASE( NTYPE_ISODEN )
    TPFLYER%CTYPE = 'ISODEN'
  CASE( NTYPE_RADIOS )
    TPFLYER%CTYPE = 'RADIOS'
  CASE DEFAULT
    CALL PRINT_MSG( NVERB_FATAL, 'FLYER_RECV_AND_ALLOCATE', 'invalid CTYPE for flyer' )
END SELECT
IPOS = IPOS + 1

! Convert integers to characters for title
DO JI = 1, LEN(TPFLYER%CNAME)
  TPFLYER%CNAME(JI:JI) = ACHAR( NINT( ZPACK(IPOS) ) )
  IPOS = IPOS + 1
END DO

! Print full message only now (flyer title was not yet known)
CALL PRINT_MSG( NVERB_DEBUG, 'GEN', 'FLYER_RECV_AND_ALLOCATE', &
                'receive flyer '//TRIM(TPFLYER%CNAME)//': '//TRIM(YFROM)//'->'//TRIM(YTO), OLOCAL = .TRUE. )

TPFLYER%TLAUNCH = TPREFERENCE_DATE + ZPACK(IPOS); IPOS = IPOS + 1

IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
  TPFLYER%LCRASH = .FALSE.
ELSE
  TPFLYER%LCRASH = .TRUE.
END IF
IPOS = IPOS + 1

TPFLYER%NCRASH = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1

IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
  TPFLYER%LFLY = .FALSE.
ELSE
  TPFLYER%LFLY = .TRUE.
END IF
IPOS = IPOS + 1

IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
  TPFLYER%LSTORE = .FALSE.
ELSE
  TPFLYER%LSTORE = .TRUE.
END IF
IPOS = IPOS + 1

TPFLYER%TFLYER_TIME%N_CUR = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1
TPFLYER%TFLYER_TIME%XTSTEP = ZPACK(IPOS); IPOS = IPOS + 1

DO JI = 1, ISTORE_CUR
  TPFLYER%TFLYER_TIME%TPDATES(JI) = TPREFERENCE_DATE + ZPACK(IPOS); IPOS = IPOS + 1
END DO

TPFLYER%XX_CUR = ZPACK(IPOS); IPOS = IPOS + 1
TPFLYER%XY_CUR = ZPACK(IPOS); IPOS = IPOS + 1
TPFLYER%XZ_CUR = ZPACK(IPOS); IPOS = IPOS + 1

TPFLYER%NRANK_CUR = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1

TPFLYER%NMODELHIST(1:ISTORE_CUR) = NINT( ZPACK(IPOS:IPOS+ISTORE_CUR-1) ) ; IPOS = IPOS + ISTORE_CUR

TPFLYER%XX(1:ISTORE_CUR)        = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XY(1:ISTORE_CUR)        = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XZ(1:ISTORE_CUR)        = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XLAT(1:ISTORE_CUR)      = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XLON(1:ISTORE_CUR)      = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XZON(1,1:ISTORE_CUR)    = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XMER(1,1:ISTORE_CUR)    = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XW(1,1:ISTORE_CUR)      = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XP(1,1:ISTORE_CUR)      = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XTKE(1,1:ISTORE_CUR)    = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XTKE_DISS(1:ISTORE_CUR) = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XTH(1,1:ISTORE_CUR)     = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR

TPFLYER%XR  (1,1:ISTORE_CUR,1:NRR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*NRR-1), [ISTORE_CUR,NRR] ) ; IPOS = IPOS + ISTORE_CUR * NRR
TPFLYER%XSV (1,1:ISTORE_CUR,1:NSV) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*NSV-1), [ISTORE_CUR,NSV] ) ; IPOS = IPOS + ISTORE_CUR * NSV
TPFLYER%XRTZ(1:IKU,1:ISTORE_CUR)   = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ; IPOS = IPOS + ISTORE_CUR * IKU

TPFLYER%XRZ(1:IKU,1:ISTORE_CUR,1:NRR) = RESHAPE( ZPACK(IPOS:IPOS+(ISTORE_CUR*IKU*NRR)-1), [IKU,ISTORE_CUR,NRR] )
IPOS = IPOS + ISTORE_CUR * IKU * NRR

TPFLYER%XFFZ (1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU
TPFLYER%XIWCZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU
TPFLYER%XLWCZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU
TPFLYER%XCIZ (1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU
IF ( CCLOUD == 'LIMA' ) THEN
  TPFLYER%XCCZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] );  IPOS = IPOS + ISTORE_CUR * IKU
  TPFLYER%XCRZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] );  IPOS = IPOS + ISTORE_CUR * IKU
END IF
TPFLYER%XCRARE(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] );  IPOS = IPOS + ISTORE_CUR * IKU

TPFLYER%XCRARE_ATT(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] )
IPOS = IPOS + ISTORE_CUR * IKU

TPFLYER%XWZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU
TPFLYER%XZZ(1:IKU,1:ISTORE_CUR) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*IKU-1), [IKU,ISTORE_CUR] ) ;  IPOS = IPOS + ISTORE_CUR * IKU

TPFLYER%XZS   (  1:ISTORE_CUR) = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XTSRAD(1,1:ISTORE_CUR) = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR

TPFLYER%XTHW_FLUX(1:ISTORE_CUR) = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR
TPFLYER%XRCW_FLUX(1:ISTORE_CUR) = ZPACK(IPOS:IPOS+ISTORE_CUR-1) ; IPOS = IPOS + ISTORE_CUR

TPFLYER%XSVW_FLUX(1:ISTORE_CUR,1:NSV) = RESHAPE( ZPACK(IPOS:IPOS+ISTORE_CUR*NSV-1), [ISTORE_CUR,NSV] )
IPOS = IPOS + ISTORE_CUR * NSV

SELECT TYPE ( TPFLYER )
  CLASS IS ( TAIRCRAFTDATA )
    IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
      TPFLYER%LTOOKOFF = .FALSE.
    ELSE
      TPFLYER%LTOOKOFF = .TRUE.
    END IF
    IPOS = IPOS + 1

    IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
      TPFLYER%LALTDEF = .FALSE.
    ELSE
      TPFLYER%LALTDEF = .TRUE.
    END IF
    IPOS = IPOS + 1

    TPFLYER%NPOS    = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1
    TPFLYER%NPOSCUR = NINT( ZPACK(IPOS) ); IPOS = IPOS + 1

    TPFLYER%XP_CUR  = ZPACK(IPOS);         IPOS = IPOS + 1

    IPOSAIR = TPFLYER%NPOS

    ALLOCATE( TPFLYER%XPOSLAT(IPOSAIR) )
    ALLOCATE( TPFLYER%XPOSLON(IPOSAIR) )
    ALLOCATE( TPFLYER%XPOSX(IPOSAIR) )
    ALLOCATE( TPFLYER%XPOSY(IPOSAIR) )
    IF ( TPFLYER%LALTDEF ) THEN
      ALLOCATE( TPFLYER%XPOSP(IPOSAIR) )
    ELSE
      ALLOCATE( TPFLYER%XPOSZ(IPOSAIR) )
    END IF
    ALLOCATE( TPFLYER%XPOSTIME(IPOSAIR) )

    TPFLYER%XPOSLAT(1:IPOSAIR)  = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    TPFLYER%XPOSLON(1:IPOSAIR)  = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    TPFLYER%XPOSX(1:IPOSAIR)    = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    TPFLYER%XPOSY(1:IPOSAIR)    = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    IF ( TPFLYER%LALTDEF ) THEN
      TPFLYER%XPOSP(1:IPOSAIR)  = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    ELSE
      TPFLYER%XPOSZ(1:IPOSAIR)  = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR
    END IF
    TPFLYER%XPOSTIME(1:IPOSAIR) = ZPACK(IPOS:IPOS+IPOSAIR-1) ; IPOS = IPOS + IPOSAIR

    TPFLYER%TLAND = TPREFERENCE_DATE + ZPACK(IPOS); IPOS = IPOS + 1

  CLASS IS ( TBALLOONDATA )
    IF ( NINT( ZPACK(IPOS) ) == 0 ) THEN
      TPFLYER%LPOSITION_INIT = .FALSE.
    ELSE
      TPFLYER%LPOSITION_INIT = .TRUE.
    END IF
    IPOS = IPOS + 1

    TPFLYER%XLATLAUNCH = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XLONLAUNCH = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XXLAUNCH   = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XYLAUNCH   = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XALTLAUNCH = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XWASCENT   = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XRHO       = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XPRES      = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XDIAMETER  = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XAERODRAG  = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XINDDRAG   = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XVOLUME    = ZPACK(IPOS); IPOS = IPOS + 1
    TPFLYER%XMASS      = ZPACK(IPOS); IPOS = IPOS + 1

    TPFLYER%TPOS_CUR = TPREFERENCE_DATE + ZPACK(IPOS); IPOS = IPOS + 1

END SELECT

IF ( IPOS-1 /= IPACKSIZE ) &
  call Print_msg( NVERB_WARNING, 'IO', 'FLYER_RECV_AND_ALLOCATE', 'IPOS-1 /= IPACKSIZE (receiver side)', OLOCAL = .TRUE. )

END SUBROUTINE FLYER_RECV_AND_ALLOCATE
!----------------------------------------------------------------------------
!----------------------------------------------------------------------------

END MODULE MODE_AIRCRAFT_BALLOON

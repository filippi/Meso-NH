!MNH_LIC Copyright 2000-2022 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ############################
      MODULE MODD_AIRCRAFT_BALLOON
!     ############################
!
!!****  *MODD_AIRCRAFT_BALLOON* - declaration of balloons
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to define
!      the different balloons types.
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      NONE 
!!
!!    REFERENCE
!!    --------- 
!!
!!    AUTHOR
!!    ------
!! P. Jabouille   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    15/05/00
!!              Apr,19, 2001 (G.Jaubert) add CVBALL type
!!              March, 2013 : O.Caumont, C.Lac : add vertical profiles
!!              Oct,2016 : G.DELAUTIER LIMA
!  P. Wautelet 08/02/2019: add missing NULL association for pointers
!  P. Wautelet 13/09/2019: budget: simplify and modernize date/time management
!  P. Wautelet    06/2022: reorganize flyers
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
!
use modd_parameters,    only: XUNDEF
USE MODD_TYPE_STATPROF, ONLY: TSTATPROFTIME
use modd_type_date,     only: date_time

implicit none

save

!-------------------------------------------------------------------------------------------
!
LOGICAL :: LFLYER    ! flag to use aircraft/balloons
!
TYPE :: TFLYERDATA
  !
  !* general information
  !
  CHARACTER(LEN=3)    :: MODEL = 'FIX' ! type of model used for each balloon/aircraft
                                    ! 'FIX' : NMODEL used during the run
                                    ! 'MOB' : change od model depends of the
                                    !         balloon/aircraft location
  INTEGER             :: NMODEL = 0 ! model number for each balloon/aircraft
  CHARACTER(LEN=6)    :: TYPE = ''  ! flyer type:
                                    ! 'RADIOS' : radiosounding balloon
                                    ! 'ISODEN' : iso-density balloon
                                    ! 'AIRCRA' : aircraft
                                    ! 'CVBALL' : Constant Volume balloon
  CHARACTER(LEN=10)   :: TITLE = ''  ! title or name for the balloon/aircraft
  TYPE(DATE_TIME)     :: LAUNCH      ! launch/takeoff date and time
  LOGICAL             :: CRASH = .FALSE. ! occurence of crash
  LOGICAL             :: FLY   = .FALSE. ! occurence of flying
  !
  !* storage monitoring
  !
  TYPE(TSTATPROFTIME) :: TFLYER_TIME ! Time management for flyer
  !
  !* current position of the balloon/aircraft
  !
  REAL :: X_CUR = XUNDEF ! current x
  REAL :: Y_CUR = XUNDEF ! current y
  REAL :: Z_CUR = XUNDEF ! current z (if 'RADIOS' or 'AIRCRA' and 'ALTDEF' = T)
  REAL :: P_CUR = XUNDEF ! current p (if 'AIRCRA' and 'ALTDEF' = F)
  !
  !* data records
  !
  REAL, DIMENSION(:),    POINTER :: X         => NULL() ! X(n)
  REAL, DIMENSION(:),    POINTER :: Y         => NULL() ! Y(n)
  REAL, DIMENSION(:),    POINTER :: Z         => NULL() ! Z(n)
  REAL, DIMENSION(:),    POINTER :: XLON      => NULL() ! longitude(n)
  REAL, DIMENSION(:),    POINTER :: YLAT      => NULL() ! latitude (n)
  REAL, DIMENSION(:),    POINTER :: ZON       => NULL() ! zonal wind(n)
  REAL, DIMENSION(:),    POINTER :: MER       => NULL() ! meridian wind(n)
  REAL, DIMENSION(:),    POINTER :: W         => NULL() ! w(n)  (air vertical speed)
  REAL, DIMENSION(:),    POINTER :: P         => NULL() ! p(n)
  REAL, DIMENSION(:),    POINTER :: TKE       => NULL() ! tke(n)
  REAL, DIMENSION(:),    POINTER :: TKE_DISS  => NULL() ! tke dissipation rate
  REAL, DIMENSION(:),    POINTER :: TH        => NULL() ! th(n)
  REAL, DIMENSION(:,:),  POINTER :: R         => NULL() ! r*(n)
  REAL, DIMENSION(:,:),  POINTER :: SV        => NULL() ! Sv*(n)
  REAL, DIMENSION(:,:),  POINTER :: RTZ       => NULL() ! tot hydrometeor mixing ratio
  REAL, DIMENSION(:,:,:),POINTER :: RZ        => NULL() ! water vapour mixing ratio
  REAL, DIMENSION(:,:),  POINTER :: FFZ       => NULL() ! horizontal wind
  REAL, DIMENSION(:,:),  POINTER :: IWCZ      => NULL() ! ice water content
  REAL, DIMENSION(:,:),  POINTER :: LWCZ      => NULL() ! liquid water content
  REAL, DIMENSION(:,:),  POINTER :: CIZ       => NULL() ! Ice concentration
  REAL, DIMENSION(:,:),  POINTER :: CCZ       => NULL() ! Cloud concentration (LIMA)
  REAL, DIMENSION(:,:),  POINTER :: CRZ       => NULL() ! Rain concentration (LIMA)
  REAL, DIMENSION(:,:),  POINTER :: CRARE     => NULL() ! cloud radar reflectivity
  REAL, DIMENSION(:,:),  POINTER :: CRARE_ATT => NULL() ! attenuated (= more realistic) cloud radar reflectivity
  REAL, DIMENSION(:,:),  POINTER :: WZ        => NULL() ! vertical profile of vertical velocity
  REAL, DIMENSION(:,:),  POINTER :: ZZ        => NULL() ! vertical profile of mass point altitude (above sea)
  REAL, DIMENSION(:,:),  POINTER :: AER       => NULL() ! Extinction at 550 nm
  REAL, DIMENSION(:,:),  POINTER :: DST_WL    => NULL() ! Extinction by wavelength
  REAL, DIMENSION(:),    POINTER :: ZS        => NULL() ! zs(n)
  REAL, DIMENSION(:),    POINTER :: TSRAD     => NULL() ! Ts(n)
  !
  REAL, DIMENSION(:)  ,   POINTER :: THW_FLUX => NULL() ! thw_flux(n)
  REAL, DIMENSION(:)  ,   POINTER :: RCW_FLUX => NULL() ! rcw_flux(n)
  REAL, DIMENSION(:,:),   POINTER :: SVW_FLUX => NULL() ! psw_flux(n)
END TYPE TFLYERDATA

TYPE, EXTENDS( TFLYERDATA ) :: TAIRCRAFTDATA
  !
  !* aircraft flight definition
  !
  INTEGER :: SEG     = 0  ! number of aircraft flight segments
  INTEGER :: SEGCURN = 1  ! current flight segment number
  REAL    :: SEGCURT = 0. ! current flight segment time spent
  REAL, DIMENSION(:),   POINTER :: SEGLAT  => NULL() ! latitude of flight segment extremities  (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGLON  => NULL() ! longitude of flight segment extremities (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGX    => NULL() ! X of flight segment extremities         (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGY    => NULL() ! Y of flight segment extremities         (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGP    => NULL() ! pressure of flight segment extremities  (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGZ    => NULL() ! altitude of flight segment extremities  (LEG+1)
  REAL, DIMENSION(:),   POINTER :: SEGTIME => NULL() ! duration of flight segments             (LEG  )
  !
  !* aircraft altitude type definition
  !
  LOGICAL                       :: ALTDEF = .FALSE.  ! TRUE == altitude given in pressure
END TYPE TAIRCRAFTDATA

TYPE, EXTENDS( TFLYERDATA ) :: TBALLOONDATA
  !
  !* balloon dynamical characteristics
  !
  REAL :: LAT      = XUNDEF ! latitude of launch
  REAL :: LON      = XUNDEF ! lontitude of launch
  REAL :: XLAUNCH  = XUNDEF ! X coordinate of launch
  REAL :: YLAUNCH  = XUNDEF ! Y coordinate of launch
  REAL :: ALT      = XUNDEF ! altitude of launch (if 'RADIOS' or 'ISODEN' or 'CVBALL')
  REAL :: WASCENT  = 5.     ! ascent vertical speed, m/s (if 'RADIOS')
  REAL :: RHO      = XUNDEF ! density of launch (if 'ISODEN')
  REAL :: PRES     = XUNDEF ! pressure of launch (if 'ISODEN')
  REAL :: DIAMETER = XUNDEF ! apparent diameter of the balloon (m) (if 'CVBALL')
  REAL :: AERODRAG = XUNDEF ! aerodynamic drag coefficient of the balloon (if 'CVBALL')
  REAL :: INDDRAG  = XUNDEF ! induced drag coefficient (i.e. air shifted by the balloon) (if 'CVBALL')
  REAL :: VOLUME   = XUNDEF ! volume of the balloon (m3) (if 'CVBALL')
  REAL :: MASS     = XUNDEF ! mass of the balloon (kg) (if 'CVBALL')
END TYPE TBALLOONDATA

INTEGER :: NAIRCRAFTS = 0 ! Total number of aircrafts
INTEGER :: NBALLOONS  = 0 ! Total number of balloons

TYPE(TAIRCRAFTDATA), DIMENSION(:), ALLOCATABLE :: TAIRCRAFTS ! characteristics and records of the aircrafts

TYPE(TBALLOONDATA),  DIMENSION(:), ALLOCATABLE :: TBALLOONS  ! characteristics and records of the balloons

END MODULE MODD_AIRCRAFT_BALLOON

!MNH_LIC Copyright 1994-2019 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Modifications:
!  Philippe Wautelet: 05/2016-04/2018: new data structures and calls for I/O
!  J. Escobar : 18/06/2018 , bug compile R*4 => real*8 pointer XT_VISC  
!  P. Wautelet 08/02/2019: add missing NULL association for pointers
!  J. Escobar : 09/07/2019 , Norme Doctor -> Rename Module Type variable TZ -> T
!  J. Escobar : 09/07/2019 , for bug in management of XLSZWSM variable , add/use specific 2D TLSFIELD2D_ll pointer
!-----------------------------------------------------------------
!     #################
      MODULE MODD_SUB_MODEL_n
!     #################
!
USE MODD_ARGSLIST_ll, ONLY : LIST_ll, HALO2LIST_ll
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE SUB_MODEL_t
  TYPE(LIST_ll), POINTER :: TFIELDS_ll => NULL(), TLSFIELD_ll => NULL(), TFIELDM_ll => NULL()
                       ! list of fields to update halo
  TYPE(LIST_ll), POINTER :: TLSFIELD2D_ll => NULL()
  TYPE(HALO2LIST_ll), POINTER :: THALO2M_ll => NULL(), TLSHALO2_ll => NULL()
                       ! list of fields for the halo updates (2nd layer)
  ! halo lists and updates for 4th order schemes
! list of fields to update halo at time t
  TYPE(LIST_ll), POINTER :: TFIELDT_ll  => NULL() ! for meteorological scalars
  TYPE(LIST_ll), POINTER :: TFIELDMT_ll => NULL() ! for momentum
  TYPE(LIST_ll), POINTER :: TFIELDSC_ll => NULL() ! for tracer scalars
! list of fields for the halo updates (2nd layer) at time t
  TYPE(HALO2LIST_ll), POINTER :: THALO2T_ll  => NULL()
  TYPE(HALO2LIST_ll), POINTER :: THALO2MT_ll => NULL()
  TYPE(HALO2LIST_ll), POINTER :: THALO2SC_ll => NULL()
  INTEGER :: IBAK, IOUT          ! number of the backup / output
  REAL*8,DIMENSION(2)    :: XT_START
  REAL*8,DIMENSION(2)    :: XT_STORE,XT_BOUND,XT_GUESS
  REAL*8,DIMENSION(2)    :: XT_ADV,XT_SOURCES,XT_DRAG
  REAL*8,DIMENSION(2)    :: XT_ADVUVW,XT_GRAV,XT_VISC
  REAL*8,DIMENSION(2)    :: XT_DIFF,XT_RELAX,XT_PARAM,XT_SPECTRA
  REAL*8,DIMENSION(2)    :: XT_HALO,XT_RAD_BOUND,XT_PRESS
  REAL*8,DIMENSION(2)    :: XT_CLOUD,XT_STEP_SWA,XT_STEP_MISC
  REAL*8,DIMENSION(2)    :: XT_ELEC                          
  REAL*8,DIMENSION(2)    :: XT_COUPL,XT_1WAY,XT_STEP_BUD
  REAL*8,DIMENSION(2)    :: XT_RAD,XT_DCONV,XT_GROUND,XT_TRACER,XT_MAFL
  REAL*8,DIMENSION(2)    :: XT_TURB,XT_2WAY,XT_SHADOWS
  REAL*8,DIMENSION(2)    :: XT_FORCING,XT_NUDGING,XT_CHEM

  REAL, DIMENSION(:,:,:), POINTER :: ZWT_ACT_NUC=>NULL()
                             ! Vertical motion used for ACTivation/NUCleation
  LOGICAL, DIMENSION(:,:), POINTER :: GMASKkids=>NULL() ! kids domains mask

  LOGICAL :: GCLOSE_OUT = .FALSE. ! conditional closure of the OUTPUT FM-file
END TYPE SUB_MODEL_t

TYPE(SUB_MODEL_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: SUB_MODEL_MODEL

TYPE(LIST_ll), POINTER :: TFIELDS_ll=>NULL(),TLSFIELD_ll=>NULL(),TFIELDM_ll=>NULL()
TYPE(LIST_ll), POINTER :: TLSFIELD2D_ll => NULL()
TYPE(LIST_ll), POINTER :: TFIELDT_ll=>NULL(),TFIELDMT_ll=>NULL(),TFIELDSC_ll=>NULL()
TYPE(HALO2LIST_ll), POINTER :: THALO2M_ll=>NULL(), TLSHALO2_ll=>NULL()
TYPE(HALO2LIST_ll), POINTER :: THALO2T_ll=>NULL(), THALO2MT_ll=>NULL(), THALO2SC_ll=>NULL()
INTEGER, POINTER :: IBAK=>NULL()
INTEGER, POINTER :: IOUT=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_START=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_STORE=>NULL(),XT_BOUND=>NULL(),XT_GUESS=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_ADV=>NULL(),XT_SOURCES=>NULL(),XT_DRAG=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_ADVUVW=>NULL(),XT_GRAV=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_DIFF=>NULL(),XT_RELAX=>NULL(),XT_PARAM=>NULL(),XT_SPECTRA=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_HALO=>NULL(),XT_RAD_BOUND=>NULL(),XT_PRESS=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_VISC=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_CLOUD=>NULL(),XT_STEP_SWA=>NULL(),XT_STEP_MISC=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_ELEC=>NULL(),XT_SHADOWS=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_COUPL=>NULL(),XT_1WAY=>NULL(),XT_STEP_BUD=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_RAD=>NULL(),XT_DCONV=>NULL(),XT_GROUND=>NULL(),XT_MAFL=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_TURB=>NULL(),XT_2WAY=>NULL(),XT_TRACER=>NULL()
REAL*8,DIMENSION(:), POINTER :: XT_FORCING=>NULL(),XT_NUDGING=>NULL(),XT_CHEM=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: ZWT_ACT_NUC=>NULL()
LOGICAL, DIMENSION(:,:), POINTER :: GMASKkids=>NULL()
LOGICAL, POINTER :: GCLOSE_OUT=>NULL()

CONTAINS

SUBROUTINE SUB_MODEL_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
SUB_MODEL_MODEL(KFROM)%TFIELDS_ll=>TFIELDS_ll
SUB_MODEL_MODEL(KFROM)%TLSFIELD_ll=>TLSFIELD_ll
SUB_MODEL_MODEL(KFROM)%TFIELDM_ll=>TFIELDM_ll
SUB_MODEL_MODEL(KFROM)%TFIELDT_ll=>TFIELDT_ll
SUB_MODEL_MODEL(KFROM)%TFIELDMT_ll=>TFIELDMT_ll
SUB_MODEL_MODEL(KFROM)%TLSFIELD2D_ll=>TLSFIELD2D_ll
SUB_MODEL_MODEL(KFROM)%TFIELDSC_ll=>TFIELDSC_ll
SUB_MODEL_MODEL(KFROM)%THALO2M_ll=>THALO2M_ll
SUB_MODEL_MODEL(KFROM)%TLSHALO2_ll=>TLSHALO2_ll
SUB_MODEL_MODEL(KFROM)%THALO2T_ll=>THALO2T_ll
SUB_MODEL_MODEL(KFROM)%THALO2MT_ll=>THALO2MT_ll
SUB_MODEL_MODEL(KFROM)%THALO2SC_ll=>THALO2SC_ll
SUB_MODEL_MODEL(KFROM)%ZWT_ACT_NUC=>ZWT_ACT_NUC
SUB_MODEL_MODEL(KFROM)%GMASKkids=>GMASKkids  
!
! Current model is set to model KTO
TFIELDS_ll=>SUB_MODEL_MODEL(KTO)%TFIELDS_ll
TLSFIELD_ll=>SUB_MODEL_MODEL(KTO)%TLSFIELD_ll
TFIELDM_ll=>SUB_MODEL_MODEL(KTO)%TFIELDM_ll
TFIELDT_ll=>SUB_MODEL_MODEL(KTO)%TFIELDT_ll
TFIELDMT_ll=>SUB_MODEL_MODEL(KTO)%TFIELDMT_ll
TLSFIELD2D_ll=>SUB_MODEL_MODEL(KTO)%TLSFIELD2D_ll
TFIELDSC_ll=>SUB_MODEL_MODEL(KTO)%TFIELDSC_ll
THALO2M_ll=>SUB_MODEL_MODEL(KTO)%THALO2M_ll
TLSHALO2_ll=>SUB_MODEL_MODEL(KTO)%TLSHALO2_ll
THALO2T_ll=>SUB_MODEL_MODEL(KTO)%THALO2T_ll
THALO2MT_ll=>SUB_MODEL_MODEL(KTO)%THALO2MT_ll
THALO2SC_ll=>SUB_MODEL_MODEL(KTO)%THALO2SC_ll
IBAK=>SUB_MODEL_MODEL(KTO)%IBAK
IOUT=>SUB_MODEL_MODEL(KTO)%IOUT
XT_START=>SUB_MODEL_MODEL(KTO)%XT_START
XT_STORE=>SUB_MODEL_MODEL(KTO)%XT_STORE
XT_BOUND=>SUB_MODEL_MODEL(KTO)%XT_BOUND
XT_GUESS=>SUB_MODEL_MODEL(KTO)%XT_GUESS
XT_ADV=>SUB_MODEL_MODEL(KTO)%XT_ADV
XT_ADVUVW=>SUB_MODEL_MODEL(KTO)%XT_ADVUVW
XT_GRAV=>SUB_MODEL_MODEL(KTO)%XT_GRAV
XT_SOURCES=>SUB_MODEL_MODEL(KTO)%XT_SOURCES
XT_DRAG=>SUB_MODEL_MODEL(KTO)%XT_DRAG
XT_DIFF=>SUB_MODEL_MODEL(KTO)%XT_DIFF
XT_RELAX=>SUB_MODEL_MODEL(KTO)%XT_RELAX
XT_PARAM=>SUB_MODEL_MODEL(KTO)%XT_PARAM
XT_SPECTRA=>SUB_MODEL_MODEL(KTO)%XT_SPECTRA
XT_HALO=>SUB_MODEL_MODEL(KTO)%XT_HALO
XT_VISC=>SUB_MODEL_MODEL(KTO)%XT_VISC
XT_RAD_BOUND=>SUB_MODEL_MODEL(KTO)%XT_RAD_BOUND
XT_PRESS=>SUB_MODEL_MODEL(KTO)%XT_PRESS
XT_CLOUD=>SUB_MODEL_MODEL(KTO)%XT_CLOUD
XT_ELEC=>SUB_MODEL_MODEL(KTO)%XT_ELEC
XT_STEP_SWA=>SUB_MODEL_MODEL(KTO)%XT_STEP_SWA
XT_STEP_MISC=>SUB_MODEL_MODEL(KTO)%XT_STEP_MISC
XT_COUPL=>SUB_MODEL_MODEL(KTO)%XT_COUPL
XT_1WAY=>SUB_MODEL_MODEL(KTO)%XT_1WAY
XT_STEP_BUD=>SUB_MODEL_MODEL(KTO)%XT_STEP_BUD
XT_RAD=>SUB_MODEL_MODEL(KTO)%XT_RAD
XT_DCONV=>SUB_MODEL_MODEL(KTO)%XT_DCONV
XT_GROUND=>SUB_MODEL_MODEL(KTO)%XT_GROUND
XT_MAFL=>SUB_MODEL_MODEL(KTO)%XT_MAFL
XT_TRACER=>SUB_MODEL_MODEL(KTO)%XT_TRACER
XT_TURB=>SUB_MODEL_MODEL(KTO)%XT_TURB
XT_2WAY=>SUB_MODEL_MODEL(KTO)%XT_2WAY
XT_SHADOWS=>SUB_MODEL_MODEL(KTO)%XT_SHADOWS
XT_FORCING=>SUB_MODEL_MODEL(KTO)%XT_FORCING
XT_NUDGING=>SUB_MODEL_MODEL(KTO)%XT_NUDGING
XT_CHEM=>SUB_MODEL_MODEL(KTO)%XT_CHEM
ZWT_ACT_NUC=>SUB_MODEL_MODEL(KTO)%ZWT_ACT_NUC
GMASKkids=>SUB_MODEL_MODEL(KTO)%GMASKkids  
GCLOSE_OUT=>SUB_MODEL_MODEL(KTO)%GCLOSE_OUT

END SUBROUTINE SUB_MODEL_GOTO_MODEL

END MODULE MODD_SUB_MODEL_n

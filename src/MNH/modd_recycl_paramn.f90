!MNH_LIC Copyright 2021-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!
!     #######################
      MODULE MODD_RECYCL_PARAM_n
!     #######################
!
!****  MODD_RECYCL_PARAM_n - declaration of the control parameters
!                         used in the turbulence recycling method
!
!    PURPOSE
!    -------
!****  The purpose of this module is to declare the constants
!      allowing to initialize the turbulence recycling method 
!
!
!    IMPLICIT ARGUMENTS
!    ------------------
!      None 
!
!    REFERENCE
!    ---------
!          
!    AUTHOR
!    ------
!	Tim Nagel (Meteo-France)
!
!    MODIFICATIONS
!    -------------
!      Original    01/02/2021
!
!------------------------------------------------------------------------------
!
!**** 0. DECLARATIONS
!     ---------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE
!
TYPE RECYCL_t
!
LOGICAL          :: LRECYCL,LRECYCLN,LRECYCLW,LRECYCLE,LRECYCLS              ! Recycling logical
REAL             :: XDRECYCLN,XDRECYCLW,XDRECYCLE,XDRECYCLS,    &
                    XARECYCLN,XARECYCLW,XARECYCLE,XARECYCLS,    &
                    XTMOY,XTMOYCOUNT,XNUMBELT,XRCOEFF,XTBVTOP,XTBVBOT

INTEGER                             :: NR_COUNT
REAL, DIMENSION(:,:,:)   ,POINTER :: XUMEANW=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XVMEANW=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XWMEANW=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XUMEANN=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XVMEANN=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XWMEANN=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XUMEANE=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XVMEANE=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XWMEANE=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XUMEANS=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XVMEANS=>NULL()
REAL, DIMENSION(:,:,:)   ,POINTER :: XWMEANS=>NULL()
!
END TYPE RECYCL_t

TYPE(RECYCL_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: RECYCL_MODEL

LOGICAL                 ,POINTER :: LRECYCL=>NULL()
LOGICAL                 ,POINTER :: LRECYCLN=>NULL()
LOGICAL                 ,POINTER :: LRECYCLW=>NULL()
LOGICAL                 ,POINTER :: LRECYCLE=>NULL()
LOGICAL                 ,POINTER :: LRECYCLS=>NULL()

REAL                    ,POINTER :: XDRECYCLN=>NULL()
REAL                    ,POINTER :: XARECYCLN=>NULL()
REAL                    ,POINTER :: XDRECYCLW=>NULL()
REAL                    ,POINTER :: XARECYCLW=>NULL()
REAL                    ,POINTER :: XDRECYCLE=>NULL()
REAL                    ,POINTER :: XARECYCLE=>NULL()
REAL                    ,POINTER :: XDRECYCLS=>NULL()
REAL                    ,POINTER :: XARECYCLS=>NULL()
REAL                    ,POINTER :: XTMOY=>NULL()
REAL                    ,POINTER :: XTMOYCOUNT=>NULL()
REAL                    ,POINTER :: XNUMBELT=>NULL()
REAL                    ,POINTER :: XRCOEFF=>NULL()
REAL                    ,POINTER :: XTBVTOP=>NULL()
REAL                    ,POINTER :: XTBVBOT=>NULL()

REAL, DIMENSION(:,:,:),POINTER :: XUMEANW=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XVMEANW=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XWMEANW=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XUMEANN=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XVMEANN=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XWMEANN=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XUMEANE=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XVMEANE=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XWMEANE=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XUMEANS=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XVMEANS=>NULL()
REAL, DIMENSION(:,:,:),POINTER :: XWMEANS=>NULL()



INTEGER                 ,POINTER :: NR_COUNT =>NULL()
REAL, DIMENSION(:,:,:)  ,POINTER :: XTBV=>NULL()

CONTAINS

SUBROUTINE RECYCL_GOTO_MODEL(KFROM, KTO)

INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
RECYCL_MODEL(KFROM)%XUMEANW=>XUMEANW
RECYCL_MODEL(KFROM)%XVMEANW=>XVMEANW
RECYCL_MODEL(KFROM)%XWMEANW=>XWMEANW
RECYCL_MODEL(KFROM)%XUMEANN=>XUMEANN
RECYCL_MODEL(KFROM)%XVMEANN=>XVMEANN
RECYCL_MODEL(KFROM)%XWMEANN=>XWMEANN
RECYCL_MODEL(KFROM)%XUMEANE=>XUMEANE
RECYCL_MODEL(KFROM)%XVMEANE=>XVMEANE
RECYCL_MODEL(KFROM)%XWMEANE=>XWMEANE
RECYCL_MODEL(KFROM)%XUMEANS=>XUMEANS
RECYCL_MODEL(KFROM)%XVMEANS=>XVMEANS
RECYCL_MODEL(KFROM)%XWMEANS=>XWMEANS


!
! Current model is set to model KTO
LRECYCL=>RECYCL_MODEL(KTO)%LRECYCL
LRECYCLN=>RECYCL_MODEL(KTO)%LRECYCLN
LRECYCLW=>RECYCL_MODEL(KTO)%LRECYCLW
LRECYCLE=>RECYCL_MODEL(KTO)%LRECYCLE
LRECYCLS=>RECYCL_MODEL(KTO)%LRECYCLS
XDRECYCLN=>RECYCL_MODEL(KTO)%XDRECYCLN
XARECYCLN=>RECYCL_MODEL(KTO)%XARECYCLN
XDRECYCLW=>RECYCL_MODEL(KTO)%XDRECYCLW
XARECYCLW=>RECYCL_MODEL(KTO)%XARECYCLW
XDRECYCLE=>RECYCL_MODEL(KTO)%XDRECYCLE
XARECYCLE=>RECYCL_MODEL(KTO)%XARECYCLE
XDRECYCLS=>RECYCL_MODEL(KTO)%XDRECYCLS
XARECYCLS=>RECYCL_MODEL(KTO)%XARECYCLS
XTMOY=>RECYCL_MODEL(KTO)%XTMOY
XTMOYCOUNT=>RECYCL_MODEL(KTO)%XTMOYCOUNT
XNUMBELT=>RECYCL_MODEL(KTO)%XNUMBELT
XRCOEFF=>RECYCL_MODEL(KTO)%XRCOEFF
XTBVTOP=>RECYCL_MODEL(KTO)%XTBVTOP
XTBVBOT=>RECYCL_MODEL(KTO)%XTBVBOT

XUMEANW=>RECYCL_MODEL(KTO)%XUMEANW
XVMEANW=>RECYCL_MODEL(KTO)%XVMEANW
XWMEANW=>RECYCL_MODEL(KTO)%XWMEANW
XUMEANN=>RECYCL_MODEL(KTO)%XUMEANN
XVMEANN=>RECYCL_MODEL(KTO)%XVMEANN
XWMEANN=>RECYCL_MODEL(KTO)%XWMEANN
XUMEANE=>RECYCL_MODEL(KTO)%XUMEANE
XVMEANE=>RECYCL_MODEL(KTO)%XVMEANE
XWMEANE=>RECYCL_MODEL(KTO)%XWMEANE
XUMEANS=>RECYCL_MODEL(KTO)%XUMEANS
XVMEANS=>RECYCL_MODEL(KTO)%XVMEANS
XWMEANS=>RECYCL_MODEL(KTO)%XWMEANS

NR_COUNT=>RECYCL_MODEL(KTO)%NR_COUNT

END SUBROUTINE RECYCL_GOTO_MODEL

END MODULE MODD_RECYCL_PARAM_n
!


!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/10/24 10:07:40
!-----------------------------------------------------------------
MODULE MODD_DIAG_IN_RUN
!
!* stores instantaneous diagnostic arrays for the current time-step
!
IMPLICIT NONE

LOGICAL                             :: LDIAG_IN_RUN   ! flag for diagnostics
!
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_RN    ! net radiation
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_H     ! sensible heat flux
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_LE    ! Total latent heat flux
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_LEI   ! Solid latent heat flux
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_GFLUX ! ground flux
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_LW    ! incoming longwave at the surface
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_SW    ! incoming Shortwave at the surface
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_T2M   ! temperature at 2m
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_Q2M   ! humidity at 2m
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_HU2M  ! relative humidity at 2m
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_ZON10M! zonal wind at 10m
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_MER10M! meridian wind at 10m
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_DSTAOD! dust aerosol optical depth
REAL, DIMENSION(:,:),   ALLOCATABLE :: XCURRENT_SFCO2    ! CO2 Surface flux
REAL, DIMENSION(:,:,:), ALLOCATABLE :: XCURRENT_TKE_DISS ! Tke dissipation rate
END MODULE MODD_DIAG_IN_RUN

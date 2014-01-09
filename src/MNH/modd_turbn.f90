!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/06/27 12:27:59
!-----------------------------------------------------------------
!     ##################
      MODULE MODD_TURB_n
!     ##################
!
!!****  *MODD_TURB$n* - declaration of turbulence scheme free parameters
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to declare the
!     variables that may be set by namelist for the turbulence scheme
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None 
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (module MODD_PARAMn)
!!          
!!    AUTHOR
!!    ------
!!	    J. Cuxart and J. Stein       * I.N.M. and Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    January 9, 1995                   
!!      J.Cuxart    February 15, 1995 add the switches for diagnostic storages
!!      J.M. Carriere May  15, 1995 add the subgrid condensation
!!      M. Tomasini Jul  05, 2001 add the subgrid autoconversion
!!      P. Bechtold Feb 11, 2002    add switch for Sigma_s computation
!!      P. Jabouille Apr 4, 2002    add switch for Sigma_s convection
!!      V. Masson    Nov 13 2002    add switch for SBL lengths
!!                   May   2006    Remove KEPS

!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE TURB_t
! 
! 
  REAL               :: XIMPL     ! implicitness degree for the vertical terms of 
                                     ! the turbulence scheme
  REAL               :: XKEMIN      ! mimimum value for the TKE                                  
  CHARACTER (LEN=4)  :: CTURBLEN  ! type of length used for the closure
                                     ! 'BL89' Bougeault and Lacarrere scheme
                                     ! 'DELT' length = ( volum) ** 1/3
  CHARACTER (LEN=4)  :: CTURBDIM  ! dimensionality of the turbulence scheme
                                     ! '1DIM' for purely vertical computations
                                     ! '3DIM' for computations in the 3 
                                     ! directions
  LOGICAL            :: LTURB_FLX ! logical switch for the storage of all  
                                     ! the turbulent fluxes
  LOGICAL            :: LTURB_DIAG! logical switch for the storage of some 
                                     ! turbulence related diagnostics
  LOGICAL            :: LSUBG_COND! Switch for subgrid condensation 
  LOGICAL            :: LSIGMAS   ! Switch for using Sigma_s from turbulence scheme
  LOGICAL            :: LSIG_CONV ! Switch for computing Sigma_s due to convection
!
  LOGICAL            :: LRMC01    ! Switch for computing separate mixing
!                                    ! and dissipative length in the SBL
!                                    ! according to Redelsperger, Mahe &
!                                    ! Carlotti 2001
  CHARACTER(LEN=4)   :: CTOM      ! type of Third Order Moments
                                  ! 'NONE' none
                                  ! 'TM06' Tomas Masson 2006
  CHARACTER(LEN=4)   :: CSUBG_AUCV ! type of subgrid autoconv. method
  REAL, DIMENSION(:,:), POINTER :: XBL_DEPTH=>NULL() ! BL depth for TOMS computations
  REAL, DIMENSION(:,:), POINTER :: XSBL_DEPTH=>NULL()! SurfaceBL depth for RMC01 computations
  REAL, DIMENSION(:,:,:), POINTER :: XWTHVMF=>NULL()! Mass Flux vert. transport of buoyancy
  REAL               :: VSIGQSAT  ! coeff applied to qsat variance contribution
!
END TYPE TURB_t

TYPE(TURB_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: TURB_MODEL

REAL, POINTER :: XIMPL=>NULL()
REAL, POINTER :: XKEMIN=>NULL()
CHARACTER (LEN=4), POINTER :: CTURBLEN=>NULL()
CHARACTER (LEN=4), POINTER :: CTURBDIM=>NULL()
LOGICAL, POINTER :: LTURB_FLX=>NULL()
LOGICAL, POINTER :: LTURB_DIAG=>NULL()
LOGICAL, POINTER :: LSUBG_COND=>NULL()
LOGICAL, POINTER :: LSIGMAS=>NULL()
LOGICAL, POINTER :: LSIG_CONV=>NULL()
LOGICAL, POINTER :: LRMC01=>NULL()
CHARACTER(LEN=4),POINTER :: CTOM=>NULL()
CHARACTER(LEN=4),POINTER :: CSUBG_AUCV=>NULL()
REAL, DIMENSION(:,:), POINTER :: XBL_DEPTH=>NULL()
REAL, DIMENSION(:,:), POINTER :: XSBL_DEPTH=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XWTHVMF=>NULL()
REAL, POINTER :: VSIGQSAT=>NULL()

CONTAINS

SUBROUTINE TURB_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
!
TURB_MODEL(KFROM)%XBL_DEPTH=>XBL_DEPTH
TURB_MODEL(KFROM)%XSBL_DEPTH=>XSBL_DEPTH
TURB_MODEL(KFROM)%XWTHVMF=>XWTHVMF
!
! Current model is set to model KTO
XIMPL=>TURB_MODEL(KTO)%XIMPL
XKEMIN=>TURB_MODEL(KTO)%XKEMIN
CTURBLEN=>TURB_MODEL(KTO)%CTURBLEN
CTURBDIM=>TURB_MODEL(KTO)%CTURBDIM
LTURB_FLX=>TURB_MODEL(KTO)%LTURB_FLX
LTURB_DIAG=>TURB_MODEL(KTO)%LTURB_DIAG
LSUBG_COND=>TURB_MODEL(KTO)%LSUBG_COND
LSIGMAS=>TURB_MODEL(KTO)%LSIGMAS
LSIG_CONV=>TURB_MODEL(KTO)%LSIG_CONV
LRMC01=>TURB_MODEL(KTO)%LRMC01
CTOM=>TURB_MODEL(KTO)%CTOM
CSUBG_AUCV=>TURB_MODEL(KTO)%CSUBG_AUCV
XBL_DEPTH=>TURB_MODEL(KTO)%XBL_DEPTH
XSBL_DEPTH=>TURB_MODEL(KTO)%XSBL_DEPTH
XWTHVMF=>TURB_MODEL(KTO)%XWTHVMF
VSIGQSAT=>TURB_MODEL(KTO)%VSIGQSAT

END SUBROUTINE TURB_GOTO_MODEL

END MODULE MODD_TURB_n

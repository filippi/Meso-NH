!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2007/02/19 11:58:44
!-----------------------------------------------------------------
!     ################
      MODULE MODD_ADV_n
!     ################
!
!!****  *MODD_ADV$n* - declaration of scalar advection scheme control variables
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to declare the advective 
!     control variables.    
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None 
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (module MODD_ADVn)
!!          
!!    AUTHOR
!!    ------
!!	Vila, Lafore   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original     23/10/95  (Vila, lafore) For new scalar advection schemes
!!      C.Lac       24/04/06  Introduction of CUVW_ADV_SCHEME and
!!                            removal of CFV_ADV_SCHEME
!!      J.-P. Pinty  20/03/10 Add NWENO_ORDER
!!      C.Lac and V.Masson    Add CTEMP_SCHEME and TIME SPLITTING
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE ADV_t
!
  CHARACTER(LEN=6)       :: CMET_ADV_SCHEME, CSV_ADV_SCHEME, CUVW_ADV_SCHEME
                                  ! Control the selected advection scheme
                                  ! for the scalar variables
  CHARACTER(LEN=4)       :: CTEMP_SCHEME
!
  INTEGER                :: NWENO_ORDER ! Order of the WENO scheme (3 or 5)
!
  INTEGER                :: NSPLIT      ! Number of time splitting   
                                        ! for advection  
!
  LOGICAL                :: LSPLIT_CFL  ! Flag to automatically choose number of iterations
  REAL                   :: XSPLIT_CFL  ! Limit of CFL to automatically choose number of iterations
!
  LOGICAL                :: LCFL_WRIT   ! Flag to write CFL fields in output file               
!
REAL, DIMENSION(:,:,:), POINTER :: XRTKEMS=>NULL()   ! Advection TKE source term
END TYPE ADV_t

TYPE(ADV_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: ADV_MODEL

CHARACTER(LEN=6), POINTER :: CMET_ADV_SCHEME=>NULL(), CSV_ADV_SCHEME=>NULL(), CUVW_ADV_SCHEME=>NULL()
CHARACTER(LEN=4), POINTER :: CTEMP_SCHEME=>NULL()
INTEGER, POINTER :: NWENO_ORDER=>NULL()
INTEGER, POINTER :: NSPLIT=>NULL()
LOGICAL, POINTER :: LSPLIT_CFL=>NULL()
LOGICAL, POINTER :: LCFL_WRIT=>NULL()
REAL,    POINTER :: XSPLIT_CFL=>NULL()
REAL, DIMENSION(:,:,:), POINTER :: XRTKEMS=>NULL()


CONTAINS

SUBROUTINE ADV_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
ADV_MODEL(KFROM)%XRTKEMS=>XRTKEMS
!
! Current model is set to model KTO
CUVW_ADV_SCHEME=>ADV_MODEL(KTO)%CUVW_ADV_SCHEME
CMET_ADV_SCHEME=>ADV_MODEL(KTO)%CMET_ADV_SCHEME
CSV_ADV_SCHEME=>ADV_MODEL(KTO)%CSV_ADV_SCHEME
CTEMP_SCHEME=>ADV_MODEL(KTO)%CTEMP_SCHEME
NWENO_ORDER=>ADV_MODEL(KTO)%NWENO_ORDER
NSPLIT=>ADV_MODEL(KTO)%NSPLIT         
LSPLIT_CFL=>ADV_MODEL(KTO)%LSPLIT_CFL         
LCFL_WRIT=>ADV_MODEL(KTO)%LCFL_WRIT          
XSPLIT_CFL=>ADV_MODEL(KTO)%XSPLIT_CFL         
XRTKEMS=>ADV_MODEL(KTO)%XRTKEMS

END SUBROUTINE ADV_GOTO_MODEL

END MODULE MODD_ADV_n

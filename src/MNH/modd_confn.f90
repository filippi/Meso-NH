!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! masdev4_7 BUG1 2007/06/15 17:47:27
!-----------------------------------------------------------------
!     #################
      MODULE MODD_CONF_n
!     #################
!
!!****  *MODD_CONF$n* - declaration of configuration variables
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to declare  the variables
!     which concern the configuration of the model. For exemple, 
!     the  type of moist variables. 
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None 
!!
!!    REFERENCE
!!    ---------
!!      Book2 of documentation of Meso-NH (module MODD_CONFn)
!!      Technical Specifications Report of the Meso-NH (chapters 2 and 3)
!!       
!!    AUTHOR
!!    ------
!!	V. Ducrocq   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    05/05/94                      
!!      J.-P. Pinty 11/04/96  include the ice concentration
!!      D. Gazen    22/01/01  move NSV to MODD_NSV module
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE CONF_t
  LOGICAL :: LUSERV  ! Logical to use rv
  LOGICAL :: LUSERC  ! Logical to use rc
  LOGICAL :: LUSERR  ! Logical to use rr
  LOGICAL :: LUSERI  ! Logical to use ri
  LOGICAL :: LUSERS  ! Logical to use rs
  LOGICAL :: LUSERG  ! Logical to use rg
  LOGICAL :: LUSERH  ! Logical to use rh
  INTEGER :: NRR     ! Total number of water variables
  INTEGER :: NRRL    ! Number of liquid water variables
  INTEGER :: NRRI    ! Number of solid water variables
!
  CHARACTER (LEN=2) :: CSTORAGE_TYPE ! storage type for the informations 
                                 ! written in the FM files ( 'TT' if the MesoNH 
                                 ! prognostic fields are at the same instant;
                                 ! 'MT' if they are taken at two instants in
                                 ! succession; 'PG' for PGD files informations )
  LOGICAL :: LUSECI  ! Logical to use Ci
!
END TYPE CONF_t

TYPE(CONF_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: CONF_MODEL

LOGICAL, POINTER :: LUSERV=>NULL()
LOGICAL, POINTER :: LUSERC=>NULL()
LOGICAL, POINTER :: LUSERR=>NULL()
LOGICAL, POINTER :: LUSERI=>NULL()
LOGICAL, POINTER :: LUSERS=>NULL()
LOGICAL, POINTER :: LUSERG=>NULL()
LOGICAL, POINTER :: LUSERH=>NULL()
INTEGER, POINTER :: NRR=>NULL()
INTEGER, POINTER :: NRRL=>NULL()
INTEGER, POINTER :: NRRI=>NULL()
LOGICAL, POINTER :: LUSECI=>NULL()
CHARACTER (LEN=2),POINTER :: CSTORAGE_TYPE=>NULL()

CONTAINS

SUBROUTINE CONF_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
!
! Current model is set to model KTO
LUSERV=>CONF_MODEL(KTO)%LUSERV
LUSERC=>CONF_MODEL(KTO)%LUSERC
LUSERR=>CONF_MODEL(KTO)%LUSERR
LUSERI=>CONF_MODEL(KTO)%LUSERI
LUSERS=>CONF_MODEL(KTO)%LUSERS
LUSERG=>CONF_MODEL(KTO)%LUSERG
LUSERH=>CONF_MODEL(KTO)%LUSERH
NRR=>CONF_MODEL(KTO)%NRR
NRRL=>CONF_MODEL(KTO)%NRRL
NRRI=>CONF_MODEL(KTO)%NRRI
LUSECI=>CONF_MODEL(KTO)%LUSECI
CSTORAGE_TYPE=>CONF_MODEL(KTO)%CSTORAGE_TYPE

END SUBROUTINE CONF_GOTO_MODEL

END MODULE MODD_CONF_n

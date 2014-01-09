!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     #################
      MODULE MODD_SPAWN
!     #################
!
!!****  *MODD_SPAWN* - declaration of configuration variables between model 2
!!                          and model 1 for spawning purpose
!!
!!    PURPOSE
!!    -------
!       The purpose of this declarative module is to specify  the variables
!     which concern the configuration between model 2 and model 1 during spawning
!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!
!!      NONE
!!
!!    REFERENCE
!!    ---------
!!       
!!    AUTHOR
!!    ------
!!	P. Jabouille   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    12/07/99
!!      Modification 08/04/04   (G.Jaubert) Spawning 1 option
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
IMPLICIT NONE
!
INTEGER,SAVE   :: NDXRATIO,NDYRATIO ! x and y-direction resolution RATIO between models 2 and 1
!
INTEGER,SAVE   :: NXSIZE,NYSIZE     ! number of model 1 grid points in x and y-directions
                                    ! in the model 2 physical domain
INTEGER,SAVE   :: NXOR, NYOR        ! horizontal position (i,j) of the
INTEGER,SAVE   :: NXEND,NYEND       ! ORigin and END of model 2 relative to model 1 
!
CHARACTER (LEN=28) :: CDOMAIN       ! input fm-file for grid definition
!
LOGICAL            :: LBAL_ONLY     ! logical switch for spawning 1 with
                                    ! balance calculation only and
                                    ! no modification of the model definition
                                    ! v.s its DAD except the DAD name
!
CHARACTER (LEN=28) :: CDADINIFILE ! DAD fm-file for initial file
                                    ! if LBAL_ONLY=T
CHARACTER (LEN=28) :: CDADSPAFILE ! DAD fm-file for spawning file
                                    ! if LBAL_ONLY=T
!
END MODULE MODD_SPAWN

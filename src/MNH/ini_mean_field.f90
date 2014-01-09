!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ##########################
      MODULE MODI_INI_MEAN_FIELD
!     ##########################
!
INTERFACE
!
SUBROUTINE INI_MEAN_FIELD
!
END SUBROUTINE INI_MEAN_FIELD                  
!
END INTERFACE
!
END MODULE MODI_INI_MEAN_FIELD
!
!     ############################################################
      SUBROUTINE INI_MEAN_FIELD
!     ############################################################
!
!!****  *INI_MEAN_FIELD* - routine to initialize mean variables      
!!
!!    PURPOSE
!!    -------
!      
!!**  METHOD
!!    ------
!    !!      
!!    EXTERNAL
!!    --------   
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------ 
!!  !!
!!
!!    REFERENCE
!!    ---------
!!       
!!
!!    AUTHOR
!!    ------
!!	P. Aumond      * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original        11/12/09
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------ 
!
!
USE MODD_MEAN_FIELD_n
USE MODD_MEAN_FIELD

IMPLICIT NONE
!
MEAN_COUNT = 0

XUM_MEAN  = 0.0
XVM_MEAN  = 0.0
XWM_MEAN  = 0.0
XTHM_MEAN = 0.0
XTEMPM_MEAN = 0.0
XTKEM_MEAN = 0.0
XPABSM_MEAN = 0.0

XU2_MEAN  = 0.0
XV2_MEAN  = 0.0
XW2_MEAN  = 0.0
XTH2_MEAN = 0.0
XTEMP2_MEAN = 0.0
XPABS2_MEAN = 0.0

END SUBROUTINE INI_MEAN_FIELD

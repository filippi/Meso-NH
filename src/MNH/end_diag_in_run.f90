!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 profiler 2006/10/24 10:07:27
!-----------------------------------------------------------------
!      #########################
MODULE MODI_END_DIAG_IN_RUN
!      #########################
!
INTERFACE
!
SUBROUTINE END_DIAG_IN_RUN
!
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE END_DIAG_IN_RUN
!
END INTERFACE
!
END MODULE MODI_END_DIAG_IN_RUN
!
!     ####################
SUBROUTINE END_DIAG_IN_RUN
!     ####################
!
!
!!****  *END_DIAG_IN_RUN* - 
!!
!!    PURPOSE
!!    -------
!
!
!!**  METHOD
!!    ------
!!    
!!
!!    EXTERNAL
!!    --------
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!
!!    AUTHOR
!!    ------
!!      Valery Masson             * Meteo-France *
!!
!!    MODIFICATIONS
!!    -------------
!!     Original 11/2003
!!
!! --------------------------------------------------------------------------
!       
!*      0. DECLARATIONS
!          ------------
!
USE MODD_PARAMETERS, ONLY : XUNDEF
USE MODD_DIAG_IN_RUN
!
IMPLICIT NONE
!
!
!*      0.1  declarations of arguments
!
!-------------------------------------------------------------------------------
!
DEALLOCATE(XCURRENT_RN    )! net radiation
DEALLOCATE(XCURRENT_H     )! sensible heat flux
DEALLOCATE(XCURRENT_LE    )! latent heat flux
DEALLOCATE(XCURRENT_LEI   )! Solid latent heat flux
DEALLOCATE(XCURRENT_GFLUX )! ground flux
DEALLOCATE(XCURRENT_LW    )! incoming longwave at the surface
DEALLOCATE(XCURRENT_SW    )! incoming Shortwave at the surface
DEALLOCATE(XCURRENT_T2M   )! temperature at 2m
DEALLOCATE(XCURRENT_Q2M   )! humidity at 2m
DEALLOCATE(XCURRENT_HU2M  )! humidity at 2m
DEALLOCATE(XCURRENT_ZON10M)! zonal wind at 10m
DEALLOCATE(XCURRENT_MER10M)! meridian wind at 10m
DEALLOCATE(XCURRENT_DSTAOD)! dust aerosol optical depth
DEALLOCATE(XCURRENT_SFCO2   ) ! CO2 Surface flux
DEALLOCATE(XCURRENT_TKE_DISS) ! Tke dissipation rate
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE END_DIAG_IN_RUN

!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!!
!!    #####################
      MODULE MODN_STATION_n
!!    #####################
!!
!!*** *MODN_STATION*
!!
!!    PURPOSE
!!    -------
!       Namelist to define the stations 
!!
!!**  AUTHOR
!!    ------
!!    E. Jézéquel                   *CNRM & IFPEN*
!
!!    MODIFICATIONS
!!    -------------
!!    Original 10/03/20
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
USE MODD_STATION_n
USE MODD_ALLSTATION_n, ONLY:&
        NNUMB_STAT_n    =>NNUMB_STAT    ,&
        XSTEP_STAT_n    =>XSTEP_STAT    ,&
        XX_STAT_n       =>XX_STAT       ,&
        XY_STAT_n       =>XY_STAT       ,&
        XLAT_STAT_n     =>XLAT_STAT     ,&
        XLON_STAT_n     =>XLON_STAT     ,&
        XZ_STAT_n       =>XZ_STAT       ,&
        CNAME_STAT_n    =>CNAME_STAT    ,&
        CTYPE_STAT_n    =>CTYPE_STAT    ,&
        CFILE_STAT_n    =>CFILE_STAT    ,&
        LDIAG_RESULTS_n =>LDIAG_RESULTS 
!!
!-----------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!        -----------------
IMPLICIT NONE
INTEGER                          ,SAVE:: NNUMB_STAT
REAL                             ,SAVE:: XSTEP_STAT
REAL, DIMENSION(100)             ,SAVE:: XX_STAT, XY_STAT, XZ_STAT, XLAT_STAT, XLON_STAT
CHARACTER (LEN=7), DIMENSION(100),SAVE:: CNAME_STAT, CTYPE_STAT
CHARACTER (LEN=20)               ,SAVE:: CFILE_STAT              !filename
LOGICAL                          ,SAVE:: LDIAG_RESULTS

NAMELIST /NAM_STATIONn/  &
     NNUMB_STAT, XSTEP_STAT, &
     XX_STAT,XY_STAT,XZ_STAT,&
     XLON_STAT,XLAT_STAT,&
     CNAME_STAT,CTYPE_STAT,&
     CFILE_STAT,LDIAG_RESULTS
     
!
CONTAINS
!
SUBROUTINE INIT_NAM_STATIONn
  NNUMB_STAT   = NNUMB_STAT_n
  XSTEP_STAT   = XSTEP_STAT_n
  XX_STAT      = XX_STAT_n
  XY_STAT      = XY_STAT_n  
  XLAT_STAT    = XLAT_STAT_n
  XLON_STAT    = XLON_STAT_n
  XZ_STAT      = XZ_STAT_n
  CNAME_STAT   = CNAME_STAT_n
  CTYPE_STAT   = CTYPE_STAT_n
  CFILE_STAT   = CFILE_STAT_n
  LDIAG_RESULTS= LDIAG_RESULTS_n
END SUBROUTINE INIT_NAM_STATIONn

SUBROUTINE UPDATE_NAM_STATIONn
  NNUMB_STAT_n   = NNUMB_STAT
  XSTEP_STAT_n   = XSTEP_STAT
  XX_STAT_n      = XX_STAT
  XY_STAT_n      = XY_STAT
  XLAT_STAT_n    = XLAT_STAT
  XLON_STAT_n    = XLON_STAT
  XZ_STAT_n      = XZ_STAT
  CNAME_STAT_n   = CNAME_STAT
  CTYPE_STAT_n   = CTYPE_STAT
  CFILE_STAT_n   = CFILE_STAT
  LDIAG_RESULTS_n= LDIAG_RESULTS
END SUBROUTINE UPDATE_NAM_STATIONn
END MODULE MODN_STATION_n
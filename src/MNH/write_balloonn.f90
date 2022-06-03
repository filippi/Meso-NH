!MNH_LIC Copyright 2001-2022 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ###########################
      MODULE MODI_WRITE_BALLOON_n
!     ###########################
!
INTERFACE
!
SUBROUTINE WRITE_BALLOON_n(TPFILE)
USE MODD_IO, ONLY: TFILEDATA
!
IMPLICIT NONE
!
TYPE(TFILEDATA),   INTENT(IN) :: TPFILE ! File characteristics
!
END SUBROUTINE WRITE_BALLOON_n
!
END INTERFACE
!
END MODULE MODI_WRITE_BALLOON_n
!
!
!     ###################################
      SUBROUTINE WRITE_BALLOON_n(TPFILE)
!     ###################################
!
!!****  *WRITE_BALLOON_n* - routine to write balloon records in a LFIFM file
!!
!!    PURPOSE
!!    -------
!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!      FMWRIT     : FM-routine to write a record
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_AIRCRAFT_BALLOON_n : contains balloon and aircraft variables
!!      Module MODD_GRID_n : contains spatial grid variables
!!      Module MODD_LUNIT_n   : contains logical unit variables
!!
!!    REFERENCE
!!    ---------
!!
!!
!!    AUTHOR
!!    ------
!!  	G.Jaubert   *Meteo France* 
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    06/06/01 
!  P. Wautelet 05/2016-04/2018: new data structures and calls for I/O
!  P. Wautelet    06/2022: reorganize flyers
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_AIRCRAFT_BALLOON
USE MODD_GRID, ONLY: XLONORI, XLATORI
USE MODD_IO,   ONLY: TFILEDATA
USE MODD_LUNIT_n
!
USE MODE_GRIDPROJ
!
IMPLICIT NONE
!
!*       0.1   Declarations of arguments
!
TYPE(TFILEDATA),   INTENT(IN) :: TPFILE ! File characteristics
!
!*       0.2   Declarations of local variables
!
!
INTEGER :: JI

DO JI = 1, NBALLOONS
  IF ( TBALLOONS(JI)%LFLY ) CALL WRITE_LFI_BALLOON( TBALLOONS(JI) )
END DO
!
!
CONTAINS
!
!-------------------------------------------------------------------------------
!-------------------------------------------------------------------------------
SUBROUTINE WRITE_LFI_BALLOON(TPFLYER)
!
use modd_field,          only: tfieldmetadata, TYPEREAL
USE MODE_IO_FIELD_WRITE, only: IO_Field_write
!
TYPE(TBALLOONDATA), INTENT(IN) :: TPFLYER
!
!
!*       0.2   Declarations of local variables
!
REAL                 :: ZLAT          ! latitude of the balloon
REAL                 :: ZLON          ! longitude of the balloon
TYPE(TFIELDMETADATA) :: TZFIELD
!
!
CALL SM_LATLON(XLATORI,XLONORI,  &
     TPFLYER%XX_CUR,TPFLYER%XY_CUR,ZLAT,ZLON)
!
!
TZFIELD = TFIELDMETADATA(                  &
  CMNHNAME   = TRIM(TPFLYER%CTITLE)//'LAT', &
  CSTDNAME   = '',                         &
  CLONGNAME  = TRIM(TPFLYER%CTITLE)//'LAT', &
  CUNITS     = 'degree',                   &
  CDIR       = '--',                       &
  CCOMMENT   = '',                         &
  NGRID      = 0,                          &
  NTYPE      = TYPEREAL,                   &
  NDIMS      = 0,                          &
  LTIMEDEP   = .TRUE.                      )
CALL IO_Field_write(TPFILE,TZFIELD,ZLAT)
!
TZFIELD = TFIELDMETADATA(                  &
  CMNHNAME   = TRIM(TPFLYER%CTITLE)//'LON', &
  CSTDNAME   = '',                         &
  CLONGNAME  = TRIM(TPFLYER%CTITLE)//'LON', &
  CUNITS     = 'degree',                   &
  CDIR       = '--',                       &
  CCOMMENT   = '',                         &
  NGRID      = 0,                          &
  NTYPE      = TYPEREAL,                   &
  NDIMS      = 0,                          &
  LTIMEDEP   = .TRUE.                      )
CALL IO_Field_write(TPFILE,TZFIELD,ZLON)
!
TZFIELD = TFIELDMETADATA(                  &
  CMNHNAME   = TRIM(TPFLYER%CTITLE)//'ALT', &
  CSTDNAME   = '',                         &
  CLONGNAME  = TRIM(TPFLYER%CTITLE)//'ALT', &
  CUNITS     = 'm',                        &
  CDIR       = '--',                       &
  CCOMMENT   = '',                         &
  NGRID      = 0,                          &
  NTYPE      = TYPEREAL,                   &
  NDIMS      = 0,                          &
  LTIMEDEP   = .TRUE.                      )
CALL IO_Field_write(TPFILE,TZFIELD,TPFLYER%XZ_CUR)
!
TZFIELD = TFIELDMETADATA(                      &
  CMNHNAME   = TRIM(TPFLYER%CTITLE)//'WASCENT', &
  CSTDNAME   = '',                             &
  CLONGNAME  = TRIM(TPFLYER%CTITLE)//'WASCENT', &
  CUNITS     = 'm s-1',                        &
  CDIR       = '--',                           &
  CCOMMENT   = '',                             &
  NGRID      = 0,                              &
  NTYPE      = TYPEREAL,                       &
  NDIMS      = 0,                              &
  LTIMEDEP   = .TRUE.                          )
CALL IO_Field_write(TPFILE,TZFIELD,TPFLYER%XWASCENT)
!
TZFIELD = TFIELDMETADATA(                  &
  CMNHNAME   = TRIM(TPFLYER%CTITLE)//'RHO', &
  CSTDNAME   = '',                         &
  CLONGNAME  = TRIM(TPFLYER%CTITLE)//'RHO', &
  CUNITS     = 'kg m-3',                   &
  CDIR       = '--',                       &
  CCOMMENT   = '',                         &
  NGRID      = 0,                          &
  NTYPE      = TYPEREAL,                   &
  NDIMS      = 0,                          &
  LTIMEDEP   = .TRUE.                      )
CALL IO_Field_write(TPFILE,TZFIELD,TPFLYER%XRHO)
!
!
!
END SUBROUTINE WRITE_LFI_BALLOON
!-------------------------------------------------------------------------------
!
!
END SUBROUTINE WRITE_BALLOON_n

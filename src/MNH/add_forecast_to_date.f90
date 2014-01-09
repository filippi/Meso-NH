!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 prep_real 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     ################################
      MODULE MODI_ADD_FORECAST_TO_DATE
!     ################################
INTERFACE
      SUBROUTINE ADD_FORECAST_TO_DATE(KYEAR,KMONTH,KDAY,PSEC)
!
INTEGER, INTENT(INOUT) :: KYEAR  ! year of date
INTEGER, INTENT(INOUT) :: KMONTH ! month of date
INTEGER, INTENT(INOUT) :: KDAY   ! day of date
REAL,    INTENT(INOUT) :: PSEC   ! number of seconds since date at 00 UTC
!
END SUBROUTINE ADD_FORECAST_TO_DATE
END INTERFACE
END MODULE MODI_ADD_FORECAST_TO_DATE
!
!     #######################################################
      SUBROUTINE ADD_FORECAST_TO_DATE(KYEAR,KMONTH,KDAY,PSEC)
!     #######################################################
!
!!****  *ADD_FORECAST_TO_DATE* - finds the current date and hour of a forecast
!!
!!    PURPOSE
!!    -------
!!
!!                                WARNING
!!
!!      -----> Only correct for dates between 19900301 and 21000228   <-----
!!
!!  The correct test should be:
!! IF( ((MOD(KYEAR,4)==0).AND.(MOD(KYEAR,100)/=0)) .OR. (MOD(KYEAR,400)==0))THEN
!!
!!**  METHOD
!!    ------
!!
!!      A recursive method is used, adding one day ofter the other.
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
!!    Book 2
!!
!!    AUTHOR
!!    ------
!!	
!     V.Masson  Meteo-France
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    01/09/95
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
IMPLICIT NONE
!
!*       0.1   Declaration of arguments
!              ------------------------
INTEGER, INTENT(INOUT) :: KYEAR  ! year of date
INTEGER, INTENT(INOUT) :: KMONTH ! month of date
INTEGER, INTENT(INOUT) :: KDAY   ! day of date
REAL,    INTENT(INOUT) :: PSEC   ! number of seconds since date at 00 UTC
!
!*       0.2   Declaration of local variables
!              ------------------------------
!
INTEGER :: IDAYS ! number of days in KMONTH
!-------------------------------------------------------------------------------
!
!*       1.    Return condition: less than one day to add
!              ------------------------------------------
!
DO 
  IF (86400.-PSEC > 1.E-6) EXIT
!
!-------------------------------------------------------------------------------
!
!*       2.    Adding one day
!              --------------
!
  PSEC=PSEC-86400.
!
!*       2.1   Number of days in a month
!              -------------------------
!
  SELECT CASE (KMONTH)
    CASE(4,6,9,11)
      IDAYS=30
    CASE(1,3,5,7:8,10,12)
      IDAYS=31
    CASE(2)
      IF (MOD(KYEAR,4)==0) THEN 
        IDAYS=29
      ELSE
        IDAYS=28
      ENDIF
  END SELECT
!
!*       2.2   Last day of the month
!              ---------------------
!
  IF (KDAY==IDAYS) THEN
    IF (KMONTH==12) THEN
      KDAY=1
      KMONTH=1
      KYEAR=KYEAR+1
    ELSE
      KDAY=1   
      KMONTH=KMONTH+1
    ENDIF
! 
!*       2.3   Other days
!              ----------
  ELSE
    KDAY=KDAY+1
  ENDIF
!
!-------------------------------------------------------------------------------
!
!*       3.    Recursive call
!              --------------
!
ENDDO
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE ADD_FORECAST_TO_DATE

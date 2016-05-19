!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 chimie 2006/05/18 13:07:25
!-----------------------------------------------------------------
!!    #########################
      MODULE MODI_CH_INIT_METEO
!!    #########################
!!
!
INTERFACE
SUBROUTINE CH_INIT_METEO(TPM)
USE MODD_CH_M9_n,      ONLY: METEOTRANSTYPE
TYPE(METEOTRANSTYPE), INTENT(OUT) :: TPM  ! the meteo variables
END SUBROUTINE CH_INIT_METEO
END INTERFACE
END MODULE MODI_CH_INIT_METEO
!!
!!    ############################# 
      SUBROUTINE CH_INIT_METEO(TPM)
!!    #############################
!!
!!***  *CH_INIT_METEO*
!!
!!    PURPOSE
!!    -------
!!    Prepare update of meteorological data, such as temperature, pressure
!!    and water vapor mixing ratio from file and read first data set.
!!
!!**  METHOD
!!    ------
!!    The default name of the meteo file is METEO.UPDATE, and may
!!    be changed in the namelist file CHCONTROL.nam. 
!!    The format of the data in this file has to be arranged as folows:
!!    line 1:  general comment
!!    line 2:  number of meteo variables NMETEOVARS
!!    next NMETEOVARS lines: identifier of each variable, such as T, P etc.
!!    next line: NMETEOVARS values for the XMETEOVAR array
!!    next line: time of next update XTNEXTMETEO
!!      ...
!!    last line: 1E20 (meaning that no further update will be requested)
!!
!!    AUTHOR
!!    ------
!!    K. Suhre
!!
!!    MODIFICATIONS
!!    -------------
!!    Original 21/04/95
!!    27/07/96 (K. Suhre) restructured
!!    01/04/99 (K. Suhre) add optional reading from the namelistfile
!!    20/04/99 (K. Suhre) read all meteodata in one go (this allows
!!                        to interpolate between different forcings)
!!    01/12/03 (Gazen)   change Chemical scheme interface
!!
!!
!!    EXTERNAL
!!    --------
USE MODI_CH_OPEN_INPUT
USE MODE_IO_ll
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
USE MODD_CH_MODEL0D, ONLY: CMETEOFILE, NMETEOIO, NVERB
USE MODD_CH_M9_n,    ONLY: NMETEOVARS, METEOTRANSTYPE
USE MODD_CH_METEO,   ONLY: NMETEORECS, XMETEOTIME, XMETEODATA
!!
!------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!        -----------------
IMPLICIT NONE
!
!*       0.1  declaration of arguments
!
TYPE(METEOTRANSTYPE), INTENT(OUT) :: TPM  ! the meteo variables
!
!*       0.2  declaration of local variables
!
INTEGER      :: JI, JJ      ! loop control
CHARACTER*80 :: YCOMMENT    ! comment line in meteo update file
INTEGER      :: IMETEOVARS  ! number of meteovars to be read from file and
			    ! checked against NMETEOVARS
INTEGER      :: IFAIL       ! return code from CLOSE_LL
!
!------------------------------------------------------------------------------
!
!*    EXECUTABLE STATEMENTS
!     ---------------------
!
CALL CH_OPEN_INPUT(CMETEOFILE, "METEOVAR", NMETEOIO, 6, NVERB)
!
! read number of variables NMETEOVARS
READ(NMETEOIO,*) IMETEOVARS
!
! read number of records
READ(NMETEOIO,*) NMETEORECS
!
! check if number of meteovars in file corresponds to what the CCS expects
IF (IMETEOVARS .NE. NMETEOVARS) THEN
  PRINT *, "CH_INIT_METEO ERROR: number of meteo variables in file does not"
  PRINT *, "                     correspond to the number expected by the CCS:"
  PRINT *, "                     IMETEOVARS read:     ", IMETEOVARS
  PRINT *, "                     NMETEOVARS expected: ", NMETEOVARS
  PRINT *, "The program will be stopped now!"
  ! callabortstop
  CALL ABORT
  STOP 1
END IF

! read names for TPM%CMETEOVAR
DO JI = 1, NMETEOVARS
  READ(NMETEOIO,*) TPM%CMETEOVAR(JI)
END DO
!
! print names of meteo variables
IF (NVERB >= 5) THEN
  PRINT *, 'CH_INIT_METEO: the following ', NMETEOVARS, &
	   ' meteo variables will be updated:'
  DO JI = 1, NMETEOVARS
    PRINT *, TPM%CMETEOVAR(JI)
  END DO
  PRINT *, NMETEORECS, ' records will be read ...'
END IF
!
! allocate arrays and read meteo data
!
ALLOCATE(XMETEOTIME(NMETEORECS))
ALLOCATE(XMETEODATA(NMETEOVARS,NMETEORECS))
!
DO JJ = 1, NMETEORECS
  READ(NMETEOIO,*) XMETEOTIME(JJ)
  READ(NMETEOIO,*) (XMETEODATA(JI,JJ), JI = 1, NMETEOVARS)
END DO
!
! close file
!
CALL CLOSE_LL(CMETEOFILE, IOSTAT=IFAIL)
!
END SUBROUTINE CH_INIT_METEO

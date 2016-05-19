!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! ECMWF_RAD2 2003/02/19 13:36:36
!-----------------------------------------------------------------
MODULE PARCMA


#include "tsmbkind.h"

IMPLICIT NONE

SAVE

!*    PARCMA - CMA VARIOUS PARAMETERS

!        D. VASILJEVIC    ECMWF    19/09/94


!     NAME                    MEANING
!     ----                    -------

!     CMA ARRAY/FILE PARAMETERS:
!     ---------------------

!     JPMXGICL    MAX. LEN. OF "GLOBAL" INTEGER CMA ARRAY
!     JPMXGRCL    MAX. LEN. OF "GLOBAL" REAL CMA ARRAY
!     JPMXICRL    MAX. LEN. OF INPUT CMA REPORT
!     JPMXICHL    MAX. LEN. OF INPUT CMA REPORT HEADER
!     JPMXICBL    MAX. LEN. OF INPUT CMA REPORT BODY ENTRY
!     JPMXICDL    MAX. LEN. OF INPUT CMA  DDR
!     JPMXOCRL    MAX. LEN. OF OUTPUT CMA REPORT
!     JPMXOCHL    MAX. LEN. OF OUTPUT CMA REPORT HEADER
!     JPMXOCBL    MAX. LEN. OF OUTPUT CMA REPORT BODY ENTRY
!     JPMXOCDL    MAX. LEN. OF OUTPUT CMA  DDR
!     JPMXDEPL    MAX. LEN. OF DEPARTURE LIST

INTEGER_M :: JPMXGICL
INTEGER_M :: JPMXGRCL
INTEGER_M :: JPMXICRL
INTEGER_M :: JPMXICHL
INTEGER_M :: JPMXICBL
INTEGER_M :: JPMXICDL
INTEGER_M :: JPMXOCRL
INTEGER_M :: JPMXOCHL
INTEGER_M :: JPMXOCBL
INTEGER_M :: JPMXOCDL
INTEGER_M :: JPMXDEPL
PARAMETER (JPMXGICL=1)
PARAMETER (JPMXGRCL=2000000)
PARAMETER (JPMXICRL=164811)
PARAMETER (JPMXICHL=581)
PARAMETER (JPMXICBL=72)
PARAMETER (JPMXICDL=3072)
PARAMETER (JPMXOCRL=164811)
PARAMETER (JPMXOCHL=581)
PARAMETER (JPMXOCBL=72)
PARAMETER (JPMXOCDL=3072)
PARAMETER (JPMXDEPL=319)

!-----------------------------------------------------------------------


!     CMA EVENTS, FLAGS, CODES ETC. PARAMETERS:
!     -----------------------------------------

!     JPMXLID     MAX. NO. OF LEVEL ID CODES
!     JPMXPCD     MAX. NO. OF PRESSURE CODES
!     JPMXRE1     MAX. NO. REPORT (PART 1) EVENTS
!     JPMXRE2     MAX. NO. REPORT (PART 2) EVENTS
!     JPMXDE1     MAX. NO. DATUM (PART 1) EVENTS
!     JPMXDE2     MAX. NO. DATUM (PART 2) EVENTS
!     JPMXRBLE    MAX. NO. REPORT BLACKLIST EVENTS
!     JPMXDBLE    MAX. NO. DATUM BLACKLIST EVENTS
!     JPMXRDF     MAX. NO. RDB REPORT FLAGS
!     JPMXDDF     MAX. NO. RDB PRESSURE/VARIABLE FLAGS
!     JPMXADF     MAX. NO. ANALYSIS VARIABLE FLAGS
!     JPMXSBI1    MAX. NO. OF SATOB I1 CODES
!     JPMXSBI2    MAX. NO. OF SATOB I2I2 CODES
!     JPMXSMI2    MAX. NO. OF SATEM I2 CODES
!     JPMXSMV     MAX. NO. OF SATEM V CODES
!     JPMXSMW     MAX. NO. OF SATEM W CODES
!     JPMXSMX     MAX. NO. OF SATEM X CODES
!     JPMXSMY     MAX. NO. OF SATEM Y CODES
!     JPMXSMA     MAX. NO. OF SATEM A CODES
!     JPMXSMB     MAX. NO. OF SATEM B CODES
!     JPMXSMC     MAX. NO. OF SATEM C CODES

INTEGER_M :: JPMXLID
INTEGER_M :: JPMXPCD
INTEGER_M :: JPMXRE1
INTEGER_M :: JPMXRE2
INTEGER_M :: JPMXDE1
INTEGER_M :: JPMXDE2
INTEGER_M :: JPMXRBLE
INTEGER_M :: JPMXDBLE
INTEGER_M :: JPMXRDF
INTEGER_M :: JPMXDDF
INTEGER_M :: JPMXADF
INTEGER_M :: JPMXSBI2
INTEGER_M :: JPMXSMI2
INTEGER_M :: JPMXSMV
INTEGER_M :: JPMXSMW
INTEGER_M :: JPMXSMX
INTEGER_M :: JPMXSMY
INTEGER_M :: JPMXSMA
INTEGER_M :: JPMXSMB
INTEGER_M :: JPMXSMC
INTEGER_M :: JPMXSBI1
PARAMETER (JPMXLID=9)
PARAMETER (JPMXPCD=13)
PARAMETER (JPMXRE1=30)
PARAMETER (JPMXRE2=30)
PARAMETER (JPMXDE1=30)
PARAMETER (JPMXDE2=30)
PARAMETER (JPMXRBLE=30)
PARAMETER (JPMXDBLE=30)
PARAMETER (JPMXRDF=5)
PARAMETER (JPMXDDF=7)
PARAMETER (JPMXADF=7)
PARAMETER (JPMXSBI2=5)
PARAMETER (JPMXSMI2=4)
PARAMETER (JPMXSMV=3)
PARAMETER (JPMXSMW=3)
PARAMETER (JPMXSMX=5)
PARAMETER (JPMXSMY=7)
PARAMETER (JPMXSMA=3)
PARAMETER (JPMXSMB=3)
PARAMETER (JPMXSMC=3)
PARAMETER (JPMXSBI1=5)

!-----------------------------------------------------------------------

!     CMA NO. OF OBS./CODE TYPES, UPDATES, ADD. DEP. ETC. PARAMETERS:
!     --------------------------------------------------------------

!     JPMXOTP     MAX. NO. OF OBS. TYPES
!     JPMXOCT     MAX. NO. OF OBS. CODE TYPES
!     JPMXUP      MAX. NO. UPDATES
!     JPMXAD      MAX. NO. OF ADDITIONAL DEPARTURES
!     JPMXVAR     MAX. NO. OF CMA VARIABLES
!     JPMXTOCH    MAX. NO. TOVS CHANNELS
!     JPMXSSCH    MAX. NO. SSMI CHANNELS
!     JPMXTRCH    MAX. NO. TRMM CHANNELS
!     JPXSFPTS    MAX. NO. OF SIM. OBS. FILES PER 6HR TIME SLOT
!     JPXTSL      MAX. NO. OF OUTPUT/INPUT TIME SLOTS
!     JPXCMA      MAX. NO. OF OUTPUT/INPUT CMA FILES
!     JPXSATS     MAX. NO. OF SATELLITES
!     JPXSENSOR   MAX. NO. OF SENSOR TYPES FOR 1C RADIANCES
!     JPSMETSND   SENSOR INDICATOR FOR METEOSAT SOUNDER DATA

INTEGER_M :: JPMXOTP
INTEGER_M :: JPMXOCT
INTEGER_M :: JPMXUP
INTEGER_M :: JPMXAD
INTEGER_M :: JPMXVAR
INTEGER_M :: JPMXTOCH
INTEGER_M :: JPMXSSCH
INTEGER_M :: JPMXTRCH
INTEGER_M :: JPXTSL
INTEGER_M :: JPXCMA
INTEGER_M :: JPXSATS
INTEGER_M :: JPXSENSOR
INTEGER_M :: JPSMETSND
PARAMETER (JPMXOTP=10)
PARAMETER (JPMXOCT=11)
PARAMETER (JPMXUP=10)
PARAMETER (JPMXAD=20)
PARAMETER (JPMXVAR=70)
PARAMETER (JPMXTOCH=27)
PARAMETER (JPMXSSCH=7)
PARAMETER (JPMXTRCH=9)
PARAMETER (JPXTSL=25)
PARAMETER (JPXCMA=1)
PARAMETER (JPXSATS=6)
PARAMETER (JPXSENSOR=30)
PARAMETER (JPSMETSND=20)

!-----------------------------------------------------------------------

END MODULE PARCMA

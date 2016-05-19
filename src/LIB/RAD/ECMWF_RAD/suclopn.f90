!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! ECMWF_RAD2_OLD2NEW 2003/03/12 14:44:50
!-----------------------------------------------------------------
SUBROUTINE SUCLOPN (KTSW,KSW , KLEV)

!**** *SUCLOP*  - INITIALIZE COMMON YOECLOP

!     PURPOSE.
!     --------
!           INITIALIZE YOMCLOP, WITH CLOUD OPTICAL PARAMETERS

!**   INTERFACE.
!     ----------
!        *CALL*  SUCLOPN
!        FROM *SUECRAD*

!        EXPLICIT ARGUMENTS :
!        --------------------
!        NONE

!        IMPLICIT ARGUMENTS :
!        --------------------
!        COMMON YOECLOP

!     METHOD.
!     -------
!        SEE DOCUMENTATION

!     EXTERNALS.
!     ----------
!        NONE

!     REFERENCE.
!     ----------
!        ECMWF RESEARCH DEPARTMENT DOCUMENTATION OF THE
!     "INTEGRATED FORECASTING SYSTEM"

!     Fouquart, 1987: NATO ASI,  223-284
!     A. Slingo, 1989: J. Atmos. Sci., 46, 1419-1427
!     Ebert and Curry, 1992: J. Geophys. Res., 97D, 3831-3836
!     Sun and Shine, 1994: Quart. J. Roy. Meteor. Soc., 120, 111-138
!     Fu and Liou, 1993: J. Atmos. Sci., 50, 2008-2025
!     Fu, 1996: J. Climate, 9, 2058-2082
!     Fu et al., 1998: J. Climate, 11, 2223-2237

!     AUTHOR.
!     -------
!        JEAN-JACQUES MORCRETTE  *ECMWF*

!     MODIFICATIONS.
!     --------------
!        ORIGINAL : 92-02-29
!        97-04-16  JJ Morcrette  2 and 4 spectral intervals
!        00-10-25  JJMorcrette   6 spectral intervals
!        01-01-16  JJ Morcrette  ice cloud from Fu 96, Fu et al 98

!     ------------------------------------------------------------------

#include "tsmbkind.h"

USE YOESW    , ONLY : RYFWCA   ,RYFWCB   ,RYFWCC   ,RYFWCD   ,&
            &RYFWCE   ,RYFWCF   ,REBCUA   ,REBCUB   ,REBCUC   ,&
            &REBCUD   ,REBCUE   ,REBCUF   ,REBCUG   ,REBCUH   ,&
            &REBCUI   ,REBCUJ   ,RASWCA   ,RASWCB   ,RASWCC   ,&
            &RASWCD   ,RASWCE   ,RASWCF   ,RSUSHE   ,RSUSHF   ,&
            &RSUSHH   ,RSUSHK   ,RSUSHA   ,RSUSHG   ,RSUSHFA  ,&
            &RSUSHC   ,RSUSHD   ,REFFIA   ,REFFIB   ,RHSAVI   ,&
            &RFUAA0   ,RFUAA1   ,RFUBB0   ,RFUBB1   ,RFUBB2   ,&
            &RFUBB3   ,RFUCC0   ,RFUCC1   ,RFUCC2   ,RFUCC3   ,&
            &RFUETA   ,RFULIO   ,RFLAA0   ,RFLAA1   ,RFLBB0   ,&
            &RFLBB1   ,RFLBB2   ,RFLBB3   ,RFLCC0   ,RFLCC1   ,&
            &RFLCC2   ,RFLCC3   ,RFLDD0   ,RFLDD1   ,RFLDD2   ,&
            &RFLDD3   ,RLINLI   ,RTIW     ,RRIW
USE YOERAD   , ONLY : RAOVLP   ,RBOVLP

IMPLICIT NONE


!     DUMMY INTEGER SCALARS
INTEGER_M :: KSW
INTEGER_M :: KTSW
INTEGER_M :: KLEV
INTEGER_M :: JC, JNU




!     -----------------------------------------------------------------
REAL_B :: ZEBCUA2(2)  ,ZEBCUB2(2)  ,ZEBCUC2(2)  ,ZEBCUD2(2)&
  &,  ZEBCUE2(2)  ,ZEBCUF2(2)  ,ZYFWCA2(2)  ,ZYFWCB2(2)&
  &,  ZYFWCC2(2)  ,ZYFWCD2(2)  ,ZYFWCE2(2)  ,ZYFWCF2(2)&
  &,  ZASWCA2(2)  ,ZASWCB2(2)  ,ZASWCC2(2)  ,ZASWCD2(2)&
  &,  ZASWCE2(2)  ,ZASWCF2(2)  ,ZSUSHE2(2)  ,ZSUSHF2(2)&
  &,  ZSUSHH2(2)  ,ZSUSHK2(2)  ,ZSUSHA2(2)  ,ZSUSHG2(2)&
  &,  ZFLAA02(2)  ,ZFLAA12(2)  ,ZFLBB02(2)  ,ZFLBB12(2)&
  &,  ZFLBB22(2)  ,ZFLBB32(2)  ,ZFLCC02(2)  ,ZFLCC12(2)&
  &,  ZFLCC22(2)  ,ZFLCC32(2)  ,ZFLDD02(2)  ,ZFLDD12(2)&
  &,  ZFLDD22(2)  ,ZFLDD32(2)&
  &,  ZFUAA02(2)  ,ZFUAA12(2)  ,ZFUBB02(2)  ,ZFUBB12(2)&
  &,  ZFUBB22(2)  ,ZFUBB32(2)  ,ZFUCC02(2)  ,ZFUCC12(2)&
  &,  ZFUCC22(2)  ,ZFUCC32(2)  ,ZFUDD02(2)  ,ZFUDD12(2)&
  &,  ZFUDD22(2)  ,ZFUDD32(2)

REAL_B :: ZEBCUA4(4)  ,ZEBCUB4(4)  ,ZEBCUC4(4)  ,ZEBCUD4(4)&
  &,  ZEBCUE4(4)  ,ZEBCUF4(4)  ,ZYFWCA4(4)  ,ZYFWCB4(4)&
  &,  ZYFWCC4(4)  ,ZYFWCD4(4)  ,ZYFWCE4(4)  ,ZYFWCF4(4)&
  &,  ZASWCA4(4)  ,ZASWCB4(4)  ,ZASWCC4(4)  ,ZASWCD4(4)&
  &,  ZASWCE4(4)  ,ZASWCF4(4)  ,ZSUSHE4(4)  ,ZSUSHF4(4)&
  &,  ZSUSHH4(4)  ,ZSUSHK4(4)  ,ZSUSHA4(4)  ,ZSUSHG4(4)&
  &,  ZFLAA04(4)  ,ZFLAA14(4)  ,ZFLBB04(4)  ,ZFLBB14(4)&
  &,  ZFLBB24(4)  ,ZFLBB34(4)  ,ZFLCC04(4)  ,ZFLCC14(4)&
  &,  ZFLCC24(4)  ,ZFLCC34(4)  ,ZFLDD04(4)  ,ZFLDD14(4)&
  &,  ZFLDD24(4)  ,ZFLDD34(4)&
  &,  ZFUAA04(4)  ,ZFUAA14(4)  ,ZFUBB04(4)  ,ZFUBB14(4)&
  &,  ZFUBB24(4)  ,ZFUBB34(4)  ,ZFUCC04(4)  ,ZFUCC14(4)&
  &,  ZFUCC24(4)  ,ZFUCC34(4)  ,ZFUDD04(4)  ,ZFUDD14(4)&
  &,  ZFUDD24(4)  ,ZFUDD34(4)

REAL_B :: ZEBCUA6(6)  ,ZEBCUB6(6)  ,ZEBCUC6(6)  ,ZEBCUD6(6)&
  &,  ZEBCUE6(6)  ,ZEBCUF6(6)  ,ZYFWCA6(6)  ,ZYFWCB6(6)&
  &,  ZYFWCC6(6)  ,ZYFWCD6(6)  ,ZYFWCE6(6)  ,ZYFWCF6(6)&
  &,  ZASWCA6(6)  ,ZASWCB6(6)  ,ZASWCC6(6)  ,ZASWCD6(6)&
  &,  ZASWCE6(6)  ,ZASWCF6(6)  ,ZSUSHE6(6)  ,ZSUSHF6(6)&
  &,  ZSUSHH6(6)  ,ZSUSHK6(6)  ,ZSUSHA6(6)  ,ZSUSHG6(6)&
  &,  ZFLAA06(6)  ,ZFLAA16(6)  ,ZFLBB06(6)  ,ZFLBB16(6)&
  &,  ZFLBB26(6)  ,ZFLBB36(6)  ,ZFLCC06(6)  ,ZFLCC16(6)&
  &,  ZFLCC26(6)  ,ZFLCC36(6)  ,ZFLDD06(6)  ,ZFLDD16(6)&
  &,  ZFLDD26(6)  ,ZFLDD36(6)&
  &,  ZFUAA06(6)  ,ZFUAA16(6)  ,ZFUBB06(6)  ,ZFUBB16(6)&
  &,  ZFUBB26(6)  ,ZFUBB36(6)  ,ZFUCC06(6)  ,ZFUCC16(6)&
  &,  ZFUCC26(6)  ,ZFUCC36(6)  ,ZFUDD06(6)  ,ZFUDD16(6)&
  &,  ZFUDD26(6)  ,ZFUDD36(6)

  
REAL_B :: ZAOVLP(3), ZBOVLP(3)  

!     -----------------------------------------------------------------

!*          1.    SHORTWAVE CLOUD OPTICAL PROPERTIES
!                 ----------------------------------

!     ------------------------------------------------------------------

!*          1.1   TWO SPECTRAL INTERVALS
!                 ----------------------

! SW : 0.25 - 0.68 - 4.00 microns

!* Ice cloud properties - crystal: adapted from Ebert and Curry, 1992

!  optical properties
ZEBCUA2 = (/ 3.448E-04_JPRB , 3.448E-04_JPRB /)
ZEBCUB2 = (/ 2.431_JPRB     , 2.431_JPRB     /)
ZEBCUC2 = (/ 0.00001_JPRB   , 0.024366_JPRB  /)
ZEBCUD2 = (/ _ZERO_         , 2.487E-04_JPRB /)
ZEBCUE2 = (/ 0.7661_JPRB    , 0.7866_JPRB    /)
ZEBCUF2 = (/ 5.851E-04_JPRB , 5.937E-04_JPRB /)

!  optical properties
!      ZEBCUA2 = (/ 3.448E-04 , 3.448E-04 /)
!      ZEBCUB2 = (/ 2.431     , 2.431     /)
!      ZEBCUC2 = (/ 0.00001   , 0.035589  /)
!      ZEBCUD2 = (/ 0.        , 2.757E-04 /)
!      ZEBCUE2 = (/ 0.7661    , 0.7921    /)
!      ZEBCUF2 = (/ 5.851E-04 , 5.893E-04 /)

!* Water cloud properties - from Fouquart (1987)

ZYFWCA2 = (/ _ZERO_         , _ZERO_         /)
ZYFWCB2 = (/ 1.5_JPRB       , 1.5_JPRB       /)
ZYFWCC2 = (/ 0.9999_JPRB    , 0.9988_JPRB    /)
ZYFWCD2 = (/ 5.000E-04_JPRB , 2.500E-03_JPRB /)
ZYFWCE2 = (/ _HALF_         , 0.05_JPRB      /)
ZYFWCF2 = (/ 0.865_JPRB     , 0.910_JPRB     /)

!* Water cloud properties - from Slingo (1989)

ZASWCA2 = (/ 2.817_JPRB     , 2.4584_JPRB    /)
ZASWCB2 = (/ 1.305_JPRB     , 1.3994_JPRB    /)
ZASWCC2 = (/-5.62E-08_JPRB  , 1.111E-02_JPRB /)
ZASWCD2 = (/ 1.63E-07_JPRB  , 8.613E-04_JPRB /)
ZASWCE2 = (/ 0.829_JPRB     , 0.7819_JPRB    /)
ZASWCF2 = (/ 2.482_JPRB     , 5.0150_JPRB    /)

!* Ice cloud properties - from Sun and Shine (1995)

ZSUSHE2 = (/ _ZERO_         , 8.6822_JPRB    /)
ZSUSHF2 = (/ _ZERO_         , 9.6277_JPRB    /)
ZSUSHH2 = (/ 0.8522_JPRB    , 0.8819_JPRB    /)
ZSUSHK2 = (/ 0.1620_JPRB    , 0.1630_JPRB    /)
ZSUSHA2 = (/ _ZERO_         , 23.204_JPRB    /)
ZSUSHG2 = (/ 0.3270_JPRB    , 0.4180_JPRB    /)

!* Ice cloud properties - from Fu and Liou (1993)

ZFLAA02 = (/-6.656E-3_JPRB  ,-6.656E-3_JPRB  /)
ZFLAA12 = (/ 3.686_JPRB     , 3.686_JPRB     /)
ZFLBB02 = (/ .10998E-5_JPRB , .21136E-1_JPRB /)
ZFLBB12 = (/-.26101E-7_JPRB , .39150E-3_JPRB /)
ZFLBB22 = (/ .18096E-8_JPRB ,-.20740E-6_JPRB /)
ZFLBB32 = (/-.47387E-11_JPRB,-.28829E-8_JPRB /)
ZFLCC02 = (/ .22110E+1_JPRB , .22498E+1_JPRB /)
ZFLCC12 = (/-.10398E-2_JPRB , .23656E-3_JPRB /)
ZFLCC22 = (/ .65199E-4_JPRB , .51948E-4_JPRB /) 
ZFLCC32 = (/-.34498E-6_JPRB ,-.29768E-6_JPRB /)
ZFLDD02 = (/ .12495_JPRB    , .11716_JPRB    /)
ZFLDD12 = (/-.43582E-3_JPRB ,-.45208E-3_JPRB /)
ZFLDD22 = (/ .14092E-4_JPRB , .12772E-4_JPRB /)
ZFLDD32 = (/-.69565E-7_JPRB ,-.62779E-7_JPRB /) 

!* Ice cloud properties - from Fu (1996)

!ZFUAA02 = (/-.291721E-04_JPRB ,
!ZFUAA12 = (/ .251925E+01_JPRB ,
!ZFUBB02 = (/ .135403E-06_JPRB ,
!ZFUBB12 = (/ .992822E-07_JPRB ,
!ZFUBB22 = (/-.738432E-10_JPRB ,
!ZFUBB32 = (/ .331119E-12_JPRB ,
!ZFUCC02 = (/ .748127E+00_JPRB ,
!ZFUCC12 = (/ .956845E-03_JPRB ,
!ZFUCC22 = (/-.111517E-05_JPRB ,
!ZFUCC32 = (/-.815573E-08_JPRB ,
!ZFUDD02 = (/ .115730E+00_JPRB ,
!ZFUDD12 = (/ .256481E-03_JPRB ,
!ZFUDD22 = (/ .191313E-05_JPRB ,
!ZFUDD32 = (/-.124603E-07_JPRB ,
!     ------------------------------------------------------------------

!*          1.2    FOUR SPECTRAL INTERVALS
!                  -----------------------

! SW : 4 spectral intervals (0.25 - 0.69 - 1.19 - 2.38 - 4.00)

!* Ice cloud properties - crystal: adapted from Ebert and Curry, 1992

!      ZEBCUA4 = (/ 3.448E-03 , 3.448E-03 , 3.448E-03 , 3.448E-03 /)
!      ZEBCUB4 = (/ 2.431     , 2.431     , 2.431     , 2.431     /)
!      ZEBCUC4 = (/ 0.00001   , 0.00011   , 0.01861   , 0.46658   /)
!      ZEBCUD4 = (/ 0.        , 1.405E-05 , 8.328E-4  , 2.050E-05 /)
!      ZEBCUE4 = (/ 0.7661    , 0.7730    , 0.7940    , 0.9595    /)
!      ZEBCUF4 = (/ 5.851E-04 , 5.665E-04 , 7.267E-04 , 1.076E-04 /)

ZEBCUA4 = (/ 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB /)
ZEBCUB4 = (/ 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     /)
ZEBCUC4 = (/ 0.00001_JPRB   , 0.00011_JPRB   , 0.0197796_JPRB , 0.46658_JPRB   /)
ZEBCUD4 = (/ _ZERO_         , 1.405E-05_JPRB , 7.95513E-4_JPRB, 2.050E-05_JPRB /)
ZEBCUE4 = (/ 0.7661_JPRB    , 0.7730_JPRB    , 0.795653_JPRB  , 0.9595_JPRB    /)
ZEBCUF4 = (/ 5.851E-04_JPRB , 5.665E-04_JPRB , 7.267E-04_JPRB , 1.076E-04_JPRB /)

!* Water cloud properties - from Fouquart (1987)

ZYFWCA4 = (/ _ZERO_         , _ZERO_         , _ZERO_        , _ZERO_          /)
ZYFWCB4 = (/ 1.5_JPRB       , 1.5_JPRB       , 1.5_JPRB      , 1.5_JPRB        /)
ZYFWCC4 = (/ 0.9999_JPRB    , 0.9988_JPRB    , 0.9988_JPRB   , 0.9988_JPRB     /)
ZYFWCD4 = (/ 5.000E-04_JPRB , 2.500E-03_JPRB , 2.500E-03_JPRB, 2.500E-03_JPRB  /)
ZYFWCE4 = (/ _HALF_         , 0.05_JPRB      , 0.05_JPRB     , 0.05_JPRB       /)
ZYFWCF4 = (/ 0.865_JPRB     , 0.910_JPRB     , 0.910_JPRB    , 0.910_JPRB      /)

!* Water cloud properties - from Slingo (1989)

ZASWCA4 = (/ 2.817_JPRB     , 2.682_JPRB     , 2.264_JPRB    , 1.281_JPRB      /)
ZASWCB4 = (/ 1.305_JPRB     , 1.346_JPRB     , 1.455_JPRB    , 1.641_JPRB      /)
ZASWCC4 = (/-5.62E-08_JPRB  ,-6.94E-06_JPRB  , 4.64E-04_JPRB , 2.01E-01_JPRB   /)
ZASWCD4 = (/ 1.63E-07_JPRB  , 2.35E-05_JPRB  , 1.24E-03_JPRB , 7.56E-03_JPRB   /)
ZASWCE4 = (/ 0.829_JPRB     , 0.794_JPRB     , 0.754_JPRB    , 0.826_JPRB      /)
ZASWCF4 = (/ 2.482_JPRB     , 4.226_JPRB     , 6.560_JPRB    , 4.353_JPRB      /)

!* Ice cloud properties - from Sun and Shine (1995)

ZSUSHE4 = (/ _ZERO_       , 7.2471E-02_JPRB , 17.5933_JPRB  , 48.7166_JPRB  /)
ZSUSHF4 = (/ _ZERO_       , 4.01511_JPRB    , 21.1249_JPRB  , 1.20890_JPRB  /)
ZSUSHH4 = (/ 0.8522_JPRB  , 0.85841_JPRB    , 0.90778_JPRB  ,0.982046_JPRB  /)
ZSUSHK4 = (/ 0.1620_JPRB  , 0.160048_JPRB   , 0.188521_JPRB ,0.0411446_JPRB /)
ZSUSHA4 = (/ _ZERO_       , 0.273455_JPRB   , 41.7675_JPRB  , 161.104_JPRB  /)
ZSUSHG4 = (/ 0.3270_JPRB  , 0.343668_JPRB   , 0.526192_JPRB , 0.574040_JPRB /)

!* Ice cloud properties - from Fu and Liou (1993)

ZFLAA04 = (/-6.656E-03_JPRB ,-6.656E-03_JPRB,-6.656E-03_JPRB,-6.656E-03_JPRB /)
ZFLAA14 = (/ 3.686_JPRB     , 3.686_JPRB    , 3.686_JPRB    , 3.686_JPRB     /)
ZFLBB04 = (/ .10998E-5_JPRB , .20208E-4_JPRB, .51557E-3_JPRB, .39517E+0_JPRB /)
ZFLBB14 = (/-.26101E-7_JPRB , .96483E-5_JPRB, .10731E-2_JPRB, .15787E-2_JPRB /)
ZFLBB24 = (/ .18096E-8_JPRB , .83009E-7_JPRB, .17753E-5_JPRB,-.14337E-4_JPRB /)
ZFLBB34 = (/-.47387E-11_JPRB,-.32217E-9_JPRB,-.18379E-7_JPRB, .46942E-7_JPRB /)
ZFLCC04 = (/ .22110E+1_JPRB , .22151E+1_JPRB, .22534E+1_JPRB, .26653E+1_JPRB /)
ZFLCC14 = (/-.10398E-2_JPRB ,-.77982E-3_JPRB, .16163E-2_JPRB, .56935E-2_JPRB /)
ZFLCC24 = (/ .65199E-4_JPRB , .63750E-4_JPRB, .44037E-4_JPRB,-.54316E-4_JPRB /)
ZFLCC34 = (/-.34498E-6_JPRB ,-.34466E-6_JPRB,-.27627E-6_JPRB, .17858E-6_JPRB /)
ZFLDD04 = (/ .12495_JPRB    , .12363_JPRB   , .11983_JPRB   , .21834E-1_JPRB /)
ZFLDD14 = (/-.43582E-3_JPRB ,-.44419E-3_JPRB,-.50108E-3_JPRB,-.29204E-3_JPRB /)
ZFLDD24 = (/ .14092E-4_JPRB , .14038E-4_JPRB, .11843E-4_JPRB, .18060E-5_JPRB /)
ZFLDD34 = (/-.69565E-7_JPRB ,-.68851E-7_JPRB,-.59367E-7_JPRB,-.46257E-8_JPRB /)

!* Ice cloud properties - from Fu (1996) as tabulated in Sun & Rikus (1999)

ZFUAA04 = (/-1.30817E-04_JPRB,-6.39479E-05_JPRB,-6.74730E-06_JPRB, 1.62674E-04_JPRB /)
ZFUAA14 = (/ 2.52883E+00_JPRB, 2.52393E+00_JPRB, 2.52056E+00_JPRB, 2.49823E+00_JPRB /)
ZFUBB04 = (/-1.55357E-08_JPRB,-7.90657E-07_JPRB, 9.64842E-04_JPRB, 2.25112E-01_JPRB /)
ZFUBB14 = (/ 1.95793E-07_JPRB, 7.79991E-06_JPRB, 9.09809E-04_JPRB, 3.05017E-03_JPRB /)
ZFUBB24 = (/-2.31234E-10_JPRB, 2.90894E-10_JPRB,-3.57557E-06_JPRB,-2.54236E-05_JPRB /)
ZFUBB34 = (/ 1.12247E-12_JPRB,-2.02818E-12_JPRB, 1.00197E-08_JPRB, 8.49116E-08_JPRB /)
ZFUCC04 = (/ 7.39781E-01_JPRB, 7.52335E-01_JPRB, 7.56307E-01_JPRB, 8.30812E-01_JPRB /)
ZFUCC14 = (/ 9.10564E-04_JPRB, 1.06211E-03_JPRB, 1.73364E-03_JPRB, 2.62788E-03_JPRB /)
ZFUCC24 = (/-4.62479E-07_JPRB,-2.45770E-06_JPRB,-8.92191E-06_JPRB,-2.43196E-05_JPRB /)
ZFUCC34 = (/-1.05910E-08_JPRB,-3.03712E-09_JPRB, 1.97757E-08_JPRB, 8.23543E-08_JPRB /)

!     ------------------------------------------------------------------

!*          1.3    SIX SPECTRAL INTERVALS
!                  ----------------------

! SW : 6 spectral intervals (0.185-0.25-0.44-0.69-1.19-2.38-4.00)

!* Ice cloud properties - crystal: adapted from Ebert and Curry, 1992

ZEBCUA6 = (/ 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB , 3.448E-03_JPRB /)
ZEBCUB6 = (/ 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     , 2.431_JPRB     /)
ZEBCUC6 = (/ 0.00001_JPRB   , 0.00001_JPRB   , 0.00001_JPRB   , 0.00011_JPRB   , 0.0197796_JPRB , 0.46658_JPRB   /)
ZEBCUD6 = (/ _ZERO_         , _ZERO_         , _ZERO_         , 1.405E-05_JPRB , 7.95513E-4_JPRB, 2.050E-05_JPRB /)
ZEBCUE6 = (/ 0.7661_JPRB    , 0.7661_JPRB    , 0.7661_JPRB    , 0.7730_JPRB    , 0.795653_JPRB  , 0.9595_JPRB    /)
ZEBCUF6 = (/ 5.851E-04_JPRB , 5.851E-04_JPRB , 5.851E-04_JPRB , 5.665E-04_JPRB , 7.267E-04_JPRB , 1.076E-04_JPRB /)

!* Water cloud properties - from Fouquart (1987)

ZYFWCA6 = (/ _ZERO_  , _ZERO_ , _ZERO_ , _ZERO_ , _ZERO_ , _ZERO_ /)
ZYFWCB6 = (/ 1.5_JPRB       , 1.5_JPRB       , 1.5_JPRB       , 1.5_JPRB       , 1.5_JPRB      , 1.5_JPRB        /)
ZYFWCC6 = (/ 0.9999_JPRB    , 0.9999_JPRB    , 0.9999_JPRB    , 0.9988_JPRB    , 0.9988_JPRB   , 0.9988_JPRB     /)
ZYFWCD6 = (/ 5.000E-04_JPRB , 5.000E-04_JPRB , 5.000E-04_JPRB , 2.500E-03_JPRB , 2.500E-03_JPRB, 2.500E-03_JPRB  /)
ZYFWCE6 = (/ _HALF_         , _HALF_         , _HALF_         , 0.05_JPRB      , 0.05_JPRB     , 0.05_JPRB       /)
ZYFWCF6 = (/ 0.865_JPRB     , 0.865_JPRB     , 0.865_JPRB     , 0.910_JPRB     , 0.910_JPRB    , 0.910_JPRB      /)

!* Water cloud properties - from Slingo (1989)

ZASWCA6 = (/ 2.817_JPRB     , 2.817_JPRB     , 2.817_JPRB     , 2.682_JPRB     , 2.264_JPRB    , 1.281_JPRB      /)
ZASWCB6 = (/ 1.305_JPRB     , 1.305_JPRB     , 1.305_JPRB     , 1.346_JPRB     , 1.455_JPRB    , 1.641_JPRB      /)
ZASWCC6 = (/-5.62E-08_JPRB  ,-5.62E-08_JPRB  ,-5.62E-08_JPRB  ,-6.94E-06_JPRB  , 4.64E-04_JPRB , 2.01E-01_JPRB   /)
ZASWCD6 = (/ 1.63E-07_JPRB  , 1.63E-07_JPRB  , 1.63E-07_JPRB  , 2.35E-05_JPRB  , 1.24E-03_JPRB , 7.56E-03_JPRB   /)
ZASWCE6 = (/ 0.829_JPRB     , 0.829_JPRB     , 0.829_JPRB     , 0.794_JPRB     , 0.754_JPRB    , 0.826_JPRB      /)
ZASWCF6 = (/ 2.482_JPRB     , 2.482_JPRB     , 2.482_JPRB     , 4.226_JPRB     , 6.560_JPRB    , 4.353_JPRB      /)

!* Ice cloud properties - from Sun and Shine (1995)

ZSUSHE6 = (/ _ZERO_       , _ZERO_       , _ZERO_       , 7.2471E-02_JPRB , 17.5933_JPRB  , 48.7166_JPRB  /)
ZSUSHF6 = (/ _ZERO_       , _ZERO_       , _ZERO_       , 4.01511_JPRB    , 21.1249_JPRB  , 1.20890_JPRB  /)
ZSUSHH6 = (/ 0.8522_JPRB  , 0.8522_JPRB  , 0.8522_JPRB  , 0.85841_JPRB    , 0.90778_JPRB  ,0.982046_JPRB  /)
ZSUSHK6 = (/ 0.1620_JPRB  , 0.1620_JPRB  , 0.1620_JPRB  , 0.160048_JPRB   , 0.188521_JPRB ,0.0411446_JPRB /)
ZSUSHA6 = (/ _ZERO_       , _ZERO_       , _ZERO_       , 0.273455_JPRB   , 41.7675_JPRB  , 161.104_JPRB  /)
ZSUSHG6 = (/ 0.3270_JPRB  , 0.3270_JPRB  , 0.3270_JPRB  , 0.343668_JPRB   , 0.526192_JPRB , 0.574040_JPRB /)

!* Ice cloud properties - from Fu and Liou (1993)

ZFLAA06 = (/-6.656E-03_JPRB ,-6.656E-03_JPRB ,-6.656E-03_JPRB ,-6.656E-03_JPRB,-6.656E-03_JPRB,-6.656E-03_JPRB /)
ZFLAA16 = (/ 3.686_JPRB     , 3.686_JPRB     , 3.686_JPRB     , 3.686_JPRB    , 3.686_JPRB    , 3.686_JPRB     /)
ZFLBB06 = (/ .10998E-5_JPRB , .10998E-5_JPRB , .10998E-5_JPRB , .20208E-4_JPRB, .51557E-3_JPRB, .39517E+0_JPRB /)
ZFLBB16 = (/-.26101E-7_JPRB ,-.26101E-7_JPRB ,-.26101E-7_JPRB , .96483E-5_JPRB, .10731E-2_JPRB, .15787E-2_JPRB /)
ZFLBB26 = (/ .18096E-8_JPRB , .18096E-8_JPRB , .18096E-8_JPRB , .83009E-7_JPRB, .17753E-5_JPRB,-.14337E-4_JPRB /)
ZFLBB36 = (/-.47387E-11_JPRB,-.47387E-11_JPRB,-.47387E-11_JPRB,-.32217E-9_JPRB,-.18379E-7_JPRB, .46942E-7_JPRB /)
ZFLCC06 = (/ .22110E+1_JPRB , .22110E+1_JPRB , .22110E+1_JPRB , .22151E+1_JPRB, .22534E+1_JPRB, .26653E+1_JPRB /)
ZFLCC16 = (/-.10398E-2_JPRB ,-.10398E-2_JPRB ,-.10398E-2_JPRB ,-.77982E-3_JPRB, .16163E-2_JPRB, .56935E-2_JPRB /)
ZFLCC26 = (/ .65199E-4_JPRB , .65199E-4_JPRB , .65199E-4_JPRB , .63750E-4_JPRB, .44037E-4_JPRB,-.54316E-4_JPRB /)
ZFLCC36 = (/-.34498E-6_JPRB ,-.34498E-6_JPRB ,-.34498E-6_JPRB ,-.34466E-6_JPRB,-.27627E-6_JPRB, .17858E-6_JPRB /)
ZFLDD06 = (/ .12495_JPRB    , .12495_JPRB    , .12495_JPRB    , .12363_JPRB   , .11983_JPRB   , .21834E-1_JPRB /)
ZFLDD16 = (/-.43582E-3_JPRB ,-.43582E-3_JPRB ,-.43582E-3_JPRB ,-.44419E-3_JPRB,-.50108E-3_JPRB,-.29204E-3_JPRB /)
ZFLDD26 = (/ .14092E-4_JPRB , .14092E-4_JPRB , .14092E-4_JPRB , .14038E-4_JPRB, .11843E-4_JPRB, .18060E-5_JPRB /)
ZFLDD36 = (/-.69565E-7_JPRB ,-.69565E-7_JPRB ,-.69565E-7_JPRB ,-.68851E-7_JPRB,-.59367E-7_JPRB,-.46257E-8_JPRB /)

!* Ice cloud properties - from Fu (1996) as tabulated in Sun & Rikus (1999)

ZFUAA06 = (/-1.30817E-04_JPRB,-1.30817E-04_JPRB,-1.30817E-04_JPRB,-6.39479E-05_JPRB,-6.74730E-06_JPRB, 1.62674E-04_JPRB /)
ZFUAA16 = (/ 2.52883E+00_JPRB, 2.52883E+00_JPRB, 2.52883E+00_JPRB, 2.52393E+00_JPRB, 2.52056E+00_JPRB, 2.49823E+00_JPRB /)
ZFUBB06 = (/-1.55357E-08_JPRB,-1.55357E-08_JPRB,-1.55357E-08_JPRB,-7.90657E-07_JPRB, 9.64842E-04_JPRB, 2.25112E-01_JPRB /)
ZFUBB16 = (/ 1.95793E-07_JPRB, 1.95793E-07_JPRB, 1.95793E-07_JPRB, 7.79991E-06_JPRB, 9.09809E-04_JPRB, 3.05017E-03_JPRB /)
ZFUBB26 = (/-2.31234E-10_JPRB,-2.31234E-10_JPRB,-2.31234E-10_JPRB, 2.90894E-10_JPRB,-3.57557E-06_JPRB,-2.54236E-05_JPRB /)
ZFUBB36 = (/ 1.12247E-12_JPRB, 1.12247E-12_JPRB, 1.12247E-12_JPRB,-2.02818E-12_JPRB, 1.00197E-08_JPRB, 8.49116E-08_JPRB /)
ZFUCC06 = (/ 7.39781E-01_JPRB, 7.39781E-01_JPRB, 7.39781E-01_JPRB, 7.52335E-01_JPRB, 7.56307E-01_JPRB, 8.30812E-01_JPRB /)
ZFUCC16 = (/ 9.10564E-04_JPRB, 9.10564E-04_JPRB, 9.10564E-04_JPRB, 1.06211E-03_JPRB, 1.73364E-03_JPRB, 2.62788E-03_JPRB /)
ZFUCC26 = (/-4.62479E-07_JPRB,-4.62479E-07_JPRB,-4.62479E-07_JPRB,-2.45770E-06_JPRB,-8.92191E-06_JPRB,-2.43196E-05_JPRB /)
ZFUCC36 = (/-1.05910E-08_JPRB,-1.05910E-08_JPRB,-1.05910E-08_JPRB,-3.03712E-09_JPRB, 1.97757E-08_JPRB, 8.23543E-08_JPRB /)

!     ------------------------------------------------------------------

! LW : absorption coefficient as a function of effective radius in RRTM

! water clouds from Savijarvi

RHSAVI( 1, :) = (/&
    &0.1651082_JPRB  , -0.003494839_JPRB  , _ZERO_              /)
RHSAVI( 2, :) = (/&
    &0.327820597_JPRB, -0.0219634383_JPRB , 0.000506783898_JPRB /) 
RHSAVI( 3, :) = (/&
    &0.504805453_JPRB, -0.0478602354_JPRB , 0.00141521102_JPRB  /)
RHSAVI( 4, :) = (/&
    &0.513169093_JPRB, -0.0508960145_JPRB , 0.00155498711_JPRB  /)
RHSAVI( 5, :) = (/&
    &0.448042082_JPRB, -0.0431857592_JPRB , 0.00130848978_JPRB  /)
RHSAVI( 6, :) = (/&
    &0.249547237_JPRB, -0.0185273835_JPRB , 0.00050361258_JPRB  /)
RHSAVI( 7, :) = (/&
    &0.135486796_JPRB, -0.00585852322_JPRB, 0.00011873119_JPRB  /)
RHSAVI( 8, :) = (/&
    &0.126668819_JPRB, -0.00497949082_JPRB, 0.0000927679172_JPRB/)
RHSAVI( 9, :) = (/&
    &0.130938752_JPRB, -0.00531814674_JPRB, 0.0000984953029_JPRB/)
RHSAVI(10, :) = (/&
    &0.147024519_JPRB, -0.00671655774_JPRB, 0.000130885091_JPRB /)
RHSAVI(11, :) = (/&
    &0.241463914_JPRB, -0.0174486461_JPRB , 0.000457756556_JPRB /)
RHSAVI(12, :) = (/&
    &0.07576579_JPRB , -0.001695588_JPRB  , _ZERO_              /)
RHSAVI(13, :) = (/&
    &0.1032178_JPRB  , -0.00293412_JPRB   , _ZERO_              /)
RHSAVI(14, :) = (/&
    &0.07342832_JPRB , -0.001775135_JPRB  , _ZERO_              /)
RHSAVI(15, :) = (/&
    &0.04649514_JPRB , -0.0009165462_JPRB , _ZERO_              /)
RHSAVI(16, :) = (/&
    &0.06893519_JPRB , -0.0001245402_JPRB , _ZERO_              /)
    
! water clouds from Lindner & Li (2000)

RLINLI( 1, :) = (/&   
  & 0.88116E-01_JPRB,-0.12857E-02_JPRB, 0.81658E+00_JPRB,-0.39428E+01_JPRB, 0.46652E+01_JPRB /)      
RLINLI( 2, :) = (/&      
  & 0.41307E-03_JPRB,-0.59631E-04_JPRB, 0.24275E+01_JPRB,-0.90838E+01_JPRB, 0.96069E+01_JPRB /)   
RLINLI( 3, :) = (/&      
  &-0.57709E-01_JPRB, 0.99071E-03_JPRB, 0.31118E+01_JPRB,-0.95540E+01_JPRB, 0.90189E+01_JPRB /)   
RLINLI( 4, :) = (/&         
  &-0.53069E-01_JPRB, 0.99992E-03_JPRB, 0.28045E+01_JPRB,-0.72836E+01_JPRB, 0.62573E+01_JPRB /)
RLINLI( 5, :) = (/&    
  &-0.23627E-01_JPRB, 0.55291E-03_JPRB, 0.21785E+01_JPRB,-0.54664E+01_JPRB, 0.47379E+01_JPRB /)     
RLINLI( 6, :) = (/&         
  & 0.29022E-01_JPRB,-0.39657E-03_JPRB, 0.14902E+01_JPRB,-0.50777E+01_JPRB, 0.52170E+01_JPRB /)
RLINLI( 7, :) = (/&         
  &-0.24901E-01_JPRB, 0.16195E-03_JPRB, 0.29375E+02_JPRB,-0.11437E+02_JPRB, 0.12273E+02_JPRB /)
RLINLI( 8, :) = (/&         
  &-0.14269E+00_JPRB, 0.22282E-02_JPRB, 0.46478E+01_JPRB,-0.16369E+02_JPRB, 0.16533E+02_JPRB /)
RLINLI( 9, :) = (/&   
  &-0.20398E+00_JPRB, 0.34708E-02_JPRB, 0.52858E+01_JPRB,-0.16603E+02_JPRB, 0.15392E+02_JPRB /)      
RLINLI(10, :) = (/&         
  &-0.18318E+00_JPRB, 0.33080E-02_JPRB, 0.46120E+01_JPRB,-0.11550E+02_JPRB, 0.87086E+01_JPRB /)
RLINLI(11, :) = (/&   
  &-0.20420E+00_JPRB, 0.37167E-02_JPRB, 0.48566E+01_JPRB,-0.11972E+02_JPRB, 0.86344E+01_JPRB /)      
RLINLI(12, :) = (/&         
  &-0.14037E+00_JPRB, 0.28058E-02_JPRB, 0.34969E+01_JPRB,-0.33770E+01_JPRB,-0.23541E+01_JPRB /)
RLINLI(13, :) = (/& 
  &-0.14037E+00_JPRB, 0.28058E-02_JPRB, 0.34969E+01_JPRB,-0.33770E+01_JPRB,-0.23541E+01_JPRB /)
RLINLI(14, :) = (/&         
  &-0.14037E+00_JPRB, 0.28058E-02_JPRB, 0.34969E+01_JPRB,-0.33770E+01_JPRB,-0.23541E+01_JPRB /)
RLINLI(15, :) = (/&         
  &-0.14037E+00_JPRB, 0.28058E-02_JPRB, 0.34969E+01_JPRB,-0.33770E+01_JPRB,-0.23541E+01_JPRB /)
RLINLI(16, :) = (/&         
  &-0.14037E+00_JPRB, 0.28058E-02_JPRB, 0.34969E+01_JPRB,-0.33770E+01_JPRB,-0.23541E+01_JPRB /)
    
! ice clouds From Fu & Liou

RFULIO( 1, :) = (/&
 & -7.752E-03_JPRB, 4.624_JPRB, -42.01_JPRB /)
RFULIO( 2, :) = (/&
 & -1.741E-02_JPRB, 5.541_JPRB, -58.42_JPRB /)
RFULIO( 3, :) = (/&
 & -1.704E-02_JPRB, 4.830_JPRB,  16.27_JPRB /)
RFULIO( 4, :) = (/&
 & -1.151E-02_JPRB, 4.182_JPRB,  31.13_JPRB /)
RFULIO( 5, :) = (/&
 & -1.026E-02_JPRB, 4.105_JPRB,  16.36_JPRB /)
RFULIO( 6, :) = (/&
 & -8.294E-03_JPRB, 3.925_JPRB,  1.315_JPRB /)
RFULIO( 7, :) = (/&
 & -1.153E-02_JPRB, 4.109_JPRB,  17.32_JPRB /)
RFULIO( 8, :) = (/&
 & -9.609E-03_JPRB, 3.768_JPRB,  34.11_JPRB /)
RFULIO( 9, :) = (/&
 & -9.061E-03_JPRB, 3.741_JPRB,  26.48_JPRB /)
RFULIO(10, :) = (/&
 & -8.441E-03_JPRB, 3.715_JPRB,  19.48_JPRB /)
RFULIO(11, :) = (/&
 & -8.088E-03_JPRB, 3.717_JPRB,  17.17_JPRB /)
RFULIO(12, :) = (/&
 & -8.088E-03_JPRB, 3.717_JPRB,  17.17_JPRB /)
RFULIO(13, :) = (/&
 & -7.770E-03_JPRB, 3.734_JPRB,  11.85_JPRB /)
RFULIO(14, :) = (/&
 & -6.656E-03_JPRB, 3.686_JPRB,  _ZERO_     /)
RFULIO(15, :) = (/&
 & -6.656E-03_JPRB, 3.686_JPRB,  _ZERO_     /)
RFULIO(16, :) = (/&
 & -6.656E-03_JPRB, 3.686_JPRB,  _ZERO_     /)
 
! ice clouds from Fu et al. (1998) 

RFUETA( 1, :) = (/&
 & 4.919685E-03_JPRB, 2.327741E+00_JPRB,-1.390858E+01_JPRB /)
RFUETA( 2, :) = (/&
 & 3.325756E-03_JPRB, 2.601360E+00_JPRB,-1.909602E+01_JPRB /)
RFUETA( 3, :) = (/&
 &-1.334860E-02_JPRB, 4.043808E+00_JPRB,-2.171029E+01_JPRB /)
RFUETA( 4, :) = (/&
 &-9.524174E-03_JPRB, 3.587742E+00_JPRB,-1.068895E+01_JPRB /)
RFUETA( 5, :) = (/&
 &-4.159424E-03_JPRB, 3.047325E+00_JPRB,-5.061568E+00_JPRB /)
RFUETA( 6, :) = (/&
 &-1.691632E-03_JPRB, 2.765756E+00_JPRB,-8.331033E+00_JPRB /)
RFUETA( 7, :) = (/&
 &-8.372696E-03_JPRB, 3.455018E+00_JPRB,-1.516692E+01_JPRB /)
RFUETA( 8, :) = (/&
 &-8.178608E-03_JPRB, 3.401245E+00_JPRB,-8.812820E+00_JPRB /)
RFUETA( 9, :) = (/&
 &-4.936610E-03_JPRB, 3.087764E+00_JPRB,-3.884262E+00_JPRB /)
RFUETA(10, :) = (/&
 &-3.034573E-03_JPRB, 2.900043E+00_JPRB,-1.849911E+00_JPRB /)
RFUETA(11, :) = (/&
 &-3.034573E-03_JPRB, 2.900043E+00_JPRB,-1.849911E+00_JPRB /)
RFUETA(12, :) = (/&
 &-2.465236E-03_JPRB, 2.833187E+00_JPRB,-4.227573E-01_JPRB /)
RFUETA(13, :) = (/&
 &-2.308881E-03_JPRB, 2.814002E+00_JPRB, 1.072211E+00_JPRB /)
RFUETA(14, :) = (/&
 &-2.308881E-03_JPRB, 2.814002E+00_JPRB, 1.072211E+00_JPRB /)
RFUETA(15, :) = (/&
 &-2.308881E-03_JPRB, 2.814002E+00_JPRB, 1.072211E+00_JPRB /)
RFUETA(16, :) = (/&
 &-2.308881E-03_JPRB, 2.814002E+00_JPRB, 1.072211E+00_JPRB /)
 
 
!     ----------------------------------------------------------------
! Ebert-Curry

! LW : spectrally defined for EC-OPE

REBCUI = (/  1.136_JPRB,  1.338_JPRB,  1.166_JPRB,  1.166_JPRB,  1.118_JPRB,  &
 &0.600_JPRB /)
REBCUJ = (/ 0.0036_JPRB, 0.0003_JPRB, 0.0016_JPRB, 0.0016_JPRB, 0.0020_JPRB,  &
 &0.0068_JPRB /)

! LW : spectrally defined for RRTM
! mass-absorption coefficients for vertical path: no diffusivity factor

REBCUG = (/ 0.718_JPRB, 0.726_JPRB, 1.136_JPRB, 1.320_JPRB, 1.505_JPRB, &
          & 1.290_JPRB, 0.911_JPRB, 0.949_JPRB, 1.021_JPRB, 1.193_JPRB, &
          & 1.279_JPRB, 0.626_JPRB, 0.647_JPRB, 0.668_JPRB, 0.690_JPRB, &
          & 0.690_JPRB /)


REBCUH = (/ 0.0069_JPRB, 0.0060_JPRB, 0.0024_JPRB, 0.0004_JPRB,-0.0016_JPRB, &
          & 0.0003_JPRB, 0.0043_JPRB, 0.0038_JPRB, 0.0030_JPRB, 0.0013_JPRB, &
          & 0.0005_JPRB, 0.0054_JPRB, 0.0052_JPRB, 0.0050_JPRB, 0.0048_JPRB, &
          & 0.0048_JPRB /)


! Sun-Shine

RSUSHFA = (/ 1.047_JPRB, -0.913E-04_JPRB, 0.203E-03_JPRB, -0.106E-04_JPRB  /)

!     ------------------------------------------------------------------

!*         2. 

!* Liquid/Solid water transition

RTIW= 263._JPRB
RRIW= 20._JPRB

! Ice particle Effective Radius as a function of LWC

REFFIA= 40._JPRB
REFFIB= 0._JPRB

! Sun-Shine

RSUSHC= 0.0306_JPRB
RSUSHD= 0.2548_JPRB

!     ------------------------------------------------------------------

! SW : absorption coefficients

IF (KSW == 2) THEN
  DO JNU=1,KSW
    RASWCA(JNU)=ZASWCA2(JNU)*1.E-02_JPRB
    RASWCB(JNU)=ZASWCB2(JNU)
    RASWCC(JNU)=ZASWCC2(JNU)
    RASWCD(JNU)=ZASWCD2(JNU)
    RASWCE(JNU)=ZASWCE2(JNU)
    RASWCF(JNU)=ZASWCF2(JNU)*1.E-03_JPRB

    REBCUA(JNU)=ZEBCUA2(JNU)
    REBCUB(JNU)=ZEBCUB2(JNU)
    REBCUC(JNU)=ZEBCUC2(JNU)
    REBCUD(JNU)=ZEBCUD2(JNU)
    REBCUE(JNU)=ZEBCUE2(JNU)
    REBCUF(JNU)=ZEBCUF2(JNU)

    RYFWCA(JNU)=ZYFWCA2(JNU)
    RYFWCB(JNU)=ZYFWCB2(JNU)
    RYFWCC(JNU)=ZYFWCC2(JNU)
    RYFWCD(JNU)=ZYFWCD2(JNU)
    RYFWCE(JNU)=ZYFWCE2(JNU)
    RYFWCF(JNU)=ZYFWCF2(JNU)

    RSUSHE(JNU)=ZSUSHE2(JNU)*1.E-02_JPRB
    RSUSHF(JNU)=ZSUSHF2(JNU)*1.E-02_JPRB
    RSUSHH(JNU)=ZSUSHH2(JNU)
    RSUSHK(JNU)=ZSUSHK2(JNU)*1.E-01_JPRB
    RSUSHA(JNU)=ZSUSHA2(JNU)*1.E-03_JPRB
    RSUSHG(JNU)=ZSUSHG2(JNU)*1.E-01_JPRB
    
    RFLAA0(JNU)=ZFLAA02(JNU)
    RFLAA1(JNU)=ZFLAA12(JNU)
    RFLBB0(JNU)=ZFLBB02(JNU)
    RFLBB1(JNU)=ZFLBB12(JNU)
    RFLBB2(JNU)=ZFLBB22(JNU)
    RFLBB3(JNU)=ZFLBB32(JNU)
    RFLCC0(JNU)=ZFLCC02(JNU)
    RFLCC1(JNU)=ZFLCC12(JNU)
    RFLCC2(JNU)=ZFLCC22(JNU)
    RFLCC3(JNU)=ZFLCC32(JNU)
    RFLDD0(JNU)=ZFLDD02(JNU)
    RFLDD1(JNU)=ZFLDD12(JNU)
    RFLDD2(JNU)=ZFLDD22(JNU)
    RFLDD3(JNU)=ZFLDD32(JNU)
    
!    RFUAA0(JNU)=ZFUAA02(JNU)
!    RFUAA1(JNU)=ZFUAA12(JNU)
!    RFUBB0(JNU)=ZFUBB02(JNU)
!    RFUBB1(JNU)=ZFUBB12(JNU)
!    RFUBB2(JNU)=ZFUBB22(JNU)
!    RFUBB3(JNU)=ZFUBB32(JNU)
!    RFUCC0(JNU)=ZFUCC02(JNU)
!    RFUCC1(JNU)=ZFUCC12(JNU)
!    RFUCC2(JNU)=ZFUCC22(JNU)
!    RFUCC3(JNU)=ZFUCC32(JNU)
!    RFUDD0(JNU)=ZFUDD02(JNU)
!    RFUDD1(JNU)=ZFUDD12(JNU)
!    RFUDD2(JNU)=ZFUDD22(JNU)
!    RFUDD3(JNU)=ZFUDD32(JNU)
    
  ENDDO
ELSEIF (KSW == 4) THEN
  DO JNU=1,KSW
    RASWCA(JNU)=ZASWCA4(JNU)*1.E-02_JPRB
    RASWCB(JNU)=ZASWCB4(JNU)
    RASWCC(JNU)=ZASWCC4(JNU)
    RASWCD(JNU)=ZASWCD4(JNU)
    RASWCE(JNU)=ZASWCE4(JNU)
    RASWCF(JNU)=ZASWCF4(JNU)*1.E-03_JPRB

    REBCUA(JNU)=ZEBCUA4(JNU)
    REBCUB(JNU)=ZEBCUB4(JNU)
    REBCUC(JNU)=ZEBCUC4(JNU)
    REBCUD(JNU)=ZEBCUD4(JNU)
    REBCUE(JNU)=ZEBCUE4(JNU)
    REBCUF(JNU)=ZEBCUF4(JNU)

    RYFWCA(JNU)=ZYFWCA4(JNU)
    RYFWCB(JNU)=ZYFWCB4(JNU)
    RYFWCC(JNU)=ZYFWCC4(JNU)
    RYFWCD(JNU)=ZYFWCD4(JNU)
    RYFWCE(JNU)=ZYFWCE4(JNU)
    RYFWCF(JNU)=ZYFWCF4(JNU)

    RSUSHE(JNU)=ZSUSHE4(JNU)*1.E-02_JPRB
    RSUSHF(JNU)=ZSUSHF4(JNU)*1.E-02_JPRB
    RSUSHH(JNU)=ZSUSHH4(JNU)
    RSUSHK(JNU)=ZSUSHK4(JNU)*1.E-01_JPRB
    RSUSHA(JNU)=ZSUSHA4(JNU)*1.E-03_JPRB
    RSUSHG(JNU)=ZSUSHG4(JNU)*1.E-01_JPRB
    
    RFLAA0(JNU)=ZFLAA04(JNU)
    RFLAA1(JNU)=ZFLAA14(JNU)
    RFLBB0(JNU)=ZFLBB04(JNU)
    RFLBB1(JNU)=ZFLBB14(JNU)
    RFLBB2(JNU)=ZFLBB24(JNU)
    RFLBB3(JNU)=ZFLBB34(JNU)
    RFLCC0(JNU)=ZFLCC04(JNU)
    RFLCC1(JNU)=ZFLCC14(JNU)
    RFLCC2(JNU)=ZFLCC24(JNU)
    RFLCC3(JNU)=ZFLCC34(JNU)
    RFLDD0(JNU)=ZFLDD04(JNU)
    RFLDD1(JNU)=ZFLDD14(JNU)
    RFLDD2(JNU)=ZFLDD24(JNU)
    RFLDD3(JNU)=ZFLDD34(JNU)
    
    RFUAA0(JNU)=ZFUAA04(JNU)
    RFUAA1(JNU)=ZFUAA14(JNU)
    RFUBB0(JNU)=ZFUBB04(JNU)
    RFUBB1(JNU)=ZFUBB14(JNU)
    RFUBB2(JNU)=ZFUBB24(JNU)
    RFUBB3(JNU)=ZFUBB34(JNU)
    RFUCC0(JNU)=ZFUCC04(JNU)
    RFUCC1(JNU)=ZFUCC14(JNU)
    RFUCC2(JNU)=ZFUCC24(JNU)
    RFUCC3(JNU)=ZFUCC34(JNU)
!    RFUDD0(JNU)=ZFUDD04(JNU)
!    RFUDD1(JNU)=ZFUDD14(JNU)
!    RFUDD2(JNU)=ZFUDD24(JNU)
!    RFUDD3(JNU)=ZFUDD34(JNU)
    
  ENDDO
ELSEIF (KSW == 6) THEN
  DO JNU=1,KSW
    RASWCA(JNU)=ZASWCA6(JNU)*1.E-02_JPRB
    RASWCB(JNU)=ZASWCB6(JNU)
    RASWCC(JNU)=ZASWCC6(JNU)
    RASWCD(JNU)=ZASWCD6(JNU)
    RASWCE(JNU)=ZASWCE6(JNU)
    RASWCF(JNU)=ZASWCF6(JNU)*1.E-03_JPRB

    REBCUA(JNU)=ZEBCUA6(JNU)
    REBCUB(JNU)=ZEBCUB6(JNU)
    REBCUC(JNU)=ZEBCUC6(JNU)
    REBCUD(JNU)=ZEBCUD6(JNU)
    REBCUE(JNU)=ZEBCUE6(JNU)
    REBCUF(JNU)=ZEBCUF6(JNU)

    RYFWCA(JNU)=ZYFWCA6(JNU)
    RYFWCB(JNU)=ZYFWCB6(JNU)
    RYFWCC(JNU)=ZYFWCC6(JNU)
    RYFWCD(JNU)=ZYFWCD6(JNU)
    RYFWCE(JNU)=ZYFWCE6(JNU)
    RYFWCF(JNU)=ZYFWCF6(JNU)

    RSUSHE(JNU)=ZSUSHE6(JNU)*1.E-02_JPRB
    RSUSHF(JNU)=ZSUSHF6(JNU)*1.E-02_JPRB
    RSUSHH(JNU)=ZSUSHH6(JNU)
    RSUSHK(JNU)=ZSUSHK6(JNU)*1.E-01_JPRB
    RSUSHA(JNU)=ZSUSHA6(JNU)*1.E-03_JPRB
    RSUSHG(JNU)=ZSUSHG6(JNU)*1.E-01_JPRB
    
    RFLAA0(JNU)=ZFLAA06(JNU)
    RFLAA1(JNU)=ZFLAA16(JNU)
    RFLBB0(JNU)=ZFLBB06(JNU)
    RFLBB1(JNU)=ZFLBB16(JNU)
    RFLBB2(JNU)=ZFLBB26(JNU)
    RFLBB3(JNU)=ZFLBB36(JNU)
    RFLCC0(JNU)=ZFLCC06(JNU)
    RFLCC1(JNU)=ZFLCC16(JNU)
    RFLCC2(JNU)=ZFLCC26(JNU)
    RFLCC3(JNU)=ZFLCC36(JNU)
    RFLDD0(JNU)=ZFLDD06(JNU)
    RFLDD1(JNU)=ZFLDD16(JNU)
    RFLDD2(JNU)=ZFLDD26(JNU)
    RFLDD3(JNU)=ZFLDD36(JNU)
    
    RFUAA0(JNU)=ZFUAA06(JNU)
    RFUAA1(JNU)=ZFUAA16(JNU)
    RFUBB0(JNU)=ZFUBB06(JNU)
    RFUBB1(JNU)=ZFUBB16(JNU)
    RFUBB2(JNU)=ZFUBB26(JNU)
    RFUBB3(JNU)=ZFUBB36(JNU)
    RFUCC0(JNU)=ZFUCC06(JNU)
    RFUCC1(JNU)=ZFUCC16(JNU)
    RFUCC2(JNU)=ZFUCC26(JNU)
    RFUCC3(JNU)=ZFUCC36(JNU)
!    RFUDD0(JNU)=ZFUDD06(JNU)
!    RFUDD1(JNU)=ZFUDD16(JNU)
!    RFUDD2(JNU)=ZFUDD26(JNU)
!    RFUDD3(JNU)=ZFUDD36(JNU)
    
  ENDDO
ELSE
!  CALL ABOR1('SUCLOPN: WRONG SW SPECTRAL RESOLUTION')
  STOP 'SUCLOPN: WRONG SW SPECTRAL RESOLUTION'
ENDIF

!     ------------------------------------------------------------------

!*          2.    CLOUD OVERLAP PARAMETERS
!                 ------------------------

ZAOVLP = (/ -2.250E-05_JPRB,-7.316E-06_JPRB,-1.966E-05_JPRB /) 
ZBOVLP = (/  0.7865_JPRB   , 0.8186_JPRB   , 0.8900_JPRB    /)

IF (KLEV == 19) THEN
  RAOVLP=ZAOVLP(1)
  RBOVLP=ZBOVLP(1)
ELSE IF (KLEV == 31) THEN
  RAOVLP=ZAOVLP(2)
  RBOVLP=ZBOVLP(2)
ELSE IF (KLEV == 60) THEN
  RAOVLP=ZAOVLP(3)
  RBOVLP=ZBOVLP(3)
ELSE  
  RAOVLP=ZAOVLP(3)
  RBOVLP=ZBOVLP(3)
END IF  

!     ------------------------------------------------------------------

RETURN
END SUBROUTINE SUCLOPN

!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 data_expon.f 2006/05/18 13:07:25
!-----------------------------------------------------------------
C=======================================================================
C
C *** ISORROPIA CODE
C *** BLOCK DATA EXPON
C *** CONTAINS DATA FOR EXPONENT ARRAYS NEEDED IN FUNCTION EXP10
C
C *** COPYRIGHT 1996-2000, UNIVERSITY OF MIAMI, CARNEGIE MELLON UNIVERSITY
C *** WRITTEN BY ATHANASIOS NENES
C
C=======================================================================
C
      BLOCK DATA EXPON
C
C *** Common block definition
C
      REAL AINT10, ADEC10
      COMMON /EXPNC/ AINT10(20), ADEC10(200)
C
C *** Integer part        
C
      DATA AINT10/
     & 0.1000E-08, 0.1000E-07, 0.1000E-06, 0.1000E-05, 0.1000E-04,
     & 0.1000E-03, 0.1000E-02, 0.1000E-01, 0.1000E+00, 0.1000E+01,
     & 0.1000E+02, 0.1000E+03, 0.1000E+04, 0.1000E+05, 0.1000E+06,
     & 0.1000E+07, 0.1000E+08, 0.1000E+09, 0.1000E+10, 0.1000E+11
     & /
C
C *** decimal part        
C
      DATA (ADEC10(I),I=1,100)/
     & 0.1023E+00, 0.1047E+00, 0.1072E+00, 0.1096E+00, 0.1122E+00,
     & 0.1148E+00, 0.1175E+00, 0.1202E+00, 0.1230E+00, 0.1259E+00,
     & 0.1288E+00, 0.1318E+00, 0.1349E+00, 0.1380E+00, 0.1413E+00,
     & 0.1445E+00, 0.1479E+00, 0.1514E+00, 0.1549E+00, 0.1585E+00,
     & 0.1622E+00, 0.1660E+00, 0.1698E+00, 0.1738E+00, 0.1778E+00,
     & 0.1820E+00, 0.1862E+00, 0.1905E+00, 0.1950E+00, 0.1995E+00,
     & 0.2042E+00, 0.2089E+00, 0.2138E+00, 0.2188E+00, 0.2239E+00,
     & 0.2291E+00, 0.2344E+00, 0.2399E+00, 0.2455E+00, 0.2512E+00,
     & 0.2570E+00, 0.2630E+00, 0.2692E+00, 0.2754E+00, 0.2818E+00,
     & 0.2884E+00, 0.2951E+00, 0.3020E+00, 0.3090E+00, 0.3162E+00,
     & 0.3236E+00, 0.3311E+00, 0.3388E+00, 0.3467E+00, 0.3548E+00,
     & 0.3631E+00, 0.3715E+00, 0.3802E+00, 0.3890E+00, 0.3981E+00,
     & 0.4074E+00, 0.4169E+00, 0.4266E+00, 0.4365E+00, 0.4467E+00,
     & 0.4571E+00, 0.4677E+00, 0.4786E+00, 0.4898E+00, 0.5012E+00,
     & 0.5129E+00, 0.5248E+00, 0.5370E+00, 0.5495E+00, 0.5623E+00,
     & 0.5754E+00, 0.5888E+00, 0.6026E+00, 0.6166E+00, 0.6310E+00,
     & 0.6457E+00, 0.6607E+00, 0.6761E+00, 0.6918E+00, 0.7079E+00,
     & 0.7244E+00, 0.7413E+00, 0.7586E+00, 0.7762E+00, 0.7943E+00,
     & 0.8128E+00, 0.8318E+00, 0.8511E+00, 0.8710E+00, 0.8913E+00,
     & 0.9120E+00, 0.9333E+00, 0.9550E+00, 0.9772E+00, 0.1000E+01/

      DATA (ADEC10(I),I=101,200)/
     & 0.1023E+01, 0.1047E+01, 0.1072E+01, 0.1096E+01, 0.1122E+01,
     & 0.1148E+01, 0.1175E+01, 0.1202E+01, 0.1230E+01, 0.1259E+01,
     & 0.1288E+01, 0.1318E+01, 0.1349E+01, 0.1380E+01, 0.1413E+01,
     & 0.1445E+01, 0.1479E+01, 0.1514E+01, 0.1549E+01, 0.1585E+01,
     & 0.1622E+01, 0.1660E+01, 0.1698E+01, 0.1738E+01, 0.1778E+01,
     & 0.1820E+01, 0.1862E+01, 0.1905E+01, 0.1950E+01, 0.1995E+01,
     & 0.2042E+01, 0.2089E+01, 0.2138E+01, 0.2188E+01, 0.2239E+01,
     & 0.2291E+01, 0.2344E+01, 0.2399E+01, 0.2455E+01, 0.2512E+01,
     & 0.2570E+01, 0.2630E+01, 0.2692E+01, 0.2754E+01, 0.2818E+01,
     & 0.2884E+01, 0.2951E+01, 0.3020E+01, 0.3090E+01, 0.3162E+01,
     & 0.3236E+01, 0.3311E+01, 0.3388E+01, 0.3467E+01, 0.3548E+01,
     & 0.3631E+01, 0.3715E+01, 0.3802E+01, 0.3890E+01, 0.3981E+01,
     & 0.4074E+01, 0.4169E+01, 0.4266E+01, 0.4365E+01, 0.4467E+01,
     & 0.4571E+01, 0.4677E+01, 0.4786E+01, 0.4898E+01, 0.5012E+01,
     & 0.5129E+01, 0.5248E+01, 0.5370E+01, 0.5495E+01, 0.5623E+01,
     & 0.5754E+01, 0.5888E+01, 0.6026E+01, 0.6166E+01, 0.6310E+01,
     & 0.6457E+01, 0.6607E+01, 0.6761E+01, 0.6918E+01, 0.7079E+01,
     & 0.7244E+01, 0.7413E+01, 0.7586E+01, 0.7762E+01, 0.7943E+01,
     & 0.8128E+01, 0.8318E+01, 0.8511E+01, 0.8710E+01, 0.8913E+01,
     & 0.9120E+01, 0.9333E+01, 0.9550E+01, 0.9772E+01, 0.1000E+02
     & /
C
C *** END OF BLOCK DATA EXPON ******************************************
C
      END


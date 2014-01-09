!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 data_aersr.f 2006/05/18 13:07:25
!-----------------------------------------------------------------
C=======================================================================
C
C *** ISORROPIA CODE
C *** BLOCK DATA AERSR
C *** CONTAINS DATA FOR AEROSOL SULFATE RATIO ARRAY NEEDED IN FUNCTION 
C     GETASR
C
C *** COPYRIGHT 1996-2000, UNIVERSITY OF MIAMI, CARNEGIE MELLON UNIVERSITY
C *** WRITTEN BY ATHANASIOS NENES
C
C=======================================================================
C
      BLOCK DATA AERSR
      PARAMETER (NSO4S=14, NRHS=20, NASRD=NSO4S*NRHS)
      COMMON /ASRC/ ASRAT(NASRD), ASSO4(NSO4S)
C
      DATA ASSO4/1.0E-9, 2.5E-9, 5.0E-9, 7.5E-9, 1.0E-8,
     &           2.5E-8, 5.0E-8, 7.5E-8, 1.0E-7, 2.5E-7, 
     &           5.0E-7, 7.5E-7, 1.0E-6, 5.0E-6/
C
      DATA (ASRAT(I), I=1,100)/
     & 1.020464, 0.9998130, 0.9960167, 0.9984423, 1.004004,
     & 1.010885,  1.018356,  1.026726,  1.034268, 1.043846,
     & 1.052933,  1.062230,  1.062213,  1.080050, 1.088350,
     & 1.096603,  1.104289,  1.111745,  1.094662, 1.121594,
     & 1.268909,  1.242444,  1.233815,  1.232088, 1.234020,
     & 1.238068,  1.243455,  1.250636,  1.258734, 1.267543,
     & 1.276948,  1.286642,  1.293337,  1.305592, 1.314726,
     & 1.323463,  1.333258,  1.343604,  1.344793, 1.355571,
     & 1.431463,  1.405204,  1.395791,  1.393190, 1.394403,
     & 1.398107,  1.403811,  1.411744,  1.420560, 1.429990,
     & 1.439742,  1.449507,  1.458986,  1.468403, 1.477394,
     & 1.487373,  1.495385,  1.503854,  1.512281, 1.520394,
     & 1.514464,  1.489699,  1.480686,  1.478187, 1.479446,
     & 1.483310,  1.489316,  1.497517,  1.506501, 1.515816,
     & 1.524724,  1.533950,  1.542758,  1.551730, 1.559587,
     & 1.568343,  1.575610,  1.583140,  1.590440, 1.596481,
     & 1.567743,  1.544426,  1.535928,  1.533645, 1.535016,
     & 1.539003,  1.545124,  1.553283,  1.561886, 1.570530,
     & 1.579234,  1.587813,  1.595956,  1.603901, 1.611349,
     & 1.618833,  1.625819,  1.632543,  1.639032, 1.645276/

      DATA (ASRAT(I), I=101,200)/
     & 1.707390,  1.689553,  1.683198,  1.681810, 1.683490,
     & 1.687477,  1.693148,  1.700084,  1.706917, 1.713507,
     & 1.719952,  1.726190,  1.731985,  1.737544, 1.742673,
     & 1.747756,  1.752431,  1.756890,  1.761141, 1.765190,
     & 1.785657,  1.771851,  1.767063,  1.766229, 1.767901,
     & 1.771455,  1.776223,  1.781769,  1.787065, 1.792081,
     & 1.796922,  1.801561,  1.805832,  1.809896, 1.813622,
     & 1.817292,  1.820651,  1.823841,  1.826871, 1.829745,
     & 1.822215,  1.810497,  1.806496,  1.805898, 1.807480,
     & 1.810684,  1.814860,  1.819613,  1.824093, 1.828306,
     & 1.832352,  1.836209,  1.839748,  1.843105, 1.846175,
     & 1.849192,  1.851948,  1.854574,  1.857038, 1.859387,
     & 1.844588,  1.834208,  1.830701,  1.830233, 1.831727,
     & 1.834665,  1.838429,  1.842658,  1.846615, 1.850321,
     & 1.853869,  1.857243,  1.860332,  1.863257, 1.865928,
     & 1.868550,  1.870942,  1.873208,  1.875355, 1.877389,
     & 1.899556,  1.892637,  1.890367,  1.890165, 1.891317,
     & 1.893436,  1.896036,  1.898872,  1.901485, 1.903908,
     & 1.906212,  1.908391,  1.910375,  1.912248, 1.913952,
     & 1.915621,  1.917140,  1.918576,  1.919934, 1.921220/

      DATA (ASRAT(I), I=201,280)/
     & 1.928264,  1.923245,  1.921625,  1.921523, 1.922421,
     & 1.924016,  1.925931,  1.927991,  1.929875, 1.931614,
     & 1.933262,  1.934816,  1.936229,  1.937560, 1.938769,
     & 1.939951,  1.941026,  1.942042,  1.943003, 1.943911,
     & 1.941205,  1.937060,  1.935734,  1.935666, 1.936430,
     & 1.937769,  1.939359,  1.941061,  1.942612, 1.944041,
     & 1.945393,  1.946666,  1.947823,  1.948911, 1.949900,
     & 1.950866,  1.951744,  1.952574,  1.953358, 1.954099,
     & 1.948985,  1.945372,  1.944221,  1.944171, 1.944850,
     & 1.946027,  1.947419,  1.948902,  1.950251, 1.951494,
     & 1.952668,  1.953773,  1.954776,  1.955719, 1.956576,
     & 1.957413,  1.958174,  1.958892,  1.959571, 1.960213,
     & 1.977193,  1.975540,  1.975023,  1.975015, 1.975346,
     & 1.975903,  1.976547,  1.977225,  1.977838, 1.978401,
     & 1.978930,  1.979428,  1.979879,  1.980302, 1.980686,
     & 1.981060,  1.981401,  1.981722,  1.982025, 1.982312/
C
C *** END OF BLOCK DATA AERSR ******************************************
C
       END
      

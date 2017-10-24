!MNH_LIC Copyright 1994-2014 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for CVS information
!-----------------------------------------------------------------
! $Source$
! $Name$ 
! $Revision$ 
! $Date$
!   J.Escobar 30/06/2017 : Add activation of ZLIB compression if MNH_IOCDF4 == 2
!-----------------------------------------------------------------
!-----------------------------------------------------------------

MODULE MODD_IO_ll
IMPLICIT NONE 
!
!
INTEGER, SAVE :: ISTDOUT, ISTDERR

INTEGER, SAVE :: ISIOP   !! IOproc number
INTEGER, SAVE :: ISP     !! Actual proc number
INTEGER, SAVE :: ISNPROC !! Total number of allocated processors 
LOGICAL, SAVE :: GSMONOPROC = .FALSE. !! True if sequential execution (ISNPROC = 1) 

TYPE LFIPARAM
  INTEGER :: FITYP   ! FM File Type (used in FMCLOSE)
END TYPE LFIPARAM

LOGICAL, SAVE :: L1D   = .FALSE. ! TRUE if 1D model version
LOGICAL, SAVE :: L2D   = .FALSE. ! TRUE if 2D model version
LOGICAL, SAVE :: LPACK = .FALSE. ! TRUE if FM compression occurs in 1D or 2D model version

LOGICAL, SAVE :: LIOCDF4    = .FALSE. ! TRUE will enable full NetCDF4 (HDF5) I/O support
LOGICAL, SAVE :: LLFIOUT    = .FALSE. ! TRUE will also force LFI output when LIOCDF4 is on (debug only)  
LOGICAL, SAVE :: LLFIREAD   = .FALSE. ! TRUE will force LFI read (instead of NetCDF) when LIOCDF4 is on (debug only)  
#if MNH_IOCDF4 == 2
LOGICAL, SAVE :: LDEFLATEX2 = .TRUE. ! TRUE to enable Zlib deflate compression on X2/X3 fields
#else
LOGICAL, SAVE :: LDEFLATEX2 = .FALSE. ! TRUE to enable Zlib deflate compression on X2/X3 fields
#endif
END MODULE MODD_IO_ll

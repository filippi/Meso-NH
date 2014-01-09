!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
! 
! Global Data Module File
! 
! Generated by KPP-2.2 symbolic chemistry Kinetics PreProcessor
!       (http://www.cs.vt.edu/~asandu/Software/KPP)
! KPP is distributed under GPL, the general public licence
!       (http://www.gnu.org/copyleft/gpl.html)
! (C) 1995-1997, V. Damian & A. Sandu, CGRER, Univ. Iowa
! (C) 1997-2005, A. Sandu, Michigan Tech, Virginia Tech
!     With important contributions from:
!        M. Damian, Villanova University, USA
!        R. Sander, Max-Planck Institute for Chemistry, Mainz, Germany
! 
! File                 : RBK90_Global.f90
! Time                 : Mon Apr 16 16:40:45 2007
! Working directory    : /home/pinjp/chimie_num/kpp/kpp-2.2.1.December2006/my-test-NumRec
! Equation file        : RBK90.kpp
! Output root filename : RBK90
! 
! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


MODULE MODD_RBK90_Global_n

!  USE RBK90_Parameters_n, ONLY: NSPEC, NVAR, NFIX, NREACT

USE MODD_PARAMETERS, ONLY: JPMODELMAX
IMPLICIT NONE

TYPE RBK90_Global_t
!  PUBLIC
!  SAVE


! Declaration of global variables

! C - Concentration of all species
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: C
! VAR - Concentrations of variable species (global)
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: VAR
! FIX - Concentrations of fixed species (global)
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: FIX
!JPP      EQUIVALENCE( C(1),VAR(1) )
!JPP      EQUIVALENCE( C(66),FIX(1) )
! RCONST - Rate constants (global)
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: RCONST
! TIME - Current integration time
    REAL(KIND(0.0D0)) :: TIME
! SUN - Sunlight intensity between [0,1]
    REAL(KIND(0.0D0)) :: SUN
! TEMP - Temperature
    REAL(KIND(0.0D0)) :: TEMP
! RTOLS - (scalar) Relative tolerance
    REAL(KIND(0.0D0)) :: RTOLS
! TSTART - Integration start time
    REAL(KIND(0.0D0)) :: TSTART
! TEND - Integration end time
    REAL(KIND(0.0D0)) :: TEND
! DT - Integration step
    REAL(KIND(0.0D0)) :: DT
! ATOL - Absolute tolerance
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: ATOL
! RTOL - Relative tolerance
    REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: RTOL
! STEPMIN - Lower bound for integration step
    REAL(KIND(0.0D0)) :: STEPMIN
! STEPMAX - Upper bound for integration step
    REAL(KIND(0.0D0)) :: STEPMAX
! CFACTOR - Conversion factor for concentration units
    REAL(KIND(0.0D0)) :: CFACTOR
! DDMTYPE - DDM sensitivity w.r.t.: 0=init.val., 1=params
    INTEGER :: DDMTYPE

! INLINED global variable declarations


END TYPE RBK90_Global_t

TYPE(RBK90_Global_t), DIMENSION(JPMODELMAX), TARGET, SAVE :: RBK90_Global_MODEL

REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: C=>NULL()
REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: VAR=>NULL()
REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: FIX=>NULL()
REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: RCONST=>NULL()
REAL(KIND(0.0D0)), POINTER :: TIME=>NULL()
REAL(KIND(0.0D0)), POINTER :: SUN=>NULL()
REAL(KIND(0.0D0)), POINTER :: TEMP=>NULL()
REAL(KIND(0.0D0)), POINTER :: RTOLS=>NULL()
REAL(KIND(0.0D0)), POINTER :: TSTART=>NULL()
REAL(KIND(0.0D0)), POINTER :: TEND=>NULL()
REAL(KIND(0.0D0)), POINTER :: DT=>NULL()
REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: ATOL=>NULL()
REAL(KIND(0.0D0)), DIMENSION(:), POINTER :: RTOL=>NULL()
REAL(KIND(0.0D0)), POINTER :: STEPMIN=>NULL()
REAL(KIND(0.0D0)), POINTER :: STEPMAX=>NULL()
REAL(KIND(0.0D0)), POINTER :: CFACTOR=>NULL()
INTEGER, POINTER :: DDMTYPE=>NULL()

CONTAINS

SUBROUTINE RBK90_Global_GOTO_MODEL(KFROM, KTO)
INTEGER, INTENT(IN) :: KFROM, KTO
!
! Save current state for allocated arrays
RBK90_Global_MODEL(KFROM)%C=>C
RBK90_Global_MODEL(KFROM)%VAR=>VAR
RBK90_Global_MODEL(KFROM)%FIX=>FIX
RBK90_Global_MODEL(KFROM)%RCONST=>RCONST
RBK90_Global_MODEL(KFROM)%ATOL=>ATOL
RBK90_Global_MODEL(KFROM)%RTOL=>RTOL
!
! Current model is set to model KTO
C=>RBK90_Global_MODEL(KTO)%C
VAR=>RBK90_Global_MODEL(KTO)%VAR
FIX=>RBK90_Global_MODEL(KTO)%FIX
RCONST=>RBK90_Global_MODEL(KTO)%RCONST
TIME=>RBK90_Global_MODEL(KTO)%TIME
SUN=>RBK90_Global_MODEL(KTO)%SUN
TEMP=>RBK90_Global_MODEL(KTO)%TEMP
RTOLS=>RBK90_Global_MODEL(KTO)%RTOLS
TSTART=>RBK90_Global_MODEL(KTO)%TSTART
TEND=>RBK90_Global_MODEL(KTO)%TEND
DT=>RBK90_Global_MODEL(KTO)%DT
ATOL=>RBK90_Global_MODEL(KTO)%ATOL
RTOL=>RBK90_Global_MODEL(KTO)%RTOL
STEPMIN=>RBK90_Global_MODEL(KTO)%STEPMIN
STEPMAX=>RBK90_Global_MODEL(KTO)%STEPMAX
CFACTOR=>RBK90_Global_MODEL(KTO)%CFACTOR
DDMTYPE=>RBK90_Global_MODEL(KTO)%DDMTYPE

END SUBROUTINE RBK90_Global_GOTO_MODEL

END MODULE MODD_RBK90_Global_n

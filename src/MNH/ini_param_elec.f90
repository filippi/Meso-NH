!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!     	##########################
        MODULE MODI_INI_PARAM_ELEC
!      	##########################
!
INTERFACE
!
        SUBROUTINE INI_PARAM_ELEC (HINIFILE, HLUOUT, HGETSVM, PRHO00,  &
                                   KRR, KND, PFDINFTY, IIU, IJU, IKU   )
!
CHARACTER (LEN=*), INTENT(IN) :: HINIFILE ! name of the initial file
CHARACTER (LEN=*), INTENT(IN) :: HLUOUT   ! name for output-listing
                                          !  of nested models
CHARACTER (LEN=*), DIMENSION(:),INTENT(IN)  :: HGETSVM
INTEGER, INTENT(IN) :: KND      ! Number of intervals to integrate kernels
INTEGER, INTENT(IN) :: KRR      ! Number of moist variables
REAL,    INTENT(IN) :: PRHO00   ! Pressure at ground level
REAL,    INTENT(IN) :: PFDINFTY ! Factor used to define the "infinite" diameter
INTEGER, INTENT(IN) :: IIU      ! Upper dimension in x direction (local)
INTEGER, INTENT(IN) :: IJU      ! Upper dimension in y direction (local)
INTEGER, INTENT(IN) :: IKU      ! Upper dimension in z direction
!
END SUBROUTINE INI_PARAM_ELEC
END INTERFACE
END MODULE MODI_INI_PARAM_ELEC
!
!      	#################################################################
        SUBROUTINE INI_PARAM_ELEC (HINIFILE, HLUOUT, HGETSVM, PRHO00,  &
                                   KRR, KND, PFDINFTY, IIU, IJU, IKU   )
!      	#################################################################
!
!!****  *INI_PARAM_ELEC* -  initialize the constants necessary 
!!                          for the electrical scheme.
!!
!!    PURPOSE
!!    -------
!!        The purpose of this routine is to initialize the constants used to 
!!	resolve the electrical scheme.
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!      None
!!
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!
!!    REFERENCE
!!    ---------
!!	Helsdon and Farley, 1987: A numerical study of a Montana thunderstorm: 
!!	  2. Model results versus observations involving electrical aspects.
!!	  J. Geophys. Res., 92, 5661-5675.
!!
!!	Takahashi, 1978: Riming electrification as a charge generation 
!!	  mechanism in thunderstorms. J. Atmos. Sci., 35, 1536-1548.
!!
!!	Gardiner et al., 1985: Measurements of initial potential gradient and
!!	  particles charges in a Montana supercell thunderstorm.
!!	  J. Geophys. Res., 90, 6079-6086.
!!
!!	Saunders et al., 1991: The effect of liquid water on thunderstorm
!!	  charging. J. Geophys. Res., 96, 11007-11017.
!!
!!    AUTHOR
!!    ------
!!      Gilles Molinie      * Laboratoire d'Aerologie*
!!
!!    MODIFICATIONS
!!    -------------
!!        C. Barthe  01/02/2004 coefficients f/b
!!        C. Barthe  21/05/2004 Add limitations for the NI processes
!!        C. Barthe  31/05/2004 Add constants for the inductive process
!!        C. Barthe  10/11/2009 Update to Masdev 4.8.1
!!        M. Chong      26/01/10  Small ions parameters 
!!                               +Fair weather field from Helsdon-Farley
!!                                (JGR, 1987, 5661-5675)
!!
!-------------------------------------------------------------------------------
!
!*	0.	DECLARATIONS
!		------------
!
USE MODD_CST
USE MODD_PARAMETERS
USE MODD_PARAM_ICE
USE MODD_RAIN_ICE_DESCR
USE MODD_RAIN_ICE_PARAM
USE MODD_ELEC_DESCR
USE MODD_ELEC_PARAM
USE MODD_ELEC_n
USE MODD_NSV, ONLY : NSV_ELECEND
!
USE MODI_MOMG
USE MODI_RRCOLSS
USE MODI_RZCOLX
USE MODI_RSCOLRG
USE MODI_VQZCOLX
!
USE MODD_VAR_ll
USE MODE_FMREAD
!
IMPLICIT NONE
!
!*	0.1	 Declaration of dummy arguments
!		
CHARACTER (LEN=*), INTENT(IN) :: HINIFILE ! name of the initial file
CHARACTER (LEN=*), INTENT(IN) :: HLUOUT   ! name for output-listing
                                          !  of nested models
CHARACTER (LEN=*), DIMENSION(:),INTENT(IN)  :: HGETSVM
INTEGER, INTENT(IN) :: KND      ! Number of intervals to integrate kernels
INTEGER, INTENT(IN) :: KRR      ! Number of moist variables
REAL,    INTENT(IN) :: PRHO00   ! Pressure at ground level
REAL,    INTENT(IN) :: PFDINFTY ! Factor used to define the "infinite" diameter
INTEGER, INTENT(IN) :: IIU      ! Upper dimension in x direction (local)
INTEGER, INTENT(IN) :: IJU      ! Upper dimension in y direction (local)
INTEGER, INTENT(IN) :: IKU      ! Upper dimension in z direction
!
!*	0.2	 Declaration of local variables
!
REAL, DIMENSION(IIU,IJU,IKU) :: Z3D               ! 3D array used to read  data
                                                  ! in initial file
INTEGER :: JK                 ! Loop index
REAL    :: ZESR               ! Mean efficiency of rain-aggregate collection
REAL    :: ZEGS               !  
REAL    :: ZEGR
REAL, DIMENSION(:,:), ALLOCATABLE :: ZMANSELL1, ZMANSELL2 ! Used to initialize
                                                          ! XMANSELL array
INTEGER             :: IGRID,ILENCH,IRESP
CHARACTER (LEN=100) :: YCOMMENT
CHARACTER (LEN=16)  :: YRECFM
CHARACTER (LEN=2)   :: YDIR
!
!-------------------------------------------------------------------------------
! constants for electricity
!
XEPSILON = 8.85E-12     ! Dielectric permittivity of the air
XECHARGE = 1.6E-19      ! Elementary charge (C) 
!
!*	1.	SHAPE PARAMETERS
!		----------------
!
XCXR = -1.0 ! Raindrop characteristic : XCXR (not declared in ini_rain_ice.f90)
!
! Individual charge  q(d) = e_x * d ** f_x with f_x = XFx 
!
XFC = 0.5   ! cloud 
XFR = 1.3   ! rain 
XFI = 0.5   ! pristine ice 
XFS = 1.3   ! snow
XFG = 2.0   ! graupel
XFH = 2.0   ! hail
!
! Min/max values of e_x
!
XEGMIN = 1.E-12
XEGMAX = 1.E-3 
!
XESMIN = 1.E-14
XESMAX = 1.E-4 
!
XEIMIN = 1.E-12
XEIMAX = 1.E-3 
!
XECMIN = 1.E-12
XECMAX = 1.E-3
! 
XERMIN = 1.E-14
XERMAX = 1.E-4
!
XEHMIN = 1.E-14
XEHMAX = 1.E-4 
!
!  E=E_0 * exp(k_e*z)
XE_0 = -100.
XKEF = -2.E-4            !  229.E-6
!
!  E=E_0 (b1 exp(-a1 z) + b2 exp(-a2 z) + b3 exp(-a3 z) : Helsdon-Farley, 1987
XE0_HF = -80.
XA1_HF = 4.5E-3
XB1_HF = 0.5
XA2_HF = 3.8E-4
XB2_HF = 0.65
XA3_HF = 1.0E-4
XB3_HF = 0.1
!
XIONCOMB = 1.6E-12
XF_POS = 1.4E-4
XF_NEG = 1.9E-4
XEXPMOB = 1.4E-4
!
XFCORONA = 2.E-20
XECORONA = 5000.
!
XJCURR_FW = -2.7E-12
!
!
!-------------------------------------------------------------------------------
!
!*	2.	COEFFICIENTS FOR CHARGE TRANSFERS
!		---------------------------------
!
! proportionality coefficient between mass transfer and charge transfer rates
! the mixing ratio is proportional to the volume of the particle
! the electric charge is proportional to the surface of the particle
!
XCOEF_RQ_V = 1
XCOEF_RQ_C = XFC / 3.0  ! XBC=3
XCOEF_RQ_R = XFR / XBR
XCOEF_RQ_I = XFI / XBI
XCOEF_RQ_S = XFS / XBS
XCOEF_RQ_G = XFG / XBG
XCOEF_RQ_H = XFH / XBH
!
!
!-------------------------------------------------------------------------------
!
!*	3.	HOMOGENEOUS NUCLEATION
!		----------------------
!
XALPHACQ = 3.         !>
XNUCQ    = 1.         ! >--- generic values
XLBDACQ  = 1.1E5      !>
!
XQHON = (1. / XRHOLW)
XQHON = XQHON * MOMG(XALPHACQ,XNUCQ,XFC+3.)
XQHON = XQHON / MOMG(XALPHACQ,XNUCQ,3.)
XQHON = XQHON / (XLBDACQ**XFC)
!
!
!-------------------------------------------------------------------------------
!
!*	4.	SEDIMENTATION
!		-------------
IF (ALLOCATED(XQTMIN)) DEALLOCATE(XQTMIN)       
IF (ALLOCATED(XRTMIN_ELEC)) DEALLOCATE(XRTMIN_ELEC)
!
IF (KRR == 6) THEN
  ALLOCATE( XQTMIN(6) )
  ALLOCATE( XRTMIN_ELEC(6) )
ELSE IF (KRR == 7) THEN
  ALLOCATE( XQTMIN(7) )
  ALLOCATE( XRTMIN_ELEC(7) )
END IF
!
XQTMIN(1) = 1.0E-17  !
XQTMIN(2) = 1.0E-17  !
XQTMIN(3) = 1.0E-17  ! ten particles per cubic meter that carried a charge
XQTMIN(4) = 1.0E-17  ! of one electron
XQTMIN(5) = 1.0E-17  !
XQTMIN(6) = 1.0E-17  !
IF (KRR == 7) XQTMIN(7) = 1.0E-17  !
!
XRTMIN_ELEC(1) = 1.0E-6  
XRTMIN_ELEC(2) = 1.0E-6 
XRTMIN_ELEC(3) = 1.0E-6
XRTMIN_ELEC(4) = 1.0E-6
XRTMIN_ELEC(5) = 1.0E-6
XRTMIN_ELEC(6) = 1.0E-6
IF (KRR == 7) XRTMIN_ELEC(7) = 1.0E-6
!
XLBDAR_MAXE = 2.E3 ! Less than 10000 particles in cube meter of cloud. 
XLBDAS_MAXE = 2.E3 ! Less than 10000 particles in cube meter of cloud. 
XLBDAG_MAXE = 2.E3 !
XLBDAH_MAXE = 2.E3 !
!
! Rain
!
XCEXVT = 0.4
XEXQSEDR = (XCXR - XFR - XDR) / (XCXR - XBR)
XFQSEDR  = XCR * (XCCR**(1 - XEXQSEDR)) * MOMG(XALPHAR,XNUR,XDR+XFR) * &
         ((XAR * MOMG(XALPHAR,XNUR,XBR))**(-XEXQSEDR)) * (PRHO00)**XCEXVT
!
! Ice
!
XEXQSEDI = (XDI + XFI) / XBI
XFQSEDI  = XC_I * MOMG(XALPHAI,XNUI,XDI+XFI) * (PRHO00**XCEXVT) * &
           (XAI * MOMG(XALPHAI,XNUI,XBI))**(-XEXQSEDI)  
!
! Snow
!
XEXQSEDS = (XCXS - XFS - XDS) / (XCXS - XBS)    
XFQSEDS  = XCS * (XCCS**(1 - XEXQSEDS)) * MOMG(XALPHAS,XNUS,XDS+XFS) * &
         ((XAS * MOMG(XALPHAS,XNUS,XBS))**(-XEXQSEDS)) * (PRHO00)**XCEXVT
!
! Graupeln 
!
XEXQSEDG = (XCXG - XFG - XDG) / (XCXG - XBG)    
XFQSEDG  = XCG * (XCCG**(1 - XEXQSEDG)) * MOMG(XALPHAG,XNUG,XDG+XFG) * &
         ((XAG * MOMG(XALPHAG,XNUG,XBG))**(-XEXQSEDG)) * (PRHO00)**XCEXVT
!
! Hail
!
XEXQSEDH = (XCXH - XFH - XDH) / (XCXH - XBH)    
XFQSEDH  = XCH * (XCCH**(1 - XEXQSEDH)) * MOMG(XALPHAH,XNUH,XDH+XFH) * &
         ((XAH * MOMG(XALPHAH,XNUH,XBH))**(-XEXQSEDH)) * (PRHO00)**XCEXVT
!
!
!-------------------------------------------------------------------------------
!
!*	5.	EVAPORATION OF RAINDROPS
!		------------------------
!
XQREVAV1 = (2. / XPI) * MOMG(XALPHAR,XNUR,XFR) / MOMG(XALPHAR,XNUR,2.)
XQREVAV2 = (XPI / XAR) * (MOMG(XALPHAR,XNUR,2.) / MOMG(XALPHAR,XNUR,XBR)) * &
           (XCXR - 2.) / (XCXR - XBR)
!
!
!-------------------------------------------------------------------------------
!
!*	6.	RIMING OF CLOUD DROPLETS ON SNOW
!		--------------------------------
!
XEXQSRIMCG = XCXS - XFS
XQSRIMCG   = XCCS * MOMG(XALPHAS,XNUS,XFS)
!
! The array containing the tabulated function M(fs,D_cs^lim)/M(fs) 
! is implemented in ini_rain_ice.f90
!
!
!-------------------------------------------------------------------------------
!
!*	7.	CONTACT FREEZING BETWEEN RAINDROPS AND PRISTINE ICE
!		---------------------------------------------------
!
XEXQRCFRIG = XCXR - XDR - XFR - 2.0
XQRCFRIG   = (XPI / 4.0) * XCR * XCCR * MOMG(XALPHAR,XNUR,XDR+XFR+2.) * &
              PRHO00**XCEXVT
!
!
!-------------------------------------------------------------------------------
!
!*	8.	INITIALIZATIONS FOR THE NON INDUCTIVE PROCESSES
!		-----------------------------------------------
!
! arrays allocation for NI charging rate
!
ALLOCATE( XNI_SDRYG(IIU, IJU, IKU) )
ALLOCATE( XNI_IDRYG(IIU, IJU, IKU) )
ALLOCATE( XNI_IAGGS(IIU, IJU, IKU) )
ALLOCATE( XIND_RATE(IIU, IJU, IKU) )
ALLOCATE( XEW(IIU, IJU, IKU) )
XEW(:,:,:) = 0.
!
SELECT CASE(HGETSVM(NSV_ELECEND))
  CASE ('READ')
    YRECFM='NI_IAGGS'
    CALL FMREAD(HINIFILE,YRECFM,HLUOUT,YDIR,Z3D,IGRID,ILENCH,  &
         YCOMMENT,IRESP)
    XNI_IAGGS(:,:,:) = Z3D(:,:,:)
    YRECFM='NI_IDRYG'
    CALL FMREAD(HINIFILE,YRECFM,HLUOUT,YDIR,Z3D,IGRID,ILENCH,  &
         YCOMMENT,IRESP)
    XNI_IDRYG(:,:,:) = Z3D(:,:,:)
    YRECFM='NI_SDRYG'
    CALL FMREAD(HINIFILE,YRECFM,HLUOUT,YDIR,Z3D,IGRID,ILENCH,  &
         YCOMMENT,IRESP)
    XNI_SDRYG(:,:,:) = Z3D(:,:,:)
    YRECFM='INDUC_CG'
    CALL FMREAD(HINIFILE,YRECFM,HLUOUT,YDIR,Z3D,IGRID,ILENCH,  &
         YCOMMENT,IRESP)
    XIND_RATE(:,:,:) = Z3D(:,:,:)
  CASE ('INIT')
    XNI_IAGGS(:,:,:) = 0.
    XNI_IDRYG(:,:,:) = 0.
    XNI_SDRYG(:,:,:) = 0.
    XIND_RATE(:,:,:) = 0.
END SELECT

!
!*      8.1     Gardiner et al. (1985) parameterization
!
IF (CNI_CHARGING == 'GARDI') THEN
  XLWCC = 0.1   ! g.m^-3
END IF
!
!
!*      8.2     Saunders et al. (1991) and 
!*              Saunders and Peck (1998) parameterizations
!
IF (CNI_CHARGING == 'SAUN1' .OR. CNI_CHARGING == 'SAUN2' .OR. &
    CNI_CHARGING == 'SAP98') THEN
!
! ice particle = the smallest particle (I-S and I-G collisions)
  XIMP = 3.76
  XINP = 2.5
  XIKP = 4.92E13
  XIMN = 2.54
  XINN = 2.8
  XIKN = 5.25E8
! 
! snow = the smallest particle (S-G collisions)
  XSMP = 0.44
  XSNP = 2.5
  XSKP = 52.8
  XSMN = 0.5
  XSNN = 2.8
  XSKN = 24
ENDIF
!
IF (CNI_CHARGING == 'SAP98' .OR. CNI_CHARGING == 'TERAR' .OR. &
    CNI_CHARGING == 'BSMP1' .OR. CNI_CHARGING == 'BSMP2')     &
  XINISAP = PRHO00**XCEXVT
!
!
!*      8.3    Takahashi (1978) parameterization
!
IF (CNI_CHARGING == 'TAKAH') THEN
!
! last column and line are duplicated for interpolation
  NIND_TEMP = 31
  NIND_LWC  = 28
  IF( .NOT.ALLOCATED(XMANSELL)) ALLOCATE( XMANSELL(NIND_LWC+1,NIND_TEMP+1))
  ALLOCATE( ZMANSELL1(29,16) )
  ALLOCATE( ZMANSELL2(29,16) )
  ZMANSELL1 = RESHAPE( &
(/  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  1.65,  3.3 ,  &
    4.95, 13.2 , 19.8 , 26.4 , 31.02, 33.0 , 42.9 , 46.2 , 49.5 ,  &
   52.8 , 49.5 , 39.6 , 36.3 , 32.34, 32.01, 32.01, 31.68, 31.35, 31.35, 31.35,&
    0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.33,  2.64,  4.95,  6.6 ,  &
    6.93, 15.18, 23.1 , 29.7 , 33.0 , 36.3 , 49.5 , 52.8 , 52.8 ,  &
   52.8 , 49.5 , 36.3 , 33.0 , 32.34, 32.01, 32.01, 31.35, 31.35, 31.35, 31.35,&
    0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.33,  3.3 ,  4.95,  6.6 ,  7.59,  &
    9.24, 17.16, 26.4 , 32.34, 36.3 , 39.6 , 52.8 , 56.1 , 56.1 ,  &
   56.1 , 42.9 , 33.0 , 32.01, 32.01, 31.68, 31.68, 31.02, 31.02, 30.36, 30.36,&
    0.0 ,  0.0 ,  0.0 ,  0.33,  2.97,  5.61,  7.26,  8.25,  9.9 ,  &
   10.56, 19.8 , 28.71, 36.3 , 39.6 , 46.2 , 56.1 , 59.4 , 59.4 ,  &
   59.4 , 42.9 , 31.35, 31.35, 31.68, 31.35, 30.69, 30.36, 31.02, 30.03, 30.03,&
    0.0 ,  0.0 ,  0.33,  2.64,  5.61,  7.59,  9.24,  9.9 , 11.22,  &
   11.88, 22.44, 31.35, 39.6 , 47.2 , 52.8 , 59.4 , 62.7 , 62.7 ,  &
   52.8 , 33.0 , 30.69, 30.69, 30.36, 30.69, 30.36, 30.03, 30.36, 30.03, 30.03,&
    0.0 ,  0.0 ,  0.33,  4.29,  7.26,  8.91, 10.23, 11.55, 12.21,  &
   13.2 , 24.09, 33.0 , 39.6 , 49.5 , 56.1 , 56.1 , 56.1 , 66.0 ,  &
   49.5 , 31.35, 30.03, 29.7 , 29.37, 29.37, 29.37, 29.04, 30.03, 29.04, 29.04,&
    0.0 ,  0.0 ,  2.31,  6.6 ,  8.91,  9.9 , 11.22, 13.2 , 13.2 ,  &
   14.85, 25.08, 36.3 , 42.9 , 49.5 , 52.8 , 46.2 , 42.9 , 52.8 ,  &
   42.9 , 28.05, 28.05, 29.71, 28.38, 28.71, 28.71, 28.71, 29.37, 28.71, 28.71,&
    0.0 ,  0.0 ,  4.29,  7.59,  9.9 , 10.23, 11.22, 14.85, 14.85,  &
   16.5 , 26.4 , 36.3 , 42.9 , 42.9 , 46.2 , 42.9 , 39.6 , 46.2 ,  &
   33.0 , 24.75, 26.4 , 27.39, 27.39, 27.72, 28.05, 28.38, 29.04, 28.05, 28.05,&
    0.0 ,  0.0 ,  6.27,  9.24, 10.56, 12.21, 11.88, 15.18, 15.84,  &
   16.5 , 27.39, 33.0 , 39.6 , 39.6 , 39.6 , 36.3 , 33.0 , 39.6 ,  &
   19.8 , 16.5 , 23.1 , 25.74, 26.73, 27.06, 27.39, 27.39, 28.38, 27.39, 27.39,&
    0.0 ,  0.66,  6.93,  9.57, 11.22, 12.87, 12.54, 15.51, 16.5 ,  &
   18.15, 27.39, 31.02, 36.3 , 33.0 , 29.7 , 23.1 , 19.8 , 26.4 ,  &
    9.9 ,  0.99, 20.46, 23.43, 25.41, 26.4 , 27.06, 27.06, 27.39, 27.06, 27.06,&
    0.0 ,  2.64,  7.59, 10.23, 11.88, 13.53, 13.2 , 15.84, 16.5 ,  &
   19.14, 27.06, 28.71, 33.0 , 26.4 , 21.45, 16.5 ,  9.9 ,  3.3 ,  &
    0.0 , -6.6 , 18.15, 21.45, 23.76, 25.08, 26.07, 26.73, 26.73, 26.73, 26.73,&
    0.0 ,  3.3 ,  8.25, 10.89, 11.88, 13.53, 13.86, 15.84, 16.83,  &
   18.81, 26.73, 27.39, 28.71, 21.45, 16.5 ,  3.3 ,  0.99, -0.99,  &
   -4.95,-16.5 , 16.5 , 19.8 , 22.77, 24.09, 25.08, 25.41, 25.74, 26.4 , 26.4 ,&
    0.0 ,  4.62,  8.91, 11.22, 12.21, 13.53, 14.85, 16.17, 16.83,  &
   18.81, 25.74, 26.4 , 26.4 , 16.5 ,  2.97,  0.0 , -1.98, -9.9 ,  &
  -11.55,-19.8 ,  3.3 , 18.15, 20.13, 23.1 , 23.76, 24.42, 25.41, 25.41, 25.41,&
    0.0 ,  5.8 ,  9.24, 11.22, 12.54, 13.86, 15.18, 15.84, 16.83,  &
   18.48, 24.42, 23.43, 22.44,  3.3 ,  0.0 , -1.98, -4.29, -9.9 ,  &
  -13.2 ,-26.4 ,  0.0 , 16.83, 19.14, 21.45, 23.1 , 23.76, 24.42, 24.75, 24.75,&
    0.0 ,  5.94,  9.57, 11.22, 12.54, 13.86, 14.85, 15.84, 16.5 ,  &
   17.82, 23.1 , 20.79, 19.47,  0.33, -1.32, -3.3 , -6.6 , -9.9 ,  &
  -14.85,-33.0 , -0.33, 14.85, 18.48, 19.8 , 21.78, 23.1 , 23.76, 24.42, 24.42,&
    0.0 ,  5.94,  9.57, 11.22, 12.54, 13.53, 14.85, 15.51, 16.5 ,  &
   16.83, 21.45, 17.82,  9.9 , -0.33, -2.31, -3.3 , -8.25, -9.99,  &
  -14.85,-33.0 , -1.32,  4.95, 17.49, 19.47, 20.79, 22.44, 23.43, 24.09, 24.09/)&
    ,(/29, 16/))
  ZMANSELL2 = RESHAPE( &
(/  0.0 ,  6.27,  9.57, 10.89, 12.21, 13.53, 14.52, 15.18, 15.84,  &
   16.17, 19.47,  9.9 ,  0.0 , -0.99, -2.97, -4.95, -9.99, -9.99,  &
  -14.85,-29.7 , -2.97,  3.3 , 16.83, 19.14, 19.47, 21.12, 22.44, 23.43, 23.43,&
    0.0 ,  5.94,  9.57, 10.89, 12.21, 13.2 , 14.19, 14.85, 15.18,  &
   15.51, 17.16,  3.3 , -0.33, -1.65, -3.3 , -6.6 , -9.99, -9.99,  &
  -13.2 ,-28.1 , -3.3 ,  2.64, 16.5 , 17.82, 19.14, 20.13, 21.45, 22.77, 22.77,&
    0.0 ,  5.61,  8.91, 10.89, 11.88, 13.2 , 13.86, 14.52, 14.85,  &
   14.85,  9.9 ,  1.65, -0.99, -1.98, -3.3 , -6.6 , -9.99, -9.99,  &
  -13.2 ,-26.4 , -3.3 ,  1.65, 13.2 , 17.49, 18.81, 19.8 , 20.79, 22.11, 22.11,&
    0.0 ,  5.28,  8.58, 10.56, 11.55, 12.54, 13.2 , 13.86, 14.19,  &
   13.86,  6.6 ,  0.0 , -1.32, -2.31, -3.3 , -6.6 , -9.99, -9.99,  &
  -13.2 ,-24.8 , -3.3 ,  1.32,  6.6 , 17.16, 18.48, 19.47, 20.46, 21.45, 21.45,&
    0.0 ,  4.95,  8.25,  9.9 , 11.22, 11.88, 12.54, 12.87, 13.2 ,  &
   13.2 ,  3.3 , -0.66, -1.98, -2.64, -3.3 , -6.6 , -9.9 , -9.9 ,  &
  -13.2 ,-23.1 , -3.3 ,  0.66,  4.95, 16.5 , 17.82, 18.81, 19.8 , 20.46, 20.46,&
    0.0 ,  4.29,  7.59,  9.57, 10.56, 11.55, 11.88, 11.88, 12.21,  &
   11.88,  2.64, -0.66, -2.31, -2.64, -3.3 , -6.6 , -9.9 , -9.9 ,  &
  -13.2 ,-21.5 , -3.3 ,  0.0 ,  4.29, 14.85, 17.16, 18.48, 19.47, 20.13, 20.13,&
    0.0 ,  3.96,  6.93,  8.91,  9.9 , 10.89, 10.89, 10.89, 10.89,  &
   10.56,  0.99, -0.66, -2.31, -2.64, -3.3 , -6.6 , -9.9 , -9.99,  &
  -13.2 ,-19.8 , -6.6 ,  0.0 ,  3.3 , 13.2 , 16.83, 18.15, 19.47, 19.8 , 19.8 ,&
    0.0 ,  2.97,  6.27,  8.25,  9.24,  9.9 , 10.23, 10.23,  9.9 ,  &
    9.57,  0.0 , -0.99, -2.31, -2.64, -3.3 , -6.6 , -9.9 , -9.99,  &
  -11.55,-18.2 , -9.9 ,  0.0 ,  3.3 , 11.55, 16.5 , 17.82, 18.81, 19.8 , 19.8 ,&
    0.0 ,  0.66,  5.61,  7.59,  8.91,  9.24,  9.24,  9.24,  8.91,  &
    8.58,  0.0 , -0.99, -1.98, -2.64, -3.3 , -6.6 , -9.9 , -9.9 ,  &
  -11.55,-17.5 , -6.6 ,  0.0 ,  2.97,  8.25, 16.5 , 17.16, 18.48, 19.47, 19.47,&
    0.0 ,  0.0 ,  4.29,  6.6 ,  7.59,  8.25,  8.25,  7.59,  7.92,  &
    7.59, -0.33, -1.32, -1.98, -2.64, -3.3 , -4.95, -9.9 , -9.9 ,  &
   -9.9 ,-16.5 , -6.6 ,  0.0 ,  2.97,  6.6 , 14.85, 16.83, 18.15, 19.47, 19.47,&
    0.0 ,  0.0 ,  2.64,  5.28,  6.93,  7.26,  7.59,  7.26,  6.93,  &
    6.6 , -0.66, -1.32, -1.98, -2.64, -3.3 , -4.29, -8.25, -9.9 ,  &
   -9.9 ,-16.5 , -6.6 ,  0.0 ,  2.64,  6.6 , 14.85, 16.5 , 17.82, 19.14, 19.14,&
    0.0 ,  0.0 ,  0.33,  3.63,  5.61,  6.6 ,  6.6 ,  6.6 ,  4.95,  &
    3.63, -0.66, -1.32, -1.98, -2.64, -3.3 , -3.3 , -6.6 , -8.25,  &
   -8.25,-16.5 , -6.6 ,  0.0 ,  2.64,  6.6 , 13.2 , 16.5 , 17.49, 18.81, 18.81,&
    0.0 ,  0.0 ,  0.0 ,  0.99,  3.3 ,  4.29,  4.29,  4.62,  3.3 ,  &
    2.97, -0.66, -1.32, -1.98, -2.64, -2.97, -2.97, -3.3 , -4.95,  &
   -4.95,-15.8 , -4.95,  0.0 ,  2.31,  6.6 , 11.55, 16.5 , 17.49, 18.15, 18.15,&
    0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.99,  3.3 ,  2.64,  2.31,  2.31,  &
    2.31, -0.66, -1.32, -1.98, -2.31, -2.97, -2.64, -2.97, -3.63,  &
   -4.95, -9.99, -4.95,  0.0 ,  2.31,  6.6 ,  9.9 , 14.85, 17.16, 18.15, 18.15,&
    0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.66,  0.99,  1.65,  1.98,  &
    1.65, -0.66, -1.32, -1.65, -2.31, -2.64, -2.64, -2.97, -2.97,  &
   -3.3 , -9.99, -3.3 ,  0.0 ,  2.31,  6.6 ,  9.9 , 14.85, 17.16, 18.15, 18.15,&
    0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.0 ,  0.66,  0.99,  1.65,  1.98,  &
    1.65, -0.66, -1.32, -1.65, -2.31, -2.64, -2.64, -2.97, -2.97,  &
   -3.3 , -9.99, -3.3 ,  0.0 ,  2.31,  6.6 ,  9.9 , 14.85, 17.16, 18.15, 18.15/)&        
    ,(/29, 16/)) 
  XMANSELL(:, 1:16) = ZMANSELL1(:,:)
  XMANSELL(:,17:32) = ZMANSELL2(:,:)
  DEALLOCATE(ZMANSELL1)
  DEALLOCATE(ZMANSELL2)
!
  XMANSELL(:,:) = XMANSELL(:,:) * 1.E-15 ! in C
END IF
!
!-------------------------------------------------------------------------------
!
!*	9.	NON_INDUCTIVE PROCESS: AGGREGATION OF ICE ON SNOW
!		-------------------------------------------------
!
!*      9.1     Helsdon and Farley (1987) parameterization
!
XFQIAGGSBH = 2.E-14  ! (C.) Constant for ice-snow charging process 
!
!
!*      9.2     Gardiner et al. (1985) parameterization
!
XFQIAGGSBG = (XPI / 4.0) * XCCS * XCS**4. * PRHO00**(4. * XCEXVT) * &
              MOMG(XALPHAS,XNUS,2.+4.*XDS) * 7.3 *          &
              MOMG(XALPHAI,XNUI,4.)
!
!
!*      9.3     Saunders et al.(1991) parameterization
!
XFQIAGGSBS = (XPI / 4.0) * XCCS
!
!
!*      9.4     Takahashi (1978) parameterization
!
IF (CNI_CHARGING == 'TAKAH') THEN
  XFQIAGGSBT1 = (XPI / 4.0) * XCCS * (PRHO00**XCEXVT) * XCS
  XFQIAGGSBT2 = 10 * MOMG(XALPHAS,XNUS,2.+XDS)
  XFQIAGGSBT3 = 5. * XCS * (PRHO00**XCEXVT) * MOMG(XALPHAI,XNUI,2.) * & 
                MOMG(XALPHAS,XNUS,2.+2*XDS) / ((1.E-4)**2 * 8. *      & 
                (XAI * MOMG(XALPHAI,XNUI,XBI))**(2 / XBI))  
END IF
!
!
!-------------------------------------------------------------------------------
!
!*	10.	ACCRETION OF RAINDROPS ON SNOW
!		------------------------------
!
IF( .NOT.ALLOCATED(XKER_Q_RACCSS)) ALLOCATE( XKER_Q_RACCSS(NACCLBDAS,NACCLBDAR) )
IF( .NOT.ALLOCATED(XKER_Q_RACCS)) ALLOCATE( XKER_Q_RACCS (NACCLBDAS,NACCLBDAR) )
IF( .NOT.ALLOCATED(XKER_Q_SACCRG)) ALLOCATE( XKER_Q_SACCRG(NACCLBDAR,NACCLBDAS) )
!
XFQRACCS = (XPI / 4.0) * XCCS * XCCR * (PRHO00**XCEXVT)
!
XLBQRACCS1  =      MOMG(XALPHAR,XNUR,2.+XFR)
XLBQRACCS2  = 2. * MOMG(XALPHAR,XNUR,1.+XFR) * MOMG(XALPHAS,XNUS,1.)
XLBQRACCS3  =      MOMG(XALPHAR,XNUR,XFR)    * MOMG(XALPHAS,XNUS,2.)
!
XLBQSACCRG1 =      MOMG(XALPHAS,XNUS,2.+XFS)
XLBQSACCRG2 = 2. * MOMG(XALPHAS,XNUS,1.+XFS) * MOMG(XALPHAR,XNUR,1.)
XLBQSACCRG3 =      MOMG(XALPHAS,XNUS,XFS)    * MOMG(XALPHAR,XNUR,2.)
!
ZESR = 1.0
!
CALL RRCOLSS (KND, XALPHAS, XNUS, XALPHAR, XNUR,                          &
              ZESR, XFR, XCS, XDS, XCR, XDR,                              &
              XACCLBDAS_MAX, XACCLBDAR_MAX, XACCLBDAS_MIN, XACCLBDAR_MIN, &
              PFDINFTY, XKER_Q_RACCSS, XAG, XBS, XAS                      )
!
CALL RZCOLX  (KND, XALPHAS, XNUS, XALPHAR, XNUR,                          &
              ZESR, XFR, XCS, XDS, XCR, XDR,                              &
              XACCLBDAS_MAX, XACCLBDAR_MAX, XACCLBDAS_MIN, XACCLBDAR_MIN, &
              PFDINFTY, XKER_Q_RACCS                                      )
!
CALL RSCOLRG (KND, XALPHAS, XNUS, XALPHAR, XNUR,                          &
              ZESR, XFS, XCS, XDS, XCR, XDR,                              &
              XACCLBDAS_MAX, XACCLBDAR_MAX, XACCLBDAS_MIN, XACCLBDAR_MIN, &
              PFDINFTY, XKER_Q_SACCRG, XAG, XBS, XAS                      )
!
!-------------------------------------------------------------------------------
!
!*	11.	DRY GROWTH OF GRAUPELN BY CAPTURE OF SNOW OR ICE
!		------------------------------------------------
!
!*      11.1    charge transfer associated to mass transfer
!
IF( .NOT.ALLOCATED(XKER_Q_SDRYG)) ALLOCATE( XKER_Q_SDRYG(NDRYLBDAG,NDRYLBDAS) )
!
XFQSDRYG = (XPI / 4.0) * XCCS * XCCG * (PRHO00**XCEXVT)
!
XLBQSDRYG1 =      MOMG(XALPHAS,XNUS,2.+XFS)
XLBQSDRYG2 = 2. * MOMG(XALPHAS,XNUS,1.+XFS) * MOMG(XALPHAG,XNUG,1.)
XLBQSDRYG3 =      MOMG(XALPHAS,XNUS,XFS)    * MOMG(XALPHAG,XNUG,2.)
!
ZEGS = 1. ! also initialized in ini_rain_ice_elec
!
CALL RZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
             ZEGS, XFS, XCG, XDG, XCS, XDS,                              &
             XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
             PFDINFTY, XKER_Q_SDRYG                                      )
!
!
!*      11.2    NI process: Heldson et Farley (1987) parameterization
!
IF (CNI_CHARGING == 'HELFA') THEN
  XHIDRYG = 2.E-15   ! Charge exchanged per collision between ice and graupel
  XHSDRYG = 2.E-14
!
  XFQSDRYGBH   = (XPI / 4.0) * XCCG * XCCS * (PRHO00**(XCEXVT)) * XHSDRYG 
! 
  XLBQSDRYGB4H =      MOMG(XALPHAS,XNUS,2.)  
  XLBQSDRYGB5H = 2. * MOMG(XALPHAS,XNUS,1.) * MOMG(XALPHAG,XNUG,1.) 
  XLBQSDRYGB6H =      MOMG(XALPHAG,XNUG,2.) 
!
  IF( .NOT.ALLOCATED(XKER_Q_SDRYGB)) ALLOCATE( XKER_Q_SDRYGB(NDRYLBDAG,NDRYLBDAS) )
  CALL RZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
               ZEGS, 0., XCG, XDG, XCS, XDS,                               &
               XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
               PFDINFTY, XKER_Q_SDRYGB                                     )
! Delta vqb1_sg
ENDIF
!
!
!*      11.3    NI process: Gardiner et al. (1985) parameterization
!
IF (CNI_CHARGING == 'GARDI') THEN 
  XFQIDRYGBG   = (XPI / 4.0) * XCCG * (PRHO00**(4. * XCEXVT)) * XCG**4. * &
                  7.3
  XLBQIDRYGBG  = MOMG(XALPHAI,XNUI,4.) * MOMG(XALPHAG,XNUG,2.+4.*XDG)
!
  XFQSDRYGBG   = (XPI / 4.0) * XCCS * XCCG * (PRHO00**(4. * XCEXVT)) *    &
                  7.3
  XLBQSDRYGB4G =      MOMG(XALPHAS,XNUS,4.) * MOMG(XALPHAG,XNUG,2.)
  XLBQSDRYGB5G = 2. * MOMG(XALPHAS,XNUS,5.) * MOMG(XALPHAG,XNUG,1.)
  XLBQSDRYGB6G =      MOMG(XALPHAS,XNUS,6.)    
!
  IF( .NOT.ALLOCATED(XKER_Q_SDRYGB)) ALLOCATE( XKER_Q_SDRYGB(NDRYLBDAG,NDRYLBDAS) )
  CALL VQZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
                ZEGS, 4., XCG, XDG, XCS, XDS, 4.,                           &
                XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
                PFDINFTY, XKER_Q_SDRYGB                                     )
END IF
!
!
!*      11.4    NI process: Saunders et al. (1991) and 
!*                          Saunders and Peck (1998) parameterizations
!
IF (CNI_CHARGING == 'SAUN1' .OR. CNI_CHARGING == 'SAUN2' .OR. &
    CNI_CHARGING == 'SAP98' .OR.                              &
    CNI_CHARGING == 'BSMP1' .OR. CNI_CHARGING == 'BSMP2' .OR. &
    CNI_CHARGING == 'TEEWC' .OR. CNI_CHARGING == 'TERAR') THEN
  XFQIDRYGBS   = (XPI / 4.0) * XCCG
  XFQSDRYGBS   = (XPI / 4.0) * XCCS * XCCG
  XLBQSDRYGB1S = MOMG(XALPHAG,XNUG,2.)
  XLBQSDRYGB2S = 2. * MOMG(XALPHAG,XNUG,1.)
!
  IF( .NOT.ALLOCATED(XKER_Q_SDRYGB1)) ALLOCATE( XKER_Q_SDRYGB1(NDRYLBDAG,NDRYLBDAS) )
  IF( .NOT.ALLOCATED(XKER_Q_SDRYGB2)) ALLOCATE( XKER_Q_SDRYGB2(NDRYLBDAG,NDRYLBDAS) )
!
! Positive charging region
  CALL VQZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
                ZEGS, XSMP, XCG, XDG, XCS, XDS, (1.+XSNP),                  &
                XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
                PFDINFTY, XKER_Q_SDRYGB1                                    )
!
! Negative charging region
  CALL VQZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
                ZEGS, XSMN, XCG, XDG, XCS, XDS, (1.+XSNN),                  &
                XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
                PFDINFTY, XKER_Q_SDRYGB2                                    )
ENDIF
!
!
!*      11.5    NI process: Takahashi (1978) parameterization
!
IF (CNI_CHARGING == 'TAKAH') THEN
!
! IDRYG_boun
  XFQIDRYGBT1 = (XPI / 4.0) * XCCG * (PRHO00**XCEXVT) * XCG
  XFQIDRYGBT2 = 10.0 * MOMG(XALPHAG,XNUG,2.+XDG) 
  XFQIDRYGBT3 = 5.0 * XCG * (PRHO00**XCEXVT) * MOMG(XALPHAI,XNUI,2.) *    & 
                MOMG(XALPHAG,XNUG,2.+2.*XDG) / ((2.E-4)**2 * 8. *         & 
               (XAI * MOMG(XALPHAI,XNUI,XBI))**(2 / XBI))  
!
! SDRYG_boun
  XFQSDRYGBT1  = (XPI / 4.0) * XCCG * (PRHO00**XCEXVT) * XCCS
  XFQSDRYGBT2  = XCG * MOMG(XALPHAG,XNUG,XDG) * MOMG(XALPHAS,XNUS,2.)
  XFQSDRYGBT3  = XCS * MOMG(XALPHAS,XNUS,2.+XDS)
  XFQSDRYGBT4  = XCG * MOMG(XALPHAG,XNUG,2.+XDG)
  XFQSDRYGBT5  = XCS * MOMG(XALPHAG,XNUG,2.) * MOMG(XALPHAS,XNUS,XDS)
  XFQSDRYGBT6  = 2. * XCG * MOMG(XALPHAG,XNUG,1.+XDG) * MOMG(XALPHAS,XNUS,1.)
  XFQSDRYGBT7  = 2. * XCS * MOMG(XALPHAG,XNUG,1.) * MOMG(XALPHAS,XNUS,1.+XDS)
  XFQSDRYGBT8  = 5. * (PRHO00**XCEXVT) / ((1.E-4)**2 * 8.)  
  XFQSDRYGBT9  = MOMG(XALPHAG,XNUG,2.) * MOMG(XALPHAS,XNUS,2.)
  XFQSDRYGBT10 = MOMG(XALPHAS,XNUS,4.)
  XFQSDRYGBT11 = 2. * MOMG(XALPHAG,XNUG,1.) * MOMG(XALPHAS,XNUS,3.)
!
  IF( .NOT.ALLOCATED(XKER_Q_SDRYGB)) ALLOCATE( XKER_Q_SDRYGB(NDRYLBDAG,NDRYLBDAS) )
  CALL VQZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
                ZEGS, 2., XCG, XDG, XCS, XDS, 2.,                           &
                XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
                PFDINFTY, XKER_Q_SDRYGB                                     )
END IF
!
!
!*      11.6    NI process: limit the charge exchanged during QSDRYG_boun
!
IF (CNI_CHARGING == 'TAKAH' .OR. CNI_CHARGING == 'SAP98' .OR. &
    CNI_CHARGING == 'SAUN1' .OR. CNI_CHARGING == 'SAUN2' .OR. &
    CNI_CHARGING == 'GARDI' .OR.                              &
    CNI_CHARGING == 'BSMP1' .OR. CNI_CHARGING == 'BSMP2' .OR. &
    CNI_CHARGING == 'TEEWC' .OR. CNI_CHARGING == 'TERAR') THEN
  XAUX_LIM  = (XPI / 4.0) * XCCG * XCCS * (PRHO00**(XCEXVT)) 
  XAUX_LIM1 =      MOMG(XALPHAS,XNUS,2.)  
  XAUX_LIM2 = 2. * MOMG(XALPHAS,XNUS,1.) * MOMG(XALPHAG,XNUG,1.) 
  XAUX_LIM3 =      MOMG(XALPHAG,XNUG,2.)
  IF( .NOT.ALLOCATED(XKER_Q_LIMSG)) ALLOCATE( XKER_Q_LIMSG(NDRYLBDAG,NDRYLBDAS) )
  CALL RZCOLX (KND, XALPHAG, XNUG, XALPHAS, XNUS,                          &
               ZEGS, 0., XCG, XDG, XCS, XDS,                               &
               XDRYLBDAG_MAX, XDRYLBDAS_MAX, XDRYLBDAG_MIN, XDRYLBDAS_MIN, &
               PFDINFTY, XKER_Q_LIMSG)
ENDIF
!
!
!-------------------------------------------------------------------------------
!
!*	12.	DRY GROWTH OF GRAUPELN BY CAPTURE OF RAINDROP
!		---------------------------------------------
!
IF( .NOT.ALLOCATED(XKER_Q_RDRYG)) ALLOCATE( XKER_Q_RDRYG(NDRYLBDAG,NDRYLBDAR) ) 
!
XFQRDRYG = (XPI / 4.0) * XCCG * XCCR * (PRHO00**XCEXVT)
!
XLBQRDRYG1 =      MOMG(XALPHAR,XNUR,2.+XFR)
XLBQRDRYG2 = 2. * MOMG(XALPHAR,XNUR,1.+XFR) * MOMG(XALPHAG,XNUG,1.)
XLBQRDRYG3 =      MOMG(XALPHAR,XNUR,XFR)    * MOMG(XALPHAG,XNUG,2.)
!
ZEGR = 1.0 
!
CALL RZCOLX (KND, XALPHAG, XNUG, XALPHAR, XNUR,                            & 
             ZEGR, XFR, XCG, XDG, XCR, XDR,                                &
             XDRYLBDAG_MAX, XDRYLBDAR_MAX, XDRYLBDAG_MIN, XDRYLBDAR_MIN,   &
             PFDINFTY, XKER_Q_RDRYG                                        )
!
!
!-------------------------------------------------------------------------------
!
!*	13.	UPDATE THE Q=f(D) RELATION
!		--------------------------
!
XFQUPDC   = 400.E6 * MOMG(XALPHACQ,XNUCQ,XFC) / XLBDACQ**XFC ! Nc~400E6 m-3 as 
                                                          ! proposed for RCHONI
!
XFQUPDR   = XCCR * MOMG(XALPHAR,XNUR,XFR)
XEXFQUPDI = (XFI/XBI)
XFQUPDI   = MOMG(XALPHAI,XNUI,XFI) * (XAI*MOMG(XALPHAI,XNUI,XBI))**(-XEXFQUPDI)
XFQUPDS   = XCCS * MOMG(XALPHAS,XNUS,XFS)
XFQUPDG   = XCCG * MOMG(XALPHAG,XNUG,XFG)
XFQUPDH   = XCCH * MOMG(XALPHAH,XNUH,XFH)
!
!
!------------------------------------------------------------------------------
!
!*      14.     INDUCTIVE PROCESS
!               -----------------
!
! d = 15 microns and N_c = 400 cm**(-3)
!
XCOLCG_IND = 0.8
XEBOUND    = 0.1
XALPHA_IND = 0.07    ! moderate inductive charging
XCOS_THETA = 0.2  
!
XIND1 = (XPI**3 / 8.) * (15.E-6)**2 * &
        PRHO00**(XCEXVT) * XCG * 400.E6 * XCCG * &
        XCOLCG_IND * XEBOUND * XALPHA_IND
XIND2 = XPI * XEPSILON * XCOS_THETA * MOMG(XALPHAG,XNUG,2.+XDG)
XIND3 = MOMG(XALPHAG,XNUG,XDG+XFG) / 3.
!
!-------------------------------------------------------------------------------
!
!*	15.	LIGHTNING FLASHES
!		-----------------
! 
XFQLIGHTC  = 660. * MOMG(3.,3.,2.) / MOMG(3.,3.,3.)   ! PI/A*lbda^(b-2) = 660.
!
XFQLIGHTR  = XPI * XCCR * MOMG(XALPHAR,XNUR,2.)
XEXQLIGHTR = XCXR - 2.
!
XEXQLIGHTI = 2. / XBI
XFQLIGHTI  = XPI / 4. * MOMG(XALPHAI,XNUI,2.) *                   &
            (XAI * MOMG(XALPHAI,XNUI,XBI))**(-XEXQLIGHTI)
!
XFQLIGHTS  = XPI * XCCS * MOMG(XALPHAS,XNUS,2.)
XEXQLIGHTS = XCXS - 2.
!
XFQLIGHTG  = XPI * XCCG * MOMG(XALPHAG,XNUG,2.)
XEXQLIGHTG = XCXG - 2.
!
IF (IP == 1) THEN
  IF( .NOT.ALLOCATED(XNEUT_POS)) ALLOCATE( XNEUT_POS(NLGHTMAX) )
  IF( .NOT.ALLOCATED(XNEUT_NEG)) ALLOCATE( XNEUT_NEG(NLGHTMAX) )
  XNEUT_POS(:) = 0.
  XNEUT_NEG(:) = 0.
ENDIF
!
XALT_CG = 2000.  ! m
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE INI_PARAM_ELEC

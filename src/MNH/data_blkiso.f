!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 data_blkiso.f 2006/05/18 13:07:25
!-----------------------------------------------------------------
C=======================================================================
C
C *** ISORROPIA CODE
C *** BLOCK DATA BLKISO
C *** THIS SUBROUTINE PROVIDES INITIAL (DEFAULT) VALUES TO PROGRAM
C     PARAMETERS VIA DATA STATEMENTS
C
C *** COPYRIGHT 1996-2000, UNIVERSITY OF MIAMI, CARNEGIE MELLON UNIVERSITY
C *** WRITTEN BY ATHANASIOS NENES
C
C=======================================================================
C
      BLOCK DATA BLKISO
      INCLUDE 'isrpia.inc'
C
C *** DEFAULT VALUES *************************************************
C
      DATA TEMP/298.0/, R/82.0567D-6/, RH/0.9D0/, EPS/1D-6/, MAXIT/100/,
     &     TINY/1D-20/, GREAT/1D10/, ZERO/0.0D0/, ONE/1.0D0/,NSWEEP/4/, 
     &     TINY2/1D-11/,NDIV/5/
C
      DATA MOLAL/NIONS*0.0D0/, MOLALR/NPAIR*0.0D0/, GAMA/NPAIR*0.1D0/,
     &     GAMOU/NPAIR*1D10/,  GAMIN/NPAIR*1D10/,   CALAIN/.TRUE./,
     &     CALAOU/.TRUE./,     EPSACT/5D-2/,        ICLACT/0/,
     &     IACALC/1/,          WFTYP/2/
C
      DATA ERRSTK/NERRMX*0/,   ERRMSG/NERRMX*' '/,  NOFER/0/, 
     &     STKOFL/.FALSE./ 
C
      DATA IPROB/0/, METSTBL/0/
C
      DATA VERSION /'1.5 (12/03/03)'/
C
C *** OTHER PARAMETERS ***********************************************
C
      DATA SMW/58.5,142.,85.0,132.,80.0,53.5,98.0,98.0,115.,63.0,
     &         36.5,120.,247./
     &     IMW/ 1.0,23.0,18.0,35.5,96.0,97.0,63.0/,
     &     WMW/23.0,98.0,17.0,63.0,36.5/
C
      DATA ZZ/1,2,1,2,1,1,2,1,1,1,1,1,2/, Z /1,1,1,1,2,1,1/
C
C *** ZSR RELATIONSHIP PARAMETERS **************************************
C
C awas= ammonium sulfate
C
      DATA AWAS/33*100.,30,30,30,29.54,28.25,27.06,25.94,
     & 24.89,23.90,22.97,22.10,21.27,20.48,19.73,19.02,18.34,17.69,
     & 17.07,16.48,15.91,15.37,14.85,14.34,13.86,13.39,12.94,12.50,
     & 12.08,11.67,11.27,10.88,10.51,10.14, 9.79, 9.44, 9.10, 8.78,
     &  8.45, 8.14, 7.83, 7.53, 7.23, 6.94, 6.65, 6.36, 6.08, 5.81,
     &  5.53, 5.26, 4.99, 4.72, 4.46, 4.19, 3.92, 3.65, 3.38, 3.11,
     &  2.83, 2.54, 2.25, 1.95, 1.63, 1.31, 0.97, 0.63, 0.30, 0.001/
C
C awsn= sodium nitrate
C
      DATA AWSN/ 9*1.e5,685.59,
     & 451.00,336.46,268.48,223.41,191.28,
     & 167.20,148.46,133.44,121.12,110.83,
     & 102.09,94.57,88.03,82.29,77.20,72.65,68.56,64.87,61.51,58.44,
     & 55.62,53.03,50.63,48.40,46.32,44.39,42.57,40.87,39.27,37.76,
     & 36.33,34.98,33.70,32.48,31.32,30.21,29.16,28.14,27.18,26.25,
     & 25.35,24.50,23.67,22.87,22.11,21.36,20.65,19.95,19.28,18.62,
     & 17.99,17.37,16.77,16.18,15.61,15.05,14.51,13.98,13.45,12.94,
     & 12.44,11.94,11.46,10.98,10.51,10.04, 9.58, 9.12, 8.67, 8.22,
     &  7.77, 7.32, 6.88, 6.43, 5.98, 5.53, 5.07, 4.61, 4.15, 3.69,
     &  3.22, 2.76, 2.31, 1.87, 1.47, 1.10, 0.77, 0.48, 0.23, 0.001/
C
C awsc= sodium chloride
C
      DATA AWSC/
     &  100., 100., 100., 100., 100., 100., 100., 100., 100., 100.,
     &  100., 100., 100., 100., 100., 100., 100., 100., 100.,16.34,
     & 16.28,16.22,16.15,16.09,16.02,15.95,15.88,15.80,15.72,15.64,
     & 15.55,15.45,15.36,15.25,15.14,15.02,14.89,14.75,14.60,14.43,
     & 14.25,14.04,13.81,13.55,13.25,12.92,12.56,12.19,11.82,11.47,
     & 11.13,10.82,10.53,10.26,10.00, 9.76, 9.53, 9.30, 9.09, 8.88,
     &  8.67, 8.48, 8.28, 8.09, 7.90, 7.72, 7.54, 7.36, 7.17, 6.99,
     &  6.81, 6.63, 6.45, 6.27, 6.09, 5.91, 5.72, 5.53, 5.34, 5.14,
     &  4.94, 4.74, 4.53, 4.31, 4.09, 3.86, 3.62, 3.37, 3.12, 2.85,
     &  2.58, 2.30, 2.01, 1.72, 1.44, 1.16, 0.89, 0.64, 0.40, 0.18/
C
C awac= ammonium chloride
C
      DATA AWAC/
     &  100., 100., 100., 100., 100., 100., 100., 100., 100., 100.,
     &  100., 100., 100., 100., 100., 100., 100., 100., 100.,31.45,
     & 31.30,31.14,30.98,30.82,30.65,30.48,30.30,30.11,29.92,29.71,
     & 29.50,29.29,29.06,28.82,28.57,28.30,28.03,27.78,27.78,27.77,
     & 27.77,27.43,27.07,26.67,26.21,25.73,25.18,24.56,23.84,23.01,
     & 22.05,20.97,19.85,18.77,17.78,16.89,16.10,15.39,14.74,14.14,
     & 13.59,13.06,12.56,12.09,11.65,11.22,10.81,10.42,10.03, 9.66,
     &  9.30, 8.94, 8.59, 8.25, 7.92, 7.59, 7.27, 6.95, 6.63, 6.32,
     &  6.01, 5.70, 5.39, 5.08, 4.78, 4.47, 4.17, 3.86, 3.56, 3.25,
     &  2.94, 2.62, 2.30, 1.98, 1.65, 1.32, 0.97, 0.62, 0.26, 0.13/
C
C awss= sodium sulfate
C
      DATA AWSS/34*1.e5,23*14.30,14.21,12.53,11.47,
     & 10.66,10.01, 9.46, 8.99, 8.57, 8.19, 7.85, 7.54, 7.25, 6.98,
     &  6.74, 6.50, 6.29, 6.08, 5.88, 5.70, 5.52, 5.36, 5.20, 5.04,
     &  4.90, 4.75, 4.54, 4.34, 4.14, 3.93, 3.71, 3.49, 3.26, 3.02,
     &  2.76, 2.49, 2.20, 1.89, 1.55, 1.18, 0.82, 0.49, 0.22, 0.001/
C
C awab= ammonium bisulfate
C
      DATA AWAB/356.45,296.51,253.21,220.47,194.85,
     & 174.24,157.31,143.16,131.15,120.82,
     & 111.86,103.99,97.04,90.86,85.31,80.31,75.78,71.66,67.90,64.44,
     &  61.25,58.31,55.58,53.04,50.68,48.47,46.40,44.46,42.63,40.91,
     &  39.29,37.75,36.30,34.92,33.61,32.36,31.18,30.04,28.96,27.93,
     &  26.94,25.99,25.08,24.21,23.37,22.57,21.79,21.05,20.32,19.63,
     &  18.96,18.31,17.68,17.07,16.49,15.92,15.36,14.83,14.31,13.80,
     &  13.31,12.83,12.36,11.91,11.46,11.03,10.61,10.20, 9.80, 9.41,
     &   9.02, 8.64, 8.28, 7.91, 7.56, 7.21, 6.87, 6.54, 6.21, 5.88,
     &   5.56, 5.25, 4.94, 4.63, 4.33, 4.03, 3.73, 3.44, 3.14, 2.85,
     &   2.57, 2.28, 1.99, 1.71, 1.42, 1.14, 0.86, 0.57, 0.29, 0.001/
C
C awsa= sulfuric acid
C
      DATA AWSA/
     & 34.0,33.56,29.22,26.55,24.61,23.11,21.89,20.87,19.99,
     & 19.21,18.51,17.87,17.29,16.76,16.26,15.8,15.37,14.95,14.56,
     & 14.20,13.85,13.53,13.22,12.93,12.66,12.40,12.14,11.90,11.67,
     & 11.44,11.22,11.01,10.8,10.60,10.4,10.2,10.01,9.83,9.65,9.47,
     & 9.3,9.13,8.96,8.81,8.64,8.48,8.33,8.17,8.02,7.87,7.72,7.58,
     & 7.44,7.30,7.16,7.02,6.88,6.75,6.61,6.48,6.35,6.21,6.08,5.95,
     & 5.82,5.69,5.56,5.44,5.31,5.18,5.05,4.92,4.79,4.66,4.53,4.40,
     & 4.27,4.14,4.,3.87,3.73,3.6,3.46,3.31,3.17,3.02,2.87,2.72,
     & 2.56,2.4,2.23,2.05,1.87,1.68,1.48,1.27,1.05,0.807,0.552,0.281/
C
C awlc= (NH4)3H(SO4)2
C
      DATA AWLC/34*1.e5,17.0,16.5,15.94,15.31,14.71,14.14,
     & 13.60,13.08,12.59,12.12,11.68,11.25,10.84,10.44,10.07, 9.71,
     &  9.36, 9.02, 8.70, 8.39, 8.09, 7.80, 7.52, 7.25, 6.99, 6.73,
     &  6.49, 6.25, 6.02, 5.79, 5.57, 5.36, 5.15, 4.95, 4.76, 4.56,
     &  4.38, 4.20, 4.02, 3.84, 3.67, 3.51, 3.34, 3.18, 3.02, 2.87,
     &  2.72, 2.57, 2.42, 2.28, 2.13, 1.99, 1.85, 1.71, 1.57, 1.43,
     &  1.30, 1.16, 1.02, 0.89, 0.75, 0.61, 0.46, 0.32, 0.16, 0.001/
C
C awan= ammonium nitrate
C
      DATA AWAN/31*1.e5,
     &       97.17,92.28,87.66,83.15,78.87,74.84,70.98,67.46,64.11,
     & 60.98,58.07,55.37,52.85,50.43,48.24,46.19,44.26,42.40,40.70,
     & 39.10,37.54,36.10,34.69,33.35,32.11,30.89,29.71,28.58,27.46,
     & 26.42,25.37,24.33,23.89,22.42,21.48,20.56,19.65,18.76,17.91,
     & 17.05,16.23,15.40,14.61,13.82,13.03,12.30,11.55,10.83,10.14,
     &  9.44, 8.79, 8.13, 7.51, 6.91, 6.32, 5.75, 5.18, 4.65, 4.14,
     &  3.65, 3.16, 2.71, 2.26, 1.83, 1.42, 1.03, 0.66, 0.30, 0.001/
C
C awsb= sodium bisulfate
C
      DATA AWSB/173.72,156.88,142.80,130.85,120.57,
     & 111.64,103.80,96.88,90.71,85.18,
     & 80.20,75.69,71.58,67.82,64.37,61.19,58.26,55.53,53.00,50.64,
     & 48.44,46.37,44.44,42.61,40.90,39.27,37.74,36.29,34.91,33.61,
     & 32.36,31.18,30.05,28.97,27.94,26.95,26.00,25.10,24.23,23.39,
     & 22.59,21.81,21.07,20.35,19.65,18.98,18.34,17.71,17.11,16.52,
     & 15.95,15.40,14.87,14.35,13.85,13.36,12.88,12.42,11.97,11.53,
     & 11.10,10.69,10.28, 9.88, 9.49, 9.12, 8.75, 8.38, 8.03, 7.68,
     &  7.34, 7.01, 6.69, 6.37, 6.06, 5.75, 5.45, 5.15, 4.86, 4.58,
     &  4.30, 4.02, 3.76, 3.49, 3.23, 2.98, 2.73, 2.48, 2.24, 2.01,
     &  1.78, 1.56, 1.34, 1.13, 0.92, 0.73, 0.53, 0.35, 0.17, 0.001/
C
C *** END OF BLOCK DATA SUBPROGRAM *************************************
C
      END


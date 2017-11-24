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
!-----------------------------------------------------------------
!-----------------------------------------------------------------

MODULE MODI_IO_ll
!
INTERFACE 
  SUBROUTINE INITIO_ll()
  END SUBROUTINE INITIO_ll

  SUBROUTINE OPEN_ll(&
       TPFILE,  &
       MODE,    &
       COMM,    &
       STATUS,  &
       ACCESS,  &
       IOSTAT,  &
       FORM,    &
       RECL,    &
       BLANK,   &
       POSITION,&
       DELIM,    &
       PAD,      &
       KNB_PROCIO,&
       KMELEV,&
       OPARALLELIO)

    USE MODD_IO_ll, ONLY : TFILEDATA

    TYPE(TFILEDATA), INTENT(INOUT)         :: TPFILE
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: MODE
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: STATUS
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: ACCESS
    INTEGER,         INTENT(OUT)           :: IOSTAT
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: FORM
    INTEGER,         INTENT(IN),  OPTIONAL :: RECL
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: BLANK
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: POSITION
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: DELIM
    CHARACTER(len=*),INTENT(IN),  OPTIONAL :: PAD
    INTEGER,         INTENT(IN),  OPTIONAL :: COMM
    INTEGER,         INTENT(IN),  OPTIONAL :: KNB_PROCIO
    INTEGER(KIND=LFI_INT), INTENT(IN),  OPTIONAL :: KMELEV
    LOGICAL,         INTENT(IN),  OPTIONAL :: OPARALLELIO
  END SUBROUTINE OPEN_ll
  
  SUBROUTINE CLOSE_ll(TPFILE,IOSTAT,STATUS,OPARALLELIO)
  USE MODD_IO_ll, ONLY : TFILEDATA

  TYPE(TFILEDATA),  INTENT(INOUT)         :: TPFILE
  INTEGER,          INTENT(OUT), OPTIONAL :: IOSTAT
  CHARACTER(LEN=*), INTENT(IN),  OPTIONAL :: STATUS
  LOGICAL,          INTENT(IN),  OPTIONAL :: OPARALLELIO
  END SUBROUTINE CLOSE_ll

END INTERFACE
!
END MODULE MODI_IO_ll

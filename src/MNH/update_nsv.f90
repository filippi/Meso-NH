!MNH_LIC Copyright 2001-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!     ######spl
        MODULE MODI_UPDATE_NSV
!       ######################
!
INTERFACE 
  SUBROUTINE UPDATE_NSV(KMI)
  INTEGER, INTENT(IN) :: KMI ! Model index
  END SUBROUTINE UPDATE_NSV
!
END INTERFACE
END MODULE MODI_UPDATE_NSV
!     ######spl
    SUBROUTINE UPDATE_NSV(KMI)
!   ##########################

!!****  *UPDATE_NSV* - routine that updates the NSV_* variables for the
!!                   current model. It is intended to be called from 
!!                   any MesoNH routine WITH or WITHOUT $n before using 
!!                   the NSV_* variables.
!!  Modify (Escobar ) 2/2014 : add Forefire var
!!  Modify (Vie) 2016 : add LIMA
!!         V. Vionnet 7/2017 : add blowing snow var
!  P. Wautelet 10/04/2019: replace ABORT and STOP calls by Print_msg
!  P. Wautelet 10/03/2021: add CSVNAMES and CSVNAMES_A to store the name of all the scalar variables
!-------------------------------------------------------------------------------
!
USE MODD_CONF, ONLY : NVERB
USE MODD_NSV

use mode_msg

IMPLICIT NONE 

INTEGER, INTENT(IN) :: KMI ! Model index
!
! STOP if INI_NSV has not be called yet
IF (.NOT. LINI_NSV) THEN
  call Print_msg( NVERB_FATAL, 'GEN', 'UPDATE_NSV', 'can not continue because INI_NSV was not called' )
END IF
!
! Update the NSV_* variables from original NSV_*_A arrays
! that have been initialized in ini_nsv.f90 for model KMI
!
CSVNAMES => CSVNAMES_A(:,KMI)

NSV         = NSV_A(KMI)
NSV_USER    = NSV_USER_A(KMI)
NSV_C2R2    = NSV_C2R2_A(KMI)
NSV_C2R2BEG = NSV_C2R2BEG_A(KMI)
NSV_C2R2END = NSV_C2R2END_A(KMI)
NSV_C1R3    = NSV_C1R3_A(KMI)
NSV_C1R3BEG = NSV_C1R3BEG_A(KMI)
NSV_C1R3END = NSV_C1R3END_A(KMI)
!
NSV_LIMA          = NSV_LIMA_A(KMI)
NSV_LIMA_BEG      = NSV_LIMA_BEG_A(KMI)
NSV_LIMA_END      = NSV_LIMA_END_A(KMI)
NSV_LIMA_NC       = NSV_LIMA_NC_A(KMI)
NSV_LIMA_NR       = NSV_LIMA_NR_A(KMI)
NSV_LIMA_CCN_FREE = NSV_LIMA_CCN_FREE_A(KMI)
NSV_LIMA_CCN_ACTI = NSV_LIMA_CCN_ACTI_A(KMI)
NSV_LIMA_SCAVMASS = NSV_LIMA_SCAVMASS_A(KMI)
NSV_LIMA_NI       = NSV_LIMA_NI_A(KMI)
NSV_LIMA_IFN_FREE = NSV_LIMA_IFN_FREE_A(KMI)
NSV_LIMA_IFN_NUCL = NSV_LIMA_IFN_NUCL_A(KMI)
NSV_LIMA_IMM_NUCL = NSV_LIMA_IMM_NUCL_A(KMI)
NSV_LIMA_HOM_HAZE = NSV_LIMA_HOM_HAZE_A(KMI)
!
NSV_ELEC    = NSV_ELEC_A(KMI)
NSV_ELECBEG = NSV_ELECBEG_A(KMI)
NSV_ELECEND = NSV_ELECEND_A(KMI)
NSV_CHEM    = NSV_CHEM_A(KMI)
NSV_CHEMBEG = NSV_CHEMBEG_A(KMI)
NSV_CHEMEND = NSV_CHEMEND_A(KMI)
NSV_CHGS    = NSV_CHGS_A(KMI)
NSV_CHGSBEG = NSV_CHGSBEG_A(KMI)
NSV_CHGSEND = NSV_CHGSEND_A(KMI)
NSV_CHAC    = NSV_CHAC_A(KMI)
NSV_CHACBEG = NSV_CHACBEG_A(KMI)
NSV_CHACEND = NSV_CHACEND_A(KMI)
NSV_CHIC    = NSV_CHIC_A(KMI)
NSV_CHICBEG = NSV_CHICBEG_A(KMI)
NSV_CHICEND = NSV_CHICEND_A(KMI)
NSV_LNOX    = NSV_LNOX_A(KMI)
NSV_LNOXBEG = NSV_LNOXBEG_A(KMI)
NSV_LNOXEND = NSV_LNOXEND_A(KMI)
NSV_DST     = NSV_DST_A(KMI)
NSV_DSTBEG  = NSV_DSTBEG_A(KMI)
NSV_DSTEND  = NSV_DSTEND_A(KMI)
NSV_DSTDEP     = NSV_DSTDEP_A(KMI)
NSV_DSTDEPBEG  = NSV_DSTDEPBEG_A(KMI)
NSV_DSTDEPEND  = NSV_DSTDEPEND_A(KMI)
NSV_SLT     = NSV_SLT_A(KMI)
NSV_SLTBEG  = NSV_SLTBEG_A(KMI)
NSV_SLTEND  = NSV_SLTEND_A(KMI)
NSV_SLTDEPBEG  = NSV_SLTDEPBEG_A(KMI)
NSV_SLTDEPEND  = NSV_SLTDEPEND_A(KMI)
NSV_AER     = NSV_AER_A(KMI)
NSV_AERBEG  = NSV_AERBEG_A(KMI)
NSV_AEREND  = NSV_AEREND_A(KMI)
NSV_AERDEPBEG  = NSV_AERDEPBEG_A(KMI)
NSV_AERDEPEND  = NSV_AERDEPEND_A(KMI)
NSV_LG      = NSV_LG_A(KMI)
NSV_LGBEG   = NSV_LGBEG_A(KMI)
NSV_LGEND   = NSV_LGEND_A(KMI)
NSV_PP      = NSV_PP_A(KMI)
NSV_PPBEG   = NSV_PPBEG_A(KMI)
NSV_PPEND   = NSV_PPEND_A(KMI)
#ifdef MNH_FOREFIRE
NSV_FF      = NSV_FF_A(KMI)
NSV_FFBEG   = NSV_FFBEG_A(KMI)
NSV_FFEND   = NSV_FFEND_A(KMI)
#endif
NSV_CS      = NSV_CS_A(KMI)
NSV_CSBEG   = NSV_CSBEG_A(KMI)
NSV_CSEND   = NSV_CSEND_A(KMI)
NSV_SNW     = NSV_SNW_A(KMI)
NSV_SNWBEG  = NSV_SNWBEG_A(KMI)
NSV_SNWEND  = NSV_SNWEND_A(KMI)
!

END SUBROUTINE UPDATE_NSV

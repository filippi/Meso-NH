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
USE MODD_CONF, ONLY : NVERB
USE MODD_NSV
IMPLICIT NONE 
INTEGER, INTENT(IN) :: KMI ! Model index
!
! STOP if INI_NSV has not be called yet
IF (.NOT. LINI_NSV) THEN
  PRINT *, 'UPDATE_NSV  FATAL Error : can t continue because INI_NSV was not called.'
!callabortstop
  CALL ABORT
  STOP
END IF
!
! Update the NSV_* variables from original NSV_*_A arrays
! that have been initialized in ini_nsv.f90 for model KMI
!
NSV         = NSV_A(KMI)
NSV_USER    = NSV_USER_A(KMI)
NSV_C2R2    = NSV_C2R2_A(KMI)
NSV_C2R2BEG = NSV_C2R2BEG_A(KMI)
NSV_C2R2END = NSV_C2R2END_A(KMI)
NSV_C1R3    = NSV_C1R3_A(KMI)
NSV_C1R3BEG = NSV_C1R3BEG_A(KMI)
NSV_C1R3END = NSV_C1R3END_A(KMI)
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
NSV_CS      = NSV_CS_A(KMI)
NSV_CSBEG   = NSV_CSBEG_A(KMI)
NSV_CSEND   = NSV_CSEND_A(KMI)
!

END SUBROUTINE UPDATE_NSV

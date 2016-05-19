!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modn 2006/11/23 17:22:54
!-----------------------------------------------------------------
!     ########################  
      MODULE MODN_PARAM_RAD_n
!     ########################
!
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
USE MODD_PARAM_RAD_n, ONLY: &
         XDTRAD_n => XDTRAD, &
         XDTRAD_CLONLY_n => XDTRAD_CLONLY, &
         LCLEAR_SKY_n => LCLEAR_SKY, &
         NRAD_COLNBR_n => NRAD_COLNBR, &
         NRAD_DIAG_n => NRAD_DIAG, &
         CLW_n => CLW, &
         CAER_n => CAER, &
         CAOP_n => CAOP, &
         CEFRADL_n => CEFRADL, &
         CEFRADI_n => CEFRADI, &
         COPWLW_n => COPWLW, &
         COPILW_n => COPILW, &
         COPWSW_n => COPWSW, &
         COPISW_n => COPISW, &
         XFUDG_n => XFUDG, &
         LAERO_FT_n => LAERO_FT, &
         LFIX_DAT_n => LFIX_DAT, &
         LRAD_DUST_n => LRAD_DUST

!
IMPLICIT NONE
!
REAL,SAVE  :: XDTRAD
REAL,SAVE  :: XDTRAD_CLONLY
LOGICAL,SAVE :: LCLEAR_SKY
INTEGER,SAVE :: NRAD_COLNBR
INTEGER,SAVE :: NRAD_DIAG
CHARACTER (LEN=4), SAVE  :: CLW
CHARACTER (LEN=4), SAVE  :: CAER
CHARACTER (LEN=4), SAVE  :: CAOP
CHARACTER (LEN=4), SAVE  :: CEFRADL
CHARACTER (LEN=4), SAVE  :: CEFRADI
CHARACTER (LEN=4), SAVE  :: COPWLW
CHARACTER (LEN=4), SAVE  :: COPILW
CHARACTER (LEN=4), SAVE  :: COPWSW
CHARACTER (LEN=4), SAVE  :: COPISW
REAL, SAVE  :: XFUDG
LOGICAL,SAVE :: LAERO_FT
LOGICAL,SAVE :: LFIX_DAT
LOGICAL,SAVE :: LRAD_DUST
!
NAMELIST/NAM_PARAM_RADn/XDTRAD,XDTRAD_CLONLY,LCLEAR_SKY,NRAD_COLNBR,&
                        NRAD_DIAG,CLW,CAER,CAOP,CEFRADL,CEFRADI,COPWLW,&
                        COPILW,COPWSW,COPISW,XFUDG,LAERO_FT,LFIX_DAT,LRAD_DUST
!
CONTAINS
!
SUBROUTINE INIT_NAM_PARAM_RADn
  XDTRAD = XDTRAD_n
  XDTRAD_CLONLY = XDTRAD_CLONLY_n
  LCLEAR_SKY = LCLEAR_SKY_n
  NRAD_COLNBR = NRAD_COLNBR_n
  NRAD_DIAG = NRAD_DIAG_n
  CLW = CLW_n
  CAER = CAER_n
  CAOP = CAOP_n
  CEFRADL = CEFRADL_n
  CEFRADI = CEFRADI_n
  COPWLW = COPWLW_n
  COPILW = COPILW_n
  COPWSW = COPWSW_n
  COPISW = COPISW_n
  XFUDG = XFUDG_n
  LAERO_FT = LAERO_FT_n
  LFIX_DAT = LFIX_DAT_n
  LRAD_DUST = LRAD_DUST_n
END SUBROUTINE INIT_NAM_PARAM_RADn

SUBROUTINE UPDATE_NAM_PARAM_RADn
  XDTRAD_n = XDTRAD
  XDTRAD_CLONLY_n = XDTRAD_CLONLY
  LCLEAR_SKY_n = LCLEAR_SKY
  NRAD_COLNBR_n = NRAD_COLNBR
  NRAD_DIAG_n = NRAD_DIAG
  CLW_n = CLW
  CAER_n = CAER
  CAOP_n = CAOP
  CEFRADL_n = CEFRADL
  CEFRADI_n = CEFRADI
  COPWLW_n = COPWLW
  COPILW_n = COPILW
  COPWSW_n = COPWSW
  COPISW_n = COPISW
  XFUDG_n = XFUDG
  LAERO_FT_n = LAERO_FT
  LFIX_DAT_n = LFIX_DAT
  LRAD_DUST_n = LRAD_DUST
END SUBROUTINE UPDATE_NAM_PARAM_RADn

END MODULE MODN_PARAM_RAD_n

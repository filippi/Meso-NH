!MNH_LIC Copyright 1997-2021 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!############################
MODULE MODI_DEALLOCATE_MODEL1
!############################
!
INTERFACE
!
SUBROUTINE DEALLOCATE_MODEL1 (KCALL)
!
INTEGER, INTENT(IN) :: KCALL
!
END SUBROUTINE DEALLOCATE_MODEL1
!
END INTERFACE 
!
END MODULE MODI_DEALLOCATE_MODEL1
!
!
!     ####################################
      SUBROUTINE DEALLOCATE_MODEL1 (KCALL)
!     ####################################
!
!!****  *DEALLOCATE_MODEL1* - deallocate all model1 fields
!!
!!    PURPOSE
!!    -------
!       deallocate all model #1 fields in order to spare memory in spawning
!
!!**  METHOD
!!    ------
!!   
!!    KCALL = 1   --> deallocates all SOURCES, LES, FORCING and SOLVER variables
!!
!!    KCALL = 2   --> deallocates all METRIC, RADIATION and CORIOLIS variables
!!
!!    KCALL = 3   --> deallocates all other variables of model1
!!
!!    KCALL = 4   --> deallocates all variables common to ALL models
!!
!!    1 + 2         --> all variables used in spawning
!!    1 + 2 + 3 + 4 --> in diag after a file has been treated
!!
!!    EXTERNAL
!!    --------
!!
!!    REFERENCE
!!    ---------
!!      
!!
!!    AUTHOR
!!    ------
!!  	V. Masson       * Meteo France *
!!
!!    MODIFICATIONS
!!    -------------
!!      Original     08/12/97
!!
!!                   20/05/98  use the LB fields
!!                   15/03/99 new PGD fields
!!                   08/03/01 D.Gazen add chemical emission field
!!                   01/2004 V. Masson surface externalization
!!                   06/2012 M.Tomasini add 2D nesting ADVFRC
!!                   10/2016 M.Mazoyer New KHKO output fields
!  P. Wautelet 05/2016-04/2018: new data structures and calls for I/O
!  C. Lac         02/2019: add rain fraction as an output field
!  P. Wautelet 07/06/2019: bugfix: deallocate XLSRVM only if allocated
!  S. Riette      04/2020: XHL* fields
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
USE MODD_REF
!
USE MODD_METRICS_n
USE MODD_FIELD_n
USE MODD_DUMMY_GR_FIELD_n
USE MODD_LSFIELD_n
USE MODD_GRID_n
USE MODD_REF_n
USE MODD_CURVCOR_n
USE MODD_DYN_n
USE MODD_DEEP_CONVECTION_n
USE MODD_RADIATIONS_n
USE MODD_FRC
USE MODD_PRECIP_n
USE MODD_ELEC_n
USE MODD_PASPOL_n
USE MODD_RAIN_ICE_PARAM
USE MODD_RAIN_ICE_DESCR
USE MODD_PARAM_n , ONLY : CCLOUD
USE MODE_MODELN_HANDLER
!
! Modif 2D
USE MODD_LATZ_EDFLX                      ! For ADVFRC and EDDY FLUXES
USE MODD_DEF_EDDY_FLUX_n           ! For EDDY FLUXES
USE MODD_DEF_EDDYUV_FLUX_n         ! For EDDY FLUXES
!
USE MODD_2D_FRC
USE MODD_ADVFRC_n                  ! For ADVFRC and EDDY FLUXES
USE MODD_RELFRC_n
USE MODD_ADV_n
USE MODD_PAST_FIELD_n
USE MODD_TURB_n
USE MODD_PARAM_C2R2, ONLY :LSUPSAT
!
IMPLICIT NONE
!
!*       0.1   declarations of arguments
!
INTEGER, INTENT(IN) :: KCALL ! number of times this routine has been called
INTEGER :: IMI ! Current Model index
!
!*       0.2   declarations of local variables
!
!-------------------------------------------------------------------------------
!
! Save current Model index and switch to model 1 variables
IMI = GET_CURRENT_MODEL_INDEX()
CALL GOTO_MODEL(1)
!*       1.    Module MODD_FIELD$n
!
IF ( KCALL==3 ) THEN
  IF (CUVW_ADV_SCHEME(1:3)=='CEN'.AND. CTEMP_SCHEME=='LEFR') THEN
    DEALLOCATE(XUM)
    DEALLOCATE(XVM)
    DEALLOCATE(XWM)
    DEALLOCATE(XDUM)
    DEALLOCATE(XDVM)
    DEALLOCATE(XDWM)
  END IF
  DEALLOCATE(XUT)
  DEALLOCATE(XVT)
  DEALLOCATE(XWT)
  DEALLOCATE(XTHT)
  IF (L2D_ADV_FRC) THEN
    IF (ASSOCIATED(XDTHFRC)) DEALLOCATE(XDTHFRC)
    IF (ASSOCIATED(XDRVFRC)) DEALLOCATE(XDRVFRC)
    IF (ASSOCIATED(TDTADVFRC)) DEALLOCATE(TDTADVFRC)
  END IF
    IF (L2D_REL_FRC) THEN
    IF (ASSOCIATED(XTHREL)) DEALLOCATE(XTHREL)
    IF (ASSOCIATED(XRVREL)) DEALLOCATE(XRVREL)
    IF (ASSOCIATED(TDTRELFRC)) DEALLOCATE(TDTRELFRC)
  END IF
  ! DEALLOCATE EDDY FLUXES 
  IF (LTH_FLX) THEN
    DEALLOCATE(XVTH_FLUX_M)
    DEALLOCATE(XWTH_FLUX_M)
  END IF
  IF (LUV_FLX) THEN
    DEALLOCATE(XVU_FLUX_M)
  END IF
END IF
IF ( KCALL==1 ) THEN
  DEALLOCATE(XRUS)
  DEALLOCATE(XRVS)
  DEALLOCATE(XRWS)
  DEALLOCATE(XRTHS)
  DEALLOCATE(XRUS_PRES, XRVS_PRES, XRWS_PRES )                
  DEALLOCATE(XRTHS_CLD )
END IF
!
IF ( KCALL==3 ) THEN
  IF (ASSOCIATED(XTKET)) DEALLOCATE(XTKET)
END IF
IF ( ASSOCIATED(XRTKES) .AND. KCALL==1 ) THEN
  DEALLOCATE(XRTKES)
END IF
!
IF ( KCALL==3 ) THEN
  DEALLOCATE(XPABST)
!
  DEALLOCATE(XRT)
END IF
!
IF ( KCALL==1 ) THEN
  DEALLOCATE(XRRS)
  DEALLOCATE(XRRS_CLD)
END IF
!
IF ( ASSOCIATED(XSRCT) .AND. KCALL==3 ) THEN
  DEALLOCATE(XSRCT)
  DEALLOCATE(XSIGS)
END IF   
!
IF ( ASSOCIATED(XHLC_HRC) .AND. KCALL==3 ) THEN
  DEALLOCATE(XHLC_HRC)
  DEALLOCATE(XHLC_HCF)
  DEALLOCATE(XHLI_HRI)
  DEALLOCATE(XHLI_HCF)
END IF
!
IF ( ASSOCIATED(XCLDFR) .AND. KCALL==2 ) THEN
  DEALLOCATE(XCLDFR)
END IF   
!
IF ( ASSOCIATED(XICEFR) .AND. KCALL==2 ) THEN
  DEALLOCATE(XICEFR)
END IF   
!
IF ( ASSOCIATED(XRAINFR) .AND. KCALL==2 ) THEN
  DEALLOCATE(XRAINFR)
END IF   
!
IF ( KCALL == 3 ) THEN
  DEALLOCATE(XSVT)
END IF
IF ( KCALL == 1 ) THEN
  DEALLOCATE(XRSVS)
  DEALLOCATE(XRSVS_CLD)
END IF
!
IF ((CCLOUD == 'KHKO') .AND. LSUPSAT)  THEN
    DEALLOCATE(XSUPSAT)
    DEALLOCATE(XNACT)
    DEALLOCATE(XNPRO)
    DEALLOCATE(XSSPRO)
END IF
!
IF (ASSOCIATED(XDUMMY_GR_FIELDS) .AND. KCALL==3 ) THEN
  DEALLOCATE(XDUMMY_GR_FIELDS)
END IF
!
!*       3.    Module MODD_GRID$n
!
IF ( ASSOCIATED(XLON) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XLON)
  DEALLOCATE(XLAT)
  DEALLOCATE(XMAP)
END IF
!
IF ( KCALL == 3 ) THEN
  !Philippe W.: do not deallocate XXHAT, XYHAT and XZHAT because they are needed later on
  !As they are 1D, their memory footprint is negligible
  ! DEALLOCATE(XXHAT)
  DEALLOCATE(XDXHAT)
  ! DEALLOCATE(XYHAT)
  DEALLOCATE(XDYHAT)
  DEALLOCATE(XZS)
  DEALLOCATE(XZSMT)
  DEALLOCATE(XZZ)
  ! DEALLOCATE(XZHAT)
END IF
!
IF ( KCALL == 2 ) THEN
  DEALLOCATE(XDIRCOSZW)
  DEALLOCATE(XDIRCOSXW)
  DEALLOCATE(XDIRCOSYW)
  DEALLOCATE(XCOSSLOPE)
  DEALLOCATE(XSINSLOPE)
END IF

IF ( KCALL == 2 ) THEN
  DEALLOCATE(XDXX)
  DEALLOCATE(XDYY)
  DEALLOCATE(XDZX)
  DEALLOCATE(XDZY)
  DEALLOCATE(XDZZ)
END IF
!
!*       4.    Modules MODD_REF and  MODD_REF$n
!
IF ( KCALL == 4 ) THEN
  DEALLOCATE(XRHODREFZ)
  DEALLOCATE(XTHVREFZ)
END IF
!
IF ( KCALL == 3 ) THEN
  DEALLOCATE(XRHODREF)
  DEALLOCATE(XTHVREF)
  DEALLOCATE(XEXNREF)
  DEALLOCATE(XRHODJ)
  IF ( ASSOCIATED(XRVREF) ) THEN
    DEALLOCATE(XRVREF)  
  END IF
END IF
!
!*       5.    Module MODD_CURVCOR$n
!
IF ( ASSOCIATED(XCORIOX) .AND. KCALL == 2 ) THEN
  DEALLOCATE(XCORIOX)
  DEALLOCATE(XCORIOY)
END IF
IF ( KCALL == 2 ) THEN
  DEALLOCATE(XCORIOZ)
END IF
IF ( ASSOCIATED(XCURVX) .AND. KCALL == 2) THEN
  DEALLOCATE(XCURVX)
  DEALLOCATE(XCURVY)
END IF
!
!*       6.    Module MODD_DYN$n
!
IF ( KCALL == 1 ) THEN
  DEALLOCATE(XBFY)
  DEALLOCATE(XAF,XCF)
  DEALLOCATE(XTRIGSX)
  DEALLOCATE(XTRIGSY)
  DEALLOCATE(XRHOM)
  DEALLOCATE(XALK)
  DEALLOCATE(XALKW)
  DEALLOCATE(XALKBAS)
  DEALLOCATE(XALKWBAS)
  IF ( ASSOCIATED(XKURELAX) ) THEN
    DEALLOCATE(XKURELAX)
    DEALLOCATE(XKVRELAX)
    DEALLOCATE(XKWRELAX)
    DEALLOCATE(LMASK_RELAX)
  END IF
END IF
!
!*       7.    Larger Scale variables (Module MODD_LSFIELD$n)
!
IF ( KCALL == 3 ) THEN
  DEALLOCATE(XLSUM)
  DEALLOCATE(XLSVM)
  DEALLOCATE(XLSWM)
  DEALLOCATE(XLSTHM)
  IF(ASSOCIATED(XLSRVM)) DEALLOCATE(XLSRVM)
  IF (ASSOCIATED(XLBXUM)) THEN
    DEALLOCATE(XLBXUM)
    DEALLOCATE(XLBYUM)
    DEALLOCATE(XLBXVM)
    DEALLOCATE(XLBYVM)
    DEALLOCATE(XLBXWM)
    DEALLOCATE(XLBYWM)
    DEALLOCATE(XLBXTHM)
    DEALLOCATE(XLBYTHM)
  END IF
  IF (ASSOCIATED(XLBXTKEM)) THEN
    DEALLOCATE(XLBXTKEM)
    DEALLOCATE(XLBYTKEM)
  END IF
  IF (ASSOCIATED(XLBXRM)) THEN
    DEALLOCATE(XLBXRM)
    DEALLOCATE(XLBYRM)
  END IF
  IF (ASSOCIATED(XLBXSVM)) THEN
    DEALLOCATE(XLBXSVM)
    DEALLOCATE(XLBYSVM)
  END IF
END IF
!
                  ! steady LS fields only for model 1 or independent models
!
IF( ASSOCIATED(XLSUS) .AND. KCALL == 3 ) THEN
    DEALLOCATE(XLSUS)
    DEALLOCATE(XLSVS)
    DEALLOCATE(XLSWS)
    DEALLOCATE(XLSTHS)
    IF(ASSOCIATED(XLSRVS))  DEALLOCATE(XLSRVS)
!
    IF ( ASSOCIATED(XLBXUS) ) THEN
      DEALLOCATE(XLBXUS)
      DEALLOCATE(XLBYUS)
      DEALLOCATE(XLBXVS)
      DEALLOCATE(XLBYVS)
      DEALLOCATE(XLBXWS)
      DEALLOCATE(XLBYWS)
      DEALLOCATE(XLBXTHS)
      DEALLOCATE(XLBYTHS)
    END IF
    IF ( ASSOCIATED(XLBXTKES) ) THEN
      DEALLOCATE(XLBXTKES)
      DEALLOCATE(XLBYTKES)
    END IF
!
    IF ( ASSOCIATED(XLBXRS) ) THEN
      DEALLOCATE(XLBXRS)
      DEALLOCATE(XLBYRS)
    END IF
!
    IF ( ASSOCIATED(XLBXSVS) ) THEN
      DEALLOCATE(XLBXSVS)
      DEALLOCATE(XLBYSVS)
    END IF
!
    IF ( ASSOCIATED(XCOEFLIN_LBXM) ) THEN
      DEALLOCATE(XCOEFLIN_LBXM)
      DEALLOCATE(NKLIN_LBXM)
    END IF

    IF ( ASSOCIATED(XCOEFLIN_LBYM) ) THEN
      DEALLOCATE(XCOEFLIN_LBYM)
      DEALLOCATE(NKLIN_LBYM)
    END IF

    IF ( ASSOCIATED(XCOEFLIN_LBXU) ) THEN
      DEALLOCATE(XCOEFLIN_LBXU)
      DEALLOCATE(NKLIN_LBXU)
      DEALLOCATE(XCOEFLIN_LBYU)
      DEALLOCATE(NKLIN_LBYU)
      DEALLOCATE(XCOEFLIN_LBXV)
      DEALLOCATE(NKLIN_LBXV)
      DEALLOCATE(XCOEFLIN_LBYV)
      DEALLOCATE(NKLIN_LBYV)
      DEALLOCATE(XCOEFLIN_LBXW)
      DEALLOCATE(NKLIN_LBXW)
      DEALLOCATE(XCOEFLIN_LBYW)
      DEALLOCATE(NKLIN_LBYW)
    END IF 
END IF
!
!*       8.    L.E.S. variables 
!

!
!*       9.    Module MODD_RADIATIONS$n
!
!
IF ( ASSOCIATED(XSLOPANG) .AND. KCALL == 2 ) THEN
  DEALLOCATE(XSLOPANG)
  DEALLOCATE(XSLOPAZI)
  DEALLOCATE(XDTHRAD)
  DEALLOCATE(XFLALWD)
  DEALLOCATE(XDIRFLASWD)
  DEALLOCATE(XSCAFLASWD)
  DEALLOCATE(XDIRSRFSWD)
  DEALLOCATE(XSWU)
  DEALLOCATE(XSWD)
  DEALLOCATE(XLWU)
  DEALLOCATE(XLWD)
  DEALLOCATE(XDTHRADSW)
  DEALLOCATE(XDTHRADLW)
  DEALLOCATE(XRADEFF)
  DEALLOCATE(NCLEARCOL_TM1)
END IF
IF (ASSOCIATED(XSTATM)) DEALLOCATE(XSTATM)
!
!*      10.    Module MODD_DEEP_CONVECTION$n
!
IF ( ASSOCIATED(XDTHCONV) .AND. KCALL == 2 ) THEN
  DEALLOCATE(NCOUNTCONV)
  DEALLOCATE(XDTHCONV)
  DEALLOCATE(XDRVCONV)
  DEALLOCATE(XDRCCONV)
  DEALLOCATE(XDRICONV)
END IF
!
IF ( ASSOCIATED(XPRCONV) .AND. KCALL == 2 ) THEN
  DEALLOCATE(XPRCONV)
  DEALLOCATE(XPACCONV)
END IF
IF ( ASSOCIATED(XPRSCONV) .AND. KCALL == 2  ) THEN
  DEALLOCATE(XPRSCONV)
END IF
!
IF ( ASSOCIATED(XDSVCONV) .AND. KCALL == 2 ) THEN
  DEALLOCATE(XDSVCONV)
END IF
!
!*     11.   Forcing variables (Module MODD_FRC)
!
IF ( ALLOCATED(XUFRC) .AND. KCALL == 4 ) THEN
    DEALLOCATE(TDTFRC)
    DEALLOCATE(XUFRC)
    DEALLOCATE(XVFRC)
    DEALLOCATE(XWFRC)
    DEALLOCATE(XTHFRC)
    DEALLOCATE(XRVFRC)
    DEALLOCATE(XTENDTHFRC)
    DEALLOCATE(XTENDRVFRC)
    DEALLOCATE(XGXTHFRC)
    DEALLOCATE(XGYTHFRC)
    DEALLOCATE(XPGROUNDFRC)
END IF
!
!*     12.     Module MODD_ICE_CONC$n
!
IF ( ASSOCIATED(XCIT) .AND. KCALL == 2 ) THEN
  DEALLOCATE(XCIT)
END IF
!
!*     13.     Module MODD_PRECIP$n
!
IF ( ASSOCIATED(XINPRC) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XINPRC)
  DEALLOCATE(XACPRC)
END IF
!
IF ( ASSOCIATED(XINPRR) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XINPRR)
  DEALLOCATE(XACPRR)
END IF
!
IF ( ASSOCIATED(XINPRR3D) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XINPRR3D)
  DEALLOCATE(XEVAP3D)
END IF
!
IF ( ASSOCIATED(XINPRS) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XINPRS)
  DEALLOCATE(XACPRS)
  DEALLOCATE(XINPRG)
  DEALLOCATE(XACPRG)
END IF
!
IF ( ASSOCIATED(XINPRH) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XINPRH)
  DEALLOCATE(XACPRH)
END IF
!
!*     13b.     Module MODD_ELEC$n
!
IF ( ASSOCIATED(XNI_SDRYG) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XNI_SDRYG)
  DEALLOCATE(XNI_IDRYG)
  DEALLOCATE(XNI_IAGGS)
  DEALLOCATE(XEW)
  DEALLOCATE(XIND_RATE)
END IF
!
IF ( ASSOCIATED(XEFIELDU) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XEFIELDU)
  DEALLOCATE(XEFIELDV)
  DEALLOCATE(XEFIELDW)
  DEALLOCATE(XESOURCEFW)
  DEALLOCATE(XIONSOURCEFW)
  DEALLOCATE(XCION_POS_FW)
  DEALLOCATE(XCION_NEG_FW)
  DEALLOCATE(XMOBIL_POS)  
  DEALLOCATE(XMOBIL_NEG)  
END IF
!
IF ( ASSOCIATED(XRHOM_E) .AND. KCALL == 3 ) THEN
  DEALLOCATE (XRHOM_E)
  DEALLOCATE (XAF_E)
  DEALLOCATE (XCF_E)
  DEALLOCATE (XBFY_E)
END IF
!
!*     14.     Modules RAIN_ICE_DESCR and MODD_RAIN_ICE_PARAM
!
IF (  ALLOCATED(XRTMIN) .AND. KCALL == 4 ) THEN
  DEALLOCATE( XRTMIN )
  DEALLOCATE( XGAMINC_RIM1 )
  DEALLOCATE( XGAMINC_RIM2 )
  DEALLOCATE( XKER_RACCSS )
  DEALLOCATE( XKER_RACCS )
  DEALLOCATE( XKER_SACCRG )
  DEALLOCATE( XKER_SDRYG )
  DEALLOCATE( XKER_RDRYG )
END IF
!
!*     15.     Module PASPOLn           
!
IF ( ASSOCIATED(XATC) .AND. KCALL == 3 ) THEN
  DEALLOCATE(XATC)
END IF
!
!*     16.     Module TURBn           
!
IF ( KCALL==3 ) THEN
  IF (ASSOCIATED(XDYP)) DEALLOCATE(XDYP)
  IF (ASSOCIATED(XTHP)) DEALLOCATE(XTHP)
  IF (ASSOCIATED(XTR)) DEALLOCATE(XTR)
  IF (ASSOCIATED(XDISS)) DEALLOCATE(XDISS)
  IF (ASSOCIATED(XLEM)) DEALLOCATE(XLEM)
END IF
!-------------------------------------------------------------------------------
!
CALL GOTO_MODEL(IMI)
!
END SUBROUTINE DEALLOCATE_MODEL1

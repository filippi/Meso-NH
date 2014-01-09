!MNH_LIC Copyright 1994-2013 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENCE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt  
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 newsrc 2006/06/26 12:01:39
!
!!    MODIFICATIONS
!!    -------------
!!      06/12 (Tomasini) Grid-nesting of ADVFRC and EDDY_FLUX
!-----------------------------------------------------------------
MODULE MODI_GOTO_MODEL_WRAPPER

INTERFACE 
SUBROUTINE GOTO_MODEL_WRAPPER(KFROM, KTO)
INTEGER,INTENT(IN) :: KFROM, KTO
END SUBROUTINE GOTO_MODEL_WRAPPER
END INTERFACE

END MODULE MODI_GOTO_MODEL_WRAPPER

SUBROUTINE GOTO_MODEL_WRAPPER(KFROM, KTO)
! all USE modd*_n modules
USE MODD_ADV_n
USE MODD_BIKHARDT_n
USE MODD_CH_AERO_n
USE MODD_CH_DEP_n
USE MODD_CH_JVALUES_n
USE MODD_CH_MNHC_n
USE MODD_CH_SOLVER_n
USE MODD_CLOUDPAR_n
USE MODD_CLOUD_MF_n
USE MODD_CONF_n
USE MODD_CURVCOR_n
USE MODD_DEEP_CONVECTION_n
USE MODD_DIM_n
USE MODD_DUMMY_GR_FIELD_n
USE MODD_DYN_n
USE MODD_DYNZD_n
USE MODD_FIELD_n
USE MODD_PAST_FIELD_n
USE MODD_GET_n
USE MODD_GR_FIELD_n
USE MODD_GRID_n
USE MODD_HURR_FIELD_n
USE MODD_LBC_n
USE MODD_LES_n
USE MODD_LSFIELD_n
USE MODD_LUNIT_n
USE MODD_MEAN_FIELD_n
USE MODD_METRICS_n
USE MODD_NEST_PGD_n
USE MODD_NUDGING_n
USE MODD_OUT_n
USE MODD_PACK_GR_FIELD_n
USE MODD_PARAM_KAFR_n
USE MODD_PARAM_MFSHALL_n
USE MODD_PARAM_n
USE MODD_PARAM_RAD_n
USE MODD_PASPOL_n
USE MODD_PRECIP_n
USE MODD_ELEC_n
USE MODD_PROFILER_n
USE MODD_RADIATIONS_n
USE MODD_SHADOWS_n
USE MODD_REF_n
USE MODD_FRC_n
USE MODD_SECPGD_FIELD_n
USE MODD_SERIES_n
USE MODD_STATION_n
USE MODD_TIME_n
USE MODD_TURB_n
!
USE MODD_SUB_CH_FIELD_VALUE_n
USE MODD_SUB_CH_MONITOR_n
USE MODD_SUB_MODEL_n
USE MODD_SUB_PHYS_PARAM_n  
USE MODD_SUB_PROFILER_n
USE MODD_SUB_STATION_n
USE MODD_TIMEZ
USE MODD_SUB_PASPOL_n
USE MODD_SUB_ELEC_n
USE MODD_CH_PH_n
USE MODD_CH_M9_n
USE MODD_CH_ROSENBROCK_n
USE MODD_RBK90_Global_n
USE MODD_RBK90_JacobianSP_n
USE MODD_RBK90_Parameters_n
USE MODD_DEF_EDDY_FLUX_n
USE MODD_DEF_EDDYUV_FLUX_n
USE MODD_RELFRC_n
USE MODD_ADVFRC_n
!
IMPLICIT NONE 
INTEGER,INTENT(IN) :: KFROM, KTO
!
! All calls to specific modd_*n goto_model routines
!
CALL ADV_GOTO_MODEL(KFROM, KTO)
CALL BIKHARDT_GOTO_MODEL(KFROM, KTO)
CALL CH_AERO_GOTO_MODEL(KFROM,KTO)
CALL CH_DEP_GOTO_MODEL(KFROM, KTO)
CALL CH_JVALUES_GOTO_MODEL(KFROM, KTO)
CALL CH_MNHC_GOTO_MODEL(KFROM, KTO)
CALL CH_SOLVER_GOTO_MODEL(KFROM, KTO)
CALL CLOUDPAR_GOTO_MODEL(KFROM, KTO)
CALL CLOUD_MF_GOTO_MODEL(KFROM, KTO)
CALL CONF_GOTO_MODEL(KFROM, KTO)
CALL CURVCOR_GOTO_MODEL(KFROM, KTO)
CALL DEEP_CONVECTION_GOTO_MODEL(KFROM, KTO)
CALL DIM_GOTO_MODEL(KFROM, KTO)
CALL DUMMY_GR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL DYN_GOTO_MODEL(KFROM, KTO)
CALL DYNZD_GOTO_MODEL(KFROM,KTO)
CALL FIELD_GOTO_MODEL(KFROM, KTO)
CALL PAST_FIELD_GOTO_MODEL(KFROM, KTO)
CALL GET_GOTO_MODEL(KFROM, KTO)
CALL GR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL GRID_GOTO_MODEL(KFROM, KTO)
CALL HURR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL LBC_GOTO_MODEL(KFROM, KTO)
CALL LES_GOTO_MODEL(KFROM, KTO)
CALL LSFIELD_GOTO_MODEL(KFROM, KTO)
CALL LUNIT_GOTO_MODEL(KFROM, KTO)
CALL MEAN_FIELD_GOTO_MODEL(KFROM, KTO)
CALL METRICS_GOTO_MODEL(KFROM, KTO)
CALL NEST_PGD_GOTO_MODEL(KFROM, KTO)
CALL NUDGING_GOTO_MODEL(KFROM, KTO)
CALL OUT_GOTO_MODEL(KFROM, KTO)
CALL PACK_GR_FIELD_GOTO_MODEL(KFROM, KTO)
CALL PARAM_KAFR_GOTO_MODEL(KFROM, KTO)
CALL PARAM_MFSHALL_GOTO_MODEL(KFROM, KTO)
CALL PARAM_GOTO_MODEL(KFROM, KTO)
CALL PARAM_RAD_GOTO_MODEL(KFROM, KTO)
CALL PASPOL_GOTO_MODEL(KFROM, KTO)
CALL PRECIP_GOTO_MODEL(KFROM, KTO)
CALL ELEC_GOTO_MODEL(KFROM, KTO)
CALL PROFILER_GOTO_MODEL(KFROM, KTO)
CALL RADIATIONS_GOTO_MODEL(KFROM, KTO)
CALL SHADOWS_GOTO_MODEL(KFROM, KTO)
CALL REF_GOTO_MODEL(KFROM, KTO)
CALL FRC_GOTO_MODEL(KFROM, KTO)
CALL SECPGD_FIELD_GOTO_MODEL(KFROM, KTO)
CALL SERIES_GOTO_MODEL(KFROM, KTO)
CALL STATION_GOTO_MODEL(KFROM, KTO)
CALL SUB_CH_FIELD_VALUE_GOTO_MODEL(KFROM, KTO)
CALL SUB_CH_MONITOR_GOTO_MODEL(KFROM, KTO)
CALL SUB_MODEL_GOTO_MODEL(KFROM, KTO)
CALL SUB_PHYS_PARAM_GOTO_MODEL(KFROM, KTO)
CALL SUB_PROFILER_GOTO_MODEL(KFROM, KTO)
CALL SUB_STATION_GOTO_MODEL(KFROM, KTO)
CALL SUB_PASPOL_GOTO_MODEL(KFROM, KTO)
CALL SUB_ELEC_GOTO_MODEL(KFROM, KTO)
CALL TIME_GOTO_MODEL(KFROM, KTO)
CALL TURB_GOTO_MODEL(KFROM, KTO)
CALL TIMEZ_GOTO_MODEL(KFROM, KTO)
CALL CH_PH_GOTO_MODEL(KFROM, KTO)
CALL CH_M9_GOTO_MODEL(KFROM, KTO)
CALL CH_ROSENBROCK_GOTO_MODEL(KFROM, KTO)
CALL RBK90_Global_GOTO_MODEL(KFROM, KTO)
CALL RBK90_JacobianSP_GOTO_MODEL(KFROM, KTO)
CALL RBK90_Parameters_GOTO_MODEL(KFROM, KTO)
CALL EDDY_FLUX_GOTO_MODEL(KFROM, KTO)
CALL EDDYUV_FLUX_GOTO_MODEL(KFROM, KTO)
CALL ADVFRC_GOTO_MODEL(KFROM, KTO)
CALL RELFRC_GOTO_MODEL(KFROM, KTO)

END SUBROUTINE GOTO_MODEL_WRAPPER

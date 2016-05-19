!-----------------------------------------------------------------
!--------------- special set of characters for CVS information
!-----------------------------------------------------------------
! $Source$
! $Name$ 
! $Revision$ 
! $Date$
!-----------------------------------------------------------------
!-----------------------------------------------------------------

!     ###################
      MODULE MODI_INIT_ll
!     ###################
!!
INTERFACE 
!
!      #########################################
       SUBROUTINE SET_SPLITTING_ll( HSPLITTING )
!      #########################################
!
  CHARACTER(LEN=*) :: HSPLITTING
!
       END SUBROUTINE SET_SPLITTING_ll
!
!      ##################################
       SUBROUTINE SET_LBX_ll( KLBX, KMI )
!      ##################################
!
  CHARACTER(LEN=*) :: KLBX
  INTEGER :: KMI
!
       END SUBROUTINE SET_LBX_ll
!
!      ##################################
       SUBROUTINE SET_LBY_ll( KLBY, KMI )
!      ##################################
!
  CHARACTER(LEN=*) :: KLBY
  INTEGER :: KMI
!
       END SUBROUTINE SET_LBY_ll
!
!      ############################################
       SUBROUTINE SET_LBSIZEX_ll( KNBRIM, KRIMTAB )
!      ############################################
!
  INTEGER :: KNBRIM
  INTEGER, DIMENSION(:) :: KRIMTAB
!
       END SUBROUTINE SET_LBSIZEX_ll
!
!      ############################################
       SUBROUTINE SET_LBSIZEY_ll( KNBRIM, KRIMTAB )
!      ############################################
!
  INTEGER :: KNBRIM
  INTEGER, DIMENSION(:) :: KRIMTAB
!
       END SUBROUTINE SET_LBSIZEY_ll
!
!      ###################################
       SUBROUTINE SET_DIM_ll( KX, KY, KZ )
!      ###################################
!
 INTEGER :: KX,KY,KZ
!
        END SUBROUTINE SET_DIM_ll
!
!      #######################################################
       SUBROUTINE SET_JP_ll( KMODELMAX, KHEXT, KVEXT, KPHALO )
!      #######################################################
!
  INTEGER :: KMODELMAX, KHEXT, KVEXT, KPHALO
!
       END SUBROUTINE SET_JP_ll
!
!      ########################################
       SUBROUTINE SET_XRATIO_ll( KXRATIO, KMI )
!      ########################################
!
  INTEGER :: KXRATIO, KMI
!
       END SUBROUTINE SET_XRATIO_ll
!
!      ########################################
       SUBROUTINE SET_YRATIO_ll( KYRATIO, KMI )
!      ########################################
!
  INTEGER :: KYRATIO, KMI
!
       END SUBROUTINE SET_YRATIO_ll
!
!      ##################################
       SUBROUTINE SET_DAD_ll( KDAD, KMI )
!      ##################################
!
  INTEGER :: KDAD, KMI
!
       END SUBROUTINE SET_DAD_ll
!
!      ##################################
       SUBROUTINE SET_XOR_ll( KXOR, KMI )
!      ##################################
!
  INTEGER :: KXOR, KMI
!
       END SUBROUTINE SET_XOR_ll
!
!      ####################################
       SUBROUTINE SET_XEND_ll( KXEND, KMI )
!      ####################################
!
  INTEGER :: KXEND, KMI
!
       END SUBROUTINE SET_XEND_ll
!
!      ##################################
       SUBROUTINE SET_YOR_ll( KYOR, KMI )
!      ##################################
!
  INTEGER :: KYOR, KMI
!
       END SUBROUTINE SET_YOR_ll
!
!      ####################################
       SUBROUTINE SET_YEND_ll( KYEND, KMI )
!      ####################################
!
  INTEGER :: KYEND, KMI
!
       END SUBROUTINE SET_YEND_ll
!
!      ########################
       SUBROUTINE SET_DAD0_ll()
!      ########################
!
       END SUBROUTINE SET_DAD0_ll
!
!      #######################
       SUBROUTINE INIT_LB_ll()
!      #######################
!
       END SUBROUTINE INIT_LB_ll
!
!      ###################################
        SUBROUTINE INI_PARA_ll( KINFO_ll )
!      ###################################
!
  INTEGER, INTENT(OUT) :: KINFO_ll
!
       END SUBROUTINE INI_PARA_ll
!
!     ###################################
       SUBROUTINE END_PARA_ll( KINFO_ll )
!     ###################################
!
  INTEGER, INTENT(OUT) :: KINFO_ll
!
       END SUBROUTINE END_PARA_ll
!
END INTERFACE
!
END MODULE MODI_INIT_ll

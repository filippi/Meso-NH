INTERFACE
 SUBROUTINE ARO_TURB_MNH( KKA,KKU,KKL,KLON,KLEV, KRR, KRRL, KRRI,KSV,&
 & KTCOUNT,KGRADIENTS, LDHARATU, CMICRO, PTSTEP,&
 & PZZ, PZZF, PZZTOP,&
 & PRHODJ, PTHVREF,HINST_SFU,&
 & PSFTH,PSFRV,PSFSV,PSFU,PSFV,&
 & PPABSM,PUM,PVM,PWM,PTKEM,PEPSM,PSVM,PSRCM,&
 & PTHM,PRM,&
 & PRUS,PRVS,PRWS,PRTHS,PRRS,PRSVSIN,PRSVS,PRTKES,PRTKES_OUT,PREPSS,&
 & PHGRAD,PSIGS,OSUBG_COND,&
 & PFLXZTHVMF,PLENGTHM,PLENGTHH,MFMOIST,&
 & PDRUS_TURB,PDRVS_TURB,&
 & PDRTHLS_TURB,PDRRTS_TURB,PDRSVS_TURB,&
 & PDP,PTP,PTPMF,PTDIFF,PTDISS,PEDR,YDDDH,YDLDDH,YDMDDH)

USE PARKIND1  ,ONLY : JPIM     ,JPRB
USE DDH_MIX, ONLY : TYP_DDH
USE YOMLDDH, ONLY  : TLDDH
USE YOMMDDH, ONLY  : TMDDH

INTEGER(KIND=JPIM), INTENT(IN) :: KLON
INTEGER(KIND=JPIM), INTENT(IN) :: KLEV
INTEGER(KIND=JPIM), INTENT(IN)   :: KKA   !Index of nearest point to ground  
INTEGER(KIND=JPIM), INTENT(IN)   :: KKU   !Index of nearest point to top
INTEGER(KIND=JPIM), INTENT(IN)   :: KKL   !vertical levels type
                                                ! 1=MNH -1=ARO

INTEGER(KIND=JPIM), INTENT(IN) :: KRR
INTEGER(KIND=JPIM), INTENT(IN) :: KRRL
INTEGER(KIND=JPIM), INTENT(IN) :: KRRI
INTEGER(KIND=JPIM), INTENT(IN) :: KSV
INTEGER(KIND=JPIM), INTENT(IN) :: KTCOUNT
INTEGER(KIND=JPIM), INTENT(IN) :: KGRADIENTS  ! Number of stored horizontal gradients
LOGICAL,            INTENT(IN) :: LDHARATU ! HARATU scheme active
CHARACTER(LEN=4),        INTENT(IN)   :: CMICRO  ! Microphysics scheme
REAL(KIND=JPRB), INTENT(IN) :: PTSTEP
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PZZ
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV), INTENT(IN) :: PZZF
REAL(KIND=JPRB), DIMENSION(KLON),        INTENT(IN) :: PZZTOP
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PRHODJ
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT)  :: MFMOIST
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PTHVREF
CHARACTER*1 , INTENT(IN) :: HINST_SFU
REAL(KIND=JPRB), DIMENSION(KLON,1), INTENT(INOUT) :: PSFTH,PSFRV
REAL(KIND=JPRB), DIMENSION(KLON,1), INTENT(INOUT) :: PSFU,PSFV
REAL(KIND=JPRB), DIMENSION(KLON,1,KSV), INTENT(INOUT) :: PSFSV
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PPABSM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PUM,PVM,PWM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PTKEM
REAL(KIND=JPRB), DIMENSION(0,0,0), INTENT(INOUT) :: PEPSM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KSV), INTENT(INOUT) :: PSVM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PSRCM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT)   :: PLENGTHM, PLENGTHH
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PTHM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KRR), INTENT(INOUT) :: PRM
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PRUS,PRVS,PRWS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),   INTENT(INOUT) :: PRTHS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV),     INTENT(IN)  ::  PRTKES
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),   INTENT(OUT) ::  PRTKES_OUT
REAL(KIND=JPRB), DIMENSION(0,0,0) , INTENT(INOUT) ::PREPSS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KRR), INTENT(INOUT) :: PRRS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KSV), INTENT(IN)  ::  PRSVSIN
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KSV), INTENT(OUT) ::  PRSVS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KGRADIENTS),   INTENT(INOUT) :: PHGRAD    
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(OUT) :: PSIGS
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(OUT) :: PDRUS_TURB
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(OUT) :: PDRVS_TURB
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(OUT) :: PDRTHLS_TURB
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(OUT) :: PDRRTS_TURB
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV,KSV), INTENT(OUT) :: PDRSVS_TURB
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2), INTENT(INOUT) :: PFLXZTHVMF
LOGICAL , INTENT(IN) :: OSUBG_COND
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),  INTENT(OUT)   :: PDP
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),  INTENT(OUT)   :: PTP
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),  INTENT(OUT)   :: PTPMF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),  INTENT(OUT)   :: PTDIFF
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),  INTENT(OUT)   :: PTDISS
!                                                !for TKE DDH budgets
REAL(KIND=JPRB), DIMENSION(KLON,1,KLEV+2),   INTENT(OUT) ::  PEDR
TYPE(TYP_DDH),                     INTENT(INOUT) :: YDDDH
TYPE(TLDDH),                       INTENT(IN)    :: YDLDDH
TYPE(TMDDH),                       INTENT(IN)    :: YDMDDH
END SUBROUTINE ARO_TURB_MNH
END INTERFACE

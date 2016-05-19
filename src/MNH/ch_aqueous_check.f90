!      ############################
       MODULE MODI_CH_AQUEOUS_CHECK
!      ############################
!
INTERFACE
      SUBROUTINE CH_AQUEOUS_CHECK (PTSTEP, PRHODREF, PRHODJ,PRRS, PRSVS, &
                                   KRRL, KRR, KEQAQ, PRTMIN_AQ, OUSECHIC )
!
REAL,                     INTENT(IN)    :: PTSTEP    ! Timestep  
REAL,                     INTENT(IN)    :: PRTMIN_AQ ! LWC threshold liq. chem.
!
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODREF! Reference density
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODJ  ! Dry density * Jacobian
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRRS    ! water m.r. source
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRSVS   ! S.V. source
!
INTEGER,                  INTENT(IN)    :: KRRL    ! Number of liq. variables
INTEGER,                  INTENT(IN)    :: KRR     ! Number of water variables
INTEGER,                  INTENT(IN)    :: KEQAQ   ! Number of liq. chem. spec.
LOGICAL,                  INTENT(IN)    :: OUSECHIC ! flag for ice chem.
!
END SUBROUTINE CH_AQUEOUS_CHECK
END INTERFACE
END MODULE MODI_CH_AQUEOUS_CHECK 
!
!     ####################################################################
      SUBROUTINE CH_AQUEOUS_CHECK (PTSTEP, PRHODREF, PRHODJ,PRRS, PRSVS, &
                                   KRRL, KRR, KEQAQ, PRTMIN_AQ, OUSECHIC )
!     ####################################################################
!
!!****  * -  Check the coherence between the mixing ratio of water and the
!!           concentrations of aqueous species
!!
!!    PURPOSE
!!    -------
!!      The purpose of this routine is to nullify the concentration of aqueous
!!    species in place where the mixing ratio of the corresponding water
!!    contents are very low. The residual aqueous concentrations are lost.
!!
!!**  METHOD
!!    ------
!!
!!    EXTERNAL
!!    --------
!!      None
!!     
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!      Module MODD_PARAMETERS
!!          JPHEXT       : Horizontal external points number
!!          JPVEXT       : Vertical external points number
!!
!!    REFERENCE
!!    ---------
!!      Book1 of the documentation ( routine CH_AQUEOUS_CHECK )
!!
!!    AUTHOR
!!    ------
!!      J.-P. Pinty      * Laboratoire d'Aerologie*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    08/11/07
!!      21/11/07 (M. Leriche) correct threshold for aqueous phase chemistry
!!      20/09/10 (M. Leriche) add ice phase chemical species
!!
!-------------------------------------------------------------------------------
!
!*       0.    DECLARATIONS
!              ------------
!
USE MODD_PARAMETERS,ONLY: JPHEXT,    &! number of horizontal External points
                          JPVEXT      ! number of vertical External points
USE MODD_NSV,       ONLY : NSV_CHACBEG, NSV_CHACEND, NSV_CHICBEG, NSV_CHICEND
!
IMPLICIT NONE
!
!*       0.1   Declarations of dummy arguments :
!
!
REAL,                     INTENT(IN)    :: PTSTEP    ! Timestep  
REAL,                     INTENT(IN)    :: PRTMIN_AQ ! LWC threshold liq. chem.
!
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODREF! Reference density
REAL, DIMENSION(:,:,:),   INTENT(IN)    :: PRHODJ  ! Dry density * Jacobian
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRRS    ! water m.r. source
REAL, DIMENSION(:,:,:,:), INTENT(INOUT) :: PRSVS   ! S.V. source
!
INTEGER,                  INTENT(IN)    :: KRRL    ! Number of liq. variables
INTEGER,                  INTENT(IN)    :: KRR     ! Number of water variables
INTEGER,                  INTENT(IN)    :: KEQAQ   ! Number of liq. chem. spec.
LOGICAL,                  INTENT(IN)    :: OUSECHIC ! flag for ice chem.
!
!*       0.2   Declarations of local variables :
!
INTEGER :: JRR           ! Loop index for the moist variables
INTEGER :: JSV           ! Loop index for the aqueous/ice concentrations
!
INTEGER :: IWATER        ! Case number aqueous species
INTEGER :: IICE          ! Case number ice phase species
LOGICAL, DIMENSION(SIZE(PRRS,1),SIZE(PRRS,2),SIZE(PRRS,3)) &
                                   :: GWATER ! where to compute
LOGICAL, DIMENSION(SIZE(PRRS,1),SIZE(PRRS,2),SIZE(PRRS,3)) &
                                   :: GICE   ! where to compute
REAL,    DIMENSION(SIZE(PRRS,1),SIZE(PRRS,2),SIZE(PRRS,3),SIZE(PRRS,4)) &
                                   :: ZRRS
REAL,    DIMENSION(:), ALLOCATABLE :: ZWORK  ! work array
INTEGER, DIMENSION(3)              :: ISV_BEG, ISV_END
!
REAL                               :: ZRTMIN_AQ
!
INTEGER , DIMENSION(SIZE(GWATER)) :: I1W,I2W,I3W ! Used to replace the COUNT
INTEGER , DIMENSION(SIZE(GICE))   :: I1I,I2I,I3I
INTEGER                           :: JL       ! and PACK intrinsics
!
!-------------------------------------------------------------------------------
!
!*       1.     TRANSFORMATION INTO PHYSICAL TENDENCIES
!               ---------------------------------------
!
DO JRR = 2, KRRL+1
  ZRRS(:,:,:,JRR)  = PRRS(:,:,:,JRR) / PRHODJ(:,:,:)
END DO
IF (OUSECHIC) THEN
  DO JRR = KRRL+1, KRR
    ZRRS(:,:,:,JRR)  = PRRS(:,:,:,JRR) / PRHODJ(:,:,:)
  END DO
ENDIF  
!
!-------------------------------------------------------------------------------
!
!*       2.     COMPUTE THE CHECK (RS) SOURCE
!	        -----------------------------
!
!*       2.1    threshold for the aqueous phase species
!
ZRTMIN_AQ = PRTMIN_AQ / PTSTEP
!
!*       2.2    bounds of the aqueous phase species
!
IF( KRRL==1 ) THEN
  ISV_BEG(2) = NSV_CHACBEG
  ISV_END(2) = NSV_CHACEND
ELSE
  ISV_BEG(2) = NSV_CHACBEG
  ISV_BEG(3) = NSV_CHACBEG+KEQAQ/2
  ISV_END(2) = ISV_BEG(3)-1
  ISV_END(3) = NSV_CHACEND
END IF
!
!*       3.     FILTER OUT THE AQUEOUS SPECIES WHEN MICROPHYSICS<ZRTMIN_AQ
!	        --------------------------------------------------------
!
DO JRR = 2, KRRL+1
  GWATER(:,:,:) = .FALSE.
  WHERE (ZRRS(:,:,:,JRR)>(ZRTMIN_AQ*1.e3/PRHODREF(:,:,:)))
    GWATER(:,:,:)=.TRUE.
  END WHERE
!
  IWATER = COUNTJV( GWATER(:,:,:),I1W(:),I2W(:),I3W(:))
  IF( IWATER >= 1 ) THEN
    ALLOCATE(ZWORK(IWATER))
    DO JSV = ISV_BEG(JRR), ISV_END(JRR)
      DO JL = 1, IWATER
        ZWORK(JL) = PRSVS(I1W(JL),I2W(JL),I3W(JL),JSV)
      END DO
      PRSVS(:,:,:,JSV) = 0.0
      PRSVS(:,:,:,JSV) = UNPACK( ZWORK(:),MASK=GWATER(:,:,:),FIELD=0.0 )
    END DO
    DEALLOCATE(ZWORK)
  ELSE
    DO JSV = ISV_BEG(JRR), ISV_END(JRR)
      PRSVS(:,:,:,JSV) = 0.0
    ENDDO
  END IF
END DO
!
!
!*       4.     FILTER OUT THE ICE PHASE SPECIES WHEN MICROPHYSICS<ZRTMIN_AQ
!	        ------------------------------------------------------------
!
IF (OUSECHIC) THEN
  DO JRR = KRRL+1, KRR
    GICE(:,:,:) = .FALSE.
    WHERE (ZRRS(:,:,:,JRR)>(ZRTMIN_AQ*1.e3/PRHODREF(:,:,:)))
      GICE(:,:,:)=.TRUE.
    END WHERE
  ENDDO
!
  IICE = COUNTJV( GICE(:,:,:),I1I(:),I2I(:),I3I(:))
  IF( IICE >= 1 ) THEN
    ALLOCATE(ZWORK(IICE))
    DO JSV = NSV_CHICBEG, NSV_CHICEND
      DO JL = 1, IICE
        ZWORK(JL) = PRSVS(I1I(JL),I2I(JL),I3I(JL),JSV)
      END DO
      PRSVS(:,:,:,JSV) = 0.0
      PRSVS(:,:,:,JSV) = UNPACK( ZWORK(:),MASK=GICE(:,:,:),FIELD=0.0 )
    END DO
    DEALLOCATE(ZWORK)
  ELSE
    DO JSV = NSV_CHICBEG, NSV_CHICEND
      PRSVS(:,:,:,JSV) = 0.0
    ENDDO
  ENDIF
ENDIF
!
CONTAINS
!
!-------------------------------------------------------------------------------
!
  FUNCTION COUNTJV(GTAB,I1,I2,I3) RESULT(IC)
!
!*      0. DECLARATIONS
!          ------------
!
IMPLICIT NONE
!
!*       0.2  declaration of local variables
!
!
LOGICAL, DIMENSION(:,:,:) :: GTAB ! Mask
INTEGER, DIMENSION(:) :: I1,I2,I3 ! Used to replace the COUNT and PACK
INTEGER :: JI,JJ,JK,IC
!  
!-------------------------------------------------------------------------------
!
IC = 0
DO JK = 1,SIZE(GTAB,3)
  DO JJ = 1,SIZE(GTAB,2)
    DO JI = 1,SIZE(GTAB,1)
      IF( GTAB(JI,JJ,JK) ) THEN
        IC = IC +1
        I1(IC) = JI
        I2(IC) = JJ
        I3(IC) = JK
      END IF
    END DO
  END DO
END DO
!
END FUNCTION COUNTJV
!
!-------------------------------------------------------------------------------
!
END SUBROUTINE CH_AQUEOUS_CHECK 

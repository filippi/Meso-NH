MODULE MODE_IO_WRITE_FIELD
!
USE MODD_IO_ll, ONLY: TOUTBAK
USE MODE_FIELD
USE MODE_FMWRIT
!
IMPLICIT NONE
!
CONTAINS
!
SUBROUTINE IO_WRITE_FIELDLIST(TPOUTPUT,HFIPRI)
!
USE MODE_MODELN_HANDLER, ONLY : GET_CURRENT_MODEL_INDEX
!
IMPLICIT NONE
!
TYPE(TOUTBAK),POINTER,INTENT(IN) :: TPOUTPUT !Output structure
CHARACTER(LEN=*),     INTENT(IN)  :: HFIPRI ! File for prints in FM
!
INTEGER :: IDX
INTEGER :: IMI
INTEGER :: IRESP
INTEGER :: JI
!
IMI = GET_CURRENT_MODEL_INDEX()
!
DO JI = 1,SIZE(TPOUTPUT%NFIELDLIST)
  IDX = TPOUTPUT%NFIELDLIST(JI)
  SELECT CASE (TFIELDLIST(IDX)%NDIMS)
    !
    !0D output
    !
    CASE (0)
      SELECT CASE (TFIELDLIST(IDX)%NTYPE)
        !
        !0D logical
        !
        CASE (TYPELOG)
          IF ( .NOT.ALLOCATED(TFIELDLIST(IDX)%TFIELD_L0D) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_L0D is NOT allocated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          IF ( .NOT.ASSOCIATED(TFIELDLIST(IDX)%TFIELD_L0D(IMI)%DATA) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_L0D%DATA is not associated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TFIELDLIST(IDX),HFIPRI,IRESP,TFIELDLIST(IDX)%TFIELD_L0D(IMI)%DATA)
        !
        !0D real
        !
        CASE (TYPEREAL)
          IF ( .NOT.ALLOCATED(TFIELDLIST(IDX)%TFIELD_X0D) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X0D is NOT allocated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          IF ( .NOT.ASSOCIATED(TFIELDLIST(IDX)%TFIELD_X0D(IMI)%DATA) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X0D%DATA is not associated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TFIELDLIST(IDX),HFIPRI,IRESP,TFIELDLIST(IDX)%TFIELD_X0D(IMI)%DATA)
        !
        !0D other types
        !
        CASE DEFAULT
          PRINT *,'FATAL: IO_WRITE_FIELDLIST: type not yet supported for 0D output of ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
          STOP
      END SELECT
    !
    !1D output
    !
    CASE (1)
      SELECT CASE (TFIELDLIST(IDX)%NTYPE)
        !
        !1D real
        !
        CASE (TYPEREAL)
          IF ( .NOT.ALLOCATED(TFIELDLIST(IDX)%TFIELD_X1D) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X1D is NOT allocated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          IF ( .NOT.ASSOCIATED(TFIELDLIST(IDX)%TFIELD_X1D(IMI)%DATA) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X1D%DATA is not associated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TFIELDLIST(IDX),HFIPRI,IRESP,TFIELDLIST(IDX)%TFIELD_X1D(IMI)%DATA)
        !
        !1D other types
        !
        CASE DEFAULT
          PRINT *,'FATAL: IO_WRITE_FIELDLIST: type not yet supported for 1D output of ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
          STOP
      END SELECT
    !
    !2D output
    !
    CASE (2)
      SELECT CASE (TFIELDLIST(IDX)%NTYPE)
        !
        !2D real
        !
        CASE (TYPEREAL)
          IF ( .NOT.ALLOCATED(TFIELDLIST(IDX)%TFIELD_X2D) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X2D is NOT allocated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          IF ( .NOT.ASSOCIATED(TFIELDLIST(IDX)%TFIELD_X2D(IMI)%DATA) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X2D%DATA is not associated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TFIELDLIST(IDX),HFIPRI,IRESP,TFIELDLIST(IDX)%TFIELD_X2D(IMI)%DATA)
        !
        !2D other types
        !
        CASE DEFAULT
          PRINT *,'FATAL: IO_WRITE_FIELDLIST: type not yet supported for 2D output of ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
          STOP
      END SELECT
    !
    !3D output
    !
    CASE (3)
      SELECT CASE (TFIELDLIST(IDX)%NTYPE)
        !
        !3D real
        !
        CASE (TYPEREAL)
          IF ( .NOT.ALLOCATED(TFIELDLIST(IDX)%TFIELD_X3D) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X3D is NOT allocated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          IF ( .NOT.ASSOCIATED(TFIELDLIST(IDX)%TFIELD_X3D(IMI)%DATA) ) THEN
            PRINT *,'FATAL: IO_WRITE_FIELDLIST: TFIELD_X3D%DATA is not associated for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
            STOP
          END IF
          CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TFIELDLIST(IDX),HFIPRI,IRESP,TFIELDLIST(IDX)%TFIELD_X3D(IMI)%DATA)
        !
        !3D other types
        !
        CASE DEFAULT
          PRINT *,'FATAL: IO_WRITE_FIELDLIST: type not yet supported for 3D output of ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
          STOP
      END SELECT
    !
    !Other number of dimensions
    !
    CASE DEFAULT
      PRINT *,'FATAL: IO_WRITE_FIELDLIST: number of dimensions not yet supported for ',TRIM(TFIELDLIST(IDX)%CMNHNAME)
      STOP
  END SELECT
END DO
!
END SUBROUTINE IO_WRITE_FIELDLIST
!
!
!
SUBROUTINE IO_WRITE_FIELD_USER(TPOUTPUT,HFIPRI)
!
#if 0
USE MODD_PARAMETERS, ONLY : JPVEXT
USE MODD_DYN_n,    ONLY: XTSTEP
USE MODD_FIELD_n,    ONLY: XUT, XVT, XRT, XTHT
USE MODD_PRECIP_n, ONLY: XINPRR
#endif
!
IMPLICIT NONE
!
TYPE(TOUTBAK),POINTER,INTENT(IN) :: TPOUTPUT !Output structure
CHARACTER(LEN=*),     INTENT(IN)  :: HFIPRI ! File for prints in FM
!
INTEGER          :: IRESP
TYPE(TFIELDDATA) :: TZFIELD
!
#if 0
INTEGER          :: IKB
!
IKB=JPVEXT+1
!
TZFIELD%CMNHNAME   = 'UTLOW'
TZFIELD%CSTDNAME   = 'x_wind'
TZFIELD%CLONGNAME  = ''
TZFIELD%CUNITS     = 'm s-1'
TZFIELD%CDIR       = 'XY'
TZFIELD%CCOMMENT   = 'X_Y_Z_U component of wind (m/s) at lowest physical level'
TZFIELD%NGRID      = 2
TZFIELD%NTYPE      = TYPEREAL
TZFIELD%NDIMS      = 2
CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TZFIELD,HFIPRI,IRESP,XUT(:,:,IKB))
!
TZFIELD%CMNHNAME   = 'VTLOW'
TZFIELD%CSTDNAME   = 'y_wind'
TZFIELD%CLONGNAME  = ''
TZFIELD%CUNITS     = 'm s-1'
TZFIELD%CDIR       = 'XY'
TZFIELD%CCOMMENT   = 'X_Y_Z_V component of wind (m/s) at lowest physical level'
TZFIELD%NGRID      = 3
TZFIELD%NTYPE      = TYPEREAL
TZFIELD%NDIMS      = 2
CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TZFIELD,HFIPRI,IRESP,XVT(:,:,IKB))
!
TZFIELD%CMNHNAME   = 'THTLOW'
TZFIELD%CSTDNAME   = 'air_potential_temperature'
TZFIELD%CLONGNAME  = ''
TZFIELD%CUNITS     = 'K'
TZFIELD%CDIR       = 'XY'
TZFIELD%CCOMMENT   = 'X_Y_Z_potential temperature (K) at lowest physical level'
TZFIELD%NGRID      = 1
TZFIELD%NTYPE      = TYPEREAL
TZFIELD%NDIMS      = 2
CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TZFIELD,HFIPRI,IRESP,XTHT(:,:,IKB))
!
TZFIELD%CMNHNAME   = 'RVTLOW'
!TZFIELD%CSTDNAME   = 'humidity_mixing_ratio' !ratio of the mass of water vapor to the mass of dry air
TZFIELD%CSTDNAME   = 'specific_humidity'     !mass fraction of water vapor in (moist) air
TZFIELD%CLONGNAME  = ''
TZFIELD%CUNITS     = 'kg kg-1'
TZFIELD%CDIR       = 'XY'
TZFIELD%CCOMMENT   = 'X_Y_Z_Vapor mixing Ratio (KG/KG) at lowest physical level'
TZFIELD%NGRID      = 1
TZFIELD%NTYPE      = TYPEREAL
TZFIELD%NDIMS      = 2
CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TZFIELD,HFIPRI,IRESP,XRT(:,:,IKB,1))
!
TZFIELD%CMNHNAME   = 'ACPRRSTEP'
TZFIELD%CSTDNAME   = 'rainfall_amount'
TZFIELD%CLONGNAME  = ''
TZFIELD%CUNITS     = 'kg m-2'
TZFIELD%CDIR       = ''
TZFIELD%CCOMMENT   = 'X_Y_ACcumulated Precipitation Rain Rate during timestep (kg m-2)'
TZFIELD%NGRID      = 1
TZFIELD%NTYPE      = TYPEREAL
TZFIELD%NDIMS      = 2
!XACPRR is multiplied by 1000. to convert from m to kg m-2 (water density is assumed to be 1000 kg m-3)
CALL IO_WRITE_FIELD(TPOUTPUT%TFILE,TZFIELD,HFIPRI,IRESP,XINPRR*XTSTEP*1.0E3)
#endif
!
END SUBROUTINE IO_WRITE_FIELD_USER
!
END MODULE MODE_IO_WRITE_FIELD

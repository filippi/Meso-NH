!MNH_LIC Copyright 1995-2020 CNRS, Meteo-France and Universite Paul Sabatier
!MNH_LIC This is part of the Meso-NH software governed by the CeCILL-C licence
!MNH_LIC version 1. See LICENSE, CeCILL-C_V1-en.txt and CeCILL-C_V1-fr.txt
!MNH_LIC for details. version 1.
!-----------------------------------------------------------------
! Author:
!  J. Nicolau (Meteo-France) 27/02/1995
! Modifications:
!  J. Stein    09/09/1996: add the writings in the diachronic file
!  J.-P. Pinty 18/12/1996: clarify the coding
!  J.-P. Pinty 18/03/1997: correction for the SVx
!  V. Gouget M. Chong J.-P. Lafore 10/02/1998: add the BURHODJ, TSTEP and BULEN and writes in physical units
!  V. Ducrocq  07/06/1999: //
!  N. Asencio  18/06/1999: // budget with MASK case
!                         delete ZTORE arrays no longer used, so delete
!                         KIU,KJU,KKU arguments
!                         the mask is written once with a FMWRIT call outside
!                         write_diachro: its name is MASK_(value of NBUTSHIFT).MASK
!                         MENU_DIACHRO must be called after FMWRIT to be read in
!                         read_diachro.
!                         NBUTSHIFT is incremented at the beginning of the routine
!                         The dimensions of the XBUR.. arrays are : first one
!                         is the dimension along K, second one is the time, the
!                         third one is the number of the masks.
!  G. Tanguy      10/2009: add ILENCH=LEN(YCOMMENT) after change of YCOMMENT
!  J. Escobar  24/03/2014: misplaced deallocate in RSV budget
!  C. Lac      11/09/2015: orrection due to FIT temporal scheme
!  P. Wautelet 28/03/2018: Replace TEMPORAL_DIST by DATETIME_DISTANCE
!  P. Wautelet 05/2016-04/2018: new data structures and calls for I/O
!  P. Wautelet 13/09/2019: budget: simplify and modernize date/time management
!  P. Wautelet 14/10/2019: complete restructuration and deduplication of code
!  P. Wautelet 10/03/2020: use the new data structures and subroutines for budgets
!-----------------------------------------------------------------

!#######################
module mode_write_budget
!#######################

use mode_msg

implicit none

private

public :: Write_budget

contains

!#########################################################
subroutine Write_budget( tpdiafile, tpdtcur, ptstep, ksv )
!#########################################################
!
!!****  *WRITE_BUDGET* - routine to write a budget file
!!                           
!!
!!    PURPOSE
!!    -------
!        The purpose of this routine is to write an initial LFIFM File 
!     of name YFILEDIA//'.lfi' with the FM routines. This routine is 
!     temporary because the budget terms had to be stored in the diachronic
!     MesoNH-files, not yet developped. 
!
!!**  METHOD
!!    ------
!!      The data are written in the LFIFM file :
!!        - dimensions
!!        - budget arrays
!!        - tracer array in mask case
!!
!!      The localization on the model grid is also indicated :
!!
!!        IGRID = 1 for mass grid point
!!        IGRID = 2 for U grid point
!!        IGRID = 3 for V grid point
!!        IGRID = 4 for w grid point
!!        IGRID = 0 for meaningless case
!!
!!
!!
!!    EXTERNAL
!!    --------
!!       NONE
!!
!!    IMPLICIT ARGUMENTS
!!    ------------------
!!       Module MODD_BUDGET
!!
!!
!!    REFERENCE
!!    ---------
!!      Book2 of MESO-NH documentation (routine WRITE_BUDGET)
!!
!-------------------------------------------------------------------------------

  use modd_budget,         only: cbutype, nbumask, nbutshift, nbustep, nbuwrnb, xbulen, xbusurf,                                  &
                                 lbu_icp, lbu_jcp,                                                                                &
                                 lbu_ru, lbu_rv, lbu_rw, lbu_rth, lbu_rtke, lbu_rrv, lbu_rrc, lbu_rrr,                            &
                                 lbu_rri, lbu_rrs, lbu_rrg, lbu_rrh, lbu_rsv,                                                     &
                                 NBUDGET_RHO, NBUDGET_U, NBUDGET_V, NBUDGET_W, NBUDGET_TH, NBUDGET_TKE,                           &
                                 NBUDGET_RV, NBUDGET_RC, NBUDGET_RR, NBUDGET_RI, NBUDGET_RS, NBUDGET_RG, NBUDGET_RH, NBUDGET_SV1, &
                                 tbudgets, tburhodj
  use modd_field,          only: tfielddata, TYPEREAL
  use modd_io,             only: tfiledata
  use modd_lunit_n,        only: tluout
  use modd_parameters,     only: NMNHNAMELGTMAX
  use modd_type_date,      only: date_time

  use mode_datetime,       only: datetime_distance
  use mode_io_field_write, only: IO_Field_write
  use mode_menu_diachro,   only: Menu_diachro
  use mode_msg
  use mode_time,           only: tdtexp

  implicit none

  type(tfiledata), intent(in) :: tpdiafile    ! file to write
  type(date_time), intent(in) :: tpdtcur      ! current date and time
  real,            intent(in) :: ptstep       ! time step
  integer,         intent(in) :: ksv          ! number of scalar variables

  character(len=NMNHNAMELGTMAX)                        :: yrecfm        ! name of the article to be written
  integer                                              :: jt, jmask
  integer                                              :: jsv           ! loop index over the ksv svx
  logical                                              :: gnocompress   ! true: no compression along x and y direction (cart option)
  real,            dimension(:),           allocatable :: zworktemp
  real,            dimension(:,:,:,:,:,:), allocatable :: zrhodjn, zworkmask
  type(date_time), dimension(:),           allocatable :: tzdates
  type(tfielddata) :: tzfield
  !
  !-------------------------------------------------------------------------------
  !
  call Print_msg( NVERB_DEBUG, 'BUD', 'Write_budget', 'called' )

  gnocompress = .true.
  !
  !* Write TSTEP and BULEN
  !  ---------------------
  !
  TZFIELD%CMNHNAME   = 'TSTEP'
  TZFIELD%CSTDNAME   = ''
  TZFIELD%CLONGNAME  = 'TSTEP'
  TZFIELD%CUNITS     = 's'
  TZFIELD%CDIR       = '--'
  TZFIELD%CCOMMENT   = 'Time step'
  TZFIELD%NGRID      = 0
  TZFIELD%NTYPE      = TYPEREAL
  TZFIELD%NDIMS      = 0
  TZFIELD%LTIMEDEP   = .FALSE.
  CALL IO_Field_write(TPDIAFILE,TZFIELD,PTSTEP)
  !
  TZFIELD%CMNHNAME   = 'BULEN'
  TZFIELD%CSTDNAME   = ''
  TZFIELD%CLONGNAME  = 'BULEN'
  TZFIELD%CUNITS     = 's'
  TZFIELD%CDIR       = '--'
  TZFIELD%CCOMMENT   = 'Time step'
  TZFIELD%NGRID      = 0
  TZFIELD%NTYPE      = TYPEREAL
  TZFIELD%NDIMS      = 0
  TZFIELD%LTIMEDEP   = .FALSE.
  CALL IO_Field_write(TPDIAFILE,TZFIELD,XBULEN)
  !
  ! Initialize NBUTSHIFT
  NBUTSHIFT = NBUTSHIFT+1
  !
  !
  SELECT CASE (CBUTYPE)
  !
  !-------------------------------------------------------------------------------
  !
  !* 2.     'CART' CASE
  !         -----------
  !
    CASE('CART','SKIP')
      GNOCOMPRESS=(.NOT.LBU_ICP .AND. .NOT.LBU_JCP)
  !
  !* 2.1    Initialization
  !
      ALLOCATE( ZWORKTEMP(1) )
      allocate( tzdates(1) )
  !
      !Compute time at the middle of the temporally-averaged budget timestep
      !This time is computed from the beginning of the experiment
      CALL DATETIME_DISTANCE(TDTEXP,TPDTCUR,ZWORKTEMP(1))
  !
      ZWORKTEMP(1)=ZWORKTEMP(1)+(1.-NBUSTEP*0.5)*PTSTEP
  !
      tzdates(1)%tdate%year  = tdtexp%tdate%year
      tzdates(1)%tdate%month = tdtexp%tdate%month
      tzdates(1)%tdate%day   = tdtexp%tdate%day
      tzdates(1)%time        = tdtexp%time + zworktemp(1)

      DEALLOCATE ( ZWORKTEMP )
  !
  !-------------------------------------------------------------------------------
  !
  !* 3.     'MASK' CASE
  !         -----------
  !
    CASE('MASK')
      ALLOCATE(ZWORKTEMP(NBUWRNB))
      allocate( tzdates(NBUWRNB) )
      ALLOCATE(ZWORKMASK(SIZE(XBUSURF,1),SIZE(XBUSURF,2),1,NBUWRNB,NBUMASK,1))
  !
  ! local array
      DO JMASK=1,NBUMASK
        DO JT=1,NBUWRNB
          ZWORKMASK(:,:,1,JT,JMASK,1) = XBUSURF(:,:,JMASK,JT)
        END DO
      END DO
  !
      CALL DATETIME_DISTANCE(TDTEXP,TPDTCUR,ZWORKTEMP(NBUWRNB))
  !
      ZWORKTEMP(NBUWRNB)=ZWORKTEMP(NBUWRNB)+(1.-NBUSTEP*0.5)*PTSTEP
  !
      tzdates(NBUWRNB)%tdate%year  = tdtexp%tdate%year
      tzdates(NBUWRNB)%tdate%month = tdtexp%tdate%month
      tzdates(NBUWRNB)%tdate%day   = tdtexp%tdate%day
      tzdates(NBUWRNB)%time        = tdtexp%time + zworktemp(NBUWRNB)
      DO JT=1,NBUWRNB-1
        ZWORKTEMP(JT) = ZWORKTEMP(NBUWRNB)-NBUSTEP*PTSTEP*(NBUWRNB-JT)
        tzdates(jt)%tdate%year  = tdtexp%tdate%year
        tzdates(jt)%tdate%month = tdtexp%tdate%month
        tzdates(jt)%tdate%day   = tdtexp%tdate%day
        tzdates(jt)%time        = tdtexp%time + zworktemp(jt)
      END DO

      DEALLOCATE( ZWORKTEMP )
  !
  !*     3.1    storage of the masks  array
  !
      WRITE(TZFIELD%CMNHNAME,FMT="('MASK_',I4.4,'.MASK')" ) nbutshift
      TZFIELD%CSTDNAME   = ''
      TZFIELD%CLONGNAME  = TRIM(TZFIELD%CMNHNAME)
      TZFIELD%CUNITS     = ''
      TZFIELD%CDIR       = 'XY'
      WRITE(TZFIELD%CCOMMENT,FMT="('X_Y_MASK',I4.4)" ) nbutshift
      TZFIELD%NGRID      = 1
      TZFIELD%NTYPE      = TYPEREAL
      TZFIELD%NDIMS      = 6
      TZFIELD%LTIMEDEP   = .FALSE.
      CALL IO_Field_write(TPDIAFILE,TZFIELD,ZWORKMASK(:,:,:,:,:,:))
      WRITE(YRECFM,FMT="('MASK_',I4.4)" ) nbutshift
      CALL MENU_DIACHRO(TPDIAFILE,YRECFM)
      DEALLOCATE(ZWORKMASK)
  !
  END SELECT
  !
  if ( cbutype == 'CART' .or. cbutype == 'SKIP' .or. cbutype == 'MASK' ) then
  !
  !* Storage of the budgets array
  !
  !* RU budgets
  !
    IF (LBU_RU) THEN
      call Store_one_budget_rho( tpdiafile, tzdates, tbudgets(NBUDGET_U)%trhodj,   NBUDGET_U, gnocompress, zrhodjn )
      call Store_one_budget    ( tpdiafile, tzdates, tbudgets(NBUDGET_U), zrhodjn, NBUDGET_U, gnocompress, ptstep  )
    END IF
  !
  !* RV budgets
  !
    IF (LBU_RV) THEN
      call Store_one_budget_rho( tpdiafile, tzdates, tbudgets(NBUDGET_V)%trhodj,   NBUDGET_V, gnocompress, zrhodjn )
      call Store_one_budget    ( tpdiafile, tzdates, tbudgets(NBUDGET_V), zrhodjn, NBUDGET_V, gnocompress, ptstep  )
    END IF
  !
  !* RW budgets
  !
    IF (LBU_RW) THEN
      call Store_one_budget_rho( tpdiafile, tzdates, tbudgets(NBUDGET_W)%trhodj,   NBUDGET_W, gnocompress, zrhodjn )
      call Store_one_budget    ( tpdiafile, tzdates, tbudgets(NBUDGET_W), zrhodjn, NBUDGET_W, gnocompress, ptstep  )
    END IF
  !
  !* RHODJ storage for Scalars
  !
    IF (LBU_RTH .OR. LBU_RTKE .OR. LBU_RRV .OR. LBU_RRC .OR. LBU_RRR .OR. &
        LBU_RRI .OR. LBU_RRS  .OR. LBU_RRG .OR. LBU_RRH .OR. LBU_RSV      ) THEN
      if ( .not. associated( tburhodj ) ) call Print_msg( NVERB_FATAL, 'BUD', 'Write_budget', 'tburhodj not associated' )
      call Store_one_budget_rho( tpdiafile, tzdates, tburhodj, NBUDGET_RHO, gnocompress, zrhodjn )
    ENDIF
  !
  !* RTH budget
  !
    IF (LBU_RTH) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_TH), zrhodjn, NBUDGET_TH, gnocompress, ptstep  )
    END IF
  !
  !* RTKE budget
  !
    IF (LBU_RTKE) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_TKE), zrhodjn, NBUDGET_TKE, gnocompress, ptstep  )
    END IF
  !
  !* RRV budget
  !
    IF (LBU_RRV) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RV), zrhodjn, NBUDGET_RV, gnocompress, ptstep  )
    END IF
  !
  !* RRC budget
  !
    IF (LBU_RRC) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RC), zrhodjn, NBUDGET_RC, gnocompress, ptstep  )
    END IF
  !
  !* RRR budget
  !
    IF (LBU_RRR) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RR), zrhodjn, NBUDGET_RR, gnocompress, ptstep  )
    END IF
  !
  !* RRI budget
  !
    IF (LBU_RRI) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RI), zrhodjn, NBUDGET_RI, gnocompress, ptstep  )
    END IF
  !
  !* RRS budget
  !
    IF (LBU_RRS) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RS), zrhodjn, NBUDGET_RS, gnocompress, ptstep  )
    END IF
  !
  !* RRG budget
  !
    IF (LBU_RRG) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RG), zrhodjn, NBUDGET_RG, gnocompress, ptstep  )
    END IF
  !
  !* RRH budget
  !
    IF (LBU_RRH) THEN
      call Store_one_budget( tpdiafile, tzdates, tbudgets(NBUDGET_RH), zrhodjn, NBUDGET_RH, gnocompress, ptstep  )
    END IF
  !
  !* RSV budgets
  !
    IF (LBU_RSV) THEN
      do jsv = nbudget_sv1, nbudget_sv1 - 1 + ksv
        call Store_one_budget( tpdiafile, tzdates, tbudgets(jsv), zrhodjn, jsv, gnocompress, ptstep  )
      end do
    END IF
  end if

end subroutine Write_budget


subroutine Store_one_budget_rho( tpdiafile, tpdates, tprhodj, kp, knocompress, prhodjn )
  use modd_budget,            only: cbutype,                                                      &
                                    lbu_icp, lbu_jcp, lbu_kcp,                                    &
                                    nbuil, nbuih, nbujl, nbujh, nbukl, nbukh,                     &
                                    nbuimax, nbuimax_ll, nbujmax, nbujmax_ll, nbukmax, nbutshift, &
                                    nbumask, nbuwrnb,                                             &
                                    tburhodata,                                                   &
                                    NBUDGET_RHO, NBUDGET_U, NBUDGET_V, NBUDGET_W
  use modd_io,                only: tfiledata
  use modd_lunit_n,           only: tluout
  use modd_parameters,        only: XNEGUNDEF
  use modd_type_date,         only: date_time

  use mode_msg
  use mode_write_diachro,     only: Write_diachro

  use modi_end_cart_compress, only: End_cart_compress
  use modi_end_mask_compress, only: End_mask_compress

  implicit none

  type(tfiledata),                                      intent(in)  :: tpdiafile   ! file to write
  type(date_time), dimension(:),                        intent(in)  :: tpdates
  type(tburhodata),                                     intent(in)  :: tprhodj     ! rhodj datastructure
  integer,                                              intent(in)  :: kp          ! reference number of budget
  logical,                                              intent(in)  :: knocompress ! compression for the cart option
  real,            dimension(:,:,:,:,:,:), allocatable, intent(out) :: prhodjn

  character(len=4)                               :: ybutype
  character(len=9)                               :: ygroup_name   ! group name
  character(len=99),  dimension(:), allocatable  :: ybucomment    ! comment
  character(len=100), dimension(:), allocatable  :: yworkcomment  ! comment
  character(len=100), dimension(:), allocatable  :: yworkunit     ! comment
  integer,            dimension(:), allocatable  :: iworkgrid     ! grid label

  call Print_msg( NVERB_DEBUG, 'BUD', 'Store_one_budget_rho', 'called for '//trim( tprhodj%cmnhname ) )

  if ( allocated( prhodjn ) ) deallocate( prhodjn )

  ! pburhodj storage
  select case ( cbutype )
    case( 'CART', 'SKIP' )
      ybutype = 'CART'
        if ( knocompress ) then
          allocate( prhodjn(nbuimax, nbujmax, nbukmax, 1, 1, 1) ) ! local budget of RHODJU
          prhodjn(:, :, :, 1, 1, 1) = tprhodj%xdata(:, :, :)
        else
          allocate( prhodjn(nbuimax_ll, nbujmax_ll, nbukmax, 1, 1, 1) ) ! global budget of RhodjU
          prhodjn(:,:,:,1,1,1)=End_cart_compress( tprhodj%xdata(:,:,:) )
        end if
    case('MASK')
      ybutype = 'MASK'
        allocate( prhodjn(1, 1, nbukmax, nbuwrnb, nbumask, 1) )
        prhodjn(1, 1, :, :, :, 1) = End_mask_compress( tprhodj%xdata(:, :, :) )
        where  ( prhodjn(1, 1, :, :, :, 1) <= 0. )
            prhodjn(1, 1, :, :, :, 1) = XNEGUNDEF
        end where

    case default
      call Print_msg( NVERB_ERROR, 'BUD', 'Store_one_budget_rho', 'unknown CBUTYPE' )
  end select

  allocate( ybucomment(1) )
  allocate( yworkunit(1) )
  allocate( yworkcomment(1) )
  allocate( iworkgrid(1) )

  ybucomment(1)   = tprhodj%cmnhname
  yworkunit(1)    = tprhodj%cunits
  yworkcomment(1) = tprhodj%ccomment
  iworkgrid(1)    = tprhodj%ngrid

  select case( kp )
    case( NBUDGET_RHO )
      write( ygroup_name, fmt = "('RJS__',I4.4)" ) nbutshift

    case( NBUDGET_U )
      write( ygroup_name, fmt = "('RJX__',I4.4)" ) nbutshift

    case( NBUDGET_V )
      write( ygroup_name, fmt = "('RJY__',I4.4)" ) nbutshift

    case( NBUDGET_W )
      write( ygroup_name, fmt = "('RJZ__',I4.4)" ) nbutshift

    case default
      call Print_msg( NVERB_ERROR, 'BUD', 'Store_one_budget_rho', 'unknown budget type' )
  end select

  call Write_diachro( tpdiafile, tluout, ygroup_name, ybutype, iworkgrid,                          &
                      tpdates, prhodjn, ybucomment,                                                &
                      yworkunit, yworkcomment,                                                     &
                      oicp = lbu_icp, ojcp = lbu_jcp, okcp = lbu_kcp,                              &
                      kil = nbuil, kih = nbuih, kjl = nbujl, kjh = nbujh, kkl = nbukl, kkh = nbukh )
  deallocate( ybucomment, yworkunit, yworkcomment, iworkgrid )

end subroutine Store_one_budget_rho


subroutine Store_one_budget( tpdiafile, tpdates, tpbudget, prhodjn, kp, knocompress, ptstep )
  use modd_budget,            only: cbutype,                                                                                      &
                                    lbu_icp, lbu_jcp, lbu_kcp,                                                                    &
                                    nbuil, nbuih, nbujl, nbujh, nbukl, nbukh,                                                     &
                                    nbuimax, nbuimax_ll, nbujmax, nbujmax_ll, nbukmax, nbustep, nbutshift,                        &
                                    nbumask, nbuwrnb,                                                                             &
                                    NBUDGET_U, NBUDGET_V, NBUDGET_W, NBUDGET_TH, NBUDGET_TKE, NBUDGET_RV, NBUDGET_RC, NBUDGET_RR, &
                                    NBUDGET_RI, NBUDGET_RS, NBUDGET_RG, NBUDGET_RH, NBUDGET_SV1,                                  &
                                    tbudgetdata
  use modd_io,                only: tfiledata
  use modd_lunit_n,           only: tluout
  use modd_parameters,        only: NBUNAMELGTMAX
  use modd_type_date,         only: date_time

  use mode_msg
  use mode_write_diachro,     only: Write_diachro

  use modi_end_cart_compress, only: End_cart_compress
  use modi_end_mask_compress, only: End_mask_compress

  implicit none

  type(tfiledata),                                      intent(in) :: tpdiafile   ! file to write
  type(date_time), dimension(:),                        intent(in) :: tpdates
  type(tbudgetdata),                                    intent(in) :: tpbudget ! Budget datastructure
  real,            dimension(:,:,:,:,:,:), allocatable, intent(in) :: prhodjn
  integer,                                              intent(in) :: kp          ! reference number of budget
  logical,                                              intent(in) :: knocompress ! compression for the cart option
  real,                                                 intent(in) :: ptstep      ! time step

  character(len=4)                                        :: ybutype
  character(len=9)                                        :: ygroup_name
  character(len=NBUNAMELGTMAX), dimension(:), allocatable :: ytitles
  character(len=100), dimension(:),           allocatable :: yworkcomment
  character(len=100), dimension(:),           allocatable :: yworkunit
  integer                                                 :: igroups
  integer                                                 :: jproc
  integer                                                 :: jsv
  integer                                                 :: jt
  integer,            dimension(:),           allocatable :: iworkgrid  ! grid label
  real,               dimension(:),           allocatable :: zconvert   ! unit conversion coefficient
  real,               dimension(:,:,:,:,:,:), allocatable :: zworkt

  call Print_msg( NVERB_DEBUG, 'BUD', 'Store_one_budget', 'called for '//trim( tpbudget%cname ) )

  if( .not. allocated( prhodjn ) ) then
    call Print_msg( NVERB_ERROR, 'BUD', 'Store_one_budget', 'prhodjn not allocated' )
    return
  end if

  igroups = tpbudget%ngroups

  ! unit conversion for  ru budgets
  allocate( zconvert( igroups ) )
  do jproc = 1, igroups
    if (      tpbudget%tgroups(jproc)%cmnhname == 'INIF' &
         .or. tpbudget%tgroups(jproc)%cmnhname == 'ENDF' &
         .or. tpbudget%tgroups(jproc)%cmnhname == 'AVEF' ) then
      zconvert(jproc) = ptstep * Real( nbustep )
    else
      zconvert(jproc) = 1.
    end if
  end do

  select case ( cbutype )
    case( 'CART', 'SKIP' )
      ybutype = 'CART'
        if ( knocompress ) then
          allocate( zworkt(nbuimax, nbujmax, nbukmax, 1, 1, igroups ) ) ! local budget of ru
          do jproc = 1, igroups
            zworkt(:, :, :, 1, 1, jproc) = tpbudget%tgroups(jproc)%xdata(:, :, :) &
                                           * zconvert(jproc) / prhodjn(:, :, :, 1, 1, 1)
          end do
        else
          allocate( zworkt(nbuimax_ll, nbujmax_ll, nbukmax, 1, 1, igroups ) ) ! global budget of ru

          do jproc = 1, igroups
            zworkt(:, :, :, 1, 1, jproc) = End_cart_compress( tpbudget%tgroups(jproc)%xdata(:, :, :) )
            zworkt(:, :, :, 1, 1, jproc) = zworkt(:, :, :, 1, 1, jproc) * zconvert(jproc) / prhodjn(:, :, :, 1, 1, 1)
          end do
        endif
    case('MASK')
      ybutype = 'MASK'
        allocate( zworkt(1, 1, nbukmax, nbuwrnb, nbumask, igroups ) )
        do jproc = 1, igroups
          zworkt(1, 1, :, :, :, jproc) = End_mask_compress( tpbudget%tgroups(jproc)%xdata(:, :, :) ) &
                                        * zconvert(jproc) / prhodjn(1, 1, :, :, :, 1)
        end do

    case default
      call Print_msg( NVERB_ERROR, 'BUD', 'Store_one_budget', 'unknown CBUTYPE' )
  end select

  deallocate(zconvert)

  allocate( ytitles( igroups ) )
  allocate( yworkunit( igroups ) )
  allocate( yworkcomment( igroups ) )
  allocate( iworkgrid( igroups ) )

  yworkunit(:)    = tpbudget%tgroups(:)%cunits
  yworkcomment(:) = tpbudget%tgroups(:)%ccomment
  iworkgrid(:)    = tpbudget%tgroups(:)%ngrid

  select case( kp )
    case ( NBUDGET_U )
      write( ygroup_name, fmt = "('UU___',I4.4)" ) nbutshift

    case ( NBUDGET_V )
      write( ygroup_name, fmt = "('VV___',I4.4)" ) nbutshift

    case ( NBUDGET_W )
      write( ygroup_name, fmt = "('WW___',I4.4)" ) nbutshift

    case ( NBUDGET_TH )
      write( ygroup_name, fmt = "('TH___',I4.4)" ) nbutshift

    case ( NBUDGET_TKE )
      write( ygroup_name, fmt = "('TK___',I4.4)" ) nbutshift

    case ( NBUDGET_RV )
      write( ygroup_name, fmt = "('RV___',I4.4)" ) nbutshift

    case ( NBUDGET_RC )
      write( ygroup_name, fmt = "('RC___',I4.4)" ) nbutshift

    case ( NBUDGET_RR )
      write( ygroup_name, fmt = "('RR___',I4.4)" ) nbutshift

    case ( NBUDGET_RI )
      write( ygroup_name, fmt = "('RI___',I4.4)" ) nbutshift

    case ( NBUDGET_RS )
      write( ygroup_name, fmt = "('RS___',I4.4)" ) nbutshift

    case ( NBUDGET_RG )
      write( ygroup_name, fmt = "('RG___',I4.4)" ) nbutshift

    case ( NBUDGET_RH )
      write( ygroup_name, fmt = "('RH___',I4.4)" ) nbutshift

    case ( NBUDGET_SV1 : )
      jsv = kp - NBUDGET_SV1 + 1
!       yworkunit(:)       = 's-1' ;  yworkunit(1:3) = '  '
!       DO JT = 1, igroups
!         WRITE(yworkcomment(JT),FMT="('Budget of SVx=',I3.3)") jsv
!       END DO
      write( ygroup_name, fmt = "('SV',I3.3,I4.4)") jsv, nbutshift

    case default
      call Print_msg( NVERB_ERROR, 'BUD', 'Store_one_budget', 'unknown budget type' )
  end select

  do jproc = 1, igroups
    ytitles(jproc) = trim( tpbudget%tgroups(jproc)%cmnhname )
  end do

  call Write_diachro( tpdiafile, tluout, ygroup_name, ybutype, iworkgrid,                              &
                          tpdates, zworkt, ytitles,                                                    &
                          yworkunit, yworkcomment,                                                     &
                          oicp = lbu_icp, ojcp = lbu_jcp, okcp = lbu_kcp,                              &
                          kil = nbuil, kih = nbuih, kjl = nbujl, kjh = nbujh, kkl = nbukl, kkh = nbukh )

  deallocate( zworkt, yworkunit, yworkcomment, iworkgrid )

end subroutine Store_one_budget

end module mode_write_budget

!-----------------------------------------------------------------
!--------------- special set of characters for RCS information
!-----------------------------------------------------------------
! $Source$ $Revision$
! MASDEV4_7 modd 2006/05/18 13:07:25
!-----------------------------------------------------------------
!     ######################
      MODULE MODD_PGDSILWORK
!     ######################
!
!!****  *MODD_PGDSILWORK* - declaration of work arrays and variables
!!                          for silhouette orography
!!
!!    PURPOSE
!!    -------  
!!
!!
!!**  IMPLICIT ARGUMENTS
!!    ------------------
!!      None 
!!
!!    REFERENCE
!!    ---------
!!          
!!    AUTHOR
!!    ------
!!	V. Masson   *Meteo France*
!!
!!    MODIFICATIONS
!!    -------------
!!      Original    12/09/95                      
!-------------------------------------------------------------------------------
!
!*       0.   DECLARATIONS
!             ------------
!
IMPLICIT NONE
!
REAL,    DIMENSION(:,:), ALLOCATABLE           :: ZMAXX  ! maximum of orography
REAL,    DIMENSION(:,:), ALLOCATABLE           :: ZMAXY  ! in a silhouette segment
                                                         ! in x and y directions
LOGICAL, DIMENSION(:,:), ALLOCATABLE           :: GSEGX  ! presence of data in
LOGICAL, DIMENSION(:,:), ALLOCATABLE           :: GSEGY  ! x and y segments
INTEGER :: ISTEPX                ! number of silhouette computation segments
INTEGER :: ISTEPY                ! in x and y directions in the grid mesh
!
!-------------------------------------------------------------------------------
!
END MODULE MODD_PGDSILWORK

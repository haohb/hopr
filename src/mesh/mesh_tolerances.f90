#include "defines.f90"
MODULE MOD_Mesh_Tolerances
!===================================================================================================================================
! ?
!===================================================================================================================================
! MODULES
USE MOD_Globals
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
PRIVATE
!-----------------------------------------------------------------------------------------------------------------------------------
! GLOBAL VARIABLES 
!-----------------------------------------------------------------------------------------------------------------------------------
! Private Part ---------------------------------------------------------------------------------------------------------------------
! Public Part ----------------------------------------------------------------------------------------------------------------------
INTERFACE COMPAREPOINT
  MODULE PROCEDURE COMPAREPOINT
END INTERFACE

INTERFACE SAMEPOINT
  MODULE PROCEDURE SAMEPOINT
END INTERFACE

PUBLIC::COMPAREPOINT,SAMEPOINT
!===================================================================================================================================

CONTAINS
FUNCTION COMPAREPOINT(x1,x2,tol)
!===================================================================================================================================
! check if distance betwen points "x1" and "x2" is lower than tolerance "tol"
!===================================================================================================================================
! MODULES
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT VARIABLES
REAL,INTENT(IN)       :: x1(3)  ! two points
REAL,INTENT(IN)       :: x2(3)    ! ? 
REAL,INTENT(IN)       :: tol     ! tolerance
!-----------------------------------------------------------------------------------------------------------------------------------
! OUTPUT VARIABLES
LOGICAL               :: COMPAREPOINT ! true if same point
!-----------------------------------------------------------------------------------------------------------------------------------
! LOCAL VARIABLES 
!===================================================================================================================================
COMPAREPOINT=(SQRT(SUM((x2-x1)*(x2-x1))).LT.tol)
END FUNCTION COMPAREPOINT

FUNCTION SAMEPOINT(x1,x2,tolin)
!===================================================================================================================================
! check if distance betwen points "x1" and "x2" is lower than toreance "tolin"
!===================================================================================================================================
! MODULES
USE MOD_Mesh_Vars,ONLY:SpaceQuandt
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT VARIABLES
REAL,INTENT(IN)                  :: x1(3)  ! two points
REAL,INTENT(IN)                  :: x2(3)    ! ? 
REAL,INTENT(IN),OPTIONAL         :: tolin     ! tolerance
!-----------------------------------------------------------------------------------------------------------------------------------
! OUTPUT VARIABLES
LOGICAL               :: samePoint ! true if same point
!-----------------------------------------------------------------------------------------------------------------------------------
! LOCAL VARIABLES 
REAL                  :: r,tol  ! ?
!===================================================================================================================================
! as sometimes only sinlge (or even less) precision data
! available. If samePoint does not detect identical points,
! (or falsely detects non-identical points) fatal behaviour of the code.
IF (PRESENT(tolin)) THEN
  tol=tolin
ELSE
  tol=RealTolerance
END IF
tol=tol*SpaceQuandt
! use L_2 vektor norm
!v1=x2-x1
!r=SUM(v1*v1)
! use L_1 vektor norm
r=SQRT(SUM((x2-x1)*(x2-x1)))
samePoint=.FALSE.
! L_2 norm is quadratic, so we need tol**2
!IF ( r .LT. tol*tol) samePoint=.TRUE.
! compare the norm to tolerance
IF ( r .LT. tol) samePoint=.TRUE.
END FUNCTION SAMEPOINT

END MODULE MOD_Mesh_Tolerances

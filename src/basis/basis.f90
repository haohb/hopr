#include "defines.f90"
MODULE MOD_Basis
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
INTERFACE fillBasisMapping
   MODULE PROCEDURE fillBasisMapping
END INTERFACE

INTERFACE InitBasis
   MODULE PROCEDURE InitBasis
END INTERFACE

PUBLIC:: InitBasis
!===================================================================================================================================

CONTAINS
SUBROUTINE InitBasis()
!===================================================================================================================================
! Initialize...
!===================================================================================================================================
! MODULES
USE MOD_Basis_Vars
USE MOD_Mesh_Vars,ONLY:MeshInitDone,N
USE MOD_ReadInTools
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
! OUTPUT VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
! LOCAL VARIABLES 
CHARACTER(LEN=4) :: tmpstr  ! ?
!===================================================================================================================================
WRITE(UNIT_StdOut,'(132("-"))')
WRITE(UNIT_stdOut,'(A)') ' INIT BASIS...'
IF(.NOT.MeshInitDone)THEN
  CALL abort(__STAMP__,  &
             'ERROR: InitMesh has to be called before InitBasis!',999,999.)
END IF
WRITE(tmpstr,'(I4)')N
nVisu=GETINT('nVisu',tmpstr)
WRITE(tmpstr,'(I4)')N+2
nAnalyze=GETINT('nAnalyze',tmpstr)
IF(nVisu.LT.1)THEN
  CALL abort(__STAMP__,'nVisu has to be >= 1')
END IF
CALL fillBasisMapping()
WRITE(UNIT_stdOut,'(A)')' INIT BASIS DONE!'
WRITE(UNIT_StdOut,'(132("-"))')
END SUBROUTINE InitBasis


SUBROUTINE fillBasisMapping()
!===================================================================================================================================
! determines the hierarchical relation from iAns to the position of the testfunction in the basis triangle, tetrahedra 
! example: linear monomial basis function in 2D: nAns=3: 1,x,y
! iAns=1: 1, iAns=2: x, iAns=3: y
!===================================================================================================================================
! MODULES
USE MOD_Basis_Vars,ONLY:nVisu,nAnalyze
USE MOD_Basis_Vars,ONLY:TriaMap,TriaMapInv,VisuTriaMap,VisuTriaMapInv,Vdm_visu_Tria,D_visu_Tria
USE MOD_Basis_Vars,ONLY:QuadMap,QuadMapInv,VisuQuadMap,VisuQuadMapInv,Vdm_visu_Quad,D_visu_Quad
USE MOD_Basis_Vars,ONLY:TetraMap,TetraMapInv !,Vdm_visu_Tetra,D_visu_Tetra
USE MOD_Basis_Vars,ONLY:PyraMap,PyraMapInv   !,Vdm_visu_Pyra,D_visu_Pyra
USE MOD_Basis_Vars,ONLY:PrismMap,PrismMapInv !,Vdm_visu_Prism,D_visu_Prism
USE MOD_Basis_Vars,ONLY:HexaMap,HexaMapInv,Vdm_visu_Hexa,D_visu_Hexa,VisuHexaMap,VisuHexaMapInv
USE MOD_Basis_Vars,ONLY:Vdm_Analyze_Hexa,D_Analyze_Hexa
USE MOD_Basis_Vars,ONLY:EdgeToTria,EdgeToQuad
USE MOD_Mesh_Vars,ONLY:N
USE MOD_QuadBasis
USE MOD_TriaBasis
USE MOD_TetraBasis
USE MOD_PyraBasis
USE MOD_PrismBasis
USE MOD_HexaBasis
! IMPLICIT VARIABLE HANDLING
IMPLICIT NONE
!-----------------------------------------------------------------------------------------------------------------------------------
! INPUT VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
! OUTPUT VARIABLES
!-----------------------------------------------------------------------------------------------------------------------------------
! LOCAL VARIABLES 
INTEGER             :: i,j,nNodes   ! ?
!===================================================================================================================================

! Build mappings for each element type
CALL getBasisMappingTria(N,nNodes,TriaMap,TriaMapInv)
CALL getBasisMappingQuad(N,nNodes,QuadMap,QuadMapInv)
CALL getBasisMappingTetra(N,nNodes,TetraMap,TetraMapInv)
CALL getBasisMappingPyra(N,nNodes,PyraMap,PyraMapInv)
CALL getBasisMappingPrism(N,nNodes,PrismMap,PrismMapInv)

! basis mappings used for visualization (often number of visu points != order) + mapping tria->quad(tensorproduct) required
CALL getBasisMappingQuad(nVisu,nNodes,VisuTriaMap,VisuTriaMapInv)
CALL getBasisMappingQuad(nVisu,nNodes,VisuQuadMap,VisuQuadMapInv)
CALL getBasisMappingHexa(N,nNodes,HexaMap,HexaMapInv)
CALL getBasisMappingHexa(nVisu,nNodes,VisuHexaMap,VisuHexaMapInv)

! get Vandermonde and D matrices for visualization
CALL getTriaBasis(N,nVisu+1,Vdm_visu_Tria,D_visu_Tria)
CALL getQuadBasis(N,nVisu+1,Vdm_visu_Quad,D_visu_Quad)
!CALL getTetraBasis(N,nVisu+1,Vdm_visu_Tetra,D_visu_Tetra)
CALL getHexaBasis(N,nVisu+1,Vdm_visu_Hexa,D_visu_Hexa)
CALL getHexaBasis(N,nAnalyze,Vdm_Analyze_Hexa,D_Analyze_Hexa)

! map edges of triangle surface counterclockwise points to BoundaBasisMappingInv(i,j)
ALLOCATE(EdgeToTria(3,N+1))
!first Side
j=0
DO i=0,N
  edgeToTria(1,i+1)=TriaMapInv(i,j)
END DO
!Second Side
DO i=0,N
  edgeToTria(2,i+1)=TriaMapInv(N-i,i)
END DO
!last Side
i=0
DO j=0,N
  edgeToTria(3,j+1)=TriaMapInv(i,N-j)
END DO
! map edges of quadrangle counterclockwise points to BoundaBasisMappingInv(i,j)
ALLOCATE(EdgeToQuad(4,N+1))
!first Side
j=0
DO i=0,N
  EdgeToQuad(1,i+1)=QuadMapInv(i,j)
END DO
!Second Side
i=N
DO j=0,N
  EdgeToQuad(2,j+1)=QuadMapInv(i,j)
END DO
!Third Side
j=N
DO i=0,N
  EdgeToQuad(3,i+1)=QuadMapInv(N-i,j)
END DO
!last Side
i=0
DO j=0,N
  EdgeToQuad(4,j+1)=QuadMapInv(i,N-j) 
END DO
END SUBROUTINE fillBasisMapping

END MODULE MOD_Basis

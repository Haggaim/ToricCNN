#include "mex.h"
#include <Eigen/Dense>
#include <Eigen/SparseCore>
#include "mexHelpers.cpp"
#include "meshHelpers.cpp"

using namespace Eigen;

void mexFunction(int nlhs, mxArray *plhs[],
	int nrhs, const mxArray*prhs[])

{
	// assign input
	int n_tri = mxGetM(prhs[0]); // # rows of F
	int d_simplex = mxGetN(prhs[0]); // # cols of F
	int n_vert = mxGetM(prhs[1]); // # rows of V
	int dim = mxGetN(prhs[1]); // # cols of V
	const Map<MatrixXd, Aligned> Fmatlab(mxGetPr(prhs[0]), n_tri, d_simplex);
	const Map<MatrixXd, Aligned> V(mxGetPr(prhs[1]), n_vert, dim);
	
	// update index numbers to 0-base
	MatrixXd F (Fmatlab);
	F = F.array() - 1;	

	// compute
	SparseMatrix<double> T;
	VectorXd areas;
	if (d_simplex == 3 && dim == 2)
	{
		// Planar triangulation
		computeMeshTranformationCoeffsFullDim(F, V, T, areas);
	}
	else if (d_simplex == 4 && dim == 3)
	{
		// Tet mesh
		computeMeshTranformationCoeffsFullDim(F, V, T, areas);
	}
	else if (d_simplex == 3 && dim == 3)
	{
		// 3D surface
		computeMeshTranformationCoeffsFlatenning(F, V, T, areas);
	}
	else
		mexErrMsgIdAndTxt("MATLAB:invalidInputs", "Invalid input dimensions or mesh type not supported");


	// assign outputs
	mapSparseMatrixToMex(T, &(plhs[0]));

	plhs[1] = mxCreateDoubleMatrix(areas.rows(), areas.cols(), mxREAL);
	Map<VectorXd> out(mxGetPr(plhs[1]), areas.rows());
	out = areas; // copy init
}
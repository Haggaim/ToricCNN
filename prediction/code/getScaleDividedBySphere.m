function dividedScale =  getScaleDividedBySphere(V_flat2,cutMesh2,f2)

orbifold_type = OrbifoldType.Square;
% flatten sphere
[V1,F1] = read_off('sphere.off');
a1  =0; a2 = 2*pi/3; a3 = 4*pi/3;
idealPoints = [cos(a1) sin(a1) 0;cos(a2) sin(a2) 0;cos(a3) sin(a3) 0];
cones1 = knnsearch(V1',idealPoints); 
V1 = V1/sqrt(CORR_calculate_area(F1',V1'));
[V_flat1,cutMesh1,f1] = flatten_sphere(V1',F1',cones1,orbifold_type);


% map scale
scale1OnMesh2 = getSphereScalesOnOnMesh(V_flat1,cutMesh1,f1,V_flat2,cutMesh2);

% calcluate sacles
scale2 = f2.valsOnUncutMesh(f2.vertexScale());


dividedScale = scale2./scale1OnMesh2;
end
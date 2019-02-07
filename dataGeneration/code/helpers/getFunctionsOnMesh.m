function    functionsOnMesh = getFunctionsOnMesh(V,F,params)
doplotfunctions = getoptions(params,'doplotfunctions',0);

% normalize shape by shape area
area = CORR_calculate_area(F,V);
V = V/sqrt(area);

% WKS
functionsOnMesh = compute_WKS(V,F);
wksTimes = [20:3:70, 90:3:100];
functionsOnMesh = functionsOnMesh(:,wksTimes);
% curvature
[Cmin,Cmax,Cmean,Cgauss] = calcCurvature(V,F,params);
functionsOnMesh = [functionsOnMesh Cmin Cmax Cmean Cgauss];
%AGD
AGD = calcAgd(V,F,params);
functionsOnMesh = [functionsOnMesh AGD];


% normalize to [0,255]
for ii = 1:size(functionsOnMesh,2)
    f = functionsOnMesh(:,ii);
    f=255*(f-min(f))/(max(f)-min(f));
    functionsOnMesh(:,ii) = f;
end

if doplotfunctions
    
    for ii = 1:size(functionsOnMesh,2)
        figure
        patch('faces',F,'vertices',V,'facecolor','flat','FaceVertexCData',functionsOnMesh(:,ii),'edgecolor','none'); axis off, axis equal, addRot3D
    end
end

end

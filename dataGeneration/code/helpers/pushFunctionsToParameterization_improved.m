function [dataFunctions,dataSeg,flatteningInfo] = pushFunctionsToParameterization_improved( V, F, cones, seg, functions,params)

params.null = [];
doplot = getoptions(params,'doplot',0);

% for flattening the mesh
orbifold_type=OrbifoldType.Square;
[V_flat,cutMesh,flattener]=flatten_sphere(V,F,cones,orbifold_type);


flatteningInfo = struct('V_flat',V_flat,'cutMesh',cutMesh,'flattener',flattener);
dataFunctions =  [];

numFunctions = size(functions,2);

% functions
for ii=1:numFunctions
    f=functions(:,ii);
    fOnFlatGrid =  captureFunctionOnTriangles(V_flat,cutMesh,f,struct('isseg',0));
    dataFunctions(:,:,ii) = fOnFlatGrid;
end
% GT
 segsOnFlatGrid =  [];
 for ii=1:max(seg)
        f=double(seg==ii);
        fOnFlatGrid =  captureFunctionOnTriangles(V_flat,cutMesh,f,struct('isseg',1));
        segsOnFlatGrid(:,:,ii) = fOnFlatGrid;
 end
 [~,dataSeg] = max(segsOnFlatGrid,[],3);

if doplot
    for ii=1:numFunctions
        figure, imagesc(dataFunctions(:,:,ii))
    end
    figure,imagesc(dataSeg)
end
end



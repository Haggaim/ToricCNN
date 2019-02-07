function make_data(params)
addpath(genpath(pwd))
% assumes off input meshes - can be easily changed
mesh_ext = 'ply';
params.null = [];
prefix = 'train';
MeshInputFolder = getoptions(params,'MeshInputFolder','../data/train/');
MeshOutputFolder = getoptions(params,'MeshOutputFolder','../data/train_processed/');
mkdir(MeshOutputFolder);
mkdir(fullfile(MeshOutputFolder,'jpeg'));
mkdir(fullfile(MeshOutputFolder,'seg'));
mkdir(fullfile(MeshOutputFolder,'flatenningInfo'));
mkdir(fullfile(MeshOutputFolder,'functionsOnMesh'));
mkdir(fullfile(MeshOutputFolder,'selectedPoints'));


files = rdir(fullfile(MeshInputFolder,['*.' mesh_ext]));
fnames = {files.name};

for ii=1:numel(fnames)
    
    fname = fnames{ii};
    [~,shortname,ext] = fileparts(fname);
    GTsegmentation = textread(strrep(fname,mesh_ext,'txt'));
    disp(['Processing file ',num2str(ii),' mesh:' shortname]);
    disp('-------------------------');
    
    if strcmp(mesh_ext,ext(2:end))
        [V,F] = read_ply(fname);
    else
        error('This file currently supports only *.%s',mesh_ext)
    end
    V = V/sqrt(CORR_calculate_area(F,V));
    
    functionsOnMesh = getFunctionsOnMesh(V,F,params);
    
    % compute triples  points on the mesh
    [triplets,AGD]  = getPointTripletsByFarthestPointSampling(V,F,params);
    name=[prefix,'_', shortname];
    
    % plot selected points
    for jj = 1:size(triplets,1)
        figure('visible','off'),hold on
        axis equal, axis off;
        patch('vertices',V,'faces',F,'FaceVertexCData',AGD,'FaceColor','interp','EdgeColor','none','FaceAlpha',1);
        scatter3(V(triplets(jj,:),1),V(triplets(jj,:),2),V(triplets(jj,:),3),'r','filled')
        saveas(gcf,(fullfile(MeshOutputFolder,'selectedPoints',[name '_tri' num2str(jj) '.jpg'])));
        close all;
    end
    
    %for each triple compute parameterization and push functions
    for jj=1:size(triplets,1)
        cones=triplets(jj,:);
        filename = [name,'_tri_',num2str(jj)];
        [dataFunctions,dataSeg,flatteningInfo] = pushFunctionsToParameterization_improved( V, F, cones, GTsegmentation, functionsOnMesh,params );
        data = dataFunctions;
        save (fullfile(MeshOutputFolder,'jpeg',filename),'data');
        data = dataSeg;
        save (fullfile(MeshOutputFolder,'seg',filename),'data');
        data = flatteningInfo;
        save (fullfile(MeshOutputFolder,'flatenningInfo',filename),'data','cones','V','F');
    end
    save (fullfile(MeshOutputFolder,'functionsOnMesh',name),'functionsOnMesh','GTsegmentation');
    
end

disp('-------------------------');
disp('Done Processing data!');
disp('-------------------------');
end
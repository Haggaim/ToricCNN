function  visualizeAgregatedSegmentationsFinal(params)
params.null = [];
data = getoptions(params,'data',0);
workingDir = params.comparedFolder;

% get unique file names without triangles
namesNoTriangle = {};
for ii = 1:numel(data.predictionOnMeshs)
    if ~isempty(data.predictionOnMeshs{ii})
        name = data.predictionOnMeshs{ii}.fname;
        idx = strfind(name,'_');
        namesNoTriangle =[namesNoTriangle {name(1:idx(end-1))}];
    end
end
namesNoTriangle = unique(namesNoTriangle);
finalPredictions = cell(1,numel(namesNoTriangle));


for ii = 1:numel(namesNoTriangle)
    prefix = namesNoTriangle{ii};
    relevantData = [];
    
    %  aggregate
    %--------------------------------------
    
    for jj = 1:numel(data.predictionOnMeshs)
        if ~isempty(data.predictionOnMeshs{jj})            
            name = data.predictionOnMeshs{jj}.fname;
            if strncmpi(name,prefix,numel(prefix))
                relevantData = [relevantData data.predictionOnMeshs{jj}];                
            end
        end
    end   
    
    % create combined prediction by weighted scale averaging
    %--------------------------------------
    numClasses = size(relevantData(1).scoresOnMesh,2);
    
    combinedScoresWeightedScaleAveraging = zeros(size(relevantData(1).scoresOnMesh));
    for jj = 1:numel(relevantData)
        combinedScoresWeightedScaleAveraging = combinedScoresWeightedScaleAveraging + relevantData(jj).scoresOnMesh .* repmat(relevantData(jj).scaleOnMesh,[1 size(relevantData(jj).scoresOnMesh,2)]);
    end
    
    [~,predictionOnMeshWeighted] = max(combinedScoresWeightedScaleAveraging,[],2);
      
    % plot prediction
    %--------------------------------------
    face = relevantData(jj).F;
    vertex = relevantData(jj).V;
    %     plot prediction average
    f1 = figure;
    c = colormap('jet');
    cc = c(ceil(size(c,1)*double(predictionOnMeshWeighted)/numClasses),:);
    patch('faces',face','vertices',vertex','facecolor','interp','FaceVertexCData',cc,'edgecolor','none');title('prediction weighted')
    hold on
    axis off, axis equal,addRot3D
    
    % save
    %--------------------------------------
    saveas(f1,fullfile(workingDir,[prefix 'combined.fig']));
    saveas(f1,fullfile(workingDir,[prefix 'combined.png']));
    
    finalPredictions{ii} = struct('V',vertex,'F',face,'predictionOnMeshWeighted',predictionOnMeshWeighted,'combinedScores',combinedScoresWeightedScaleAveraging,...
        'fname',prefix,'fullPath',relevantData(1).fullPath);
    
end


end


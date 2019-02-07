function postprocessAggregateSegmentations(params)
%--------------------------------------------
% Default params
%--------------------------------------------
% default params
params.null = [];
params.comparedFolder = getoptions(params, 'comparedFolder', pwd); % folder to process
verbose = getoptions(params, 'verbose', 1); % print stuff
%============================================
% verbose
if verbose
    disp(['Gathering results... (' params.comparedFolder ')']);
end
files = dir('pred*.mat');
predictionOnMeshs = cell(1,numel(files));
% aggregate on all files
parfor ii = 1:numel(files)
    if mod(ii,10)==1 fprintf('Loading file %d/%d\n',ii,numel(files)); end
    fname = files(ii).name;
    curData = load(fname);
    predictionOnMeshs{ii} = curData.predictionOnMesh;
    
end

% call the function that actually does the aggregation
data.predictionOnMeshs = predictionOnMeshs;
visualizeAgregatedSegmentationsFinal(catstruct(struct('data',data), params))
% verbose
if verbose
    fprintf('\n');
    disp('Finished gathering results');
end

end
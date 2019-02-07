function fcnTrain(params)
params.null = [];
% Train segmentation network on human meshes starting from a pretrained image segmentation network
experimentFolder = getoptions(params,'experimentFolder','exp');
params.sourceModelPath = getoptions(params,'sourceModelPath','../base_net/pascal-fcn32s-dag.mat'); %the basic net
params.resultsDir = getoptions(params,'resultsDir','../trained_nets/');
params.train.gpus=getoptions(params,'gpus',[1]);
params.inputImageSize = getoptions(params,'inputImageSize',[512 512]);
params.dataDir = getoptions(params,'dataDir','../../dataGeneration/data/train_processed/');
params.imdbPath = fullfile(params.resultsDir, experimentFolder, 'imdb.mat');
params.imdbStatsPath = fullfile(params.resultsDir, experimentFolder, 'imdbstats.mat');
params.paramsPath = fullfile(params.resultsDir, experimentFolder, 'params.mat');
params.numFetchThreads = 1 ; % not used yet
params.expDir = [params.resultsDir experimentFolder];

% training options (SGD)
trainParams.batchSize = getoptions(params,'batchSize',10) ;
trainParams.numSubBatches = getoptions(params,'numSubBatches',5) ;
trainParams.continue = getoptions(params,'continue',true) ;
trainParams.prefetch = getoptions(params,'prefetch',true) ;
trainParams.expDir =  [params.resultsDir experimentFolder];
trainParams.learningRate = getoptions(params,'learningRate',0.0001 * ones(1,50)) ;
trainParams.numEpochs = getoptions(params,'numEpochs',numel(trainParams.learningRate));

% -------------------------------------------------------------------------
% IMDB and stats
% -------------------------------------------------------------------------

if exist(params.imdbPath)
    imdb = load(params.imdbPath) ;
else
    imdb =  createIMDB(params);
    mkdir(params.expDir) ;
    save(params.imdbPath, '-struct', 'imdb') ;
end
params.imdb = imdb;
% Get training and test/validation subsets
train = find(imdb.images.set == 1 & imdb.images.segmentation) ;
val = find(imdb.images.set == 2 & imdb.images.segmentation) ;

% Get dataset statistics
if exist(params.imdbStatsPath)
    stats = load(params.imdbStatsPath) ;
else
    stats = getDatasetStatistics(imdb) ;
    save(params.imdbStatsPath, '-struct', 'stats') ;
end
params.stats = stats;
% -------------------------------------------------------------------------
% Setup model
% -------------------------------------------------------------------------
net = fcnInitializeModel32s(params) ;

% -------------------------------------------------------------------------
% Train
% -------------------------------------------------------------------------
% Setup data fetching options
batchParams.numThreads = params.numFetchThreads ;
batchParams.labelStride = 1 ;
batchParams.labelOffset = 1 ;
batchParams.classWeights = ones(1,2,'single') ;
batchParams.rgbMean = stats.rgbMean ;
batchParams.imageSize = params.inputImageSize;
batchParams.useGpu = numel(params.train.gpus) > 0 ;

% save params
save(params.paramsPath,'params','batchParams','trainParams');
copyfile([mfilename('fullpath') '.m'],[params.expDir '/' mfilename '_runHistory.m']);

% Launch SGD

info = cnn_train_dag(net, imdb, getBatchWrapper(batchParams), ...
    trainParams, ....
    'train', train, ...
    'val', val, ...
    params.train) ;

end
% -------------------------------------------------------------------------
function fn = getBatchWrapper(opts)
% -------------------------------------------------------------------------
fn = @(imdb,batch) getBatch(imdb,batch,opts,'prefetch',nargout==0) ;
end
% -------------------------------------------------------------------------
function fn = getBatchWithScaleWrapper(opts)
% -------------------------------------------------------------------------
fn = @(imdb,batch) getBatchWithScale(imdb,batch,opts,'prefetch',nargout==0) ;
end

function y = getBatch(imdb, images, varargin)
% GET_BATCH  Load, preprocess, and pack images for CNN evaluation
numChannels = numel(varargin{1}.rgbMean);
numClasses = numel(imdb.classes.id);
opts.imageSize = varargin{1}.imageSize ;
opts.numAugments = 1 ;
opts.transformation = 'none' ;
opts.rgbMean = [] ;
opts.rgbVariance = zeros(0,numChannels,'single') ;
opts.labelStride = 1 ;
opts.labelOffset = 0 ;
opts.classWeights = ones(1,numClasses,'single') ;
opts.interpolation = 'bilinear' ;
opts.numThreads = 1 ;
opts.prefetch = false ;
opts.useGpu = false ;
opts = vl_argparse(opts, varargin);
if opts.prefetch
    % to be implemented
    ims = [] ;
    labels = [] ;
    return ;
end

if ~isempty(opts.rgbVariance) && isempty(opts.rgbMean)
    opts.rgbMean = single([128;128;128]) ;
    error('');
end
if ~isempty(opts.rgbMean)
    opts.rgbMean = reshape(opts.rgbMean, [1 1 numChannels]) ;
end

% space for images
ims = zeros(opts.imageSize(1), opts.imageSize(2), numChannels, ...
    numel(images)*opts.numAugments, 'single') ;

% space for labels
lx = opts.labelOffset : opts.labelStride : opts.imageSize(2) ;
ly = opts.labelOffset : opts.labelStride : opts.imageSize(1) ;
labels = zeros(numel(ly), numel(lx), 1, numel(images)*opts.numAugments, 'single') ;

im = cell(1,numel(images)) ;


for ii=1:numel(images)
    
    % acquire image
    if isempty(im{ii})
        rgbPath = sprintf(imdb.paths.image, imdb.images.rgbname{images(ii)}) ;
        labelsPath = sprintf(imdb.paths.classSegmentation, imdb.images.segname{images(ii)}) ;
        rgb = load(rgbPath);
        rgb = single(rgb.data );
        anno = load(labelsPath) ;
        anno = anno.data;
    else
        rgb = im{ii} ;
    end
    if size(rgb,3) == 1
        rgb = cat(3, rgb, rgb, rgb) ;
    end
    
    % resize
    sz = opts.imageSize(1:2) ;    
    ims(:,:,:,ii) = imresize(bsxfun(@minus, rgb, opts.rgbMean) ,sz);
    % special ugly case for binary segemntation since the data is already
    % prepared
    if numClasses==2
        labels(:,:,1,ii) = imresize(anno,sz,'nearest') + 1;    
    else
        labels(:,:,1,ii) = imresize(anno,sz,'nearest');    
    end
end

if opts.useGpu
    ims = gpuArray(ims) ;
end
y = {'data', ims, 'label', labels} ;

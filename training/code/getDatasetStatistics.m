function stats = getDatasetStatistics(imdb)

% check num channels
rgb = load(sprintf(imdb.paths.image, imdb.images.rgbname{1})) ;

[m,n,d] = size(rgb.data);
stats.numChannels = d;
stats.numClasses = numel(imdb.classes.id);
train = find(imdb.images.set == 1 & imdb.images.segmentation) ;

% Class statistics
classCounts = zeros(stats.numClasses,1) ;
parfor i = 1:numel(train)
    fprintf('%s: computing segmentation stats for training image %d\n', mfilename, i) ;
    lb = load(sprintf(imdb.paths.classSegmentation, imdb.images.segname{train(i)})) ;
    lb = lb.data;
    ok = lb < 255 ;
    if stats.numClasses==2
        classCounts = classCounts + accumarray(lb(ok(:))+1, 1, [stats.numClasses 1]) ;
    else
        classCounts = classCounts + accumarray(lb(ok(:)), 1, [stats.numClasses 1]) ;
        
    end
end
stats.classCounts = classCounts ;

% Image statistics
parfor t=1:numel(train)
    fprintf('%s: computing RGB stats for training image %d\n', mfilename, t) ;
    rgb = load(sprintf(imdb.paths.image, imdb.images.rgbname{train(t)})) ;
    rgb = single(rgb.data) ;
    z = reshape(permute(rgb,[3 1 2 4]),stats.numChannels,[]) ;
    n = size(z,2) ;
    rgbm1{t} = sum(z,2)/n ;
    rgbm2{t} = z*z'/n ;
end
rgbm1 = mean(cat(2,rgbm1{:}),2) ;
rgbm2 = mean(cat(3,rgbm2{:}),3) ;

stats.rgbMean = rgbm1 ;
stats.rgbCovariance = rgbm2 - rgbm1*rgbm1' ;

function generateSegmentationsPerTriplet(params)
doplot = 1;
% load net
params.null = [];
expPath = getoptions(params,'expPath','../../training/trained_nets/exp/');

epoch = getoptions(params,'epoch',50);
netPath = [expPath sprintf('net-epoch-%d.mat',epoch)];
load(netPath);
net = dagnn.DagNN.loadobj(net) ;% for each validation

net.mode = 'test';
net.move('cpu');
% create IMDB for test data
imdb = createIMDB(struct('dataDir','../../dataGeneration/data/test_processed/','valSize',1));

pathsclassSegmentation = imdb.paths.classSegmentation;
pathsimage = imdb.paths.image;

rgbname = imdb.images.rgbname(imdb.images.set==2);
segname = imdb.images.segname(imdb.images.set==2);
[rgbname,I] = sort(rgbname);
segname = segname(I);
imSize =  net.meta.normalization.imageSize(1:2);

%output
resultsFolder = '../outputs/';
outputFolder = [resultsFolder '/' strrep(strrep(datestr(datetime('now')),'-','_'),':','_')];

mkdir(outputFolder)
copyfile([mfilename('fullpath') '.m'],[outputFolder '/' mfilename '_runHistory.m']);

for ii=1:numel(rgbname)
    fprintf('%s: running on instance %d/%d...\n',rgbname{ii},ii,numel(rgbname));
    % read off file
    fname = rgbname{ii};
    flatteningInfoName = strrep(rgbname{ii},'jpeg','flatenningInfo');
    flatteningInfo = load(sprintf(pathsimage,flatteningInfoName));
    f = flatteningInfo.data.flattener;
    cones = flatteningInfo.cones;
    vertex = flatteningInfo.V;
    face = flatteningInfo.F;
    [vertex,face] =  orgenizeFV(vertex,face);
    % tricky - here we assume it is the opposite
    face = face';
    vertex = vertex';
    
    % load functions
    rgb = load(sprintf(pathsimage,rgbname{ii}));
    rgb = rgb.data;
    rgb = single(rgb) ; % note: 0-255 range
    rgb = imresize(bsxfun(@minus,rgb, reshape(net.meta.normalization.rgbMean,[1 1 numel(net.meta.normalization.rgbMean)])) ,imSize);
    anno = load(sprintf(pathsclassSegmentation,segname{ii}));
    anno = anno.data;
    % run the CNN
    net.eval({'data', rgb}) ;
    % obtain the CNN otuput
    scores = net.vars(net.getVarIndex('proj_1')).value ;
    scores = squeeze(gather(scores)) ;
    [~,prediction] = max(scores,[],3);
    % sample scores on the mesh
    scoresOnMesh = zeros(max(size(vertex)),size(scores,3));
    for jj = 1:size(scores,3)
        quarteCurPrediction = scores(floor(size(scores,1)/2+1:end),floor(size(scores,2)/2)+1:end,jj);
        scoresOnMesh(:,jj) = f.liftImage(quarteCurPrediction);
    end
    % map back to mesh
    [~,predictionOnMesh] = max(scoresOnMesh,[],2);
    GT = anno(floor(size(anno,1)/2+1:end),floor(size(anno,2)/2)+1:end);
    GTOnMesh = f.liftImage(GT);
    scaleOnMesh =  getScaleDividedBySphere(flatteningInfo.data.V_flat,flatteningInfo.data.cutMesh,flatteningInfo.data.flattener);
    % visualize
    if doplot
        % show image of output
        numClasses = size(scoresOnMesh,2);
        f1 = figure('Visible','Off');
        subplot(1,2,1),imshow((prediction/numClasses)), title('prediction'),axis equal, colormap jet
        subplot(1,2,2),imshow((anno/numClasses)),title('GT'),axis equal,colormap jet
        
        % plot prediction on mesh
        c = colormap('jet');
        f2 = figure('Visible','Off');
        subplot(1,3,1);
        cc = c(ceil(size(c,1)*double(predictionOnMesh)/numClasses),:);
        patch('faces',face','vertices',vertex','facecolor','interp','FaceVertexCData',cc,'edgecolor','none','CDataMapping','direct');title('prediction')
        hold on;
        if ~isempty(cones )
            scatter3(vertex(1,cones)',vertex(2,cones)',vertex(3,cones)','r','filled')
        end
        axis equal;axis off;addRot3D;
        % plot scaling factor on mesh
        subplot(1,3,2);
        patch('faces',face','vertices',vertex','facecolor','interp','FaceVertexCData',log(abs(scaleOnMesh)),'edgecolor','none');title('log(scale)')
        hold on
        axis off, axis equal,addRot3D,colorbar
        if ~isempty(cones )
            scatter3(vertex(1,cones)',vertex(2,cones)',vertex(3,cones)','r','filled')
        end
        
        % plot GT on mesh
        subplot(1,3,3);
        cc = c(ceil(size(c,1)*double(round(GTOnMesh))/numClasses),:);
        patch('faces',face','vertices',vertex','facecolor','interp','FaceVertexCData',cc,'edgecolor','none','CDataMapping','direct');title('GT')
        hold on;
        if ~isempty(cones )
            scatter3(vertex(1,cones)',vertex(2,cones)',vertex(3,cones)','r','filled')
        end
        axis equal;axis off;addRot3D;
        
        
        % save
        [~,fname,~] = fileparts(fname);
        saveas(f1,fullfile(outputFolder,[fname '_image.fig']))
        saveas(f2,fullfile(outputFolder,[fname '_mesh.fig']))
        saveas(f1,fullfile(outputFolder,[fname '_image.png']))
        saveas(f2,fullfile(outputFolder,[fname '_mesh.png']))
        close all
    end    
    predictionOnMesh = struct('predictionOnMesh',predictionOnMesh,'fname',fname,'scaleOnMesh',scaleOnMesh,'scoresOnMesh',scoresOnMesh,'V',vertex,'F',face,'fullPath',rgbname{ii},'GTOnMesh',GTOnMesh);
    fname = fullfile(outputFolder,[sprintf('predictionOnMeshs_%s',fname) '.mat']);
    save(fname,'predictionOnMesh');   
end


end

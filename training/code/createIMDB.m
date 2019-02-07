% -------------------------------------------------------------------------
function imdb =  createIMDB(params)
% -------------------------------------------------------------------------
params.null = [];
dataDir =  getoptions(params,'dataDir','/net/mraid11/export/data/haggaim/deepLearningSurfaces/data/');
valSize =  getoptions(params,'valSize',0.05);



% path
imdb.paths.image = esc(fullfile(dataDir, '%s')) ;
imdb.paths.classSegmentation = esc(fullfile(dataDir, '%s')) ;

% files
rgbfiles = rdir([dataDir 'jpeg/*.mat']);
rgbfiles = [{rgbfiles.name}];


% segmentation files
segfiles = cell(size(rgbfiles));
for ii = 1:numel(rgbfiles)
    idx = strfind(rgbfiles{ii},'/');
    rgbfiles{ii} = rgbfiles{ii}(idx(end-1)+1:end);
    segfiles{ii} = strrep(rgbfiles{ii},'jpeg','seg');
end

imdb.images.id = 1:numel(rgbfiles) ;
imdb.images.segname = segfiles ;
imdb.images.rgbname = rgbfiles ;
imdb.images.segmentation = true(1,numel(rgbfiles));

% split to train-validation
imdb.images.set = ones(1,numel(rgbfiles));
validationIdx = randperm(numel(rgbfiles),floor(valSize*numel(rgbfiles)));
imdb.images.set(validationIdx)=2;


imdb.classes.id = uint8(1:8) ;
imdb.classes.name = {'head', 'hand','lower arm','upper arm','torso','upper leg','lower leg','foot'};
imdb.classes.images = cell(1,8);


imdb.sets.id = uint8([1 2 3]) ;
imdb.sets.name = {'train', 'val', 'test'} ;



end


% -------------------------------------------------------------------------
function str=esc(str)
% -------------------------------------------------------------------------
str = strrep(str, '\', '\\') ;
end
function net = fcnInitializeModel32s(params)

% -------------------------------------------------------------------------
%                    load trained segmentation net
% -------------------------------------------------------------------------

%
sourceModelPath = getoptions(params,'sourceModelPath','');
imdb = getoptions(params,'imdb','');
stats = getoptions(params,'stats','');
net = dagnn.DagNN.loadobj(sourceModelPath) ;
numChannels = params.stats.numChannels;
numClasses = params.stats.numClasses;


% -------------------------------------------------------------------------
%                    edit the model
% -------------------------------------------------------------------------


% 21 classes -> numClasses classes

p1_ind = net.getParamIndex('score_fr_filter');
net.params(p1_ind).value = net.params(p1_ind).value(:,:,:,1:numClasses);

p2_ind = net.getParamIndex('score_fr_bias');
net.params(p2_ind).value = net.params(p2_ind).value(1:numClasses,:);

p3_ind = net.getParamIndex('upsample_filter');
net.params(p3_ind).value = net.params(p3_ind).value(:,:,1:numClasses,1:numClasses);

p4_ind = net.getParamIndex('upsample_bias');
net.params(p4_ind).value = net.params(p4_ind).value(1:numClasses,:);

% first layer - accept images NxNxnumChannels

net.layers(1).block.size(3)=numChannels;
net.params(1).value = repmat(net.params(1).value,[1 1 floor(numChannels/3) 1]);
% in case 3 does not divide numChannels
if size(net.params(1).value,3) ~= numChannels
    difference = numChannels-size(net.params(1).value,3);
    net.params(1).value = cat(3,net.params(1).value,net.params(1).value(:,:,1:difference,:));
end
% change net meta
net.meta.normalization.imageSize(1:2) = params.inputImageSize;
net.meta.normalization.imageSize(3)=numChannels;
net.meta.normalization.averageImage=stats.rgbMean';
net.meta.normalization.rgbMean = stats.rgbMean';
net.meta.classes = imdb.classes.name ;
net.meta.inputs.size = [params.inputImageSize numChannels 1];



% add padding layer
padIdx=0;
for i=1:size(net.layers,2)
    %  if we are att a convolutional layer
    if strncmpi(net.layers(i).name,'conv',4)
        padIdx=padIdx+1;
        padSz = net.layers(i).block.pad(1);
        % set pad == 0
        net.layers(i).block.pad = [0 0 0 0];
        layerName = ['cpad_' num2str(padIdx)];
        fprintf('Adding cyclic pad layer before %s with padsize = %d\n',net.layers(i).name,padSz)
        % first layer
        if i==1
            newLayerInput = 'data';
            newLayerOutput = layerName;
            addLayer(net,layerName, ...
                cPad('padSz',padSz), ...
                newLayerInput,newLayerOutput);
            % not first layer
        else
            % new layer is the output of the last layer
            newLayerInput = net.layers(i-1).outputs;
            newLayerOutput = layerName;
            addLayer(net,layerName, ...
                cPad('padSz',padSz), ...
                newLayerInput,newLayerOutput);
            
        end
        % input of conv layer is the output of padding layer
        net.layers(i).inputs{1} = newLayerOutput;
    end
end

projIdx=0;
% add projection at end (after crop)
for i= 1:size(net.layers,2)
    if  strncmpi(net.layers(i).name,'crop',4)
        
        projIdx = projIdx+1;
        layerName = ['proj_' num2str(projIdx)];
        % input of projection is output of last layer
        newLayerInput = net.layers(i).outputs;
        newLayerOutput = layerName;
        addLayer(net,layerName, ...
            MaxProjection(), ...
            newLayerInput,newLayerOutput);
    end
end


lastLayer = sprintf('proj_%d',projIdx);

% -------------------------------------------------------------------------
% Losses and statistics
% -------------------------------------------------------------------------
% Add loss layer
addLayer(net,'objective', ...
    SegmentationLossClassDistributionScaling('loss', 'softmaxlog'), ...
    {lastLayer, 'label'}, 'objective') ;
% Add accuracy layer
net.addLayer('accuracy', ...
    SegmentationAccuracy(), ...
    {lastLayer, 'label'}, 'accuracy') ;

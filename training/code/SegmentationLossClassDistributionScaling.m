classdef SegmentationLossClassDistributionScaling < dagnn.Loss
    
    methods
        function outputs = forward(obj, inputs, params)
            % calc class distribution
            labels = inputs{2};            
            numClasses = size(inputs{1},3);
            dist = 4000*ones(1,numClasses);
            for ii = 1:numClasses
                dist(ii) = dist(ii) + sum(labels(:)==ii);
            end
            inverseWeights =  1./dist;
            %  generate weight mask
            mass =  inverseWeights(labels);
%             mass = mass/sum(mass(:));
            outputs{1} = vl_nnloss(inputs{1}, inputs{2}, [], ...
                'loss', obj.loss, ...
                'instanceWeights', mass) ;
            n = obj.numAveraged ;
            m = n + size(inputs{1},4) ;
            obj.average = (n * obj.average + double(gather(outputs{1}))) / m ;
            obj.numAveraged = m ;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
           % calc class distribution
            labels = inputs{2};            
            numClasses = size(inputs{1},3);
            dist = 4*ones(1,numClasses);
            for ii = 1:numClasses
                dist(ii) =dist(ii) + sum(labels(:)==ii);
            end
            inverseWeights =  1./dist;
            %  generate weight mask
            mass =  inverseWeights(labels);
%             mass = mass/sum(mass(:));
            derInputs{1} = vl_nnloss(inputs{1}, inputs{2}, derOutputs{1}, ...
                'loss', obj.loss, ...
                'instanceWeights', mass) ;
            derInputs{2} = [] ;
            derParams = {} ;
        end
        
        function obj = SegmentationLossClassDistributionScaling(varargin)
            obj.load(varargin) ;
        end
    end
end

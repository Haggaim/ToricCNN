classdef MaxProjection < dagnn.Layer
    properties
        
    end
    
    properties (Transient)
        
    end
    
    methods
        function outputs = forward(obj, inputs, params)
            outputs{1} = doMaxProjectionForward(inputs{1}) ;
        end
        
        function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
            derInputs{1} = doMaxProjectionbackward(inputs{1},derOutputs{1});
            derParams = {} ;
        end
        
        
        
        function obj = Projection(varargin)
            obj.load(varargin{:}) ;
        end
        
        function outputSizes = getOutputSizes(obj, inputSizes)
            outputSizes = inputSizes;
        end
        
        function rfs = getReceptiveFields(obj)
            rfs.size = [1 1] ;
            rfs.stride = [1 1] ;
            rfs.offset = [1 1] ;
        end
    end
    
    
end



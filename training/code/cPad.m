classdef cPad < dagnn.Layer
  properties 
      padSz = -1;
  end

  methods

    function outputs = forward(obj, inputs, params)    
      outputs{1} = padarray(inputs{1},[obj.padSz obj.padSz],'circular');
    end
 
    function [derInputs, derParams] = backward(obj, inputs, params, derOutputs)
      [derInputs{1}] = paddingTranspose(derOutputs{1}, obj.padSz) ;
      derParams={};
    end

    function padSz = getPadSz(obj)
      padSz = obj.size;
    end
    
    function outSize = getOutputSizes(obj, inSize)
        outSize = inSize{1};
        outSize(1:2) = outSize(1:2)+2*obj.padSz;
        outSize = {outSize};
    end
    
    function obj = cPad(varargin)
      obj.load(varargin) ;
      obj.padSz = obj.padSz ;      
    end
    
    function rfs = getReceptiveFields(obj)
      rfs.size = [1 1] ;
      rfs.stride = [1 1] ;
      rfs.offset = [1 1] ;
    end
  end
end

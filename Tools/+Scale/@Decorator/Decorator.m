classdef Decorator < Scale.Interface
% Decorator is a decorator for Scale objectes.

    properties (Access = protected, Hidden = true)
        scaleObj_
    end
    
    methods
        function obj = Decorator(scaleObj,varargin)
            obj = obj@Scale.Interface(varargin{:});
            obj.scaleObj_ = scaleObj;
        end
    end
    
    methods
        function [lbScaled,ubScaled] = setup(obj,lb,ub)
            [lbScaled,ubScaled] = obj.scaleObj_.setup(lb,ub);
        end
        
        function xScaled = scale(obj,x)
            xScaled = obj.scaleObj_.scale(x);
        end
        
        function x = unscale(obj,xScaled)
            x = obj.scaleObj_.unscale(xScaled);
        end
    end
end
    
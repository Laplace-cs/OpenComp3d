classdef DecoratorNorm < Scale.Decorator
% DecoratorNorm scale variables between 0 and 1
%
    
    properties (Access = protected, Hidden = true)
        range_
        offset_
    end
    
    methods
        function obj = DecoratorNorm(scaleObj,varargin)
            obj@Scale.Decorator(scaleObj,varargin{:});
        end
    end
    
    methods
        function  [lbScaled,ubScaled]  = setup(obj,lb,ub)
            [lb,ub] = obj.setup@Scale.Decorator(lb,ub);
            
            obj.range_ = ub - lb;
            obj.offset_ = lb;
            
            lbScaled = zeros(size(lb));
            ubScaled = ones(size(lb));
        end
        
        function xScaled = scale(obj,x)
            x = obj.scale@Scale.Decorator(x);
            xScaled = ( x - obj.offset_) ./ obj.range_;
        end 
            
        function x = unscale(obj, xScaled)
            x = xScaled .* obj.range_ + obj.offset_;
            x = obj.unscale@Scale.Decorator(x);
        end
    end
end

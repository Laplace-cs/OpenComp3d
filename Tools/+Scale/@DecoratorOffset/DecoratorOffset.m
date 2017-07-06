classdef DecoratorOffset < Scale.Decorator
% DecoratorOffset scale variables from 0
    
    properties (Access = protected, Hidden = true)
        offset_
    end
    
    methods
        function obj = DecoratorOffset(scaleObj,varargin)
            obj@Scale.Decorator(scaleObj,varargin{:});
        end
    end
    
    methods
        function  [lbScaled,ubScaled] = setup(obj,lb,ub)
            [lb,ub] = obj.setup@Scale.Decorator(lb,ub);

            obj.offset_ = lb;
            lbScaled = zeros(size(lb));
            ubScaled = ub - lb;
        end
        
        function xScaled = scale(obj,x)
            x = obj.scale@Scale.Decorator(x);
            xScaled = x - obj.offset_;
        end 
            
        function x = unscale(obj, xScaled)
            x = xScaled + obj.offset_;
            x = obj.unscale@Scale.Decorator(x);
        end
    end
end

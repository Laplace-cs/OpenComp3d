classdef DecoratorLog < Scale.Decorator
% DecoratorLog scale variables with log10

    methods
        function obj = DecoratorLog(scaleObj,varargin)
            obj@Scale.Decorator(scaleObj,varargin{:});
        end
    end
    
    methods
        function [lbScaled,ubScaled] = setup(obj,lb,ub)
            [lb,ub] = obj.setup@Scale.Decorator(lb,ub);

            if any( lb < sqrt(eps) )
                warning('Scale.DecoratorLog: some lower bound value is too small, LBV replaced by sqrt(eps).');
                lb = max( lb, sqrt(eps));
            end
            lbScaled = log10(lb);
            ubScaled = log10(ub);
        end
    end
    
    methods
        function xScaled = scale(obj,x)
            x = obj.scale@Scale.Decorator(x);
            xScaled = log10(x);
        end 
        
        function x = unscale(obj,xScaled)
            x = 10.^xScaled;
            x = obj.unscale@Scale.Decorator(x);
        end
    end
end
    
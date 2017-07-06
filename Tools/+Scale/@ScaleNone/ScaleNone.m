classdef ScaleNone < Scale.Interface
%   ScaleNone is a transparent scale object and do not scale.

    properties
    end
    
    methods
        function obj = ScaleNone(varargin)
            obj = obj@Scale.Interface(varargin{:});
        end
    end
    
    methods
        function [lbScaled,ubScaled] = setup(~,lb,ub)
            lbScaled = lb;
            ubScaled = ub;
        end
        function xScaled = scale(~,x)
            xScaled = x;
        end
        function x = unscale(~,xScaled)
            x = xScaled;
        end
    end
    
end
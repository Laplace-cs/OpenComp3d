classdef OptimAlgoGaMatlab < OptimAlgo.Interface
    % OptimAlgoGaMatlab implements a Genetic Algorithm optimization problem
    %
    % OptimAlgoGaMatlab inherits all properties and methods of OptimAlgo.Interface
    %
    %   See also ga, OptimAlgo.Interface, OptimAlgo.Facture
    %

	methods
		function obj = OptimAlgoGaMatlab(varargin)
			obj@OptimAlgo.Interface(varargin{:});
			
			% gaoptimset
            obj.options_ = gaoptimset;
            
            obj.options_.TolX = 1e-12;
            obj.options_.TolFun = 1e-12;
            obj.options_.TolCon = 1e-12;
            
            obj.options_.PlotFcns = { ...
                @gaplotbestf, ...
                @gaplotstopping ...
                };
			
			% update options with varargin
            if ~isempty( varargin )
                obj.options = varargin;
            end
		end
	end
	
	methods
        function [x,fVal,extFlag] = optimize(obj,objective,X0,LB,UB,constraints,varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if ~isempty(p.Unmatched)
                obj.options = p.Unmatched;
            end
            
            [x,fVal,extFlag] = ga( ...
                objective, ...
                max( [ length(X0), length(LB), length(UB) ]), ...
                [],[],[],[], ...
                LB, ...
                UB, ...
                constraints, ...
                obj.options_ ...
                );			
		end
	end
end
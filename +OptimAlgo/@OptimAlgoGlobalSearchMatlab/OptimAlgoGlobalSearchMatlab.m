classdef OptimAlgoGlobalSearchMatlab < OptimAlgo.Interface
    % OptimAlgoGlobalSearchMatlab implements a Global Search optimization algorithm
    %
    % OptimAlgoGlobalSearchMatlab inherits all properties and methods of OptimAlgo.Interface
    %
    %   See also GlobalSearch, OptimAlgo.Interface, OptimAlgo.Facture
    %

	methods
		function obj = OptimAlgoGlobalSearchMatlab(varargin)
			obj@OptimAlgo.Interface(varargin{:});
			
			% defaultOptions = optimset('fmincon');
            obj.options_.MaxFunEvals = inf;
            obj.options_.MaxIter = 1000;
            obj.options_.TolX = 1e-6;
            obj.options_.TolFun = 1e-6;
            
            obj.options_.FinDiffType = 'central'; %/!\/!\/!\/!\
            obj.options_.ScaleProblem = 'obj-and-constr'; %/!\/!\/!\/!\
            
            obj.options_.PlotFcns = { ...
                @optimplotx, ...
                @optimplotfunccount, ...
                @optimplotfval, ...
                @optimplotconstrviolation, ...
                @optimplotfirstorderopt, ...
                @optimplotstepsize ...
                };
            
            obj.options_.randomInit = false;	

			% update options with varargin
            if ~isempty( varargin )
                obj.options = varargin;
            end			
		end
	end
	
	methods
		function [x,fVal,extFlag] = optimize(obj,objective,X0,LB,UB,constraint,varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if ~isempty(p.Unmatched)
                obj.options = p.Unmatched;
            end
            
			% create problem
            problem = createOptimProblem( ...
                'fmincon', ...
                'objective', objective, ...
                'x0', X0, ...
                'lb', LB, ...
                'ub', UB, ...
                'nonlcon', constraint, ...
                'options', obj.options_ ...
                );
            
            % create global search solver
            gs = GlobalSearch;
            gs.PlotFcns = { ...
                @gsplotbestf, ...
                @gsplotfunccount ...
                };
            % solve problem
            [x,fVal,extFlag] = gs.run(problem);
		end
	end
end
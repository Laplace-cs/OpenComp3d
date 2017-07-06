classdef OptimAlgoMultiStartMatlab < OptimAlgo.Interface
    % OptimAlgoMultiStartMatlab implements a Multi Start optimization algorithm
    %
    % OptimAlgoMultiStartMatlab inherits all properties and methods of OptimAlgo.Interface
    %
    %   See also MultiStart, OptimAlgo.Interface,  OptimAlgo.Facture
    %

	methods
		function obj = OptimAlgoMultiStartMatlab(varargin)
			obj@OptimAlgo.Interface(varargin{:});
			
			% optimizeMS - Multi START
            obj.options_.Display = 'iter';
            obj.options_.MaxFunEvals = inf;
            obj.options_.MaxIter = 1000;
            obj.options_.TolX = 1e-6;
            obj.options_.TolFun = 1e-6;
            obj.options_.FinDiffType = 'central'; %/!\/!\/!\/!\
            obj.options_.Algorithm = 'interior-point';
            obj.options_.ScaleProblem = 'obj-and-constr';
            obj.options_.TolCon = 1e-6;
            
            obj.options_.randomInit = false;
            obj.options_.UseParallel = true;
            obj.options_.NbStartingPoints = 4;

			% update optimOptions avec varargin
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
            
            % create Multi Start solver
            ms = MultiStart;
            ms.PlotFcns = {
                @gsplotbestf, ...
                @gsplotfunccount ...
                };
            % solve problem
            [x,fVal,extFlag] = ms.run( problem, obj.options_.NbStartingPoints);
			
		end
	end
end
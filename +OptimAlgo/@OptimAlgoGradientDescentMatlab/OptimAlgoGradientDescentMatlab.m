classdef OptimAlgoGradientDescentMatlab < OptimAlgo.Interface
    % OptimAlgoGradientDescentMatlab implements a Gradient Descent optimization algorithm using fmincon
    %
    % OptimAlgoGradientDescentMatlab inherits all properties and methods of OptimAlgo.Interface
    %
    %   See also fmincon, OptimAlgo.Interface, OptimAlgo.Facture
    %
    
    methods
        function obj = OptimAlgoGradientDescentMatlab(varargin)
            obj@OptimAlgo.Interface(varargin{:});
            
            % Single start problem solved with FMINCON
            obj.options_.Display = 'iter';
            obj.options_.MaxFunEvals = inf;
            obj.options_.MaxIter = 1000;
            obj.options_.TolX = 1e-6;
            obj.options_.TolFun = 1e-6;
            obj.options_.TolCon = 1e-6;
            obj.options_.Algorithm = 'interior-point';
            obj.options_.FinDiffType = 'central'; %/!\/!\/!\/!\
            obj.options_.ScaleProblem = 'obj-and-constr'; % /!\ /!\ /!\
            
            obj.options_.PlotFcns = { ...
                @optimplotx, ...
                @optimplotfunccount, ...
                @optimplotfval, ...
                @optimplotconstrviolation, ...
                @optimplotfirstorderopt, ...
                @optimplotstepsize ...
                };
            
            obj.options_.randomInit = false;
            obj.options_.ScaleProblem = 'obj-and-constr';
            
            % update options avec varargin
            if ~isempty( varargin )
                obj.options = varargin;
            end
        end
    end
    
    methods
        function [x,fVal,extFlag] = optimize(obj, objective, X0, LB, UB, constraint, varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if ~isempty(p.Unmatched)
                obj.options = p.Unmatched;
            end
            
            [x,fVal,extFlag] = fmincon( ...
                objective, ...
                X0,...
                [],[],[],[], ...
                LB, ...
                UB, ...
                constraint, ...
                obj.options_ ...
                );
        end
    end
end

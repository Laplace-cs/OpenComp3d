classdef SensitivityOptimizer < SweepTool.SweepTool & OptimProblem.Optimizer
    %SENSITIVITYOPTIMIZER is a class to perform a series of optimization
    %from a designed optimProblem automatically. It allows then to plot
    %graphically the solutions
    
    
    %%
    methods        
        function obj = SensitivityOptimizer(varargin)
        end
    end
        
    %%
    methods (Access = protected)
        function computeValues(obj,k,varargin)
            obj.solveOptimizationProblem;
            obj.readyFlag_(k) = obj.fOpt;
        end
    end
    
    %%
    methods
        function [x, fval] = evaluate(obj)
            obj.evaluate@SweepTool.SweepTool;
            
            [fval, idx] = min( obj.readyFlag_(:));
            
            combinationCellArray = obj.buildCombinationCellArray;
            x = combinationCellArray(idx,:);
        end
    end
end

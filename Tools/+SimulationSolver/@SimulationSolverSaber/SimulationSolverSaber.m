classdef SimulationSolverSaber < SimulationSolver.Interface
% SimulationSolverSaber is a simulation solver for Saber objects
%

        
    %% Constructor
    methods 
        function obj = SimulationSolverSaber(varargin)
            obj = obj@SimulationSolver.Interface(varargin{:});
        end
    end
    
    %%
    methods
        function loadDefaultOptions(obj)
            obj.type_ = 'saber';
            obj.solver_ = [];

            obj.options_ = [];
            obj.options_.tStep = 1e-9;
            obj.options_.tEnd = 0.14; % For accuracy of visualizing
            obj.options_.nameProj = 'optimization_file';
        end
        
        function results = simulate(obj, circuit, varargin)
            results = obj.solver_.simulateSABER( ...
                'circuit', circuit, ...
                catstruct( obj.options_, varargin) ...
                );

            %resultsFormated = obj.solver_.formatXSABER( results, obj.period_);
            resultsFormated = obj.solver_.formatXSABER( results, obj.options_.tEnd);
            obj.solver_.ventilXSABER(resultsFormated);
        end
        
        function showResults(obj)
            
        end
    end
    
    %%
    methods (Static)
        function buildElectricModel(component)
            component.saberBuildElectricModel;
        end
    
        function data = getSimulationData(component)
            data = component.saberGetSimulationData;
        end
    end
end

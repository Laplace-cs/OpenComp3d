classdef SimulationSolverOotee < SimulationSolver.Interface
% SimulationSolverOotee is a simulation solver for Ootee circuits, it uses a ConvertSystSolver to simulate a Ckt.CktComposite
%
% SimulationSolverOotee inherits all methods of SimulationSolver.Interface
%
%   See also ConvertSystSolver, Ckt.CktComposite, SimulationSolver.Interface, SimulationSolver.Facture
%

        
    %% Constructor
    methods 
        function obj = SimulationSolverOotee(varargin)
            obj = obj@SimulationSolver.Interface(varargin{:});
        end
    end
    
    %%
    methods
        function loadDefaultOptions(obj)
            obj.type_ = 'ootee';
            obj.solver_ = ConvertSystSolver;
            
            obj.options_ = [];
            %obj.options_.differentialBw = 1e6;
            obj.options_.design = false;
            obj.options_.harmonicPrecision = 0;
        end
        
        function r = simulate(obj, circuit, varargin)
            obj.results_ = obj.solver_.simulate( ...
                circuit, ...
                obj.options ...
                );
            r = obj.results;
        end
        
        function showResults(obj)
            if ~isempty(obj.results_)
                SimulationSolver.Viewer(obj.results_);
            end
        end
    end
    
    %%
    methods (Static)
        function buildElectricModel( comp3dComponent )
            comp3dComponent.ooteeBuildElectricModel;
        end
    
        function data = getSimulationData( comp3dComponent )
            data = comp3dComponent.ooteeGetSimulationData;
        end
        
        function copy( electricModel, electricModelToCopy)
            for k = 1:length( electricModelToCopy.cktList )
                switch class( electricModelToCopy.cktList{k} )
                    case 'Ckt.CktComposite'
                        try
                        SimulationSolver.Facture.make.copy( electricModel.cktList{k}, electricModelToCopy.cktList{k});
                        catch
                            a = 4
                        end
                    otherwise
                        electricModel.cktList{k}.behaviour = electricModelToCopy.cktList{k}.behaviour;
                end
            end
        end
    end
end

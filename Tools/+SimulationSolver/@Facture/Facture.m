classdef Facture < handle
    % Facture is a facture of SimulationSolver objects
    %
    % Facture.make( type )
    %      makes a simulation solver of type type
    %
    % Facture.typeList
    %      lists all simulation solver types availables
    %
    %
    %   See also SimulationSolver.Interface
    %

    properties ( Constant )
        typeList = { ...
            'ootee', ...
            'saber', ...
            'none'  ...
            };
    end

    %%
    methods
        function obj = Facture(varargin)
        end
    end
    
    %%
    methods (Static)
        function simulationSolver = make(type, varargin)
            persistent singletonSimulationSolver;
            persistent typeCache;
            
            if nargin > 0
                if isempty( singletonSimulationSolver ) || ~strcmp( typeCache, type)
                    p = inputParser;
                    p.KeepUnmatched = true;
                    p.parse(varargin{:});
                    
                    switch type
                        case 'ootee'
                            singletonSimulationSolver = SimulationSolver.SimulationSolverOotee(p.Unmatched);
                        case 'saber'
                            singletonSimulationSolver = SimulationSolver.SimulationSolverSaber(p.Unmatched);
                        otherwise
                            error('SimulationSolver.Facture: Simulation Solver not available.');
                    end
                    typeCache = type;
                end
            else
                if isempty( singletonSimulationSolver )
                    % Ootee by default
                    warning('SimulationSolver.Facture: Ootee by default');
                    singletonSimulationSolver = SimulationSolver.SimulationSolverOotee;
                end
            end
            
            simulationSolver = singletonSimulationSolver;
        end
    end
end
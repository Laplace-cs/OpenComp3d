classdef Interface < handle
    % Interface for all simulation solvers.
    %
    % Interface properties:
    %   options     - simulation options
    %   results     - simulation results
    %
    % Interface methods:
    %   loadDefaultOptions      - load default simulation options
    %   simulate                - simulate and store results
    %   showResults             - show results in a new window
    %
    % Interface methods:
    %   buildElectricModel( comp3dComponent )           - build electric model of comp3dComponent for this SimulationTool
    %   data = getSimulationData( comp3dComponent )     - get simulation data of comp3dComponent for this SimulationTool
    %
    % See also SimulationToolFacture, SimulationTool.SimulationToolOotee
    %
    
    properties (Access = protected)
        type_
        solver_
        options_
        results_ = [];
    end
    
    properties( Dependent )
        type
        solver
        options         % SimulationSolver options
        results         % structure with last simulation results
    end
        
    %% Constructor
    methods 
        function obj = Interface(varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            obj.loadDefaultOptions;
            obj.options = p.Unmatched;
        end
    end
    
    %%
    methods (Abstract)
        loadDefaultOptions(obj)
        
        %
        % results = simulate( circuit )
        %   simulate circuit and store results internally
        %
        % arguments:
        %    circuit        - compatible SimulationSolver circuit object
        %
        % return values:
        %    results        - compatible SimulationSolver results
        %
        results = simulate(obj, circuit, varargin)
        
        showResults(obj)
    end
    
    %%
    methods (Abstract)
        buildElectricModel( comp3dComponent )
        data = getSimulationData( comp3dComponent )
        copy( electricModel, electricModelToCopy)
    end
    
    %% Dependent Properties
    methods
        function val = get.type(obj)
            val = obj.type_;
        end
        function val = get.solver(obj)
            val = obj.solver_;
        end
        
        function val = get.options(obj)
            val = obj.options_;
        end
        function val = get.results(obj)
            val = obj.results_;
        end
        function set.options(obj, val)
            if ~isempty( fieldnames(val) )
                obj.options_ = setNewStructure( obj.options_, val);
            end
        end
    end
end

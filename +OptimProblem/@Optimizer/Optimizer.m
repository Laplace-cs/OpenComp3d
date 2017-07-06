classdef Optimizer < Comp3d.Composite & matlab.mixin.Copyable
    % OptimProblem.Optimizer is the mother class for all the optimization problems, but
    % it can also be used to solve generic user defined problems.
    %
    % Optimizer inhetires all Comp3d.Composite methods to manage a Comp3d.Component list
    %
    % Optimizer methods:
    %   addComp3d( component )      - to add a component to be optimized
    %	solveOptimizationProblem    - starts the optimization problem
    %
    %   See also Comp3d.Composite
    %
    % Optimizer properties:
    %   criteriaTypeList        - criteria availeble options
    %   criteria                - criteria to optimize
    %   weights                 - weight of each criteria
    %
    %   level                   - model level to be used [1,2]
    %   levelSwitchingOpt       - option to perform and optimization switching between levels [true,false]
    %
    %   optimAlgoTypeList       - optimization algorithm type available options
    %   optimAlgoType           - optimization algorithm type to performe optimization
    %   optimAlgo               - optimization algorithm object
    %   optimAlgo.options       - optimization algorithm options
    %       See also OptimAlgo.Facture
    %
    %   scaleTypeList           - scale type available options
    %   scaleType               - scale methods list (can combine many types)
    %   scale                   - scale object
    %       See also Scale.Facture
    %
    %   scaleContraintsTypeList     - scaling type for constraints
    %                                 available options
    %   scaleConstraintsType        - type of constraints scaling
    %
    %   simulationSolverTypeList    - SimulationSolver type available options
    %   simulationSolverType        - SimulationSolver type to simulate the electricModel
    %   simulationSolver            - SimulationSolver object
    %   simulationSolver.options    - SimulationSolver options
    %   circuit                     - circuit to simulate
    %       See also SimulationSolver.Facture
    %
    % Optimizer outputs
    %   xOpt                - optimal solution
    %   fOpt                - optimal objective function value
    %   exitFlag            - 
    %
    %
    %   See also Comp3d.Composite, Comp3d.Component, OptimAlgo.Facture, Scale.Facture, SimulationSolver.Facture
    %
    % Exemple:
    %   optimProblem = OptimProblem.Optimizer;      % creates an optimProblem
    %   optimProblem.addComp3d( myElement );        % adds myElement to be optimized
    %   optimProblem.solveOptimizationProblem;      % computes the optimization
    %
    
    properties (Access = protected)
        % objective options
        criteriaTypeList_
        criteria_
        weights_
        %
        % optimisation level options
        levelSwitchingOpt_ = false
        %
        % optimisation initial values and bound
        X0_                 % initial values
        LB_                 % lower bound
        UB_                 % upper bound
        %
        % optimisation optimAlgo
        optimAlgoTypeList_
        optimAlgoType_ = []
        optimAlgo_
        % optimisation scale
        scaleTypeList_
        scaleType_ = []
        scale_
        % system level solver
        simulationSolverTypeList_
        simulationSolverType_ = []
        simulationSolver_
        %
        % optimisation results
        exitFlag_
        xOpt_                   % Inputs of the optimal solution
        fOpt_                   % output of the optimal solution
        
        % Constraints specific optimization properties
        scaleConstraintsTypeList_ = {'none','norm'}
        scaleConstraintsType_
        
    end
    properties (Dependent)
        criteriaTypeList         % criteria available options, like 'mass', 'losses', 'cost' and 'volume'
        criteria                % criteria to optimize. It shall be included as a list Ex. {'mass'} or {'mass','cost'}. Available options in criteriaTypeList
        weights                 % weight of each criteria (same length) as a input vector Ex. [1] ou [1 0.8]
        %
        levelSwitchingOpt
        %
        optimAlgoTypeList
        optimAlgoType
        optimAlgo
        %
        scaleTypeList
        scaleType
        scale
        %
        simulationSolverTypeList
        simulationSolverType
        simulationSolver
        circuit
        %
        exitFlag
        xOpt
        fOpt
        
        randomInit
        
         % Constraints specific optimization properties
        scaleConstraintsTypeList 
        scaleConstraintsType
    end
    
    %% Constructor
    methods
        function obj = Optimizer(varargin)
            % properties options List 
            obj.criteriaTypeList_ = {'mass','losses','cost','volume'};
            obj.scaleTypeList_ = Scale.Facture.typeList;
            obj.optimAlgoTypeList_ = OptimAlgo.Facture.typeList;
            obj.simulationSolverTypeList_ = SimulationSolver.Facture.typeList;
            
            p = inputParser;
            p.KeepUnmatched = true;
            
            % 1 means first option in TypeList
            p.addParameter( 'criteria', 1, @(x) isnumeric(x) || ischar(x) || iscell(x));
            p.addParameter( 'weights', 1, @isnumeric);
            
            %
            p.addParameter( 'levelSwitchingOpt', false, @islogical);
            p.addParameter( 'level', 2, @(x) x>=0)
            
            % 1 means first option in TypeList
            p.addParameter( 'scaleType', 1, @(x) isnumeric(x) || ischar(x) || iscell(x));
            p.addParameter( 'optimAlgoType', 1, @(x) isnumeric(x) || ischar(x));
            p.addParameter( 'simulationSolverType', 1, @(x) isnumeric(x) || ischar(x))
            
            % constraints
            p.addParameter('scaleConstraintsType','none',@(x) ischar(x));
            
            % parsing
            p.parse(varargin{:});
            %
            obj.criteria = p.Results.criteria;
            obj.weights = p.Results.weights;
            %
            obj.levelSwitchingOpt_ = p.Results.levelSwitchingOpt;
            obj.level_ = p.Results.level;
            %
            obj.optimAlgoType = p.Results.optimAlgoType;
            obj.scaleType = p.Results.scaleType;
            obj.simulationSolverType = p.Results.simulationSolverType;
            %
            obj.scaleConstraintsType = p.Results.scaleConstraintsType;
            
        end
    end
    
    %% Optimization functions
    methods
        function solveOptimizationProblem(obj, varargin)
            % solveOptimizationProblem starts the optimization problem.
            % All comp3dList objects keep the optimal solution value after the optimization.
            %
                
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('optimAlgoType',obj.optimAlgoType,@ischar);
            p.parse(varargin{:});
            obj.optimAlgoType = p.Results.optimAlgoType;
            obj.optimAlgo.options = p.Unmatched;
            
            if obj.levelSwitchingOpt_
                for k = 1:2
                    obj.level_ = k;
                    obj.updateObj('level',obj.level_);
                    obj.computeOptimization;
                    
                    if numel( obj.criteria_) == 1
                        display(['Intermediary solution for level ' num2str(k), ': ' obj.criteria_{1} ' = ' num2str(obj.fOpt_) '.']);
                    else
                        display(['Intermediary solution for level ' num2str(k), ': fval = ' num2str(obj.fOpt_)]);
                    end
                end
                
            else
                obj.computeOptimization;
            end
        end
        function solveMultiObj(obj, criteria, weights, varargin)
            obj.criteria_ = criteria;
            
            % affect dependent weigths variable to parse it
            obj.weights = weights;
            % normalise user weigths
            obj.weights_ = obj.weights_/sum(obj.weights_);
            
            % compute optimal weights for normalized multiobjective optimization
            normalizedWeights = obj.computeNormalizedWeights;
            % normalise user weigths with best weights
            obj.weights_ = obj.weights_ .* normalizedWeights;
            
            obj.solveOptimizationProblem(varargin{:});
        end
    end
    
    %% Compute Pareto Front method
    methods
        function computeParetoFront(obj, nPoints, criteria, varargin)
            if numel(criteria) ~= 2
                error('Pareto-Front only possible for 2 criteria')
            end
            
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            % push
            weightOrig = obj.weights_;
            criteriaOrig = obj.criteria_;
            % push
            
            obj.criteria_ = criteria;
            normalizedWeights = obj.computeNormalizedWeights(p.Unmatched);
            
            c1 = 1/(nPoints+1);
            c2 = nPoints/(nPoints+1);
            
            weightsList = [
                linspace( c1*normalizedWeights(1), c2*normalizedWeights(1), nPoints);
                linspace( c2*normalizedWeights(2), c1*normalizedWeights(2), nPoints)
                ];
            valuesOpt = zeros(size(weightsList));
            
            for k = 1:nPoints
                obj.weights_ = weightsList(:,k);
                obj.solveOptimizationProblem(p.Unmatched);
                valuesOpt(1,k) = obj.computeTotalValue( obj.criteria_(1),1);
                valuesOpt(2,k) = obj.computeTotalValue( obj.criteria_(2),1);
            end

            figure();
            plot(valuesOpt(1,:),valuesOpt(2,:),'*-');
            xlabel([obj.criteria_{1},' values']);
            ylabel([obj.criteria_{2},' values']);
            
            % pop
            obj.weights_ = weightOrig;
            obj.criteria_ = criteriaOrig;
            % pop
        end
    end
    
    %% Internal internal protected methods of
    % getBestWeights
    % getBestValues
    methods (Access = private)
        function normalizedWeights = computeNormalizedWeights(obj,varargin)
            % This function use the optimal value for each criteria to
            % normalize the multiobjective optimization
            
            bestObjectiveValues = obj.computeBestObjectiveValues(varargin{:});
            nCriteria = length(bestObjectiveValues);
            
            normalizedWeights = zeros([1,nCriteria]);
            for k = 1:nCriteria
                normalizedWeights(k) = 1 / mean(bestObjectiveValues(:,k));
            end
            
        end
        function bestObjectiveValues = computeBestObjectiveValues(obj,varargin)
            % This function gets the optimal value for each criteria.

            % push
            weightOrig = obj.weights_;
            criteriaOrig = obj.criteria_;
            % push
            
            nCriteria = numel(obj.criteria_);
            bestObjectiveValues = zeros(nCriteria);
            
            for k = 1:nCriteria
                obj.weights_ = zeros(size(obj.criteria_));
                obj.weights_(k) = 1;
                obj.solveOptimizationProblem(varargin{:});
                
                value = zeros(size(obj.criteria_));
                for j = 1:nCriteria
                    value(j) = obj.computeTotalValue( obj.criteria_(j),1);
                end
                bestObjectiveValues(k,:) = value;
            end
            
            % pop
            obj.weights_ = weightOrig;
            obj.criteria_ = criteriaOrig;
            % pop
        end
    end
    
    %%
    methods (Access = protected)
        function computeOptimization(obj)
            obj.resetStoredData;
            obj.getFreedomDegreeArrayForOptim;
            cellfun(@(elts)obj.computeModelParameters,obj.comp3dList_);
            arrayfun(@(listConstraints)listConstraints.updateFixedValues,obj.constraintsObjects_,'UniformOutput',false)
            [obj.xOpt_, obj.fOpt_, obj.exitFlag_] = obj.optimAlgo_.optimize( ...
                @obj.objective, ...
                obj.X0_, ...
                obj.LB_, ...
                obj.UB_, ...
                @obj.constraint, ...
                'OutputFcn', @obj.outputFunction ...
                );
            
            % just to update all comp3d components with xOptimal
            obj.evaluateFunction(obj.xOpt_);
            [ineq, eq] = obj.constraint(obj.xOpt_);
            obj.evaluateFinalParameters;
            obj.exitFlagShow;
        end
    end
        
    %%
    methods (Access = protected)
        % standard objective function
        function [value] = objective(obj,x)
            % compute iteration
            obj.evaluateFunction(x);
            % calculate objective function value 
            [value] = obj.computeTotalValue( obj.criteria_, obj.weights_);
        end
        % standard constraints function
        function [ineq, eq] = constraint(obj,x)
            % compute iteration
            obj.evaluateFunction(x);

           [ineqNew,eqNew] = arrayfun(@(const) const.getConstraint(obj.scaleConstraintsType_),obj.constraintsObjects_,'UniformOutput',false);
            [ineq] = cell2mat(ineqNew);
            [eq] = cell2mat(eqNew);
            
        end
        % standard compute iteration function
        function evaluateFunction(obj,x)
            % verify if x vector changed
            persistent lastX;
            if isempty(lastX) || length(lastX) ~= length(x) || any(lastX ~= x)
                lastX = x;
                
                % compute iteration because x changed
                % update all components with new Freedom Degrees values
                obj.setFreedomDegrees(x);
                % compute new model parameters for simulate/compute output data
                obj.computeModelParameters;

                % simulate and update excitations, if possible...
                if ~isempty( obj.model_.electricPort)
                    if ~isempty( obj.simulationSolver_)
                        obj.simulationSolver_.simulate( obj.model_.electricPort);
                        simulationData = obj.getSimulationData;
                        obj.setExcitations( simulationData);
                    end
                end

                % compute output data for objective function evaluation
                obj.computeOutputData;
            end
        end
        function exitFlagShow(obj)
            switch obj.exitFlag_
                case -3
                    display('Unsuccessful optimization. Exit flag = -3. Problem seems unbounded.');
                case -2
                    display('Unsuccessful optimization. Exit flag = -2. No feasible point found.');
                case -1
                    display('Unsuccessful optimization. Exit flag = -1. Stopped by output/plot function.');
                case 0
                    display('Unfinished optimization. Exit flag = 0. Too many function evaluations or iterations.');
                case 1
                    display('Successful optimization! Exit flag = 1. First order optimality conditions satisfied.');
                case 2
                    display('Successful optimization! Exit flag = 2. Change in X too small.');
                case 3
                    display('Successful optimization! Exit flag = 3. Change in objective function too small.');
                case 4
                    display('Successful optimization! Exit flag = 4. Computed search direction too small.');
                case 5
                    display('Successful optimization! Exit flag = 5. Predicted change in objective function too small.');
                otherwise
                    display([' ' num2str(obj.exitFlag_) ' unknown exitFlag']);
            end
        end
        %
        function evaluateFinalParameters(obj)
           cellfun(@(x) x.updateModelParameters,obj.comp3dList,'UniformOutput',true); 
        end
        %
        function stop = outputFunction(obj, x, optimValues, state)
            stop = false;
            % store iteration data
            switch state
                case 'init'
                    obj.storeCurrentData;
                case 'iter'
                    obj.storeCurrentData;
                case 'done'
                otherwise
            end
            
            obj.outputFunction@Comp3d.Composite;
        end
    end
    
    %% internal protected methods
    %methods (Access = protected)
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        function setFreedomDegrees(obj,x)
            x = obj.scale_.unscale(x);
            obj.setFreedomDegrees@Comp3d.Composite(x);
        end
        function getFreedomDegreeArrayForOptim(obj) 
            [lB,x0,uB] = obj.freedomDegrees_.getArrayForOptim;
            
            [obj.LB_, obj.UB_] = obj.scale_.setup(lB, uB);
            if obj.randomInit
                obj.X0_ = rand(size(obj.UB_)) .* (obj.UB_ - obj.LB_) + obj.LB_;
            else
                obj.X0_ = obj.scale_.scale(x0);
            end
        end
    end
    
    %% Dependent properties ACCESS methods
    methods
        function value = get.criteriaTypeList(obj)
            value = obj.criteriaTypeList_;
        end
        function set.criteria(obj,value)
            if isnumeric(value)
                value = obj.criteriaTypeList(value);
            end
            if ischar(value)
                value = {value};
            end
            obj.criteria_ = value;
        end
        function value = get.criteria(obj)
            value = obj.criteria_;
        end
        function set.weights(obj,value)
            if numel( obj.criteria_) ~= numel( value)
                value = ones(size(obj.criteria_));
                value = value/sum(value);
                warning('The number of criteria & weights do not agree. Unitarians weights taken by default.');
            end
            obj.weights_ = value/sum(value);
        end
        function value = get.weights(obj)
            value = obj.weights_;
        end
        
        function set.levelSwitchingOpt(obj,value)
            obj.levelSwitchingOpt_ = value;
        end
        function value = get.levelSwitchingOpt(obj)
            value = obj.levelSwitchingOpt_;
        end
        function value = get.randomInit(obj)
            if ~isempty(obj.optimAlgo_) && ~isempty(obj.optimAlgo_.options) && isfield(obj.optimAlgo_.options, 'randomInit')
                value = obj.optimAlgo_.options.randomInit;
            else
                value = false;
            end
        end
        
        function value = get.exitFlag(obj)
            value = obj.exitFlag_;
        end
        function value = get.xOpt(obj)
            value = obj.xOpt_;
        end
        function value = get.fOpt(obj)
            value = obj.fOpt_;
        end
    end
    
    %%
    methods
        % optimAlgo
        function value = get.optimAlgoTypeList(obj)
            value = obj.optimAlgoTypeList_;
        end
        function value = get.optimAlgoType(obj)
            value = obj.optimAlgoType_;
        end
        function set.optimAlgoType(obj,value)
            if isnumeric(value)
                value = obj.optimAlgoTypeList_{value};
            end
            if ischar(value)
                if ~strcmp( obj.optimAlgoType_, value)
                    obj.optimAlgoType_ = value;
                    obj.optimAlgo_ = OptimAlgo.Facture.make( value );
                end
            else
                error('OptimProblem.Optimizer: Invalid optimAlgoType.')
            end
        end
        function value = get.optimAlgo(obj)
            value = obj.optimAlgo_;
        end
        function set.optimAlgo(obj,value)
            obj.optimAlgoType = value;
        end
        
        % scale
        function value = get.scaleTypeList(obj)
            value = obj.scaleTypeList_;
        end
        function value = get.scaleType(obj)
            value = obj.scaleType_;
        end
        function set.scaleType(obj,value)
            if isnumeric(value)
                value = obj.scaleTypeList_{value};
            end
            if ischar(value)
                value = {value};
            end
            if iscell(value)
                if length(obj.scaleType_) ~= length(value) || any( cellfun( @(x,y) ~strcmp(x,y), obj.scaleType_, value) )
                    obj.scaleType_ = value;
                    obj.scale_ = Scale.Facture.make( obj.scaleType_ );
                end
            else
                error('OptimProblem.Optimizer: Invalid scaleType.')
            end
        end
        function set.scale(obj,value)
            obj.scaleType = value;
        end
        
        % simulationSolver
        function value = get.simulationSolverTypeList(obj)
            value = obj.simulationSolverTypeList_;
        end
        function value = get.simulationSolverType(obj)
            value = obj.simulationSolverType_;
        end
        function set.simulationSolverType(obj,value)
            if isnumeric(value)
                value = obj.simulationSolverTypeList_{value};
            end
            if ischar(value)
                if ~strcmp( obj.simulationSolverType_, value)
                    obj.simulationSolverType_ = value;
                    obj.simulationSolver_ = SimulationSolver.Facture.make( obj.simulationSolverType_ );
                else
                    error('OptimProblem.Optimizer: Invalid simulationSolverType.')
                end
            end
        end
        function val = get.simulationSolver(obj)
             val = obj.simulationSolver_;
        end
        function set.simulationSolver(obj,value)
            obj.simulationSolverType = value;
        end
        function set.circuit(obj,value)
            obj.model_.electricPort = value;
        end
        function value = get.scaleConstraintsTypeList(obj)
            value = obj.scaleConstraintsTypeList_;
        end
        
        function value = get.scaleConstraintsType(obj)
           value = obj.scaleConstraintsType_;
        end
        
        function set.scaleConstraintsType(obj,value)
           if ismember(value,obj.scaleConstraintsTypeList_)
                obj.scaleConstraintsType_ = value;
           else
               error('constraints scaling not recognized, see property "scacleConstraintsTypeList"')
           end
        end
    end
end


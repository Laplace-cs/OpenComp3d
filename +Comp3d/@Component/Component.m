classdef Component < matlab.mixin.Copyable
    % Component (Abstract) base class to create a physical component or
    % composite
    %
    % inputs Component properties:
    % name            - name of the component
    % level           - complexity & precission of the model
    % recordObj       - to store simulation data on the object
    % toCopy          - if it is a copy, case of several equal components
    %
    % others Component properties:
    % comp3dParent    - comp3d object parent
    % dimensions      - geometric dimensions of the component
    % electricData    - output electric data
    % geometricData   - output geometric data
    % thermalData     - ouput thermal data
    % electricModel   - electric model
    % thermalModel    - thermal model
    % electricModelParameters   - electric model parameters
    % thermalModelParameters    - thermal model parameters
    % costModel       - cost model
    %
    % Component Methods:
    % updateObj                 - updates the inputs of the object
    %
    % computeModelParameters    - computes the parameter of the object
    %
    % setExcitations            - loads excitations to the object
    % computeOutputData         - computes the output data of the object
    % computeTotalValue
    %
    % displayInformation        - displays all the relevant information of
    %                             the component
    % drawComponent([x,y,z])    - draws the component from the x,y,z point
    %
    % resumeProperties          - standard output display circuit information
    % setName                   - to change the name (can be overloaded)
    
    properties (Constant,Access = protected)
        % Air Properties
        MU_0 = 4 * pi * 1e-7;
        E_0 = 8.8541878 * 1e-12;
    end
    
    properties (Access = {?Comp3d.Component})
        % Caracterisation
        name_ = [];
        level_ = 2;
        nComponents_ = 1;  % equal component number. Used during optimisation
        
        % Interaction objects
        comp3dParent_           % comp3d.composite
        record_ = false;        % solver
        copy_                   % consol
        dbManager_              % for data bases management
        
        % Models
        model_ = struct( ...
            'cost', [], ...
            'thermal', [], ...
            'electric', [], ...
            'electricPort', [] ...
            );
        
        % Excitations results
        outputData_ = struct( ...
            'recompute', true, ...
            'geometric', struct('weight',0,'manufacturingVolume',0), ...
            'cost', struct('total',0), ...
            'thermal', struct('losses',0,'temperature',0), ...
            'electric', [] ...
            );
        
        % Contraints
        constraints_ = struct('ineq',[],'eq',[]);
        
        outputFunctionList_ = {};
        
        % FreedomDegrees
        freedomDegrees_
    end
    
    properties (Dependent)
        name            % component name
        level           % modelling level

        electricModelPort
        
        electricModel   % electric model
        thermalModel    % thermal model
        costModel       % cost model
        
        outputData      % output electric data
        
        constraints     % constraints of the component
        
        record          % flag to store simulation data
        
        outputFunctionList
        
        freedomDegrees  % Property to store the freedom degree objects
    end
    
    properties (Access = {?OptimProblem.Optimizer,?Comp3d.Component})
        constraintsObjects_ = [];
    end
    
    properties (Dependent, Hidden = true)
        nComponents     % equal component number. Used during optimisation
        comp3dParent    % comp3d object parent
    end
    
    %% Constructor method
    methods
        function obj = Component(varargin)
            obj.freedomDegrees_ = Comp3d.FreedomDegrees;
            obj.parse(varargin{:});
        end
    end
    
    %% Assistants Methods
    methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            obj.parse(varargin{:});
        end
    end
    methods ( Access = private, Hidden = true )
        function parse(obj,varargin)
            % Parser instantiation
            p = inputParser;
            p.KeepUnmatched = true;
            p.PartialMatching = false;
            p.addParameter('name', obj.name_);
            p.addParameter('level', obj.level_, @(x) x>=0);
            p.addParameter('record', obj.record_, @(x) islogical(x) || isnumeric(x));
            p.addParameter('copy', obj.copy_);
            
            % Parsing
            p.parse(varargin{:});
            obj.name_ = p.Results.name;
            obj.record_ = p.Results.record;
            obj.copy_ = p.Results.copy;
            obj.level_ = p.Results.level;
        end
    end
    
    methods
        function copyObj = copyWithReference(obj,varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            new = str2func(class(obj));
%             copyObj = new('copy', obj, struct(obj), p.Unmatched);
            copyObj = new('copy', obj);
        end
    end    
    
    %% Abstract Methods
    methods ( Abstract  )
        % Model Parameters Methods
        computeModelParameters(obj)
        
        % Model methods
        buildElectricModel(obj)
        getSimulationData(obj)
        resetModels(obj)
        
        % Output Data Methods
        setExcitations(obj)
        computeOutputData(obj)
        computeTotalValue(obj)

        % Display Methods
        displayInformation(obj)
    end
    
    %% Optimisation Methods
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        function updateFreedomDegreeArrayForOptim(obj)
            if ~isempty(obj.comp3dParent_)
                obj.comp3dParent_.updateFreedomDegreeArrayForOptim;
            end
        end
        function [ineq, eq] = extractConstrants(obj)
            obj.computeConstraints;
            [ineq] = obj.constraints_.ineq;
            [eq] = obj.constraints_.eq;
        end
    end
    
    %% Stored Data Methods
    methods ( Abstract, Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        storeCurrentData(obj)
        resetStoredData(obj)
    end
    
    %%
    methods
        function updateObj(obj,varargin)
            obj.update(varargin{:});
        end
    end
    methods (Access = protected)
        function computeConstraints(obj)
            obj.constraints_.ineq = [];
            obj.constraints_.eq = [];
        end
    end
    %%
    methods  (Access = protected)
        function outputFunction(obj)
            cellfun( @(func) func(), obj.outputFunctionList_, 'UniformOutput', false);
        end
    end
    methods
        function set.outputFunctionList(obj, fh)
            if isa( fh, 'function_handle')
                obj.outputFunctionList_{end+1} = fh;
            else
                error('Comp3d.Component: value must be a function handle')
            end
        end
        function fhl = get.outputFunctionList(obj)
            fhl = obj.outputFunctionList_;
        end
    end
    
    %% write file methods
    methods ( Access = public )
        function writeComponent(obj,name)
            if isempty(name)
                name = reportOptim;
            end
            fid = fopen(['Comp3d\Results\',name,'_Report.txt'],'w');
            obj.writeFile(fid)
            fclose(fid);
        end
        function writeFile(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            obj.displayFreedomDegrees(fid)
            obj.displayInputs(fid)
            obj.displayOutputs(fid)
        end
    end
    
    %% Gateway methods
    % Ootee Gateway Methods
    methods ( Hidden = true, Access = {?Comp3d.Component,?SimulationSolver.SimulationSolverOotee} )
        ooteeBuildElectricModel(obj)
    end
    
    % Saber Gateway Methods
    methods ( Hidden = true, Access = {?Comp3d.Component,?SimulationSolver.SimulationSolverSaber} )
        saberBuildElectricModel(obj)
    end
    
    %% showObject
    methods ( Access = public )
        function showObject(obj)
            f = figure('name',obj.name,'Position',[400 400 210 400]);
            tgroup = uitabgroup('Parent', f);
            tab1 = uitab('Parent', tgroup, 'Title', 'Dimensions');
            tab2 = uitab('Parent', tgroup, 'Title', 'Geometric Data');
            
            fields = fieldnames(obj.dimensions);
            numData = struct2cell(obj.dimensions);
            data = [fields numData];
            t = uitable('Parent',tab1, 'Data',data,'ColumnName',{'Parameter','Value'},...
                'RowName',[],'ColumnEditable',[false false],'ColumnWidth',{'auto' 'auto'});
            
            fields = fieldnames(obj.geometricOutputData);
            numData = struct2cell(obj.geometricOutputData);
            index = cellfun(@(x) isnumeric(x) && isvector(x), numData, 'UniformOutput', 1);
            fields = fields(index);
            numData = numData(index);
            data = [fields numData];
            t = uitable('Parent',tab2, 'Data',data,'ColumnName',{'Parameter','Value'},...
                'RowName',[],'ColumnEditable',[false false],'ColumnWidth',{'auto' 'auto'});
        end
        function drawComponent(obj)
        end
    end
    
    %% Dependents properties access
    methods
        % get
        function val = get.name(obj)
            val = obj.name_;
        end
        function val = get.level(obj)
            val = obj.level_;
        end
        function val = get.nComponents(obj)
            val = obj.nComponents_;
        end
        function val = get.comp3dParent( obj )
            val = obj.comp3dParent_;
        end
        function val = get.record(obj)
            val = obj.record_;
        end
        
        % set
        function set.name(obj, val)
            obj.name_ = val;
        end
        function set.level(obj,val)
            if mod(val,1) == 0 && sum(val == 1:3)
                if obj.level_ ~= val
                    obj.level_ = val;

                    if ~isempty( obj.model_.electricPort)
                        obj.resetModels;
                        obj.buildElectricModel;
                    end
                    obj.updateFreedomDegreeArrayForOptim;
                end
            else
                warning('level must be an integer between 0 and 3.')
            end
        end
        function set.nComponents(obj,val)
           obj.nComponents_ = val;
        end
        function set.comp3dParent(obj, val)
            if isempty( obj.comp3dParent_)
                if isa( val, 'Comp3d.Composite' )
                    obj.comp3dParent_ = val;
                else
                    error('Comp3d:WrongOperation', 'comp3dParent shall be a Comp3d.Composite object.');
                end
            else
                error('Comp3d:WrongOperation', 'This component has already a Parent');
            end
        end
        function set.record(obj, val)
            if obj.record_ ~= val
                obj.record_ = val;

                if ~isempty( obj.model_.electric)
                    obj.resetModels;
                    obj.buildElectricModel;
                end
            end
        end
    end
    
    %% Dependents properties access
    methods
        function val = get.freedomDegrees(obj)
            val = obj.freedomDegrees_;
        end
        function val = get.electricModelPort(obj)
            val = obj.model_.electricPort;
        end
        function set.electricModelPort(obj, val)
            obj.model_.electricPort = val;
        end
        
        function val = get.costModel(obj)
            val = obj.model_.cost;
        end
        function val = get.thermalModel(obj)
            val = obj.model_.thermal;
        end
        function val = get.electricModel(obj)
            if isempty(obj.model_.electricPort)
                obj.buildElectricModel;
            end
            val = obj.model_.electricPort;
        end
        
        function val = get.outputData(obj)
            val = obj.outputData_;
        end
        
        function value = get.constraints(obj)
            value = rmfield( obj.constraints_, {'ineq','eq'});
        end
        function set.constraints(obj,val)
            obj.constraints_ = setNewStructure( obj.constraints_, val);  
            % We set as well the constraints objects
            if ~isempty(obj.constraintsObjects_)
                arrayfun(@(structureIn) structureIn.updateFixedValues,obj.constraintsObjects_);
            end
        end
    end
    
    %% Static methods
    % correctValues
    % compareStruct
    methods ( Static )
        function [freqVec, fftVec] = correctValues( freqVecFull, fftVecFull)
            warning('Use Comp3d.removeNegativeFrequencies function. This method will be removed.')
            [freqVec, fftVec] = Comp3d.removeNegativeFrequencies( freqVecFull, fftVecFull);
        end
    end
end


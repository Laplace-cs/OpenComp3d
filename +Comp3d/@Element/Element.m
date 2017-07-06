classdef Element < Comp3d.Component
    % Comp3d.Element models an elementary component that can be used lonely or
    % with other components inside a composite.
    % Comp3d.Element examples: inductor, capacitor,...
    %
    % Comp3d.Element properties:
    % dimensions        - structure containing the dimensions of the material
    % materials         - structure containing the materials properties of the element
    % shape             - shape of the element
    %
    % storeDataFlag     - iteration store data flag
	% storedData        - StoredData object
    %
    %
    %   See also Comp3d.Component
    %

    properties ( Access = protected )
        dimensionsCache_ = [];
        
        materials_
        materialsType_
        
        shape_
        shapeOptions_
        
        % Model Parameters
        modelParameters_ = struct( ...
            'recompute', true, ...
            'thermal', [], ...
            'electric', [] ...
            );
        
        % Excitations wave forms 
        excitations_ = struct( ...
            'electric', [], ...
            'thermal', [], ...
            'femm', [] ...
            );
        excitationsCache_ = [];
        excitationsElectricAnalytic_ = [];
        
        storeDataFlag_ = false;
        storedData_ = StoredData.Facture.makeNull;
    end 
    
    
    properties ( Dependent )
        dimensions      % input dimensions
        materials        % materials
        materialsOptions
        shape           % input shape
        shapeOptions
        
        modelParameters
        
        excitations     % electric and thermal excitations
        excitationsElectricAnalytic
        
        storeDataFlag       % false by default. See also storedData
        storedData          % See also StoredData.Interface, StoredData.Facture
    end
    
    properties (Access = {?Comp3d.Element,?Comp3d.FreedomDegreeUnit})
       dimensions_  
    end
    
    methods
        function obj = Element(varargin)
            obj@Comp3d.Component(varargin{:});
            obj.setDefaultParameters();
            obj.parse(varargin{:});
        end
    end
    
    %% Assistants Methods
    % update
    methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            update@Comp3d.Component(obj,varargin{:});
            obj.parse(varargin{:});
        end
    end
    % parse
    % setDefaultParameters
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj)
        end
        function parse(obj,varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter( 'storeDataFlag', obj.storeDataFlag_, @(x) islogical(x) || isnumeric(x))
            p.parse(varargin{:});
            
            obj.storeDataFlag = p.Results.storeDataFlag;
        end
    end
    
    %% Optimization functions
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        function setFreedomDegrees(obj,x)
            if isempty(obj.copy_)
                obj.freedomDegrees_.setDimensionsStatusFree(x');
            end
        end
        function [x0, lB, uB] = getFreedomDegreeArrayForOptim(obj)
            if isempty(obj.copy_)
                [x0, lB, uB] = obj.freedomDegrees_.getArrayForOptim;
            else
                x0 = [];
                lB = [];
                uB = [];
            end
        end
    end
    
    methods
        function setPointAsInitialOpti(obj)
            obj.freedomDegrees.setDimensionsAsInitialPoint;
        end
    end
    
    %% Model Parameters Methods
    methods
        function computeModelParameters(obj)
            if ~isempty( obj.copy_)
                obj.dimensions_ = obj.copy_.dimensions;
                elt = obj.copy_;
                obj.outputData_.geometric = elt.outputData.geometric;
            end

            if obj.modelParameters_.recompute == true || isempty( obj.modelParameters_.electric)
                obj.updateModelParameters;
                obj.modelParameters_.recompute = false;
                obj.outputData_.recompute = true;
            end
        end
    end
    methods ( Access = {?Comp3d.Component})
        function updateModelParameters(obj)
            switch obj.level_
                case 1
                    obj.computeElectricModelParametersLv1();   
                    obj.computeThermalModelParametersLv1();
                case 2
                    obj.computeElectricModelParametersLv2();
                    obj.computeThermalModelParametersLv2();
                otherwise
                    error('Level not available.')
            end
        end
    end
    methods ( Abstract, Access = protected )
        computeGeometry(obj)
        computeElectricModelParametersLv1(obj)
        computeElectricModelParametersLv2(obj)
        computeThermalModelParametersLv1(obj)
        computeThermalModelParametersLv2(obj)
    end
    
    %% Model methods
    methods
        function buildElectricModel(obj)
            if isempty( obj.model_.electric)
                % Verifies if the modelParameters are already computed
                obj.computeModelParameters;
                SimulationSolver.Facture.make.buildElectricModel(obj);
            end
            if ~isempty( obj.copy_)
                SimulationSolver.Facture.make.copy( obj.electricModel, obj.copy_.electricModel);
            end
        end
        function data = getSimulationData(obj)
            data = SimulationSolver.Facture.make.getSimulationData(obj);
        end
        function resetModels(obj)
            if ~isempty( obj.model_.electricPort )
                % remove submodels from port model
                cellfun(@(ckt) obj.model_.electricPort.removeCkt(ckt), obj.model_.electricPort.cktList);
                
                % delete sub electric models
                obj.model_.electric = [];
                % delete sub electric models components and othes parameters
                obj.modelParameters_.electric = [];
            end
            
            obj.model_.thermal = [];
        end
    end
    
        %% Gateway methods
    % Ootee Gateway Methods
    methods ( Hidden = true, Access = {?Comp3d.Component,?SimulationSolver.SimulationSolverOotee} )
        data = ooteeGetSimulationData(obj)
    end
    
    % Saber Gateway Methods
    methods ( Hidden = true, Access = {?Comp3d.Component,?SimulationSolver.SimulationSolverSaber} )
        data = saberGetSimulationData(obj)
    end
   
    %% Output Data Methods
    methods
        function computeOutputData(obj)
            if ~isempty( obj.copy_), obj.outputData_ = obj.copy_.outputData; return; end
            
            if ~isempty( obj.excitationsElectricAnalytic_ )
                % generate and set excitations => call obj.setExcitations( electricAnalytic.excitations)
                obj.excitationsElectricAnalytic_.generateExcitations;
            end

            if obj.outputData_.recompute == true || ~isequal( obj.excitationsCache_, obj.excitations_.electric )
                        obj.updateOutputData;
                        obj.excitationsCache_ = obj.excitations_.electric;
                        obj.outputData_.recompute = false;
            end
        end
        function value = computeTotalValue(obj, listVariables, weights)
            if nargin < 3
                weights = ones(size(listVariables));
            end
            value = obj.nComponents * sum( weights .* cellfun( @obj.computeTotalValueVariable, listVariables) );
        end
    end
    methods ( Access = protected )
        function updateOutputData(obj)
            switch obj.level_
                case 1
                    obj.computeElectricOutputDataLv1();
                    obj.computeThermalOutputDataLv1();
                case 2
                    obj.computeElectricOutputDataLv2();
                    obj.computeThermalOutputDataLv2();
                otherwise
                    error('Level not available.')
            end
        end
        function value = computeTotalValueVariable(obj, variable)
            switch variable
                case 'mass'
                    value = obj.outputData_.geometric.weight;
                case 'losses'
                    value = obj.outputData_.thermal.losses;
                case 'cost'
                    value = obj.outputData_.cost.total;
                case 'volume'
                    value = obj.outputData_.geometric.manufacturingVolume;
            end
        end
    end
    methods ( Abstract, Access = protected )
        computeElectricOutputDataLv1(obj)
        computeElectricOutputDataLv2(obj)
        computeThermalOutputDataLv1(obj)
        computeThermalOutputDataLv2(obj)
    end
    
    %% Display Methods
    methods
        function displayInformation(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            
            fprintf(fid,'\n');
            fprintf(fid,'%s\n','====================================================');
            fprintf(fid,'Information of %s [%s]\n', obj.name_, class(obj));
            try
                fprintf(fid,'%s\n','----------------------------------------------------');
                fprintf(fid,'%s\n', 'Shape');
                formatSpecVar = '%30s: %s\n';
                textData = [fieldnames(obj.shape_), struct2cell(obj.shape_)]';
                idNumeric = cellfun(@(elt) isnumeric(elt),textData);
                textData{idNumeric} = num2str(textData{idNumeric});
                fprintf( fid, formatSpecVar, textData{:});
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
            try
                fprintf(fid,'%s\n', 'Dimensions');
                formatSpecVar = '%30s: %6.4g\n';
                textData = [fieldnames(obj.dimensions_), struct2cell(obj.dimensions_)]';
                fprintf( fid, formatSpecVar, textData{:});
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
            try
                fprintf(fid,'%s\n', 'Materials');
                formatSpecVar = '%30s: %s\n';
                textData = [fieldnames(obj.materials_), struct2cell( structfun( @(st) st.name, obj.materials_, 'UniformOutput', false))]';
                fprintf( fid, formatSpecVar, textData{:});
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
            try
                fprintf(fid,'%s\n', 'Geometric Data');
                formatSpecVar = '%30s: %6.4g %s\n';
                fprintf( fid, formatSpecVar, 'Manufacturing Volume', obj.outputData_.geometric.manufacturingVolume*1e3, 'l');
                fprintf( fid, formatSpecVar, 'Weight', obj.outputData_.geometric.weight, 'Kg');
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
            try
                fprintf(fid,'%s\n', 'Cost Data');
                currency = '$';
                formatSpecVar = '%30s: %s %6.2f\n';
                cost = rmfield(obj.outputData_.cost,'total');
                textData = [fieldnames(cost), repmat({currency},numel(fieldnames(cost)),1), struct2cell(cost)]';
                fprintf( fid, formatSpecVar, textData{:});
                fprintf( fid, formatSpecVar, 'Total', currency, obj.outputData_.cost.total);
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
            try
                fprintf(fid,'%s\n', 'Optimization Constraints');
                formatSpecVar = '%30s: %6.4g\n';
                constraint = obj.constraints;
                notEmpty = structfun(@(x) ~isempty(x), constraint);
                fieldNames = fieldnames(constraint);
                fieldValues = struct2cell(constraint);
                textData = [fieldNames(notEmpty), fieldValues(notEmpty)]';
                fprintf( fid, formatSpecVar, textData{:});
                fprintf(fid,'%s\n','----------------------------------------------------');
            end  
            
        end
        
        function displayConstraints(obj,option,fid)
            if nargin == 1
               option = 'all'; 
               fid = 1;
            elseif nargin == 2
               fid = 1;
            end
            
            fprintf(fid,'%s\n','====================================================');
            fprintf(fid,'Constraints of %s [%s]\n', obj.name_, class(obj));
             fprintf(fid,'%s\n','----------------------------------------------------');
            fprintf(fid,'%26s %2s %11s \n','VALUE','|','CONSTRAINT');
             fprintf(fid,'%s\n','----------------------------------------------------');
            arrayfun(@(inputArray) inputArray.displayConstraint(option,fid),obj.constraintsObjects_,'UniformOutput',false);
            fprintf(fid,'%s\n','====================================================');
            
        end
        
    end
    
    %% Stored Data Methods
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        function storeCurrentData(obj)
            obj.storedData_.store;
        end
        function resetStoredData(obj)
            obj.storedData_.resetData;
        end
    end
    
    %% Dependent properties
    methods
        % get
        function val = get.materials(obj)
            val = obj.materials_;
        end
        function val = get.materialsOptions(obj)
            val = structfun(@MaterialList, obj.materialsType_, 'UniformOutput', false);
        end
        function val = get.dimensions(obj)
            val = obj.dimensions_;
        end
        function val = get.shape(obj)
            val = obj.shape_;
        end
        function val = get.shapeOptions(obj)
            val = obj.shapeOptions_;
        end
        function val = get.modelParameters(obj)
            obj.computeModelParameters;
            val = obj.modelParameters_;
        end
        function val = get.excitations(obj)
            val = obj.excitations_;
        end
        function val = get.excitationsElectricAnalytic(obj)
            val = obj.excitationsElectricAnalytic_;
        end
        function val = get.storedData(obj)
            val = obj.storedData_;
        end
        function val = get.storeDataFlag(obj)
            val = obj.storeDataFlag_;
        end
        % set
        function set.materials(obj, newMaterials)
            if obj.isNewMaterials( newMaterials)
                obj.updateGeometry;
            end
        end
        function set.dimensions(obj, newDimensions)
            if obj.isNewDimensions( newDimensions)
                obj.updateGeometry;
            end
        end
        function set.shape(obj, newShape)
            if obj.isNewShape( newShape)
                obj.updateGeometry;
            end
        end
        function set.excitations(obj, newExcitations)
            if obj.isNewExcitations( newExcitations)
                obj.outputData_.recompute = true;
            end
        end
        function set.excitationsElectricAnalytic(obj, val)
            obj.excitationsElectricAnalytic_ = val;
            obj.excitationsElectricAnalytic_.setComp3d(obj);
            obj.outputData_.recompute = true;
        end
        function set.storeDataFlag(obj, val)
            if ~islogical(val) && ~isnumeric(val)
                warning('Comp3d.Element: storedData value shall be true or false.')
                return;
            end
            
            obj.storeDataFlag_ = val;
            if ~obj.storeDataFlag_
                obj.storedData_ = StoredData.Facture.makeNull;
                return;
            end

            if isa( obj.storedData_, 'StoredData.StoredDataNull')
                obj.storedData_ = StoredData.Facture.make(obj);
            end
        end
    end
    methods ( Access = protected )
        function flag = isNewMaterials(obj, newMaterials)
            newMaterials = setNewStructure( obj.materials_, newMaterials);
            
            % update materials with material manager
            fieldNames = fieldnames( obj.materialsType_);
            newMaterialsValues = cellfun(@(name) MaterialManager( obj.materialsType_.(name), newMaterials.(name)), fieldNames, 'UniformOutput', false);
            newMaterials = cell2struct( newMaterialsValues, fieldNames);
            
            if isempty( obj.dimensions_)
                flag = false;
            else
                flag = ~isequal( obj.materials_, newMaterials);
            end
            
            obj.materials_ = newMaterials;
        end
        function flag = isNewDimensions(obj, newDimensions)
            if isempty( obj.dimensions_)
                obj.dimensions_ = newDimensions;
                flag = true;
                return;
            end
            
            % merge with dimensions
            newDimensions = setNewStructure( obj.dimensions_, newDimensions);
            if numel(fieldnames(obj.dimensions_)) ~= numel(fieldnames(newDimensions))
                error('Comp3d.Element: Unexpected field found in dimensions structure.')
            end
            
            if ~isequal( obj.dimensions_, newDimensions)                
                % We calculate the homothetic, limit between the
                % bounds the new dimensions and set the dimensions
                obj.freedomDegrees_.testDimensions( newDimensions);
%                 obj.dimensions_ = dimensionsBounded;
                flag = true;
            else
                flag = false;
            end
        end
        function flag = isNewShape(obj, newShape)
            newShape = setNewStructure( obj.shape_, newShape);
            
            % when new shape is numeric...
            numericIndex = structfun(@isnumeric, newShape);
            if any(numericIndex)
                fieldNames = fieldnames(newShape);
                fieldNames = fieldNames(numericIndex);
                % get shapeOptions values for numeric shape values
                fieldValues = cellfun( @(field) obj.shapeOptions_.(field){newShape.(field)}, fieldNames, 'UniformOutput', false);
                
                % build new struct with numeric fields
                newShapeNum = cell2struct( fieldValues, fieldNames);
                % merge newShape with shape
                newShape = setNewStructure( newShape, newShapeNum);
            end
            
            if isempty( obj.dimensions_)
                flag = false;
            else
                flag = ~isequal( obj.shape_, newShape);
            end
            
            obj.shape_ = newShape;
        end
        function flag = isNewExcitations(obj, newExcitations)
            fieldNames = fieldnames( obj.excitations_);
            fieldValues = cellfun(@(name) setNewStructure( obj.excitations_.(name), newExcitations.(name)), fieldNames, 'UniformOutput', false);
                
            newExcitations = setNewStructure( newExcitations, cell2struct( fieldValues, fieldNames));
            
            flag = ~isequal( obj.excitations_, newExcitations);
            obj.excitations_ = newExcitations;
        end
        function updateGeometry(obj)
            obj.computeGeometry();
            obj.modelParameters_.recompute = true;
            obj.outputData_.recompute = true;
        end
        
    end
    
end


classdef Composite < Comp3d.Component
    % Comp3d.Composite manages a list called comp3dList of Comp3d.Component
    %
    % Composite methods:
    %  addComp3d( component )        - to add a component to this composite
    %  removeComp3d( component )     - to remove a component from this composite
    %  changeComp3d( component )     - to repalce a component (with the same name) in this composite
    %  clearComp3dList               - to remove all components from this composite
    %
    % Composite properties:
    %  comp3dList    - list of Comp3d.Component
    %
    % Example :
    % myComp = Comp3d.Composite('name',<name>);
    %
    %   See also Comp3d.Component
    %
    
    properties (Access = protected )
        comp3dList_
        
        x0cell_
        lBcell_
        uBcell_
        
        x0Vec_
        lBVec_
        uBVec_
    end
    
    properties (Dependent = true)
        comp3dList       % list of Component3d
    end
    
     %% Constructor
    methods
        function obj = Composite(varargin)
            obj@Comp3d.Component(varargin{:});
            obj.comp3dList_ = cell(1,0);
        end
    end
    
    %% Comp3dList ....  add remove change
    % clearComp3dList
    methods
        function addComp3d(obj, component, num)
            % addComp3d adds component to comp3dList
            %
            % arguments
            %   component       Comp3d.Component or list of. Each component can be added just once.
            %   num             number of equal components (optional, default = 1).
            %
            % return values
            %   void
            %
            
            if nargin < 2
                error('Comp3d.Composite: Missing arguments.');
            else
                if nargin < 3
                    num = 1;
                end
                
                if iscell(component)
                    cellfun( obj.addComp3d, component);
                else
                    if isa( component,'Comp3d.Component')
                        % we define the parent of the component3d.
                        component.comp3dParent = obj;
                        component.nComponents = num;
                        obj.comp3dList_{end+1} = component;
                        if isempty(component.copy_)
                            obj.freedomDegrees_.attachFreedomDegrees(component.freedomDegrees);
                            % We add the constraints objects
                            for k = 1:numel(component.constraintsObjects_)
                                obj.addConstraint(component.constraintsObjects_(k));
                            end
                        end
                    else
                        error('Comp3d.Composite: component superclass type should be Comp3d.Component.');
                    end
                end
            end
        end
        function removeComp3d(obj, component )
            % removeComp3d removes component from comp3dList
            %
            % arguments
            %   component       Comp3d.Component or list of.
            %
            % return values
            %   void
            %
            
            % we remove also its comp3dParent association
            if iscell(component)
                cellfun( obj.removeComp3d, component);
            else
                j = cellfun(@(x) x == component, obj.comp3dList_);
                if sum(j) == 1
                    obj.comp3dList_{j}.comp3dParent_ = [];

                    obj.comp3dList_ = obj.comp3dList_(~j);
%                     obj.updateFreedomDegreeArrayForOptim;
                    obj.freedomDegrees_.detachFreedomDegrees(component.freedomDegrees);
                    
                    % We delete the contraints
                    constraintsList = component.constraintsObjects_;
                    for k = 1:numel(constraintsList)
                       obj.removeConstraint(constraintsList(k)); 
                    end
                else
                    % if not found...
                    warning('Composite: This component is not in this composite.')
                end
            end
        end
        function changeComp3d(obj, replaceThisComponent, withThisComponent)
            % changeComp3d replaces the Comp3d.Component in comp3dList with the same name
            %
            % arguments
            %   component       Comp3d.Component or list of.
            %
            % return values
            %   void
            %
            
            j = cellfun(@(element) element == replaceThisComponent, obj.comp3dList_);

            if sum(j) == 1
                withThisComponent.nComponents = replaceThisComponent.nComponents;
                
                obj.comp3dList_{j} = withThisComponent;
                
                obj.freedomDegrees_.detachFreedomDegrees(replaceThisComponent.freedomDegrees);
                obj.freedomDegrees_.attachFreedomDegrees(withThisComponent.freedomDegrees);
                
                % We delete the contraints
                constraintsList = withThisComponent.constraintsObjects_;
                for k = 1:numel(constraintsList)
                    obj.removeConstraint(constraintsList(k));
                end
                
                % We add the constraints
                for k = 1:numel(withThisComponent.constraintsObjects_)
                    obj.addConstraint(withThisComponent.constraintsObjects_(k));
                end

                if ~isempty( componentToRemove.electricModelPort )
                    replaceThisComponent.resetModels;
                    withThisComponent.resetModels;
                    withThisComponent.electricModelPort = componentToRemove.electricModelPort;
                    withThisComponent.buildElectricModel;
                end
            else
                warning('Composite: This component is not in this composite.')
            end
        end
        function comp3dList = clearComp3dList(obj)
            % clearComp3dList removes all components from comp3dList
            %
            % arguments
            %   void
            %
            % return values
            %   a list with all Comp3d.Components in comp3dList
            %
            
            for k = 1:numel(obj.comp3dList_)
                obj.comp3dList_{k}.comp3dParent = [];
            end
            
            comp3dList = obj.comp3dList_;
            obj.comp3dList_ = cell(1,0);
            
            obj.updateFreedomDegreeArrayForOptim;
        end
        function val = get.comp3dList(obj)
            val = obj.comp3dList_;
        end
    end
    
    
    %% Constraint .... add remove 
    methods
        function addConstraint(obj,constraint)
            j = arrayfun(@(x) x == constraint, obj.constraintsObjects_);
            if ~(sum(j)==1)
                obj.constraintsObjects_ = [obj.constraintsObjects_,constraint];
            else
                error('Constraint object has been already added');
            end
        end
        
        function removeConstraint(obj,constraint)
            j = arrayfun(@(x) x == constraint, obj.constraintsObjects_);
            if (sum(j)==1)
                obj.constraintsObjects_ = obj.constraintsObjects_(~j);
            else
                error('Constraint object has been already added');
            end
        end
        
    end
    
   
    %% Optimization functions
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        
        
        function setFreedomDegrees(obj,x)
              obj.freedomDegrees_.setXVector(x);
        end

    end
    
    
    %% Model Parameters Methods
    methods
        function updateObj(obj,varargin)
            obj.updateObj@Comp3d.Component(varargin{:});
            cellfun(@(element) element.updateObj(varargin{:}), obj.comp3dList_);
        end
        function computeModelParameters(obj)
            % We calculate for each element its parameters
            cellfun(@(element) element.computeModelParameters, obj.comp3dList_);
            
            % Now we set the sum of the properties for the composite for
            % the mass, volume and cost
            obj.outputData_.geometric.weight = obj.computeTotalValue({'mass'},1);
            obj.outputData_.geometric.manufacturingVolume = obj.computeTotalValue({'volume'},1);
            obj.outputData_.cost.total = obj.computeTotalValue({'cost'},1);
        end
    end
        
    methods (Access = {?OptimProblem.Optimizer,?Comp3d.Composite})
        function updateModelParameters(obj)
            cellfun(@(x) x.updateModelParameters,obj.comp3dList,'UniformOutput',true);
        end
    end
    
    %% Model methods
    methods
        function buildElectricModel(obj)
            % Verifies if the modelParameters are already computed
            obj.computeModelParameters;
             cellfun(@(element) element.buildElectricModel, obj.comp3dList_);
            SimulationSolver.Facture.make.buildElectricModel(obj);
        end
        function data = getSimulationData(obj)
            data = cellfun(@(element) element.getSimulationData, obj.comp3dList_, 'UniformOutput', false);
        end
        function resetModels(obj)
            % This function deletes the circuits of all the objects in order to gain memory space
            cellfun(@(element) element.resetModels, obj.comp3dList_);
        end
    end
    
    %% Output Data Methods
    methods
        function setExcitations(obj,data)
            cellfun(@(element,dt) element.setExcitations(dt), obj.comp3dList_, data);
        end
        function computeOutputData(obj)
            cellfun(@(element) element.computeOutputData, obj.comp3dList_);
            
            % We sum all the losses of the component
            obj.outputData_.thermal.losses = obj.computeTotalValue({'losses'},1);
        
        end
        function value = computeTotalValue(obj, listVariables, weights)
            value = obj.nComponents * sum( cellfun(@(element) element.computeTotalValue( listVariables, weights), obj.comp3dList_));
        end
    end
    
    %% Stored Data Methods
    methods ( Access = { ?Comp3d.Component, ?Comp3d.FreedomDegrees})
        function storeCurrentData(obj)
            cellfun( @(element) element.storeCurrentData, obj.comp3dList);
        end
        function resetStoredData(obj)
            cellfun( @(element) element.resetStoredData, obj.comp3dList);
        end
    end
    
    %%
    methods  (Access = protected)
        function outputFunction(obj)
            cellfun( @(element) element.outputFunction, obj.comp3dList);
            obj.outputFunction@Comp3d.Component;
        end
    end
    
    %% Write methods
    methods
        function displayInputs(obj,fid)
            warning('displayInputs method will be replaced in future versions. Use method displayInformation instead');
                     
            if nargin == 1
                fid = 1;
            end
            cellfun( @(element) element.displayInputs(fid), obj.comp3dList);
        end
        function displayOutputs(obj,fid)
            warning('displayOutputs method will be replaced in future versions. Use method displayInformation instead');
            if nargin == 1
                fid = 1;
            end
            cellfun( @(element) element.displayOutputs(fid), obj.comp3dList);
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
            for k = 1:numel(obj.constraintsObjects_)
                obj.constraintsObjects_(k).displayConstraintObject(option,fid);
            end
            fprintf(fid,'%s\n','====================================================');
            
        end
        function displayInformation(obj,fid)
           if nargin == 1
               fid = 1;
           end
            cellfun( @(element) element.displayInformation(fid),obj.comp3dList);
        end
        
        function writeFile(obj,fid)
            if nargin == 1
                fid = 1;
            end
            cellfun( @(element) element.writeComponent(fid), obj.comp3dList);
        end
    end
end


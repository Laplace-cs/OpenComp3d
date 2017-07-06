classdef CompositeElement < Comp3d.Composite
    % Comp3d.CompositeElement manages a list of Comp3d.Component that composes an element.
    %
    %   See also Comp3d.Composite, Comp3d.Element
    %
    
    properties (Access = protected )
        freedomDegrees_ = [];
        dimensions_ = [];
    end
    
    properties (Dependent = true)
        freedomDegrees
        dimensions
        dimensionsList
    end
    
     %% Constructor
    methods
        function obj = CompositeElement(varargin)
            obj@Comp3d.Composite(varargin{:});
        end
    end
    
    %% Optimization functions
    methods
%     methods (Access = {?Comp3d.Composite,?OptimProblem.Optimizer,?Software.BasicDisplay})
        function setFreedomDegrees(obj,x)
            obj.freedomDegrees_.setDimensionsStatusFree(x');
        end
        
        function [x0, lB, uB] = getFreedomDegreeArrayForOptim(obj)
            [x0, lB, uB] = obj.getFreedomDegreeArrayForOptim@Comp3d.Composite;
            
            obj.dimensionsList = cellfun( @(comp3d) comp3d.dimensions, obj.comp3dList_, 'UniformOutput', false);
        end
        
        function set.dimensions(obj, val)
            dimensionsValue = obj.freedomDegrees_.testDimensions( val);
            
            fieldNamesList = cellfun( @fieldnames, obj.dimensionsList, 'UniformOutput', false);
            valueList = mat2cell( struct2cell( dimensionsValue)', 1, cellfun( @length, fieldNamesList));
            
            dims = cellfun( @(val, name) cell2struct( val, name), valueList, fieldNamesList, 'UniformOutput', false);
            cellfun( @(comp3d, val) setfield( comp3d, 'dimensions', val), obj.comp3dList_, dims);
        end
        
        function val = get.freedomDegrees(obj)
            val = obj.freedomDegrees_;
        end
        function val = get.dimensions(obj)
            dimList =  obj.dimensionsList;
            fieldNames_ = cellfun( @fieldnames, dimList, 'UniformOutput', false);
            fieldValues_ = cellfun( @struct2cell, dimList, 'UniformOutput', false);
            val = cell2struct( vertcat(fieldValues_{:}), vertcat(fieldNames_{:}));
        end
        function val = get.dimensionsList(obj)
            val = cellfun( @(comp3d) comp3d.dimensions, obj.comp3dList_, 'UniformOutput', false);
        end

    end
    
    %% gateway methods
    % buildElectricModel
    % getSimulationData
    methods
        function buildElectricModel(obj)
            obj.buildElectricModel@Comp3d.Composite;
            
            
        end
    end
    
end


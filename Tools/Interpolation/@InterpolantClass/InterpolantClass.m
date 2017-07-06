classdef InterpolantClass < handle
    %INTERPOLANTCLASS is the mother class for all the classes that will use
    % databases and finite element methods to get more datapoints
    %   Detailed explanation goes here
    
    properties (Access = protected)
        dataBase_                   % property containing all the data
        interpoler_                 % object containing the interpoler class
        
        comp3dElement_
        fieldNames_
    end
    
    %%
    methods
        function obj = InterpolantClass( comp3dElement, dataBase, varargin)
            obj.comp3dElement_ = comp3dElement;
            obj.dataBase_ = dataBase;
            
            variableLenght = obj.getVariableLenght;
            
            % extract just variables with more than 1 value
            gridNames =  { obj.dataBase_.variableList(variableLenght > 1).name};
            gridPoints = { obj.dataBase_.variableList(variableLenght > 1).value};
            gridValues = obj.dataBase_.outputList.value;
            
            obj.extractCom3dElementFieldNames( gridNames);
            obj.createInterpolerObject( gridPoints, gridValues, varargin{:})
        end
    end
    %
    methods ( Access = protected, Abstract )
        variableLenght = getVariableLenght(obj)
        createInterpolerObject(obj, gridPoints, gridValues, varargin)
    end
    %
    methods ( Abstract )
        outputValues = evaluate(obj, value)
    end
    
    %%
    methods ( Access = protected )
        function extractCom3dElementFieldNames(obj, gridNames)
            % break field access names to use getfield: 'a.b.c' => {'a' 'b' 'c'}
            fieldNames = cellfun(@(name) textscan(name,'%s','Delimiter','.'), gridNames);
            % find which fieldNames are comp3dElement_ propertie
            % verifies if 'c' isfield of comp3dElement_.a.b
            %
            % separates initial fields and the last one
            initialField = cellfun(@(field) field(1:end-1), fieldNames, 'UniformOutput' ,false);
            lastField = cellfun(@(field) field(end), fieldNames, 'UniformOutput' ,false);
            % take initial field value
            initialFieldValue = cellfun( @(field) getfield( obj.comp3dElement_, field{:}), initialField, 'UniformOutput', false);
            % flag true if lastField is field of initialFieldValue
            isElementField = cellfun( @isfield, initialFieldValue, lastField);
            % save field names that are field of comp3dElement_
            obj.fieldNames_ = fieldNames(isElementField);
        end
        function inputValues = buildInputValues(obj, value)
            propertiesValues = cellfun( @(field) getfield( obj.comp3dElement_, field{:}), obj.fieldNames_);
            inputValues = cellfun(@(val) [ val propertiesValues], num2cell(value), 'UniformOutput', false);
        end
    end
end


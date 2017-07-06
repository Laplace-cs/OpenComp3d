classdef InterpolantScattered < InterpolantClass
    % InterpolantScattered 
    %
    %
    
    
    %%
    methods
        function obj = InterpolantScattered( comp3dElement, dataBase, varargin)
            obj@InterpolantClass( comp3dElement, dataBase, varargin{:});
        end
    end
    
    %%
    methods ( Access = protected )
        function variableLenght = getVariableLenght(obj)
            variableLenght = cellfun( @(val) length(unique(val)), { obj.dataBase_.variableList.value});
        end
        function createInterpolerObject(obj, gridPoints, gridValues, varargin)
            if isempty( varargin)
                varargin = [];
            end
            obj.interpoler_ = IDWinterpolation( [gridPoints{:}], gridValues, varargin{:});
        end
    end
    
    %%
    methods
        function outputValues = evaluate(obj, value)
            inputValues = obj.buildInputValues( value);
            outputValues = cellfun(@(val) obj.interpoler_.evaluate(val), inputValues);
        end
    end
    
    %%
    methods
        function addValue(obj, value)
            % break field access names to use getfield: 'a.b.c' => {'a' 'b' 'c'}
            fieldNames = cellfun(@(name) textscan(name,'%s','Delimiter','.'), obj.dataBase_.variableList.name);
            propValues = cellfun( @(field) getfield( obj.comp3dElement_, field{:}), fieldNames);
            newPropValues = cellfun(@(v,n) [v;n], {obj.dataBase_.variableList.value}, num2cell(propValues), 'UniformOutput', false);

            [obj.dataBase_.variableList.value] = newPropValues{:};
            obj.dataBase_.outputList.value = [ obj.dataBase_.outputList.value; value];
        end
    end    
end
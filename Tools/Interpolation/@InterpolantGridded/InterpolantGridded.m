classdef InterpolantGridded < InterpolantClass
    % InterpolantGridded 
    %
    %
    
    
    %%
    methods
        function obj = InterpolantGridded( comp3dElement, dataBase, varargin)
            obj@InterpolantClass( comp3dElement, dataBase, varargin{:});
        end
    end
    
    %%
    methods ( Access = protected )
        function variableLenght = getVariableLenght(obj)
            variableLenght = cellfun( @length, { obj.dataBase_.variableList.value});
        end
        function createInterpolerObject(obj, gridPoints, gridValues, varargin)
            if isempty( varargin)
%                 varargin = {'spline', 'spline'};
                varargin = {'linear', 'linear'};
            end
            obj.interpoler_ = griddedInterpolant( gridPoints, gridValues, varargin{:});
        end
    end
    
    %%
    methods
        function outputValues = evaluate(obj, value)
            inputValues = obj.buildInputValues( value);
            outputValues = cellfun(@(val) obj.interpoler_(val), inputValues);
        end
    end
end
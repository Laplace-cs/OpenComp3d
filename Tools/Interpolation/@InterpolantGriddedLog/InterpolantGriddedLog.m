classdef InterpolantGriddedLog < InterpolantGridded
    % InterpolantGriddedLog 
    %
    %
    
    
    %%
    methods
        function obj = InterpolantGriddedLog( comp3dElement, dataBase, varargin)
            obj@InterpolantGridded( comp3dElement, dataBase, varargin{:});
        end
    end
    
    %%
    methods ( Access = protected )
        function createInterpolerObject(obj, gridPoints, gridValues, varargin)
            gridPoints = cellfun(@(val) log10(val), gridPoints, 'UniformOutput', false);
            obj.createInterpolerObject@InterpolantGridded( gridPoints, gridValues, varargin{:});
        end
    end
    
    %%
    methods
        function outputValues = evaluate(obj, value)
            inputValues = obj.buildInputValues( value);
            inputValues = cellfun(@(val) log10(val), inputValues, 'UniformOutput', false);
            outputValues = cellfun(@(val) obj.interpoler_(val), inputValues);
        end
    end
end
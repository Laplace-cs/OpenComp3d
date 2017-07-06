classdef StoredDataNull < StoredData.Interface
    % StoredDataNull is a null storedData class
    %
    %   See also StoredData.Interface, StoredData.Facture
    %
    
    methods
        function obj = StoredDataNull()
            obj = obj@StoredData.Interface([]);
        end
    end
    
    methods
        function resetData(obj)
        end
        function store(obj)
        end
    end
    
    methods
        function plotData(obj, varargin)
        end
        function val = getFields(obj, varargin)
            val = [];
        end
        function val = getFieldsOf(obj, varargin)
            val = [];
        end
        function val = getData(obj, varargin)
            val = [];
        end
        function show(obj)
        end
    end
end

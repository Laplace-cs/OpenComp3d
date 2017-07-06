classdef StoredDataComp3dElement < StoredData.Interface
    % StoredDataComp3dElement is a class how stores data from Comp3d.Element objects.
    %
    % StoredDataComp3dElement inherits all methods of StoredData.Interface
    %
    %   See also StoredData.Interface, StoredData.Facture
    %
    
    properties ( Access = protected )
        dimensions_
        modelParameters_
        outputData_
    end
    
    properties ( Dependent )
        dimensions
        modelParameters
        outputData
    end
    
    methods
        function val = get.dimensions(obj)
            val = obj.dimensions_;
        end
        function val = get.modelParameters(obj)
            val = obj.modelParameters_;
        end
        function val = get.outputData(obj)
            val = obj.outputData_;
        end
    end
    
    methods
        function obj = StoredDataComp3dElement(objArg)
            obj = obj@StoredData.Interface(objArg);
        end
    end
    
    methods
        function resetData(obj)
            obj.dimensions_ = [];
            obj.modelParameters_ = [];
            obj.outputData_ = [];
        end
        function store(obj)
            obj.dimensions_ =        [ obj.dimensions_,        obj.objToSave.dimensions ];
            obj.modelParameters_ =   [ obj.modelParameters_,   obj.convert2struct(obj.objToSave.modelParameters) ];
            obj.outputData_ =        [ obj.outputData_,        obj.objToSave.outputData ];
        end
    end
end

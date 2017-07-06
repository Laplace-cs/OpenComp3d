classdef Facture < handle
% This is a facture of StoredData objects according with Comp3d type.
%
% StoredData.Facture methods:
%   makeNull    - make a StoredDataNull object (singleton)
%       ex: Facture.makeNull( element )
%   make        - make a StoredData compatible with element comp3d type given.
%       ex: storedDataObj = Facture.make( element )
%       ex: storedDataObj = Facture.make() is the same like makeNull

%
%   See also StoredData.Interface, StoredData.StoredDataComp3dElement
%

    methods
        function obj = Facture(varargin)
        end
    end
    
    methods (Static)
        function storedDataObj = make( element, varargin)
            % make a StoredData for Comp3d element type object
            % storedDataObj = make( element, varargin)
            %
            if nargin < 1
                storedDataObj = StoredData.StoredDataNull();
                return;
            end
            
            if isa( element, 'Comp3d.Element')
                storedDataObj = StoredData.StoredDataComp3dElement(element);
            else
                error('StoredData.Facture: Element type not recognized.')
            end
        end
        
        function storedDataObj = makeNull()
            % make a StoredDataNull object (singleton)
            % storedDataObj = makeNull()
            %
            persistent nullObj;
            if isempty( nullObj)
                nullObj = StoredData.StoredDataNull();
            end
            storedDataObj = nullObj;
        end
    end
end
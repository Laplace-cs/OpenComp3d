classdef Interface < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties ( Access = protected )
        comp3d_
        excitations
        nSample_ = 1000;
    end
    
    properties (Dependent)
        nSample
    end
    
    methods
        function obj = Interface(varargin)
        end
    end
    
    methods
        function setComp3d(obj, comp3d)
            obj.comp3d_ = comp3d;
        end
        
        function generateExcitations(obj)
            obj.update;
            if ~isempty(obj.comp3d_)
                obj.comp3d_.setExcitations(obj.excitations);
            end
        end
    end
    
    methods (Abstract)
        update(obj)
    end
    
    methods
        function val = get.nSample(obj)
            val = obj.nSample_;
        end
        function set.nSample(obj, val)
            if val > 0
                obj.nSample_ = round(val);
                obj.generateExcitations;
            else
                warning('InductorExcitation: Invalid value');
            end
        end
    end
end
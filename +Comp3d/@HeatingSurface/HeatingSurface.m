classdef HeatingSurface < Comp3d.Element
    %HEATINGSURFACE is a class that represents a surface evacuating a
    %certain heat flow and having determined dimensions
    %
    %HEATINGSURFACE inputs:
    % - length          length of the surface (m)
    % - width           width of the surface (m)
    % - tMax            maximal allowed temperature (°C)
    % - power           heat flow to evacuate (W)
    %
    % See <a href="matlab:help Comp3d.Element">Comp3d.Element</a> for other properties / methods
    
    % Constructor
    methods
        
        function obj = HeatingSurface(varargin)
            obj@Comp3d.Element(varargin{:});
            obj.setDefaultParameters();
            obj.parse(varargin{:});
        end
    end
    
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj)
            
            obj.outputData_.thermal.losses = 100;
            
            freedomDegrees = [ ...
                        {'width'},       {'meter'},  1e-3,	0.1,  0.5,   	'setToX0',     {[]}; ... % width (m)
                        {'length'},      {'meter'},    1e-3,  0.1, 0.5,    'setToX0',     {[]}; ... % length (m)
                        {'height'},      {'meter'},    1e-6,  1e-6, 1e-6,    'setToX0',     {[]}; ... % height (m)
                        ];
            obj.freedomDegrees_.createFreedomDegreesFromTable( obj, freedomDegrees);
            obj.outputData_.thermal.insideTemperature = [];
            
            % Constraints
            obj.constraints_.tMax = 100;
            constraintsTable = [ ...
                {'Tmax'},       {'°C'},  {'obj.outputData.thermal.insideTemperature'},  {'<'},  {'obj.constraints.tMax'} ; ... 
                ];
          
            obj.constraintsObjects_ = [obj.constraintsObjects_,...
                OptimProblem.createConstraintArray(obj,constraintsTable)];
        end
        function parse(obj,varargin)
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter( 'length', obj.dimensions_.length, @(x) x>0);
            p.addParameter( 'width', obj.dimensions_.width, @isnumeric);
            p.addParameter( 'tMax', obj.constraints_.tMax, @(x) x>0);
            p.addParameter( 'power', obj.outputData_.thermal.losses, @(x) x>0);
            p.parse(varargin{:});
            
            obj.dimensions.length = p.Results.length;
            obj.dimensions.width = p.Results.width;
            obj.constraints_.tMax = p.Results.tMax;
            obj.outputData_.thermal.losses = p.Results.power;
        end
    end
    
    %% Setting methods
    methods 
        function setExcitations(obj)
        end
    end
    
    %% Compute data
    methods (Access = protected)
        function computeThermalOutputDataLv2(obj)
            obj.outputData_.thermal.deltaTemperature = 0;
        end
        function computeThermalOutputDataLv1(obj)
            obj.computeThermalOutputDataLv2;
        end
    end
    
    %% DisplayInformation
    methods
        function displayInformation(obj,fid)
             if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
             
             if ~isempty(obj.outputData_.thermal.insideTemperature)
                fprintf(fid,'%s\n', 'Output Data');
                fprintf(fid,'%30s: %6.4g %s\n', 'Losses', obj.outputData_.thermal.losses, 'W');
                fprintf(fid,'%30s: %6.4g %s\n', 'Inside Temperature', obj.outputData_.thermal.insideTemperature, '°C');
             else
                fprintf(fid,'%s\n','Output data (losses, temperature...) not calculated yet');
            end

            fprintf(fid,'%s\n','====================================================');
        end
        
    end
    
    
    %% Specific setting methods
    methods (Access = {?Comp3d.HeatSink, ?Comp3d.HeatingSurface})
        
        function setBaseTemperature(obj, val)
           obj.outputData_.thermal.insideTemperature = val;
        end
        
    end
    
    %% Drawing methods
    methods
        function drawComponent(obj,offset,fid)
            if nargin < 2
                figure
                xlabel('x (m)');
                ylabel('y (m)'); 
                zlabel('z (m)');
                offset = [0,0,0];
            end
            offsetX = offset(1);
            offsetY = offset(2);
            offsetZ = offset(3);
            
            % Color and offset vector
            colorVector = [1,0,0];
            offsetVector = [offsetX, offsetY, offsetZ];
            
            % Drawing
             draw_parallelepiped([obj.dimensions.width,obj.dimensions.length,obj.dimensions.height],...
                                offsetVector,colorVector);
       
        end
        
    end
    
    %% Compute parameters (not used)
    methods (Access = protected)
        function computeGeometry(obj)
        end
        function computeThermalModelParametersLv1(obj)
        end
        function computeThermalModelParametersLv2(obj)
        end
        function computeElectricModelParametersLv2(obj)
        end
        function computeElectricModelParametersLv1(obj)
        end
        function computeElectricOutputDataLv1(obj)
        end
        function computeElectricOutputDataLv2(obj)
        end
    end
    
end


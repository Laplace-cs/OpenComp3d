classdef HeatSink < Comp3d.Composite
    % HeatSink is the class that represents any kind of heat sink
    %
    % HeatSink methods
    % addElement          - addition of an element to compose the heatsink
    % removeElement       - removal of an element from the heatsink
    %
    % See <a href="matlab:help Comp3d.Composite">Comp3d.Composite</a> for other properties / methods
    
    properties (Dependent)
        finElement     % type of fins
        basePlate      % base plate element
        blowingElement % Property to add the blowing
        elementsToCool % Elements to cool
    end
    
    properties (Access = protected)
        finElement_
        basePlate_
        blowingElement_
        elementsToCool_
    end
    
    % Constructor method
    methods
        function obj = HeatSink(varargin)
            obj = obj@Comp3d.Composite(varargin{:});
            obj.setDefaultParameters;
            obj.parse(varargin{:});
        end
    end
    
    %% Assistants Methods
    methods ( Access = private, Hidden = true )
        
        function setDefaultParameters(obj)
           % We setup the empty fields we are going to fill
           obj.basePlate_ = [];
           obj.finElement_ = [];
           obj.blowingElement_ = [];
           obj.elementsToCool_ = cell(1,0);
           
           % We setup the constraints
            obj.constraints_.exitTemperatureMax = [];
            obj.constraints_.pressureLossesMax = [];
            obj.constraints_.airSpeedBetweenFinsMax = [];
            obj.constraints_.rThMin = [];
            
            obj.outputData_.geometric.widthCoolingArea = 0;
            obj.outputData_.geometric.lengthCoolingArea = 0;
            constraintsTable = [ ...
                {'exitTemperature'},       {'°C'},  {'obj.outputData.thermal.exitTemperature'},  {'<'},  {'obj.constraints.exitTemperatureMax'} ; ...
                {'pressureLosses'},       {'Pa'},  {'obj.outputData.thermal.pressureLosses'},  {'<'},  {'obj.constraints.pressureLossesMax'} ; ... 
                {'airSpeedFins'},       {'m/s'},  {'obj.outputData.thermal.speedBetweenFins'},  {'<'},  {'obj.constraints.pressureLossesMax'} ; ... 
                 {'minimalWidth'},       {'m'},    {'obj.basePlate.dimensions.width'},  {'>'},  {'obj.outputData.geometric.widthCoolingArea'} ; ... 
                 {'minimalLength'},       {'m'},    {'obj.basePlate.dimensions.length'},  {'>'},  {'obj.outputData.geometric.lengthCoolingArea'} ; ... 
                 {'rThMin'},       {'°C/W'},    {'obj.model.thermal.rTh'},  {'<'},  {'obj.constraints.rThMin'} ; ... 
                ];
            obj.constraintsObjects_ = [obj.constraintsObjects_,...
                OptimProblem.createConstraintArray(obj,constraintsTable)];
        end  
        function parse(obj,varargin)
          
        end
    end
    
    %% Interfacing methods, with other elements
    methods 
        function addElement(obj,element)
            switch class(element)
                case 'Comp3d.BasePlate'
                    if ~isempty(obj.basePlate_)
                        obj.removeComp3d(obj.basePlate_)
                    end
                    obj.basePlate_ = element;
                    obj.addComp3d(obj.basePlate_);
                    obj.linkBasePlateAndFinsFreedomDegrees;
                case 'Comp3d.RectangularFins'
                    if ~isempty(obj.finElement_)
                        obj.removeComp3d(obj.finElement_)
                    end
                    obj.finElement_ = element;
                    obj.addComp3d(obj.finElement_);
                    obj.linkBasePlateAndFinsFreedomDegrees
                    obj.linkFinsAndFan;
                case 'Cooling.ForcedAir'
                    if isa(obj.blowingElement_,'Comp3d.Element')
                        obj.removeComp3d(obj.finElement_)
                    end
                    obj.blowingElement_ = element;
                 case 'Comp3d.FanDiscreteDC'
                    if isa(obj.blowingElement_,'Comp3d.Element')
                        obj.removeComp3d(obj.finElement_)
                    end
                    obj.blowingElement_ = element;
                    obj.addComp3d(obj.blowingElement_);
                    obj.linkFinsAndFan;
                case 'Comp3d.HeatingSurface'
                    obj.elementsToCool_{end+1} = element;
                    obj.addComp3d(element);
                    
                    obj.updateDimensionsToCool;
                otherwise
                    error('element not recognized');
            end
            
            % In case all the parameters have been defined we compute the
            % parameters
            if ~isempty(obj.basePlate_) && ~isempty(obj.finElement_)
               if ~isempty(obj.elementsToCool_) && ~isempty(obj.blowingElement_)
                    try 
                        obj.computeModelParameters;
                    catch
                    end
               end
            end
            
        end  
        function removeElement(obj,element)
           j = cellfun(@(elt) elt==element,obj.elementsToCool_);
           obj.elementsToCool_ = obj.elementsToCool_(~j);
           obj.removeComp3d(element);
           
           obj.updateDimensionsToCool;
        end
    end
    
    %% Display methods
    methods
        function displayInformation(obj,fid)
            
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            
            obj.displayInformation@Comp3d.Composite(fid);
            
            fprintf(fid,'%s\n','====================================================');
            fprintf(fid,'Information of %s [%s]\n', obj.name_, class(obj));
            fprintf(fid,'%s\n','----------------------------------------------------');
            fprintf(fid,'%s\n', 'Geometric Data');
            fprintf(fid,'%30s: %6.4g %s\n', 'Manufacturing Volume', obj.outputData_.geometric.manufacturingVolume*1e3, 'l');
            fprintf(fid,'%30s: %6.4g %s\n', 'Weight', obj.outputData_.geometric.weight, 'kg');
            fprintf(fid,'%s\n','----------------------------------------------------');
            fprintf(fid,'%s\n', 'Thermal Parameters');
            fprintf(fid,'%30s: %6.4g %s\n', 'Rth', obj.model_.thermal.rTh, '°C/W');
            fprintf(fid,'%s\n','====================================================');
            if ~isempty( obj.outputData_.thermal)
                fprintf(fid,'%s\n', 'Output Data');
                fprintf(fid,'%30s: %6.4g %s\n', 'Losses', obj.outputData_.thermal.losses, 'W');
                fprintf(fid,'%30s: %6.4g %s\n', 'Base Temperature', obj.outputData_.thermal.baseTemperature, '°C');
                % For forced convection
                if ~isa(obj.blowingElement_,'Cooling.NaturalAir')
                    fprintf(fid,'%30s: %6.4g %s\n', 'Exit Temperature', obj.outputData_.thermal.exitTemperature, '°C');
                    fprintf(fid,'%30s: %6.4g %s\n', 'Pressure losses', obj.outputData_.thermal.pressureLosses, 'Pa');
                end
                
            else
                fprintf(fid,'%s\n','Output data (losses, temperature...) not calculated yet or excitations not defined');
            end
            fprintf(fid,'%s\n','====================================================');
        end 
    end
    
    %% Drawing methods
    methods
        function drawComponent(obj,offset,varargin)
            if nargin < 2
                figure
                offset = [0,0,0];
            end
            offsetX = offset(1);
            offsetY = offset(2);
            offsetZ = offset(3);
            
            % Case the heatsink has a fan
            if isa(obj.blowingElement_,'Comp3d.FanDiscreteDC')
               obj.blowingElement_.drawComponent([offsetX,offsetY,offsetZ+obj.basePlate_.dimensions.height]);
               offsetY = offsetY + obj.blowingElement_.dimensions.thicknessFan + obj.blowingElement_.dimensions.lengthTube;
            end
            
             % Drawing of the surfaces
            % We determine the width extra at each side
            offsetYElt = (obj.basePlate.dimensions.length - ...
                obj.outputData_.geometric.lengthCoolingArea) / 2;
            offsetSurface = 0;
            for k = 1:numel(obj.elementsToCool_)
                offsetXElt = (obj.basePlate.dimensions.width - obj.elementsToCool_{k}.dimensions.width)/2;
                obj.elementsToCool_{k}.drawComponent([offsetX+offsetXElt,offsetY+offsetYElt,offsetZ],varargin);
                offsetYElt = offsetYElt + obj.elementsToCool_{k}.dimensions.length;
                offsetSurface = max(offsetSurface,obj.elementsToCool_{k}.dimensions.height);
            end
            
            
            % Drawing of the baseplate
            obj.basePlate_.drawComponent([offsetX,offsetY,offsetZ+offsetSurface],varargin);
            
            % Drawing of the fins
            offsetBP = obj.basePlate_.dimensions.height;
            obj.finElement_.drawComponent([offsetX,offsetY,offsetZ++offsetSurface+offsetBP],varargin);
            
            if nargin < 2
                xlabel('x (m)');
                ylabel('y (m)');
                zlabel('z (m)');
            end
        end
        function displayPressureLossesCurve(obj)
           h = figure();
           if isa(obj.blowingElement_,'Cooling.ForcedAir')
                speedAir =obj.finElement.modelParameters.thermal.airSpeedEntry;
           elseif isa(obj.blowingElement_,'Comp3d.FanDiscreteDC')
                obj.blowingElement_.displayPressureLossesCurve(h)
                hold on
                speedAir = obj.finElement.modelParameters.thermal.airSpeedEntry;
           else
                speedAir = 10;
            end
            
            speedVector = linspace(0,1.5*speedAir,50);
            volumetricFlowVector = speedVector * obj.finElement.outputData.geometric.crossSectionTotal;
            % We get the pressure losses vector from the heat sink
            [volumetricAirFlowHeatSink,pressureLossesHeatSink] = obj.finElement.calculationPressureLossesVector(volumetricFlowVector);
            
            plot(volumetricAirFlowHeatSink,pressureLossesHeatSink,'LineWidth',2);
            xlabel('Volumetric flow [m^3/s]');
            ylabel('Pressure Losses [Pa]');
            hold on
            if isa(obj.blowingElement_,'Comp3d.FanDiscreteDC')
                pressureLossesPoint = obj.finElement.calculationPressureLosses(speedAir);
                plot(speedAir*obj.finElement.outputData.geometric.crossSectionTotal,pressureLossesPoint,'*','LineWidth',2);
                legend({'Fan','Heat Sink','Operating Point'});
            elseif isa(obj.blowingElement_,'Cooling.ForcedAir')
                pressureLossesPoint = obj.finElement.calculationPressureLosses(speedAir);
                plot(speedAir*obj.finElement.outputData.geometric.crossSectionTotal,pressureLossesPoint,'*','LineWidth',2);
                legend({'Heat Sink','Operating Point'});

            else
                legend({'Heat Sink'});
            end
            hold off
        end
    end
    
    %% Computing methods
    methods 
        function computeModelParameters(obj)
            % First we update the dimensions to cool
            obj.updateDimensionsToCool;
            
            % Then we can calculate all the parameters in a restricted
            % order
            cellfun(@(elt)elt.computeModelParameters,obj.elementsToCool_);
            if ~isempty(obj.finElement_)
                obj.finElement_.computeModelParameters;
            end
            obj.basePlate_.computeModelParameters;
            
            % We launch the upper class method
            obj.computeModelParameters@Comp3d.Composite;
            
           % Specific to the heat sink
           if ~isempty(obj.finElement_)
              obj.model_.thermal.rTh = obj.finElement_.modelParameters.thermal.rTh +...
                                                 obj.basePlate_.modelParameters.thermal.rTh;
           else
               obj.model_.thermal.rTh = obj.basePlate_.modelParameters.thermal.rTh;
           end
        end
        function computeOutputData(obj)
            obj.computeOutputData@Comp3d.Composite;
            
            % We get the losses to dissipate
            lossesToCool = obj.outputData_.thermal.losses;
            
            % We get the maximal temperature
            if ~isempty(obj.blowingElement_)
                obj.outputData_.thermal.baseTemperature = obj.blowingElement_.temperature + ...
                    obj.model_.thermal.rTh * lossesToCool;
                
                % We get the exit temperature
                if ~isa(obj.blowingElement_,'Cooling.NaturalAir')
                    massFlow = obj.blowingElement_.density * obj.finElement.outputData.geometric.crossSectionTotal * ...
                        obj.blowingElement_.airSpeed;
                    obj.outputData_.thermal.exitTemperature = obj.blowingElement_.temperature + ...
                        massFlow * obj.blowingElement_.specificHeat ;
                    obj.outputData_.thermal.pressureLosses = obj.finElement.outputData.thermal.pressureLosses;
                    obj.outputData_.thermal.speedBetweenFins = obj.finElement.outputData.thermal.speedBetweenFins;
                end
                
                % We set the temperature of every element
                for k = 1:numel(obj.elementsToCool)
                    obj.elementsToCool{k}.setBaseTemperature(...
                        obj.outputData_.thermal.baseTemperature +  ...
                        obj.elementsToCool{k}.outputData_.thermal.deltaTemperature);
                end
            end
        end
    end
    
    %% Specific related protected methods
    methods (Access = protected)
        function linkBasePlateAndFinsFreedomDegrees(obj)
            if (~isempty(obj.finElement_)) && (~isempty(obj.basePlate_))
               if isa(obj.finElement_,'Comp3d.RectangularFins')
                   % We relate the length of both objects
                  obj.basePlate_.freedomDegrees.freedomDegreesArray(2).relation = {'obj.dimensions.length',obj.finElement_};
                  % We relate the width of both elements
                  obj.basePlate_.freedomDegrees.freedomDegreesArray(1).relation = {'obj.dimensions.numberOfFins*obj.dimensions.thickness+(obj.dimensions.numberOfFins-1)*obj.dimensions.gapBetweenFins',obj.finElement_};
               end
            end
        end
        function linkFinsAndFan(obj)
             if (~isempty(obj.finElement_)) && (~isempty(obj.basePlate_))
               if isa(obj.finElement_,'Comp3d.RectangularFins') && isa(obj.blowingElement_,'Comp3d.FanDiscreteDC')
                   obj.blowingElement_.freedomDegrees.freedomDegreesArray(5).relation = {'obj.dimensions.height',obj.finElement_};
                   obj.blowingElement_.freedomDegrees.freedomDegreesArray(4).relation = {'obj.dimensions.numberOfFins*obj.dimensions.thickness+(obj.dimensions.numberOfFins-1)*obj.dimensions.gapBetweenFins',obj.finElement_};
               end
             end
        end
        function updateDimensionsToCool(obj)
           if ~isempty(obj.elementsToCool_)            
           % We specify the minimal width of the heat sink
           widthCell = cellfun(@(elt) elt.dimensions.width,obj.elementsToCool_,'UniformOutput',false);
           obj.outputData_.geometric.widthCoolingArea = max([widthCell{:}]);
           
           % We specify the minimal length of the surface
           lengthCell = cellfun(@(elt) elt.dimensions.length,obj.elementsToCool_,'UniformOutput',false);
           obj.outputData_.geometric.lengthCoolingArea = sum([lengthCell{:}]);
           
           else
               obj.outputData_.geometric.widthCoolingArea = 0;
               obj.outputData_.geometric.lengthCoolingArea = 0;
           end
        end
    end
    
    %% Set & Get methods
    methods
        function value = get.basePlate(obj)
            value = obj.basePlate_;
        end
        function value = get.finElement(obj)
            value = obj.finElement_;
        end  
        function value = get.blowingElement(obj)
            value = obj.blowingElement_;
        end
        function value = get.elementsToCool(obj)
            value = obj.elementsToCool_;
        end
    end
    
end
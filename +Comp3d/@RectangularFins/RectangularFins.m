classdef RectangularFins < Comp3d.Element
    % BasePlate is the class to model a baseplate of a heat-sink
    %
    % Input arguments can be given as parameters:
    % exp: BasePlate('name, name, 'width', width, 'length', length)
    %
    % BasePlate inputs:
    % thickness               - thickness of the baseplate (m)
    % length                  - length of the baseplate (m)
    % height                  - height of the baseplate (m)
    % numberOfFins            - number of turns
    % gapBetweenFins          - gap between fins (m)
    % conductingMaterial      - conducting material
    %
    % See <a href="matlab:help Comp3d.Element">Comp3d.Element</a> for other properties / methods
    
    % Constructor
    methods
        
        function obj = RectangularFins(varargin)
            obj = obj@Comp3d.Element(varargin{:});
            obj.setDefaultParameters;
            obj.parse(varargin{:});
        end
    end
    %% Assistants Methods
    methods ( Access = private, Hidden = true )    
        function setDefaultParameters(obj)
            % Material
            obj.materialsType_.conductingMaterial = 'Conductor';
            obj.materials_.conductingMaterial = MaterialManager( obj.materialsType_.conductingMaterial, 2);
            
            freedomDegrees = [ ...
                {'thickness'},  {'meter'},    0.6e-4,  1e-3,  7e-3,   'free',     {[]}; ... % thickness (m)
                {'length'},     {'meter'},    1e-2,  1e-1,   0.3,   'free',             {[]}; ... % length (m)
                {'height'},     {'meter'},    1e-3,  3e-2,   1.5e-1,   'free',          {[]}; ... % height (m)
                {'numberOfFins'},{'fins'},    1,  15,   50,   'free',                   {[]}; ... % number of fins
                {'gapBetweenFins'}, {'meter'},0.5e-4,  1e-3,   2e-2,   'free',    {[]}; ... % gap between the fins
                ];
            obj.freedomDegrees_.createFreedomDegreesFromTable( obj, freedomDegrees);
            
        end
        function parse(obj,varargin)
            % We parse the dimensions
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('thickness',obj.dimensions.thickness,@(x) x>0);
            p.addParameter('length',obj.dimensions.length,@(x) x>0);
            p.addParameter('height',obj.dimensions.height,@(x) x>0);
            p.addParameter('numberOfFins',obj.dimensions.numberOfFins,@(x) x>0);
            p.addParameter('gapBetweenFins',obj.dimensions.gapBetweenFins,@(x) x>0);
            p.parse(varargin{:});
            obj.dimensions = p.Results;
            
            % We parse the other properties
            q = inputParser;
            q.KeepUnmatched = true;
            q.addParameter('conductingMaterial',obj.materials_.conductingMaterial.id);
            q.parse(varargin{:});
            
            % Specific to the winding
            obj.materials_.conductingMaterial = MaterialManager( obj.materialsType_.conductingMaterial,q.Results.conductingMaterial);
        end
    end
    
    %% Display methods
    methods
        function displayInformation(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            obj.displayInformation@Comp3d.Element(fid);
            fprintf(fid,'%s\n','====================================================');
            
        end
    end
    
    %% Draw methods
    methods
        function drawComponent(obj,offset,varargin)
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
            
            thickness = obj.dimensions.thickness;
            length = obj.dimensions.length;
            height = obj.dimensions.height;
            gapBetween = obj.dimensions.gapBetweenFins;
            
            colorVector = [0.7,0.7,0.7];
            for k = 1:round(obj.dimensions.numberOfFins)
                offsetVector = [offsetX + (thickness + gapBetween) * (k-1), offsetY, offsetZ];
                    draw_parallelepiped([thickness,length,height],offsetVector,colorVector);
            end
        end
    end
        
    %% Compute Parameters
    methods (Access = protected)
       
        function computeGeometry(obj)
            % Total Width
            obj.outputData_.geometric.totalWidth = obj.dimensions_.gapBetweenFins * (obj.dimensions_.numberOfFins - 1) + ...
                obj.dimensions_.thickness * obj.dimensions_.numberOfFins;
            
           % Cross section areas
           obj.outputData_.geometric.crossSectionFluid = obj.dimensions_.height * obj.dimensions_.gapBetweenFins * ...
                                        (obj.dimensions_.numberOfFins - 1);
           obj.outputData_.geometric.crossSectionTotal =  obj.outputData_.geometric.crossSectionFluid +...
               obj.dimensions_.height * obj.dimensions_.thickness * obj.dimensions_.numberOfFins;
           
           % Hydraulic diameter
           obj.outputData_.geometric.hydraulicDiameter = 4 * obj.outputData_.geometric.crossSectionTotal / ...
               (obj.dimensions_.numberOfFins * 2 * (obj.dimensions_.gapBetweenFins + obj.dimensions_.height));
           
           
           obj.outputData_.geometric.volume = (obj.outputData_.geometric.crossSectionTotal - obj.outputData_.geometric.crossSectionFluid) *...
                                             obj.dimensions_.length;
           % Envelope volume                             
           obj.outputData_.geometric.manufacturingVolume = obj.outputData_.geometric.crossSectionTotal * obj.dimensions.length;
           % Weight
           obj.outputData_.geometric.weight = obj.outputData_.geometric.volume * obj.materials_.conductingMaterial.density;
        end
        
        function computeThermalModelParametersLv1(obj)
           if isa(obj.comp3dParent_.blowingElement,'Comp3d.FanDiscreteDC')
               obj.computeThermalResistanceForced;
           elseif isa(obj.comp3dParent_.blowingElement,'Cooling.ForcedAir')
              obj.computeThermalResistanceForced;
           elseif isa(obj.comp3dParent_.blowingElement,'Cooling.NaturalAir')
              obj.computeThermalResistanceNatural;
           else
              error('blowing element has not been determined yet'); 
           end
        end
        
        function computeThermalModelParametersLv2(obj)
            obj.computeThermalModelParametersLv1;
        end
        
        function computeThermalResistanceForced(obj)
            % We get the cooling fluid from the heatSink (comp3dParent)
            fluid = obj.comp3dParent_.blowingElement;
            
            % Calculation of the fluid velocity between fins
             if isa(obj.comp3dParent_.blowingElement,'Comp3d.FanDiscreteDC')
                % Pressure losses vector of the fan
                qFlow = obj.comp3dParent.blowingElement.outputData.geometric.volumetricFlow;
                pressureLossesFan = obj.comp3dParent.blowingElement.outputData.geometric.deltaPressure;
                
                % Pressure losses vector of the fan
                qFlow(qFlow ==0) = 1e-6;
                [volumetricFlow, pressureLossesFins] = obj.calculationPressureLossesVector(qFlow);
                
                % We find the intersection point
                qOperationPoint= interp1(pressureLossesFins - pressureLossesFan,qFlow,0,'linear','extrap');
                pressureLossesFinal = interp1(qFlow,pressureLossesFan,qOperationPoint,'linear','extrap');
                obj.outputData_.thermal.pressureLosses = pressureLossesFinal;
                obj.modelParameters_.thermal.airSpeedEntry = qOperationPoint/obj.outputData_.geometric.crossSectionTotal;
                obj.comp3dParent.blowingElement.airSpeed = obj.modelParameters_.thermal.airSpeedEntry;
                obj.modelParameters_.thermal.airSpeedBetweenFins = qOperationPoint/obj.outputData_.geometric.crossSectionFluid;
            elseif isa(obj.comp3dParent_.blowingElement,'Cooling.ForcedAir')
                obj.modelParameters_.thermal.airSpeedEntry = obj.comp3dParent.blowingElement.airSpeed;
                obj.modelParameters_.thermal.airSpeedBetweenFins = obj.modelParameters_.thermal.airSpeedEntry *  obj.outputData_.geometric.crossSectionTotal / obj.outputData_.geometric.crossSectionFluid;
                obj.outputData_.thermal.pressureLosses = obj.calculationPressureLosses(obj.modelParameters_.thermal.airSpeedEntry);
            else
                error('blowing element has not been defined yet or fins have not been attached to a heat sink element');
            end
            
            % Calculation of the equivalent thermal model
            longitudinalAreaFin = obj.dimensions_.height * obj.dimensions_.length;
            
            % Prandtl number
            Pr = fluid.prandtl;
            
            % Reynolds number
            Re = (fluid.density * obj.modelParameters_.thermal.airSpeedBetweenFins * ...
                obj.dimensions_.gapBetweenFins ^ 2) / (fluid.dynamicViscosity * obj.dimensions_.length);
            
            % Nusselt number
            Nu_b = (1/(Re * Pr/2)^3 + 1/(0.664 * (Pr^0.33)* sqrt(Re + 3.65 * sqrt(Re)))^3)^(-1/3);
            
            % Equivalent heat exchange coefficient (W/(m^2 *K))
            obj.modelParameters_.thermal.hConvection = (Nu_b * fluid.conductivity) / obj.dimensions_.gapBetweenFins;
            
            % Equivalent thermal network
            m = sqrt(2 * obj.modelParameters_.thermal.hConvection /(obj.materials_.conductingMaterial.thermConduc * obj.dimensions_.thickness));
            
            % Efficiency of the fin
            rendFin = (tanh(m * obj.dimensions_.height)) / (m * obj.dimensions_.height);
            
            % number of discretized elements
            nElements = 10;
            
            % unitary thermal resistance convection
            rThConv = (1 * nElements) / ( obj.modelParameters_.thermal.hConvection * rendFin * longitudinalAreaFin);
            
            % unitary thermal resistance conduction of the fin
            rThFinCond = obj.dimensions_.height / (nElements * obj.dimensions_.thickness...
                * obj.dimensions_.length * obj.materials_.conductingMaterial.thermConduc);
            
            % Equivalent network of one side of the fin
            A = sqrt(rThFinCond * (rThFinCond + 4 * rThConv));
            B = (-2 * rThConv - rThFinCond + A) / rThConv;
            C = (2 * rThConv + rThFinCond + A) / rThConv;
            Req = -0.5 * ((A * (-B)^nElements - rThFinCond * (-B) ^ nElements + ...
                A * C ^ nElements + rThFinCond) / ((-B) ^ nElements - C ^ nElements));
            
            % Thermal resistance of just the heat sink
            obj.modelParameters_.thermal.rTh = 1/ (2 * obj.dimensions_.numberOfFins ) * Req ;
        end
        
        function computeThermalResistanceNatural(obj)
            error('Natural convection model has not been developped yet');
        end
        
        function computeThermalOutputDataLv2(obj)
        end
        
        function computeThermalOutputDataLv1(obj)
            obj.computeThermalOutputDataLv2;
        end
    end
    %% Specif compute methods
    methods (Access = {?Comp3d.RectangularFins,?Comp3d.HeatSink})
        function [pressureLosses] = calculationPressureLosses(obj,fluidSpeed)
            % Calculation based on "Comparative analysis of heat sink
            % pressure drop using different methodologies" publication
            
            % The fluid speed refers to the speed before entering the
            % heatsinks. Indeed the pressure losses calculation takes into
            % account the singular pressure losses due to the changes in
            % cross section...
            
            % Calculation of the speed on the channel
            speedBetweenFins = fluidSpeed .* (obj.outputData_.geometric.crossSectionTotal) / (obj.outputData_.geometric.crossSectionFluid);
            hydraulicDiameter = obj.outputData_.geometric.hydraulicDiameter;
            obj.outputData_.thermal.speedBetweenFins = speedBetweenFins;
            
            % We get the cooling fluid from the heatSink (comp3dParent)
            fluid = obj.comp3dParent_.blowingElement;
            
            % Re_pd : reynolds number taking into account the pressure
            % losses
            Re_pd = (fluid.density .* speedBetweenFins * hydraulicDiameter) / fluid.dynamicViscosity;
            
            % local pressure losses coefficients
            sigma = 1 - obj.dimensions_.numberOfFins * obj.dimensions_.thickness / obj.outputData_.geometric.totalWidth;
            Ke = (1 - sigma^2 )^2;                                           
            Kc = 0.42 * (1 - sigma^2);                                    
                       
            % Friction factor calculation in laminar flow
            lambda = obj.dimensions_.gapBetweenFins / obj.dimensions_.height;          
            f = (24 - 32.527* lambda + 46.721* lambda^2 - 40.829* lambda^3 + 22.954* lambda^4 - 6.089* lambda^5); 
            L_s = (obj.dimensions_.length / hydraulicDiameter) ./ Re_pd;
            f_app = (((3.44./sqrt(L_s)).^2 + (f).^2).^0.5 )./ Re_pd;

            % total pressure losses
            pressureLosses = (Kc + Ke + f_app  .* obj.dimensions_.numberOfFins .* obj.dimensions_.length .* (2 * obj.dimensions_.height + obj.dimensions_.gapBetweenFins) ./ ...
                (obj.dimensions_.height * obj.outputData_.geometric.totalWidth) ) * fluid.density .* (speedBetweenFins.^2 /2);             
        end   
    end
    
    
    %% Set Excitations
    methods
        function setExcitations(obj,varargin)
        end
    end
    
    %% Public functions
    methods
        function [volumetricAirFlowVector,pressureLossesVector] = calculationPressureLossesVector(obj, volumetricAirFlowVector)
            inputAirSpeed = volumetricAirFlowVector / (obj.outputData_.geometric.totalWidth * obj.dimensions.height);
            % We extract the delta pressure losses vector
            pressureLossesVector = obj.calculationPressureLosses(inputAirSpeed);
            pressureLossesVector(1) = 0;
        end 
    end
    
    
    %% Compute Parameters (not used)
    methods (Access = protected)
        
        function computeElectricModelParametersLv2(obj)
        end
        function computeElectricModelParametersLv1(obj)
        end
        function computeElectricOutputDataLv2(obj)
        end
        function computeElectricOutputDataLv1(obj)
        end
    end
    
end
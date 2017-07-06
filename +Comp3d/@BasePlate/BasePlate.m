classdef BasePlate < Comp3d.Element
    % BasePlate is the class to model a baseplate of a heat-sink
    % 
    % Input arguments can be given as parameters:
    % exp: BasePlate('name, name, 'width', width, 'length', length)
    %
    % BasePlate inputs:
    % width                 - width of the baseplate (m)
    % length                - length of the baseplate (m)
    % height                - height of the baseplate (m)
    % conductingMaterial    - conducting material
    %
    % See <a href="matlab:help Comp3d.Element">Comp3d.Element</a> for other properties / methods
    
    % Constructor
    methods
       
        function obj = BasePlate(varargin)
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
                {'width'},      {'meter'},    1e-2,  5e-2,   0.2,   'free',     {[]}; ... % width (m)
                {'length'},      {'meter'},    1e-2,  5e-2,   0.3,   'free',     {[]}; ... % length (m)
                {'height'},      {'meter'},    1e-3,  5e-3,   1.5e-2,   'free',     {[]}; ... % height (m)
                ];
             
            obj.freedomDegrees_.createFreedomDegreesFromTable( obj, freedomDegrees);
         end
         
         function parse(obj,varargin)
            % We parse the dimensions
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('width',obj.dimensions.width,@(x) x>0);
            p.addParameter('length',obj.dimensions.length,@(x) x>0);
            p.addParameter('height',obj.dimensions.height,@(x) x>0);
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
            fprintf(fid,'%s\n', 'Thermal Parameters');
            fprintf(fid,'%30s: %6.4g %s\n', 'Thermal Resistance', obj.modelParameters_.thermal.rTh, '°C/W');
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
            
            % Color and offset vector
            colorVector = [0.7,0.7,0.7];
            offsetVector = [offsetX, offsetY, offsetZ];
            
            % Drawing
             draw_parallelepiped([obj.dimensions.width,obj.dimensions.length,obj.dimensions.height],...
                                offsetVector,colorVector);
         end
     end
    
     %% Set Excitations
     methods
         function setExcitations(obj,varargin)
         end
     end
     
     %% Compute parameters (used)
     methods (Access = protected)
         function computeGeometry(obj)
            obj.outputData_.geometric.areaBase = obj.dimensions_.width * obj.dimensions_.length;
            obj.outputData_.geometric.volume =  obj.outputData_.geometric.areaBase * obj.dimensions_.height;
            obj.outputData_.geometric.manufacturingVolume = obj.outputData_.geometric.volume;
            obj.outputData_.geometric.weight = obj.outputData_.geometric.volume * obj.materials_.conductingMaterial.density;
         end
         function computeThermalModelParametersLv1(obj)
             obj.modelParameters_.thermal.rThSpreading = 0;
             obj.modelParameters_.thermal.rTh = obj.dimensions_.height / ...
                ( obj.outputData_.geometric.areaBase * obj.materials_.conductingMaterial.thermConduc);
         end
         function computeThermalModelParametersLv2(obj)
            obj.modelParameters_.thermal.rTh = obj.dimensions_.height / ...
                ( obj.outputData_.geometric.areaBase * obj.materials_.conductingMaterial.thermConduc);
             
            if ~isempty(obj.comp3dParent_.elementsToCool)
                 % To take into account the spreading effect
                
                %coefficient of convection transfer
                hConvection = obj.comp3dParent_.finElement.modelParameters.thermal.hConvection;
                
                % Model based on paper "Spreading resistance of isoflux
                % rectangles and strips on compound flux channels", M.M
                % Yovanovich
                a = obj.comp3dParent_.outputData_.geometric.widthCoolingArea / 2;
                b = obj.comp3dParent_.outputData_.geometric.lengthCoolingArea / 2;
                c = obj.dimensions_.width / 2;
                d = obj.dimensions_.length / 2;
                t = obj.dimensions_.height;
                
                % Coefficents
                K1 = 1 /(2 * a ^ 2 * c * d * obj.materials_.conductingMaterial.thermConduc);
                K2 = 1 /(2 * b ^ 2 * c * d * obj.materials_.conductingMaterial.thermConduc);
                K3 = 1 /(b ^ 2 * a ^ 2 * d * d * obj.materials_.conductingMaterial.thermConduc);
                
                % Number of elements for the sum of elements
                mVector = [1:100];
                nVector = [1:100];
                
                % Auxiliary coefficients
                delta = mVector .* pi ./ c;
                lambda = nVector .* pi ./ d;
                [deltaMat,lambdaMat] = meshgrid(delta,lambda);
                beta = sqrt(deltaMat .^ 2 + lambdaMat .^ 2);
                
                % First term of the polynom
                phi1 = ((exp(2 .* delta .* t) + 1) .* delta - (1 - exp(2 .* delta .* t)) .* ...
                    (hConvection ./ obj.materials_.conductingMaterial.thermConduc)) ./ ...
                    ((exp(2 .* delta .* t) - 1) .* delta + ...
                    (1 + exp(2 .* delta .* t)) .* (hConvection  ./ obj.materials_.conductingMaterial.thermConduc));
                R1 = K1 * sum((sin(a .* delta) .^ 2 ./ (delta.^3)) .* phi1);
                
                % Second term of the polynom
                phi2 = ((exp(2 .* lambda .* t) + 1) .* lambda - (1 - exp(2 .* lambda .* t)).*...
                    (hConvection ./ obj.materials_.conductingMaterial.thermConduc)) ./ ...
                    ((exp(2 .* lambda .* t) - 1) .* lambda + ...
                    (1 + exp(2 .* lambda .* t)) .* (hConvection ./ obj.materials_.conductingMaterial.thermConduc));
                R2 = K2 * sum(((sin(b .* lambda) .^2) ./ (lambda .^ 3)) .* phi2);
                
                % Third term of the polynom
                phi3= ((exp(2 .* beta .* t) + 1) .* beta - (1 - exp(2 .* beta .* t)) .*...
                    (hConvection  ./ obj.materials_.conductingMaterial.thermConduc)) ./ ...
                    ((exp(2 .* beta .* t) - 1) .* beta + (1 + exp(2 * beta * t)) * (hConvection ./ obj.materials_.conductingMaterial.thermConduc));
                vectorOfCoefficients = ((sin(a .* deltaMat) .^ 2  .* (sin(b  .* lambdaMat) .^ 2)) ./ (deltaMat .^ 2 .* lambdaMat .^2 .* beta)) .* phi3;
                R3 = K3 * sum(sum(vectorOfCoefficients));
                
                % Updating of the value
                obj.modelParameters_.thermal.rThSpreading = R1 + R2 + R3;
                obj.modelParameters_.thermal.rTh = obj.modelParameters_.thermal.rTh + obj.modelParameters_.thermal.rThSpreading;
            end
         end

     end
     
     %% Compute Parameters (not used)
     methods (Access = protected)
        
         function computeElectricModelParametersLv2(obj)
         end
         function computeElectricModelParametersLv1(obj)
         end
         function computeThermalOutputDataLv2(obj)
         end
         function computeThermalOutputDataLv1(obj)
         end
         function computeElectricOutputDataLv2(obj)
         end
         function computeElectricOutputDataLv1(obj)
         end
     end
     
end
classdef InductorCustomEI < Comp3d.Inductor
    % InductorCustomEI is the class that models an inductor with an E-I core
    %
    % Input arguments can be given as parameters:
    % exp: Inductor('name, name, 'width', width, 'nTurns', turnNumber)
    %
    % InductorCustomEI inputs
    % name                  - name
    % legWidth              - leg width (m)
    % legThickness          - leg thickness (m)
    % interLayerSpace       - distance between consecutive layers (m)
    % interTurnSpace        - distance between consecutive turns (m)
    % magneticCore          - magnetic Material
    % nLayers               - number of Layers
    % nTurns                - number of turns
    % electricConductor     - electric conductor material
    % gapAir                - Airgap (entrefer) (m)
    % conductorShape          - type of bobinage {round,rectangular}
    % diameter              - wire diameter (m) (if conductorShape = round)
    % nStrands              - number of strands (if conductorShape = round)
    % conductorWidth        - conductor Width (m) (if conductorShape =
    %                          rectangular)
    % conductorHeight       - conductor Height (m) (if conductorShape =
    %                          rectangular)
    %
    % <a href="matlab:help Comp3d.Inductor">Comp3d.Inductor </a> for other properties / methods
    
    % Constructor Method
    methods
        function obj = InductorCustomEI(varargin)
            obj = obj@Comp3d.Inductor(varargin{:});
            obj.setDefaultParameters();
            obj.parse(varargin{:});
        end
    end
    
    
    %% Assistants Methods
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj,varargin)
            %    {'nameFields'}            {'unit'}     lB     default  uB    	status      with
            basicFreedomDegrees = [ ...
                {'legWidth'},             {'meter'},    5e-3,  10e-3,   1e-1,   'free',     {[]}; ... % legWidth (m)
                {'legThickness'},         {'meter'},   10e-3,  20e-3,   1e-1,   'free',     {[]}; ... % legThickness (m)
                {'airGap'},               {'meter'},    1e-6, 0.3e-3,   3e-3,   'free',     {[]}; ... % airGap (m)

                {'windingCoreDistance'},  {'meter'},    1e-4, 0.6e-3,   1e-2,   'setToX0',  {[]}; ... % windingCoreDistance (m)
                
                {'interTurnSpace'},       {'meter'},    5e-5, 0.1e-3,   2e-4,   'setToX0',  {[]}; ... % interTurnSpace (m)
                ];
            
            switch obj.shape_.conductorShape
                case 'round'
                    %   {'nameFields'}            {'unit'}      lB     default  uB      status      with
                    conductorFreedomDegrees = [ ...
                        {'nTurns'},               {'turn'},     20,     200,    300,    'free',     {[]};  ... % number of Turns (n)
                        {'interLayerSpace'},      {'meter'},	1e-4,   0.1e-3, 1e-2,   'free',     {[]}; ... % interLayerSpace (m)
                        {'nLayers'},              {'layer'},	1,    	8,      5,      'free',     {[]}; ... % number of Layers (n)
                        {'nStrands'},             {'strand'},	1,     	1,      50,     'free',     {[]}; ... % number of wires (m)
                        {'diameterW'},            {'meter'},	1e-5, 	1e-3,   3e-2,   'free',     {[]};  ... % conductor diameter (m)
                        ];
                    
                case 'rectangular'
                    %   {'nameFields'}            {'unit'}      lB     default  uB      status      with
                    conductorFreedomDegrees = [ ...
                        {'nTurns'},               {'turn'},        2,      8,     40,   'free',     {[]};  ... % number of Turns (n)
                        {'conductorWidth'},       {'meter'},  0.1e-3,	1e-3,  2e-3,   	'free',     {[]}; ... % conductorWidth (m)
                        {'conductorHeight'},      {'meter'},    7e-3,  30e-3, 60e-3,    'free',     {[]}; ... % conductorHeight (m)
                        ];
            end
            
            freedomDegrees = [ ...
                basicFreedomDegrees; ...
                conductorFreedomDegrees ...
                ];
            obj.freedomDegrees_.createFreedomDegreesFromTable( obj, freedomDegrees);
            
            % only skin effect
            switch obj.shape_.conductorShape
                case 'round'
                    obj.rAcFactor_.evaluate = @(f) obj.rAcFactorRound(f);
                case 'rectangular'
                    obj.rAcFactor_.evaluate = @(f) obj.rAcFactorRectangular(f);
            end
            
            % Proximity effect
            switch obj.shape_.conductorShape
                case 'rectangular'
                    load 'Comp3d/InductorCustomEI/RacFactorInductorCustomEIrectangularDataBase.mat'
%                     obj.rAcFactor_ = InterpolantGriddedLog( obj, RacFactorInductorCustomEIrectangularDataBase);
                    obj.rAcFactor_ = InterpolantGridded( obj, RacFactorInductorCustomEIrectangularDataBase);
            end
            
            
        end
        
        function parse(obj,varargin)
            % Specific to the inductor
            p = inputParser;
            p.KeepUnmatched = true;
            
            % Specific to the core
            p.addParameter( 'legWidth', obj.dimensions_.legWidth, @(x) x>0);
            p.addParameter( 'legThickness', obj.dimensions_.legThickness, @(x) x>0);
            p.addParameter( 'interTurnSpace', obj.dimensions_.interTurnSpace, @(x) x>0);
            p.addParameter( 'airGap', obj.dimensions_.airGap, @(x) x>=0);
            % Specific to the winding
            p.addParameter( 'nTurns', obj.dimensions_.nTurns, @(x) x>0);
            switch obj.shape_.conductorShape
                case 'round'
                    % Specific to circular winding
                    p.addParameter( 'interLayerSpace', obj.dimensions_.interLayerSpace, @(x) x>0);
                    p.addParameter( 'nLayers', obj.dimensions_.nLayers, @(x) x>0);
                    p.addParameter( 'nStrands', obj.dimensions_.nStrands, @(x) x>0);
                    p.addParameter( 'diameterW', obj.dimensions_.diameterW, @(x) x>0);
                    
                case 'rectangular'
                    % Specific to rectangular winding
                    p.addParameter( 'conductorWidth', obj.dimensions_.conductorWidth, @(x) x>0);
                    p.addParameter( 'conductorHeight', obj.dimensions_.conductorHeight, @(x) x>0);
            end
            
            % Dimensions parsing
            p.parse(varargin{:});
            obj.dimensions = p.Results;
        end
    end
    
    methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            obj.update@Comp3d.Inductor(varargin{:});
            obj.parse(varargin{:});
        end
    end
    
    %% Initial point determination (Area product)
    methods
        getDimensionsAreaProductFromL(obj,L,sideType,fSw,vHVnom,iLVnom);
    end
    
    %% Assistants Methods
    methods (Access = protected)
        function computeGeometry(obj)
            % Computes physical parameters of the inductor depending on inductor's shape
            
            % Approximation of some parameters (Can be modified for some cases) Factor 30 (From Experience :) )
            %             obj.dimensions_.innerAirLength = 2 * obj.dimensions_.legWidth / 30;
            %             obj.dimensions_.windingCoreDistance = 2 * obj.dimensions_.legWidth / 30;
            
            switch obj.shape_.conductorShape
                case 'round'
                    if obj.dimensions_.nTurns > 1
                        if obj.dimensions_.nTurns < 2 * obj.dimensions_.nLayers
                            warning('Layers and Turns give an unfeasible inductor. Layers set to dobule the number of turns');
                            obj.dimensions_.nLayers = 2 * obj.dimensions_.nTurns;
                        end
                    end
                
                    if obj.dimensions_.nStrands > 1
                        obj.outputData_.geometric.diameterExtW = 135e-6 * (obj.dimensions_.nStrands / 3 ) ^ 0.45 * (obj.dimensions_.diameterW / 40e-6) ^ 0.85;
                    else
                        obj.outputData_.geometric.diameterExtW = obj.dimensions_.diameterW;
                    end
                    
                    obj.outputData_.geometric.windowWidth = obj.dimensions_.nLayers * obj.outputData_.geometric.diameterExtW + (obj.dimensions_.nLayers-1) * obj.dimensions_.interLayerSpace + 2* obj.dimensions_.windingCoreDistance;
                    obj.outputData_.geometric.windowHeight = (obj.dimensions_.nTurns / obj.dimensions_.nLayers) * obj.outputData_.geometric.diameterExtW + ((obj.dimensions_.nTurns / obj.dimensions_.nLayers) -1 ) * obj.dimensions_.interTurnSpace  + 2* obj.dimensions_.windingCoreDistance;
                    obj.outputData_.geometric.totalThickness = ...
                        obj.dimensions_.legThickness + ...
                        2 * obj.dimensions_.windingCoreDistance + ...
                        obj.dimensions_.nLayers * obj.dimensions_.diameterW + ...
                        (obj.dimensions_.nLayers - 1) * obj.dimensions_.interLayerSpace;
                    
                case 'rectangular'
                    obj.outputData_.geometric.windingThickness = obj.dimensions_.nTurns * obj.dimensions_.conductorWidth + (obj.dimensions_.nTurns - 1) * obj.dimensions_.interTurnSpace;
                    obj.outputData_.geometric.windowWidth = 2* obj.dimensions_.windingCoreDistance + obj.outputData_.geometric.windingThickness;
                    obj.outputData_.geometric.windowHeight = 2* obj.dimensions_.windingCoreDistance + obj.dimensions_.conductorHeight;
                    obj.outputData_.geometric.totalThickness = obj.dimensions_.legThickness + 2 * ( obj.dimensions_.windingCoreDistance + obj.outputData_.geometric.windingThickness);
            end
            
            % function that computes the object
            obj.outputData_.geometric.totalWidth = 4 * obj.dimensions_.legWidth + 2 * obj.outputData_.geometric.windowWidth;
            obj.outputData_.geometric.totalHeight = 2 * obj.dimensions_.legWidth + obj.outputData_.geometric.windowHeight;
            
            areaCube = obj.outputData_.geometric.totalWidth * obj.outputData_.geometric.totalHeight;
            areaAir = 2* obj.outputData_.geometric.windowWidth * obj.outputData_.geometric.windowHeight + 4* obj.dimensions_.legWidth * obj.dimensions_.airGap;
            
            obj.outputData_.geometric.volumeC = (areaCube - areaAir) * obj.dimensions_.legThickness;
            obj.outputData_.geometric.weightC = obj.outputData_.geometric.volumeC * obj.materials_.magneticCore.density;
            
            obj.outputData_.geometric.volumeMag.legSide = obj.dimensions_.legThickness * obj.dimensions_.legWidth * ...
                (3 * obj.dimensions_.legWidth + 2 * obj.outputData_.geometric.windowWidth + (obj.outputData_.geometric.windowHeight - obj.dimensions_.airGap));
            obj.outputData_.geometric.volumeMag.legCentral = 2 * obj.dimensions_.legWidth * obj.dimensions_.legThickness * (obj.outputData_.geometric.windowHeight - obj.dimensions_.airGap + obj.dimensions_.legWidth);
            
            % External core area
            obj.outputData_.geometric.externalAreaCore = 2 * (areaCube - areaAir) + ...
                2 * (obj.outputData_.geometric.totalWidth + obj.outputData_.geometric.totalHeight) * obj.dimensions_.legThickness + ...
                4 * (obj.outputData_.geometric.windowWidth + obj.outputData_.geometric.windowHeight) * obj.dimensions_.legThickness;
            
            % Magnetic parameters calculation
            obj.outputData_.geometric.magneticArea = 2 * obj.dimensions_.legWidth * obj.dimensions_.legThickness;
            obj.outputData_.geometric.magPathLength = 2 * (obj.outputData_.geometric.windowWidth + obj.outputData_.geometric.windowHeight + 2 * pi /8 * 2 * obj.dimensions_.legWidth);
            
            
            % Auxiliary variable to determine the iron losses per
            % turn
            obj.outputData_.geometric.path = 4 * (obj.outputData_.geometric.windowWidth + 3 / 4 * obj.dimensions_.legWidth) + 3 * (obj.outputData_.geometric.windowHeight + obj.dimensions_.legWidth / 2);
            
            
            meanWindingWidth = 2 * obj.dimensions_.legWidth + obj.outputData_.geometric.windowWidth;
            meanWindingThickness = obj.dimensions_.legThickness + obj.outputData_.geometric.windowWidth;

            obj.outputData_.geometric.meanLengthTurn = 2* meanWindingWidth + 2* meanWindingThickness;
            obj.outputData_.geometric.length = obj.dimensions_.nTurns * obj.outputData_.geometric.meanLengthTurn;
                    
            % Calculation of the winding length
            switch obj.shape_.conductorShape
                case 'round'
                    %%%
                    % $A_w  = {\pi * d_w^2 \over 4}$
                    obj.outputData_.geometric.sectionW = obj.dimensions_.nStrands * pi * obj.dimensions_.diameterW ^ 2 / 4;
                    
                    obj.outputData_.geometric.length = 0;
                    obj.outputData_.geometric.turnsLayer = ones(1,ceil(obj.dimensions_.nLayers)) .* obj.dimensions_.nTurns / obj.dimensions_.nLayers;
                    totalTurns = obj.dimensions_.nTurns;
                    
                    for i = 1:obj.dimensions_.nLayers
                        % Calculates the maximal number of turns per layer
                        difference = 2 * obj.dimensions_.windingCoreDistance + obj.outputData_.geometric.diameterExtW + 2 * obj.dimensions_.interLayerSpace + 2 *(obj.outputData_.geometric.diameterExtW + obj.dimensions_.interLayerSpace) * (i-1);
                        
                        % Calculates perimeter for this layer
                        currentsectionWidth = 2 * obj.dimensions_.legWidth + difference;
                        currentsectionThickness = obj.dimensions_.legThickness + difference;
                        perimeter = 2 * currentsectionWidth + 2 * currentsectionThickness;
                        
                        % Aproximate external copper area
                        obj.outputData_.geometric.externalAreaWindingVertical = perimeter * obj.outputData_.geometric.windowHeight;
                        
                        if obj.outputData_.geometric.turnsLayer >= totalTurns
                            obj.outputData_.geometric.lengthLayer(i) = perimeter * totalTurns;
                            obj.outputData_.geometric.length = obj.outputData_.geometric.length + perimeter * totalTurns;
                            break
                        else
                            obj.outputData_.geometric.lengthLayer(i) = perimeter * obj.outputData_.geometric.turnsLayer(i);
                            obj.outputData_.geometric.length = obj.outputData_.geometric.length + obj.outputData_.geometric.lengthLayer(i);
                            totalTurns = totalTurns - obj.outputData_.geometric.turnsLayer(i);
                        end
                    end
                    
                case 'rectangular'
                    obj.outputData_.geometric.sectionW = obj.dimensions_.conductorWidth * obj.dimensions_.conductorHeight;
                    
                    obj.outputData_.geometric.externalAreaWindingVertical = (obj.outputData_.geometric.meanLengthTurn + 2* obj.outputData_.geometric.windowWidth) * obj.outputData_.geometric.windowHeight;
                    obj.outputData_.geometric.externalAreaWindingHorizontal = ....
                        2* ( meanWindingWidth + obj.outputData_.geometric.windowWidth ) * ( meanWindingThickness + obj.outputData_.geometric.windowWidth ) ...
                        - 2* ( 2 * obj.dimensions_.legWidth * obj.dimensions_.legThickness);
            end
            
        
            obj.outputData_.geometric.volumeW = obj.dimensions_.nTurns * obj.outputData_.geometric.meanLengthTurn * obj.outputData_.geometric.sectionW;
            obj.outputData_.geometric.weightW = obj.outputData_.geometric.volumeW * obj.materials_.electricConductor.density;
            
            obj.outputData_.geometric.externalArea = obj.outputData_.geometric.externalAreaCore + obj.outputData_.geometric.externalAreaWindingVertical + obj.outputData_.geometric.externalAreaWindingHorizontal;
            
            obj.outputData_.geometric.manufacturingVolume = obj.outputData_.geometric.totalWidth * obj.outputData_.geometric.totalHeight * obj.outputData_.geometric.totalThickness;
            obj.outputData_.geometric.volume = obj.outputData_.geometric.manufacturingVolume;
            obj.outputData_.geometric.weight = obj.outputData_.geometric.weightC + obj.outputData_.geometric.weightW;
            
            obj.outputData_.geometric.fillingWinding = obj.outputData_.geometric.windowHeight / obj.outputData_.geometric.magPathLength;
            
        end
    end
    
    %% compute Model Parameters methods
    methods (Access = protected)
        function computeElectricModelParametersLv1(obj)
            % Calculation of the inductance
            obj.modelParameters_.electric.L = obj.dimensions_.nTurns^2 * obj.MU_0 * obj.outputData_.geometric.magneticArea / ( 2 * obj.dimensions_.airGap + obj.outputData_.geometric.magPathLength / obj.materials_.magneticCore.mu_e );
            % We only take into account the DC resistance
            obj.modelParameters_.electric.rS = obj.materials_.electricConductor.resisElec * obj.outputData_.geometric.length / obj.outputData_.geometric.sectionW;

            obj.modelParameters_.electric.Lmodel.val = obj.modelParameters_.electric.L;
            obj.modelParameters_.electric.rSmodel.val = obj.modelParameters_.electric.rS;
        end
        function computeElectricModelParametersLv2(obj)
            obj.modelParameters_.electric.L = obj.dimensions_.nTurns^2 * obj.MU_0 * obj.outputData_.geometric.magneticArea / ( 2 * obj.dimensions_.airGap + obj.outputData_.geometric.magPathLength / obj.materials_.magneticCore.mu_e );% Update of the resistance representing the winding losses
            obj.modelParameters_.electric.rS = obj.materials_.electricConductor.resisElec * obj.outputData_.geometric.length / obj.outputData_.geometric.sectionW;
            
            obj.modelParameters_.electric.Lmodel.val = obj.modelParameters_.electric.L;

            freqVec = [ 5e3, 50e3, 500e3, 5e6, 50e6];
            obj.modelParameters_.electric.rACmodel.freqVec = [0 freqVec];
            obj.modelParameters_.electric.rACmodel.freqValVec = obj.modelParameters_.electric.rS * [ 1 max( obj.rAcFactor_.evaluate( freqVec), 1)];
            
            % rAc femm comparison
            if isfield( obj.modelParameters_, 'femm') && isfield( obj.modelParameters_.femm, 'rAcFactorCompensation') && ~isempty( obj.modelParameters_.femm.rAcFactorCompensation)
                obj.modelParameters_.electric.rACmodel.freqValVec = obj.modelParameters_.femm.rAcFactorCompensation .* obj.modelParameters_.electric.rACmodel.freqValVec;
            end

            obj.computeMagneticModelParametersLv2;
        end
        function computeMagneticModelParametersLv2(obj)
            % Creation of the equivalent electrical-magnetic
            % coupling model (See documentation)
            % Side Leg
            
            valueAirGapSide = obj.MU_0 * obj.outputData_.geometric.magneticArea / (2 * obj.dimensions_.airGap);
            valueCoreSide = obj.MU_0 * obj.materials_.magneticCore.mu_e * obj.outputData_.geometric.magneticArea / 2 /...
                (((obj.outputData_.geometric.windowHeight - obj.dimensions_.airGap) + 2 * obj.outputData_.geometric.windowWidth + 3 * pi/4 * obj.dimensions_.legWidth ));

            valueSideLeg = valueCoreSide * valueAirGapSide / (valueCoreSide + valueAirGapSide);
            
            % CentralLeg
            valueAirGapCentralLeg = obj.MU_0 * obj.outputData_.geometric.magneticArea / obj.dimensions_.airGap;
            valueCentralLegCore = obj.materials_.magneticCore.mu_e * obj.MU_0 * obj.outputData_.geometric.magneticArea / ...
                (obj.outputData_.geometric.windowHeight +  pi/4 * obj.dimensions_.legWidth );
            
            valueCentralLeg = valueCentralLegCore * valueAirGapCentralLeg / (valueCentralLegCore + valueAirGapCentralLeg);
            
            valueCore = 1/( 1/(2*valueSideLeg) + 1/valueCentralLeg);
            obj.modelParameters_.magnetic.CoreModel.L = obj.dimensions_.nTurns^2 * valueCore;
            obj.modelParameters_.magnetic.CoreModel.r = obj.dimensions_.nTurns^2 * valueCore * 1e-3;
            
            % Core Losses
            freqVec = [0 1 100 1e3 1e4 1e6 1e7 1e8 1e9 1e10 1e11 1e12];
            coreLossesResistance = obj.computeIronLossesMagneticResistance( freqVec, obj.outputData_.geometric.volumeMag.legSide, obj.outputData_.geometric.magneticArea/2);
            coreLossesResistance = 2* coreLossesResistance /( 1 + obj.outputData_.geometric.volumeMag.legSide / obj.outputData_.geometric.volumeMag.legCentral);

            obj.modelParameters_.magnetic.RLosses.freqValVec = obj.dimensions_.nTurns^2 * coreLossesResistance;
            obj.modelParameters_.magnetic.RLosses.freqVec = freqVec;
        end
    end
    
    %% draw Methods
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
            
            obj.drawCoreCustomEI(offsetX,offsetY,offsetZ);
            switch obj.shape_.conductorShape
                case 'round'
                    obj.drawRoundCustomEI(offsetX,offsetY,offsetZ);
                case 'rectangular'
                    obj.drawRectangularCustomEI(offsetX,offsetY,offsetZ);
            end
                        
            view(3);
        end
        function drawCoreCustomEI(obj,offsetX,offsetY,offsetZ)
            % Draw function for the inductor
            color1 = [0.55 0.55  0.55];
            
            totalWidth = obj.outputData_.geometric.totalWidth;
            windowHeight = obj.outputData_.geometric.windowHeight;
            
            xCenterL = offsetX + obj.dimensions_.legWidth / 2;
            xCenterC = offsetX + totalWidth / 2;
            xCenterR = offsetX + totalWidth - obj.dimensions_.legWidth/2;
            yCenter = offsetY + obj.outputData_.geometric.totalThickness / 2;
            zCenter = offsetZ + obj.outputData_.geometric.totalHeight / 2 - obj.dimensions_.airGap/2;
            
            % Core Drawing
            [ParX,ParY,ParZ] = drawParall( obj.dimensions_.legWidth, obj.dimensions_.legThickness, windowHeight - obj.dimensions_.airGap);
            
            hold on
            % Left Leg
            patch(xCenterL + ParX, yCenter + ParY, zCenter + ParZ, color1);
            
            % Right Leg
            patch(xCenterR + ParX, yCenter + ParY, zCenter + ParZ, color1);
            
            % Center Leg
            [ParX, ParY, ParZ] = drawParall( 2 * obj.dimensions_.legWidth, obj.dimensions_.legThickness, windowHeight - obj.dimensions_.airGap);
            patch(xCenterC + ParX , yCenter + ParY , zCenter + ParZ, color1);
            
            % Connexion legs
            zCenterH = offsetZ + 1.5 * obj.dimensions_.legWidth + windowHeight;
            zCenterL = offsetZ + 0.5 * obj.dimensions_.legWidth;
            [ParX, ParY, ParZ] = drawParall( totalWidth, obj.dimensions_.legThickness , obj.dimensions_.legWidth);
            patch(xCenterC + ParX, yCenter + ParY , zCenterH + ParZ, color1);
            patch(xCenterC + ParX, yCenter + ParY , zCenterL + ParZ, color1);
        end
        function drawRoundCustomEI(obj,offsetX,offsetY,offsetZ)
            color2 = [1.00 0.552 0];
            
            totalWidth = obj.outputData_.geometric.totalWidth;
            totalThickness = obj.outputData_.geometric.totalThickness;

            xCenterC = offsetX + totalWidth / 2;
            yCenter = offsetY + totalThickness / 2;
            
            % Winding Drawing
            totalTurns = obj.dimensions_.nTurns;
            for i = 1 : obj.dimensions_.nLayers
                IntX =  2* obj.dimensions_.legWidth + 2*(i-1) * (obj.dimensions_.interLayerSpace + obj.outputData_.geometric.diameterExtW) + 2*obj.dimensions_.windingCoreDistance;
                IntY = obj.dimensions_.legThickness + 2*(i-1) * (obj.dimensions_.interLayerSpace + obj.outputData_.geometric.diameterExtW) + 2*obj.dimensions_.windingCoreDistance;
                ExtX = IntX + 2* obj.outputData_.geometric.diameterExtW;
                ExtY = IntY + 2* obj.outputData_.geometric.diameterExtW;
                H = obj.outputData_.geometric.diameterExtW;
                totalTurns = totalTurns - floor(obj.dimensions_.nTurns / obj.dimensions_.nLayers);
                
                if totalTurns > 0
                    turnsToDraw = floor(obj.dimensions_.nTurns / obj.dimensions_.nLayers);
                else
                    turnsToDraw = totalTurns + floor(obj.dimensions_.nTurns / obj.dimensions_.nLayers);
                end
                
                for k = 1:turnsToDraw
                    zCenter = offsetZ + obj.outputData_.geometric.totalHeight / 2 - obj.outputData_.geometric.windowHeight / 2 + ...
                        obj.dimensions_.diameterW + (k - 1) * (obj.dimensions_.diameterW + obj.dimensions_.interTurnSpace);
                    [SqBobX,SqBobY,SqBobZ] = drawSquareBobbin(IntX,IntY,ExtX,ExtY,H);
                    patch(xCenterC + SqBobX, yCenter + SqBobY, zCenter + SqBobZ,color2);
                end
            end
        end
        function drawRectangularCustomEI(obj,offsetX,offsetY,offsetZ)
            color2 = [1.00 0.552 0];

            % Winding Drawing
            xCenterC = offsetX + obj.outputData_.geometric.totalWidth / 2;
            yCenter = offsetY + obj.outputData_.geometric.totalThickness / 2;
            zCenter = offsetZ + obj.outputData_.geometric.totalHeight / 2;
            
            for i = 1 : obj.dimensions_.nTurns
                IntX =  2* obj.dimensions_.legWidth + 2*(i-1)* (obj.dimensions_.interTurnSpace + obj.dimensions_.conductorWidth) + 2*obj.dimensions_.windingCoreDistance;
                IntY = obj.dimensions_.legThickness + 2*(i-1)* (obj.dimensions_.interTurnSpace + obj.dimensions_.conductorWidth) + 2*obj.dimensions_.windingCoreDistance;
                ExtX = IntX + 2*obj.dimensions_.conductorWidth;
                ExtY = IntY + 2*obj.dimensions_.conductorWidth;
                H = obj.dimensions_.conductorHeight;
                [SqBobX,SqBobY,SqBobZ] = drawSquareBobbin( IntX,IntY,ExtX,ExtY,H);
                patch(xCenterC + SqBobX, yCenter + SqBobY, zCenter + SqBobZ,color2);
            end
        end
    end
    
    %% femm
    methods
        function femmDraw(obj)
            legWidth = obj.dimensions_.legWidth;
            airGap = obj.dimensions_.airGap;
            windingCoreDistance = obj.dimensions_.windingCoreDistance;
            coreHeight = obj.outputData_.geometric.totalHeight;
            coreWidth = obj.outputData_.geometric.totalWidth;

            % Define studied domain and address some shape-related particular cases
            % Rapport entre rayon du cercle d'étude et plus grande dimension du dispositif
            Kdom = 1.8;
            radius = Kdom * max( coreWidth, coreHeight);
            % Draw the outer boundary for the problem
            obj.femmDrawOuterBoundaryHalfCircle( radius);

            % External Air
            mi_addblocklabel(coreWidth/4, 0.7*coreHeight);
            mi_selectlabel(  coreWidth/4, 0.7*coreHeight);
            mi_setblockprop( 'Air', 1, 0, 'none', 0, 0, 0);
            mi_clearselected();

            % Draw Core
            % Top half of the core
            obj.femmDrawCoreI( [0 coreHeight/2], 'Magnetic');
            % Bottom half of the core
            obj.femmDrawCoreE( [0 coreHeight/2-legWidth-airGap], 'Magnetic');

            % Draw Winding
            switch obj.shape_.conductorShape
                case 'round'
                    obj.femmDrawWindingRound( [ legWidth+windingCoreDistance 0], 'Conductor', 'U1');
                case 'rectangular'
                    obj.femmDrawWindingRectangular( [ legWidth+windingCoreDistance 0], 'Conductor', 'U1');
            end
            
            % if airGap < 1.5e-6
            %     xr = legWidth + windingCoreDistance /2 ;            % absciss of top-right corner
            %     yt = 0;% ordinate of top-right corner
            %     mi_addblocklabel(xr,yt);
            %     mi_selectlabel(xr,yt);
            %     mi_setblockprop('Air', 1, 0, 'none', 0, 0, 0);
            %     mi_clearselected;
            % end

            mi_zoom( 0, -coreHeight/2, coreWidth/4, coreHeight/2)
        end
        function femmDrawCoreI(obj, origin, material)
            % Top half of the core
            oy = origin(2);

            legWidth = obj.dimensions_.legWidth;
            coreWidth = obj.outputData_.geometric.totalWidth;
            
            mi_drawrectangle( 0, oy, coreWidth/2, oy-legWidth);

            mi_addblocklabel(coreWidth/4, oy-legWidth/2);
            mi_selectlabel(  coreWidth/4, oy-legWidth/2);
            mi_setblockprop( material, 1, 1, 'none', 0, 0, 0);
            mi_clearselected();
        end
        function femmDrawCoreE(obj, origin, material)
            % Bottom half of the core
            oy = origin(2);

            legWidth = obj.dimensions_.legWidth;
            coreWidth = obj.outputData_.geometric.totalWidth;
            airGap = obj.dimensions_.airGap;
            windowHeight = obj.outputData_.geometric.windowHeight;        
            windowWidth = obj.outputData_.geometric.windowWidth;
            legHeight = windowHeight - airGap;
            coreHeight = legHeight + legWidth;

            mi_drawpolygon( [ ...
                0, oy-coreHeight; ...
                coreWidth/2, oy-coreHeight; ...
                coreWidth/2, oy; ...
                legWidth+windowWidth, oy; ...
                legWidth+windowWidth, oy-legHeight; ...
                legWidth, oy-legHeight; ...
                legWidth, oy; ...
                0, oy ...
                ] )

            mi_addblocklabel(legWidth/2, oy-legHeight/2);
            mi_selectlabel(  legWidth/2, oy-legHeight/2);
            mi_setblockprop( material, 1, 1, 'none', 0, 0, 0);
            mi_clearselected();
        end
        function femmRAcFacteurComputeCompensation(obj)
            freqVec = obj.modelParameters_.electric.rACmodel.freqVec;
            freqVec = freqVec( freqVec > 0 );
            rAcFactorFEMM = [ 1 cellfun( @(f) obj.femmCompute(f), num2cell(freqVec))];
            
            rAcFactorCompensation = rAcFactorFEMM ./ max( [ 1 obj.rAcFactor_.evaluate( freqVec)], 1);
            
            if any( rAcFactorCompensation > 1.10 )
                rAcFactorCompensation = max( rAcFactorCompensation, 1.10);
                warning('Comp3d.InductorCustomEI: rAcFacteur compensation limited at +10%. Verify if rAc database is in the valid zone.');
            end
            if any( rAcFactorCompensation < 0.90 )
                rAcFactorCompensation = min( rAcFactorCompensation, 0.90);
                warning('Comp3d.InductorCustomEI: rAcFacteur compensation limited at -10%. Verify if rAc database is in the valid zone.');
            end
             
            obj.modelParameters_.femm.rAcFactorCompensation = rAcFactorCompensation;
        end
    end
    
    %%
    methods (Access = protected)
        function computeThermalModelParametersLv2(obj)
        end
        function computeThermalOutputDataLv2(obj)
            obj.outputData_.thermal.losses = obj.outputData_.electric.jouleLosses + obj.outputData_.magnetic.coreLosses;
            obj.thermalProblemSolve;
            obj.outputData_.thermal.temperature = max( obj.outputData_.thermal.temperatureVector);
        end
    end
    %%
    methods (Access = protected)
        function thermalProblemSolve( obj)
            % nodeNumber = model nodes + air node
            nodeNumber = 19 + 12 - 5 + 1;
            obj.modelParameters_.thermal.airNodeIndex = nodeNumber;
            
            % create thermal problem
            thermalProblem = ThermalProblem( nodeNumber);
            obj.modelParameters_.thermal.problem = thermalProblem;

            % add thermal elements
            obj.thermalProblemAddCore;
            obj.thermalProblemAddWinding;
            
            % initialise temperatureVector
            if ~isfield( obj.outputData_.thermal, 'temperatureVector')
                obj.outputData_.thermal.temperatureVector = [];
            end
            
            % fix air temperature
            thermalProblem.fixTemperature( obj.modelParameters_.thermal.airNodeIndex, obj.excitations_.thermal.tAir + 273.15);
            % solve thermal problem
            obj.outputData_.thermal.temperatureVector = thermalProblem.solve( obj.outputData_.thermal.temperatureVector + 273.15) - 273.15;
        end
        function thermalProblemAddCore( obj)
            constanteStefanBoltzmann = 5.670373e-8;
            coreEmissivity = 0.45;
            
            thermalProblem = obj.modelParameters_.thermal.problem;
            h = obj.getConvectionCoefficient;
            
            legWidth = obj.dimensions_.legWidth;
            legThickness = obj.dimensions_.legThickness/2;
            windowHeight = obj.outputData_.geometric.windowHeight;
            windowWidth = obj.outputData_.geometric.windowWidth;
            totalWidth = obj.outputData_.geometric.totalWidth/2;
            
            kCore = obj.materials_.magneticCore.thermConduc;
            
            % core Node
            cn(1) = 1;
            cn(2) = 2;
            cn(3) = 3;
            cn(4) = 4;
            cn(5) = 6;
            cn(6) = 7;
            cn(7) = 8;
            cn(8) = 9;
            cn(9) = 12;
            cn(10) = 13;
            cn(11) = 17;
            cn(12) = 18;
            cn(13) = 20;
            cn(14) = 21;
            cn(15) = 22;
            cn(16) = 23;
            cn(17) = 24;
            cn(18) = 25;
            cn(19) = 26;
            cn(20) = obj.modelParameters_.thermal.airNodeIndex;
            %
            % Volumes -> losses
            thermalProblem.setNodeVolume( cn(1), legWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(3), legWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(6), legWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(8), legWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(2), windowWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(7), windowWidth * legWidth * legThickness);
            thermalProblem.setNodeVolume( cn(4), legWidth * windowHeight * legThickness);
            thermalProblem.setNodeVolume( cn(5), legWidth * windowHeight * legThickness);
            %
            % Surfaces -> radiation and natural convection
            thermalProblem.setNodeSurface( cn(9),  totalWidth * legThickness);
            thermalProblem.setNodeSurface( cn(10), totalWidth * legWidth);
            thermalProblem.setNodeSurface( cn(11), totalWidth * legWidth);
            thermalProblem.setNodeSurface( cn(12), totalWidth * legThickness);
            thermalProblem.setNodeSurface( cn(13), legWidth * windowHeight);
            thermalProblem.setNodeSurface( cn(14), legThickness * windowHeight);
            %
            % Node Connections description  [ node1 node2 conductivity distance surface]
            % core X resistance
            thermalProblem.insertA( cn(1), cn(2), kCore * ( legWidth * legThickness) / (legWidth/2 + windowWidth/2));
            thermalProblem.insertA( cn(2), cn(3), kCore * ( legWidth * legThickness) / (legWidth/2 + windowWidth/2));
            thermalProblem.insertA( cn(6), cn(7), kCore * ( legWidth * legThickness) / (legWidth/2 + windowWidth/2));
            thermalProblem.insertA( cn(7), cn(8), kCore * ( legWidth * legThickness) / (legWidth/2 + windowWidth/2));
            % core Z resistance
            thermalProblem.insertA( cn(1), cn(4), kCore * ( legWidth * legThickness) / (legWidth/2 + windowHeight/2));
            thermalProblem.insertA( cn(4), cn(6), kCore * ( legWidth * legThickness) / (legWidth/2 + windowHeight/2));
            thermalProblem.insertA( cn(3), cn(5), kCore * ( legWidth * legThickness) / (legWidth/2 + windowHeight/2));
            thermalProblem.insertA( cn(5), cn(8), kCore * ( legWidth * legThickness) / (legWidth/2 + windowHeight/2));
            % top and bottom core surfaces
            thermalProblem.insertA( cn(1), cn(9), kCore * ( legWidth * legThickness) / (legWidth/2) );
            thermalProblem.insertA( cn(2), cn(9), kCore * ( windowWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(3), cn(9), kCore * ( legWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(6), cn(12), kCore * ( legWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(7), cn(12), kCore * ( windowWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(8), cn(12), kCore * ( legWidth * legThickness) / (legWidth/2));
            % left external surface
            thermalProblem.insertA( cn(1), cn(14), kCore * ( legThickness * legWidth) / (legWidth/2));
            thermalProblem.insertA( cn(4), cn(14), kCore * ( legThickness * windowHeight) / (legWidth/2));
            thermalProblem.insertA( cn(6), cn(14), kCore * ( legThickness * legWidth) / (legWidth/2));
            % internal core surfaces
            thermalProblem.insertA( cn(2), cn(19), kCore * ( windowWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(7), cn(17), kCore * ( windowWidth * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(4), cn(18), kCore * ( legThickness * legThickness) / (legWidth/2));
            thermalProblem.insertA( cn(5), cn(16), kCore * ( legThickness * legThickness) / (legWidth/2));
            % front core top surfaces
            thermalProblem.insertA( cn(1), cn(10), kCore * ( legWidth * legWidth) / (legThickness/2));
            thermalProblem.insertA( cn(2), cn(10), kCore * ( windowWidth * legWidth) / (legThickness/2));
            thermalProblem.insertA( cn(3), cn(10), kCore * ( legWidth * legWidth) / (legThickness/2));
            thermalProblem.insertA( cn(6), cn(11), kCore * ( legWidth * legWidth) / (legThickness/2));
            thermalProblem.insertA( cn(7), cn(11), kCore * ( windowWidth * legWidth) / (legThickness/2));
            thermalProblem.insertA( cn(8), cn(11), kCore * ( legWidth * legWidth) / (legThickness/2));
            % front core side surface
            thermalProblem.insertA( cn(4), cn(13), kCore * ( legWidth * windowHeight) / (legThickness/2));
            thermalProblem.insertA( cn(5), cn(15), kCore * ( legWidth * windowHeight) / (legThickness/2));
            %
            % Natural convection
  %          thermalProblem.insertAsurface( cn(9),  cn(20), h);
            thermalProblem.insertAsurface( cn(10), cn(20), h);
            thermalProblem.insertAsurface( cn(11), cn(20), h);
            thermalProblem.insertAsurface( cn(12), cn(20), h);
            thermalProblem.insertAsurface( cn(13), cn(20), h);
            thermalProblem.insertAsurface( cn(14), cn(20), h);
            %
            % Radiation
  %          thermalProblem.insertDsurface( cn(9),  cn(20), constanteStefanBoltzmann * coreEmissivity);
            thermalProblem.insertDsurface( cn(10), cn(20), constanteStefanBoltzmann * coreEmissivity);
            thermalProblem.insertDsurface( cn(11), cn(20), constanteStefanBoltzmann * coreEmissivity);
            thermalProblem.insertDsurface( cn(12), cn(20), constanteStefanBoltzmann * coreEmissivity);
            thermalProblem.insertDsurface( cn(13), cn(20), constanteStefanBoltzmann * coreEmissivity);
            thermalProblem.insertDsurface( cn(14), cn(20), constanteStefanBoltzmann * coreEmissivity);

            % coreVolume => 4* legThickness * ( 2* lowerCoreSurface + 2* lateralLegSurface)
            coreVolume = 4* legThickness * ( 2*legWidth*totalWidth + 2*legWidth*windowHeight);
            lossesDensity = obj.outputData_.magnetic.coreLosses / coreVolume;
            % add losses
            cellfun( @(node) thermalProblem.insertZvolume( node, lossesDensity), num2cell(cn(1:8)));
        end
        function thermalProblemAddWinding( obj)
            constanteStefanBoltzmann = 5.670373e-8;
            windingEmissivity = 0.40;
            
            thermalProblem = obj.modelParameters_.thermal.problem;
            h = obj.getConvectionCoefficient;
            
            legWidth = obj.dimensions_.legWidth;
            legThickness = obj.dimensions_.legThickness/2;
            windowWidth = obj.outputData_.geometric.windowWidth;
            windowHeight = obj.outputData_.geometric.windowHeight;
            conductorWidth = obj.dimensions_.conductorWidth;
            interTurnSpace = obj.dimensions_.interTurnSpace;
            windingCoreDistance = obj.dimensions_.windingCoreDistance;
            
            kCond = obj.materials_.electricConductor.thermConduc;
            kInsu = obj.materials_.electricInsulation.thermConduc;
            kCondInsuSeries =   kCond* kInsu* ( conductorWidth + interTurnSpace)/( kCond* conductorWidth + kInsu* interTurnSpace);
            kCondInsuParallel = ( kCond* conductorWidth + kInsu* interTurnSpace )/( conductorWidth + interTurnSpace);
            % compensating winding head insulation (windingCoreDistance thickness)
            kCondInsuSeriesExternal =   kCondInsuSeries* kInsu* ( windowWidth/2 + windingCoreDistance)/( kCondInsuSeries* windowWidth/2 + kInsu* windingCoreDistance);
            kCondInsuParallelExternal = kCondInsuParallel* kInsu* ( windowHeight/2 + windingCoreDistance)/( kCondInsuParallel* windowHeight/2 + kInsu* windingCoreDistance);
            
            % winding Node
            wn(1) = 5;
            wn(2) = 10;
            wn(3) = 11;
            wn(4) = 14;
            wn(5) = 15;
            wn(6) = 16;
            wn(7) = 19;
            wn(8) = 22;
            wn(9) = 23;
            wn(10) = 24;
            wn(11) = 25;
            wn(12) = 26;
            wn(13) = obj.modelParameters_.thermal.airNodeIndex;
            
            % Volumes -> losses
            thermalProblem.setNodeVolume( wn(1), windowWidth * windowHeight * legThickness);
            thermalProblem.setNodeVolume( wn(2), windowWidth * windowHeight * windowWidth);
            thermalProblem.setNodeVolume( wn(3), legWidth * windowHeight * windowWidth);
            
            % Surfaces -> radiation and natural convection
            thermalProblem.setNodeSurface( wn(4), (windowWidth + legWidth) * windowWidth);
            thermalProblem.setNodeSurface( wn(5), (windowWidth + legWidth) * windowHeight);
            thermalProblem.setNodeSurface( wn(6), (windowWidth + legWidth) * windowWidth);
            thermalProblem.setNodeSurface( wn(7), windowWidth * windowHeight);
            
            % Resistences
            % internal resistences
            thermalProblem.insertA( wn(1), wn(2), kCondInsuParallel * (windowWidth * windowHeight) / (legThickness/2 + windowWidth/2));
            thermalProblem.insertA( wn(2), wn(3), kCondInsuParallel * (windowWidth * windowHeight) / (windowWidth/2 + legWidth/2));
            % top and bottom surfaces
            thermalProblem.insertA( wn(1), wn(10), kCondInsuParallelExternal * ( windowWidth * legThickness) / (windowHeight/2));
            thermalProblem.insertA( wn(1), wn(12), kCondInsuParallelExternal * ( windowWidth * legThickness) / (windowHeight/2));
            thermalProblem.insertA( wn(2), wn(4), kCondInsuParallelExternal * ( windowWidth * windowWidth) / (windowHeight/2));
            thermalProblem.insertA( wn(2), wn(6), kCondInsuParallelExternal * ( windowWidth * windowWidth) / (windowHeight/2));
            thermalProblem.insertA( wn(3), wn(4), kCondInsuParallelExternal * ( windowWidth * legWidth) / (windowHeight/2));
            thermalProblem.insertA( wn(3), wn(6), kCondInsuParallelExternal * ( windowWidth * legWidth) / (windowHeight/2));
            % radial surfaces
            thermalProblem.insertA( wn(1), wn(11), kCondInsuSeriesExternal * ( legThickness * windowHeight) / (windowWidth/2));
            thermalProblem.insertA( wn(2), wn(7), kCondInsuSeriesExternal * ( windowWidth * windowHeight) / (windowWidth/2));
            thermalProblem.insertA( wn(2), wn(5), kCondInsuSeriesExternal * ( windowWidth * windowHeight) / (windowWidth/2));
            thermalProblem.insertA( wn(3), wn(5), kCondInsuSeriesExternal * ( legWidth * windowHeight) / (windowWidth/2));
            thermalProblem.insertA( wn(1), wn(9), kCondInsuSeriesExternal * ( legThickness * windowHeight) / (windowWidth/2));
            thermalProblem.insertA( wn(3), wn(8), kCondInsuSeriesExternal * ( legWidth * windowHeight) / (windowWidth/2));
            
            % Natural convection
            thermalProblem.insertAsurface( wn(4), wn(13), h);
            thermalProblem.insertAsurface( wn(5), wn(13), h);
            thermalProblem.insertAsurface( wn(6), wn(13), h);
            thermalProblem.insertAsurface( wn(7), wn(13), h);
            
            % Radiation
            thermalProblem.insertDsurface( wn(4), wn(13), constanteStefanBoltzmann * windingEmissivity);
            thermalProblem.insertDsurface( wn(5), wn(13), constanteStefanBoltzmann * windingEmissivity);
            thermalProblem.insertDsurface( wn(6), wn(13), constanteStefanBoltzmann * windingEmissivity);
            thermalProblem.insertDsurface( wn(7), wn(13), constanteStefanBoltzmann * windingEmissivity);
            
            % windingVolume
            windingVolume = 4* windowWidth * windowHeight * ( legThickness + windowWidth + legWidth);
            lossesDensity = obj.outputData_.electric.jouleLosses / windingVolume;
            % add losses
            cellfun( @(node) thermalProblem.insertZvolume( node, lossesDensity), num2cell(wn(1:3)));
        end
    end
    
end

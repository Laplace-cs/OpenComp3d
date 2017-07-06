classdef Magnetic < Comp3d.Element
    % Magnetic is the superclass for all the magnetic components
    %
    %  inputs Magnetic properties:
    % correctValues       - Determines if the output should be corrected
    %                       with data calculated in FEMM simulations
    % coolingType         - type of cooling
    %                       [Forced_Convection,Natural_Convection]
    % vAir                - fluid speed for forced convection (m/s)
    % tAir                - air temperature (°C)
    %
    % conductorShape      - shape of conductor for the magnetic component:
    %                               {'round','rectangular'}
    % bobinageType        - type of bobinage for the magnetic component:
    %                               {'vertical','horizontal'}
    % bobinageForm        - type of bobinage assembly
    %                               {'stacked','concentric'}
    %
    %   See also Comp3d.Element, Comp3d.Component
    %

    properties (Access = protected)
        coreLossesModel_
        correctValues_
        rAcFactor_
        coolingFluid_
    end
    
    %% Constructor
    methods
        function obj = Magnetic(varargin)
            obj = obj@Comp3d.Element(varargin{:});
            obj.modelParameters_.magnetic = [];
            obj.outputData_.magnetic = [];
    
            obj.setDefaultParameters();
            obj.parse(varargin{:});
        end
    end
	
    %% Assistants Methods
	methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            update@Comp3d.Element(obj,varargin{:});
            obj.parse(varargin{:});
        end
    end
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj,varargin)
            obj.coreLossesModel_ = 'iGSE';
            obj.correctValues_ = false;
            
            obj.excitations_.thermal.coolingType = 'Natural_Convection';
            obj.excitations_.thermal.tAir = 25;
            obj.excitations_.thermal.vAir = 3;
            obj.coolingFluid_ = Fluid('type','Air','temperature',25);
            
            obj.constraints_.temperatureMax = 80;
            obj.constraints_.BsatRate = 0.95;
            
            % Other properties
            obj.shapeOptions_.conductorShape = {'rectangular','round'};
            obj.shape_.conductorShape = 'rectangular';
            
            obj.materialsType_.electricConductor = 'Conductor';
            obj.materialsType_.electricInsulation = 'Insulation';
            obj.materialsType_.magneticCore = 'Magnetic';
            
            % defaut materials for magnetic components
            % Specific to the winding
            obj.materials_.electricConductor = MaterialManager( obj.materialsType_.electricConductor, 1);
            obj.materials_.electricInsulation = MaterialManager( obj.materialsType_.electricInsulation, 1);
            % Specific to the core
            obj.materials_.magneticCore = MaterialManager( obj.materialsType_.magneticCore, 5);
            
          %    {'nameFields'}   {'unit'}   {'Variable Value'}    {'sign'}   {'fixed value'}
           constraintsTable = [ ...
                {'temperatureMax'},       {'°C'},  {'obj.outputData.thermal.temperature'},  {'<'},  {'obj.constraints.temperatureMax'} ; ... 
                {'Bmax'},      {'T'},  {'obj.outputData.magnetic.BMax'},  {'<'},  {'obj.constraints.BsatRate * obj.materials.magneticCore.Bsat'} ; ... 
                ];
          
            obj.constraintsObjects_ = [obj.constraintsObjects_,...
                OptimProblem.createConstraintArray(obj,constraintsTable)];
            
        end
        function parse(obj,varargin)
            % Parser instanciation
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('coreLossesModel', obj.coreLossesModel_, @ischar);
            p.addParameter('correctValues', obj.correctValues_, @islogical);
            
            p.addParameter('coolingType', obj.excitations_.thermal.coolingType, @ischar);
            p.addParameter('tAir', obj.excitations_.thermal.tAir, @isnumeric);
            p.addParameter('vAir', obj.excitations_.thermal.vAir, @(x) x>0);
            
            p.addParameter('temperatureMax', obj.constraints_.temperatureMax, @(x) x>0);
            p.addParameter('BsatRate', obj.constraints_.BsatRate, @(x) x>0);

            p.addParameter('conductorShape', obj.shape_.conductorShape, @ischar);
            
            % Matereals
            p.addParameter('electricConductor', obj.materials_.electricConductor);
            p.addParameter('electricInsulation', obj.materials_.electricInsulation);
            p.addParameter('magneticCore', obj.materials_.magneticCore);
            
            
            % Parsing
            p.parse(varargin{:});
            obj.coreLossesModel_ = p.Results.coreLossesModel;
            obj.correctValues_ = p.Results.correctValues;
            
            obj.excitations_.thermal.coolingType = p.Results.coolingType;
            obj.excitations_.thermal.vAir = p.Results.vAir;
            if obj.excitations_.thermal.tAir ~= p.Results.tAir
                obj.excitations_.thermal.tAir = p.Results.tAir;
                obj.coolingFluid_ = Fluid('type','Air','temperature',p.Results.tAir);
            end
            
            obj.constraints_.temperatureMax = p.Results.temperatureMax;
            obj.constraints_.BsatRate = p.Results.BsatRate;

            obj.shape_.conductorShape = p.Results.conductorShape;
            
            % Matereals
            obj.materials.electricConductor = p.Results.electricConductor;
            obj.materials.electricInsulation = p.Results.electricInsulation;
            obj.materials.magneticCore = p.Results.magneticCore;
        end
    end
    
    %%
    methods (Access = protected)
        function obj = computeCostOutputData(obj,varargin)
        end
    end
    
    %%
    % femm functions
    methods
        [rACfactor, LacLinear] = femmCompute(obj,freq);
    end
    methods (Access = protected)
        function femmLoadDraw(obj)
            % réinitialise la connexion à FEMM
            try
                openfemm;
            catch
                addpath('c:/femm42/mfiles');
                openfemm;
            end
            
            filename = regexprep( class(obj), 'Comp3d.', '');
            pathToGo = getpref('OpenComp3d','path');
            fullFileName = [pathToGo,'/OpenComp3d/PostProcessing/' filename '.fem'];
            
            persistent dimensions;
            if ~isempty(dimensions) && isequal( dimensions, obj.dimensions_) && exist(fullFileName, 'file') == 2
                opendocument(fullFileName)
            else
                opendocument([pathToGo,'/OpenComp3d/PreProcessing/fichierbase.FEM'])
                obj.femmDraw;
                mi_saveas(fullFileName);
                dimensions = obj.dimensions_;
            end
        end
        function femmDrawOuterBoundaryHalfCircle(~, radius)
            % Draw the outer boundary for the problem
            
            % Define an "asymptotic boundary condition" property.
            % This will mimic an "open" solution domain
            muo = pi * 4.e-7;
            mi_addboundprop('Asymptotic', 0, 0, 0, 0, 0, 0, 1/(muo*0.2), 0, 2);
            mi_clearselected();
            
            % Draw a half-circle to use as the outer boundary for the problem
            mi_drawarc([0 -radius; 0 radius], 180, 2.5);
            % Apply the "Asymptotic" boundary condition to the arc defining the boundary of the solution region
            mi_selectarcsegment(radius, 0);
            mi_setarcsegmentprop(2.5, 'Asymptotic', 0, 0);
            mi_clearselected();

            % Define an "A=0 boundary condition" property.
            mi_addboundprop('A=0', 0, 0, 0, 0, 0, 0, 0, 0, 0);
            mi_clearselected();

            % Axe de symétrie verticale
            mi_addsegment(0, -radius, 0, radius);
            % Condition de symétrie correspondante
            mi_selectsegment(0,0);
            mi_setsegmentprop('A=0', 0, 1, 1, 0);
            mi_clearselected();
        end
        function femmDrawWindingRound(obj, origin, material, circuit)
            nTurns = round(obj.dimensions_.nTurns);
            nLayers = round(obj.dimensions_.nLayers);
            nStrands = round(obj.dimensions_.nStrands);
            interLayerSpace = obj.dimensions_.interLayerSpace;
            interTurnSpace = obj.dimensions_.interTurnSpace;
            diameterW = obj.outputData_.geometric.diameterExtW;
            
            % Inside conductors with automesh for DC
            turnsLayer = round(nTurns / nLayers);
            
            dx = diameterW + interLayerSpace;
            dx = 0:dx:(nLayers-1)*dx;
            dx = dx + origin(1) + diameterW/2;
            
            dy = diameterW + interTurnSpace;
            dy = 0:dy:(turnsLayer-1)*dy;
            dy = origin(2) + dy - dy(end)/2 - diameterW/2;
            
            for ox = dx
                for oy1 = dy
                    oy2 = oy1 + diameterW;
                    mi_drawarc(ox,oy1,ox,oy2,180,10);
                    mi_drawarc(ox,oy2,ox,oy1,180,10)
                    mi_addblocklabel(ox, oy1+diameterW/2);
                    mi_selectlabel(  ox, oy1+diameterW/2);
                    mi_setblockprop( material, 1, 0, circuit, 0, 1, -nStrands); % mi_setblockprop(’blockname’, automesh, meshsize, ’incircuit’, magdir, group,turns)
                    mi_clearselected
                end
            end
        end
        function femmDrawWindingRectangular(obj, origin, material, circuit)
            oy = origin(2);
            
            nTurns = round(obj.dimensions_.nTurns);
            interTurnSpace = obj.dimensions_.interTurnSpace;
            conductorWidth = obj.dimensions_.conductorWidth;
            conductorHeight = obj.dimensions_.conductorHeight;
            
            dx = conductorWidth + interTurnSpace;
            dx = 0:dx:(nTurns-1)*dx;
            dx = dx + origin(1);
            
            for ox = dx
                mi_drawrectangle( ox, oy-conductorHeight/2, ox+conductorWidth, oy+conductorHeight/2);
                mi_addblocklabel( ox+conductorWidth/2, oy);
                mi_selectlabel(   ox+conductorWidth/2, oy);
                mi_setblockprop( material, 1, 0, circuit, 0, 1, -1);
                mi_clearselected
            end
        end
    end
    
    %% rAC calculation
    methods 
        function skinDepth = computeSkinDepth(obj, f)
            u0 = 4* pi* 1e-7;
            ro = obj.materials_.electricConductor.resisElec;
            u = u0* obj.materials_.electricConductor.mu_e;
            skinDepth = sqrt( ro/(pi*u) ./ f);
        end
        function rAcFactor = rAcFactorRound(obj, f, diameter)
            if nargin < 3
                diameter = obj.dimensions_.diameterW;
            end
            
            skinDepth = obj.computeSkinDepth(f);
            crossSection = pi .* (diameter^2)/4 ;
            perimeter = pi .* ( diameter - skinDepth);
            
            rAcFactor = abs( crossSection ./ ( perimeter .* skinDepth));
            rAcFactor = max( rAcFactor, 1);
        end
        function rAcFactor = rAcFactorRectangular(obj, f, width, height)
            if nargin < 3
                width = obj.dimensions_.conductorWidth;
                height = obj.dimensions_.conductorHeight;
            end
            
            skinDepth = obj.computeSkinDepth(f);
            crossSection = width * height;
            perimeter = 2*( width + height - 2* skinDepth);
            
            rAcFactor = abs( crossSection ./ ( perimeter .* skinDepth));
            rAcFactor = max( rAcFactor, 1);
        end
        function rAcFactor = rACFactorRoundSkin(obj,f,diameter)
              skinDepth = obj.computeSkinDepth(f);
              ghi = diameter ./(sqrt(2) * skinDepth);
              
              % We calculate the equivalent bessel functions
              be0 = besselj(0,ghi .* exp(3 * pi * 1i / 4));
              be1 = besselj(1,ghi .* exp(3 * pi * 1i / 4));
              be0r = real(be0);
              be0i = imag(be0);
              be1r = real(be1);
              be1i = imag(be1);
              
              % Calculation of the rACFactor
              rAcFactor = 2 * ghi ./(4 .* sqrt(2)) .* ((be0r .* be1i - be0r .* be1r) ./ (be1r .^2 + be1i .^2) - ...
                  (be0i .* be1r + be0i .* be1i) ./ (be1r .^2 + be1i .^2));
        end
    end
    
    %% LossDensity calculation
    % computeIronLosses
    methods  (Access = protected)
        function coreLosses = computeCoreLosses(obj, t, B)
            % This method computes core losses
            switch obj.coreLossesModel_
                case 'SE'
                    [ freqVec, Bfreq] = Comp3d.doFft( t, B);
                    coreLosses = obj.outputData_.geometric.volumeC * sum( obj.computeLossDensity( freqVec, Bfreq));
                case 'iGSE'
                    coreLosses = obj.outputData_.geometric.volumeC * obj.computeLossesDensityiGSE( t, B);
                otherwise
                    error('Comp3d.Inductor: coreLossesModel type not available.');
            end
        end   
        function [ LossDensity ] = computeLossDensity(obj, freq, Bfreq)
            %COMPUTELOSSDENSITY Compute loss density for a sinusoidal excitation.
            %
            % LossDensity = computeLossDensity(obj, freq, B)
            % * freq:         frequency [Hz]
            % * B:            induction density amplitude [T]
            % * LossDensity:  loss density [W/m^3]
            %
            % Three methods are implemented:
            % * Steinmetz
            % * FoFo
            % * Cussac
            %

            % FixMe: verify LossDensity unit [W/m^3] => shoud be SI
            
            
            %   
            %  Reviser VVVV
            % * Steinmetz is a common method: coefficients are fitted with the P(B) curves.
            %
            % * Oliver is claimed to be more accurate than Steinmetz over a wider frequency range for
            %  ferrite powder materials. Coeffs are calculated with the P(B) curves like in Steinmetz.
            %
            % * tan_delta method is used when the dependency with B is not given in the
            % datasheets. Losses are assumed to be in B^2. Coeffs are calculated with
            % the (mu',mu'') versus frequency curves at low induction.
            %
            % Formulas are:
            %       Steinmetz: P = 1e3* ((ct2*T^2 - ct1*T + ct0)
            %                     *(t + s*f^alpha_s + u*f^alpha_u + v*f^alpha_v)
            %                     * B^(w*f^beta_w + x*f^beta_x + z*f^beta_z + y))
            %
            %       Oliver:    P = 1e3 * f/(w/B^3 + x/B^2.3 + y/B^(1.65)) + z*(f*B)^2
            %
            %
            %       tan_delta: P = pi/mu_0 * f * B^2 * exp(t + s*f^(u))
            %
            coreMaterial = obj.materials_.magneticCore;
            temperature = obj.constraints_.temperatureMax;
            % Choose the computation method
            switch coreMaterial.model
                case 'Steinmetz'
                    TemperatureFactor = coreMaterial.ct2 * temperature^2 - coreMaterial.ct1 * temperature + coreMaterial.ct0;
                    FrequencyFactor = freq.^(coreMaterial.alpha_s);
                    BExponent = coreMaterial.y;
                    LossDensity = 1e3*((coreMaterial.k100).*TemperatureFactor .* FrequencyFactor .* Bfreq.^(BExponent));
                case 'FoFo'
                    TemperatureFactor = coreMaterial.ct2 * temperature^2 - coreMaterial.ct1 * temperature + coreMaterial.ct0;
                    FrequencyFactor = (coreMaterial.s).*freq.^(coreMaterial.alpha_s) ...
                        + (coreMaterial.u).*freq.^(coreMaterial.alpha_u);
                    BExponent = coreMaterial.y;
                    LossDensity =  1e3 .*((coreMaterial.k100) .* TemperatureFactor .* FrequencyFactor .* Bfreq.^(BExponent));
                case 'Cussac'
                    TemperatureFactor = coreMaterial.ct2 * temperature^2 - coreMaterial.ct1 * temperature + coreMaterial.ct0;
                    
                    FrequencyFactor = coreMaterial.t ...
                        + (coreMaterial.s).*freq.^(coreMaterial.alpha_s) ...
                        + (coreMaterial.u).*freq.^(coreMaterial.alpha_u) ...
                        + (coreMaterial.v).*freq.^(coreMaterial.alpha_v);
                    BExponent = (coreMaterial.w).*freq.^(coreMaterial.beta_w) ...
                        + (coreMaterial.y) ...
                        + (coreMaterial.x).*freq.^(coreMaterial.beta_x) ...
                        + (coreMaterial.z).*freq.^(coreMaterial.beta_z);
                    
                    LossDensity = 1e3*((coreMaterial.k100).*TemperatureFactor .* FrequencyFactor .* Bfreq.^(BExponent));
                otherwise
                    error(['Model ',(coreMaterial.model),' is not implemented yet.']);
            end
        end
        function [ LossDensity ] = computeLossesDensityiGSE(obj, t, B, plotFlag)
            % Calculates coreloss density in a magnetic material
            %
            % CoreLoss(obj, t, B)
            % * t:            time vector [s]
            %                 t shall be defined like [0,T[
            %                 diff(t) shall be constant and start with zero
            % * B:            induction vector [T]
            %                 B shall be properly sampled
            % * LossDensity:  loss density [W/m^3] 
            
            % FixMe: verify LossDensity unit [W/m^3] => shoud be SI
            
            
            %   
            %  Reviser VVVV
            %
            %--------------------------------------------------------------------------
            %  Calculation are based on the Forest & Sullivan Model:
            %  - Forest model is a modified Steinmetz model valid over an extended frequency range:
            %    P(f,Bpk)=(K1*(f^alpha1)+K2*(f^alpha2))*Bpk^(beta-abeta*f)
            %  - Sullivan model uses the Steinmetz coefficients to evaluate the influence of the dB/dt
            
            % Parameters of the core material
            % Fs_alpha=s*nsFs^alpha_s+t+u*nsFs^alpha_u+v*nsFs^alpha_v;                %	Polynome en f
            % beta_Fs=w*nsFs^beta_w+y+x_*nsFs^beta_x+z*nsFs^beta_z;                   %	Exposant de B
            % DPcoreW = Cm*(ct2*Tc^2-ct1*Tc+ct0)*Fs_alpha*((BhfW/2)^beta_Fs);   % Core Losses Density in kW/m3

            material = obj.materials_.magneticCore;
            temperature = obj.constraints_.temperatureMax;
            
            % Check model
            if ~strcmp( material.model, 'FoFo') && ~strcmp( material.model, 'Steinmetz')
                disp('Warning : CoreLoss.m only valid for Steinmetz or Forest models. Check your model in "materials.xls"');
            end
            
            % Assign model parameters
            K1 = material.s * material.k100 * (material.ct2* temperature^2 - material.ct1* temperature + material.ct0);
            alpha1 = material.alpha_s;
            K2 = material.u * material.k100 * (material.ct2* temperature^2 - material.ct1* temperature + material.ct0);
            alpha2 = material.alpha_u;
            beta = material.y;
            abeta = -material.z;
            
            %------------------------------------------------------------------------------------
            % Transposition en paramètres modèle P(dB/dt,Bpk)          (Modèle Forest & Sullivan)
            % P(dB/dt,Bpk) = C1.(abs(dB/dt)^x1)*(Bpk^(y1-yf.f))+C2.(abs(dB/dt)^x2)).(Bpk^(y2-yf.f))
            Precis = 2000;
            Integ1 = sum((sin((0:1/Precis:1)*pi/2)).^alpha1)/(Precis+1);
            Integ2 = sum((sin((0:1/Precis:1)*pi/2)).^alpha2)/(Precis+1);
            C1 = K1/((2*pi)^alpha1)/Integ1;
            C2 = K2/((2*pi)^alpha2)/Integ2;
            x1 = alpha1;
            x2 = alpha2;
            y1 = beta-alpha1;
            y2 = beta-alpha2;
            yf = abeta;
            %------------------------------------------------------------------------------------
            
            function [E,P] = computeCycleEnergy(B,t)
                % Calcul de l'énergie du cycle
                Bpk = (max(B)-min(B))/2;
                T = max(t)-min(t)+diff(t(1:2));
                BetaCycMaj1 = max(y1-yf/T,0);
                BetaCycMaj2 = max(y2-yf/T,0);
                dB = diff([B B(1)]);
                dt = diff([t t(end)+diff(t(1:2))]);
                P = (C1*abs(dB./dt).^x1) * (Bpk^BetaCycMaj1) + (C2*abs(dB./dt).^x2) * (Bpk^BetaCycMaj2);
                E = sum(P.*dt);
            end
            function indexMinorCycle = findIndexMinorCycle(B)
                % build a list with an index flag for each Minor Cycle in B when a local max is followed by a local min
                
                % start B at the minimum
                [~,index] = min(B);
                B = circshift(B,[0 -index+1]);

                % search local max/min values and indexes
                [pksMax, idLocalMax] = findPeaksOfMagneticWaveform([B B(1)]);
                [~, idLocalMin] = findPeaksOfMagneticWaveform( -B);
                idLocalMin = [1 idLocalMin];
                pksMin = B(idLocalMin);

                % peaks diff of max/min
                diffPksMax = diff(pksMax);
                diffPksMin = diff(pksMin);
                % remove flag is true when there is a local max followed by a local min
                removeA = [ (diffPksMax >= 0)&(diffPksMin >= 0) 0];
                removeB = circshift( removeA,[0 1]);
                
                % take index values of max/min to remove, the next max and previous min
                idMax = idLocalMax( removeA == 1);
                idMaxNext = idLocalMax( removeB == 1);
                idMin = idLocalMin( removeB == 1);
                idMinPrev = idLocalMin( removeA == 1);
                
                % flags for B between mins/maxs
                fullIndex = 1:length(B);
                minFlagList = cellfun( @(id1,id2) (fullIndex >= id1)&(fullIndex <= id2), num2cell(idMax), num2cell(idMaxNext), 'UniformOutput', false);
                maxFlagList = cellfun( @(id1,id2) (fullIndex >= id1)&(fullIndex <= id2), num2cell(idMinPrev), num2cell(idMin), 'UniformOutput', false);

                % mean value between local max and local min
                mean_ = cellfun( @(idMax,idMin) mean( B(idMax:idMin)), num2cell(idMax), num2cell(idMin) );
                
                indexMinorCycle = cellfun( @(val, minFlag, maxFlag) ((B>=val)&maxFlag)|((B<val)&minFlag)|(maxFlag&minFlag), num2cell(mean_), minFlagList, maxFlagList, 'UniformOutput', false);
                
                % realigns indexMinorCycle with the original B vector
                indexMinorCycle = cellfun( @(indexMC) circshift(indexMC,[0 index-1]), indexMinorCycle, 'UniformOutput', false);
            end
            function bCycleList = buildCycleList(B)
                % build a list with all minor cycles, including the fundamental
                
                % sweep sign of B
                signB = 1;
                % break all cycles in minor cycles
                bCycleList = {};
                while ~isempty(B)
                    % searck minor cycles
                    indexMinorCycle = findIndexMinorCycle( signB*B);

                    if ~isempty( indexMinorCycle)
                        % put minor cycles in the list
                        bCycleList = [ bCycleList cellfun( @(index) B( index == 1 ), indexMinorCycle, 'UniformOutput', false)];
                        % remove minor cycles of B vector
                        B = B( sum( cell2mat(indexMinorCycle'),1) == 0 );
                    else
                        if length( [findPeaksOfMagneticWaveform(B) findPeaksOfMagneticWaveform(-B)] ) < 3
                            % there is no more minor cycles, put remaining  B vector in the list
                            bCycleList = [ bCycleList {B}];
                            break;
                        end
                    end

                    % change B sign to find minor cycles in the other direction
                    signB = -1 * signB;
                end
            end
            function [values,idx] = findPeaksOfMagneticWaveform(vector)
                booleanVector = ((([1e23,vector(1:end-1)] < vector)) .* (vector > [vector(2:end),1e23]));
                idx = find(booleanVector);
                values = vector(idx);
            end
            %------------------------------------------------------------------------------------
            % build Minor Cycle List
            bCycleList = buildCycleList(B);
            % create time vector in function of B length
            tMinorCycleList = cellfun( @(Bmc) t(1:length(Bmc)), bCycleList, 'UniformOutput', false);
            % compute Cycle Energy and Power for each minor cycle
            [~,P] = cellfun( @(B,t) computeCycleEnergy(B,t), bCycleList, tMinorCycleList, 'UniformOutput', false);
            % LossDensity
            LossDensity = 1e3 * mean([P{:}]);
            %------------------------------------------------------------------------------------
            
            if nargin < 5
                plotFlag = 0;
            end
            if plotFlag == 1
                figure
                hold on
                grid on
                cellfun( @(Bmc) plot(Bmc,'-+'), bCycleList)
            end
        end
        function R = computeIronLossesElectricalResistance(obj, f, volume)
            % Calculation of the equivalent resistance representing the core losses (Hyp: Beta = 2)
            losses = volume * obj.computeLossDensity( f, 1);
            R = ( obj.dimensions_.nTurns^2 * (2*pi)^2 * obj.outputData_.geometric.magneticArea ) * f.^2./(2*losses);
            
        end
        function R = computeIronLossesMagneticResistance(obj, f, volume, A)
            losses = volume * obj.computeLossDensity( f, 1);
            R = (2*pi)^2 * f.^2 ./ (2*A^2 * losses);
            if any(isnan(R(1)))
                R(1) = R(2);
            end
        end
    end
    
    methods  (Access = protected)
        function h = getConvectionCoefficient(obj)
            switch obj.excitations_.thermal.coolingType
                case 'Natural_Convection'
                    h = 7;
                case 'Forced_Convection'
                    airSpeed = obj.excitations_.thermal.vAir;
                    h = 10.45 - airSpeed + 10 * sqrt(airSpeed);
                otherwise
                    error([obj.thermalData_.coolingType,' cooling type not known'])
            end
        end
        

    end
end


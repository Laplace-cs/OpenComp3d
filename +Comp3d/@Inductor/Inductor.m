classdef Inductor < Comp3d.Magnetic
    % Inductor  is the mother class for all the inductor objects
    %
    %
    %   See also Inductor < Comp3d.Magnetic
    
    % Constructor Method
    methods
        function obj = Inductor(varargin)
            obj = obj@Comp3d.Magnetic(varargin{:});
            obj.setDefaultParameters();
            obj.parse(varargin{:});
        end
    end
    
    %% Assistants Methods
    methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            obj.update@Comp3d.Magnetic(varargin{:});
            obj.parse(varargin{:});
        end
    end
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj,varargin)
            
            obj.constraints_.Leq = [];
            obj.constraints_.Lmax = [];
            obj.constraints_.Lmin = [];
            obj.constraints_.iDc = [];
            obj.constraints_.iMax = [];
            obj.constraints_.iRMSmax = [];
            obj.constraints_.iRippleMax = [];
            
            obj.excitations_.electric = struct('freq',[],'ifft',[],'time',[],'current',[],'voltage',[]);
            
            %    {'nameFields'}   {'unit'}   {'Variable Value'}    {'sign'}   {'fixed value'}
           constraintsTable = [ ...
                {'Leq'},       {'H'},  {'obj.modelParameters.electric.Lmodel.val'},  {'='},  {'obj.constraints.Leq'} ; ... 
                {'Lmax'},      {'H'},  {'obj.modelParameters.electric.Lmodel.val'},  {'<'},  {'obj.constraints.Lmax'} ; ... 
                {'Lmin'},      {'H'},  {'obj.modelParameters.electric.Lmodel.val'},  {'>'},  {'obj.constraints.Lmin'} ; ... 
                {'iDC'},       {'A'},  {'obj.outputData.electric.iDc'},             {'='},  {'obj.constraints.iDc'} ; ... 
                {'iMax'},      {'A'},  {'obj.outputData.electric.iMax'},            {'='},  {'obj.constraints.iMax'} ; ... 
                {'iRMSmax'},   {'A'},  {'obj.outputData.electric.iRMS'},            {'<'},  {'obj.constraints.iRMSmax'} ; ... 
                {'iRippleMax'},{'A'},  {'obj.outputData.electric.iRipple'},         {'<'},  {'obj.constraints.iRippleMax'} ; ... 
                ];
          
            obj.constraintsObjects_ = [obj.constraintsObjects_,...
                OptimProblem.createConstraintArray(obj,constraintsTable)];
        end
        function parse(obj,varargin)
            % Specific to the inductor
            q = inputParser;
            q.KeepUnmatched = true;
            
            % Specific to the core
            q.addParameter( 'Leq', obj.constraints_.Leq, @(x) x>0);
            q.addParameter( 'Lmax', obj.constraints_.Lmax, @(x) x>0);
            q.addParameter( 'Lmin', obj.constraints_.Lmin, @(x) x>0);
            q.addParameter( 'iMax', obj.constraints_.iMax, @(x) x>0);
            q.addParameter( 'iRMSmax', obj.constraints_.iRMSmax, @(x) x>0);
            q.addParameter( 'iRippleMax', obj.constraints_.iRippleMax, @(x) x>0);
            q.parse(varargin{:});
            obj.constraints_.Leq = q.Results.Leq;
            obj.constraints_.Lmax = q.Results.Lmax;
            obj.constraints_.Lmin = q.Results.Lmin;
            obj.constraints_.iMax = q.Results.iMax;
            obj.constraints_.iRMSmax = q.Results.iRMSmax;
            obj.constraints_.iRippleMax = q.Results.iRippleMax;
        end
    end
    
    %%
    methods
        function setExcitations(obj, varargin)
            p = inputParser;
            p.KeepUnmatched = true;

            p.addParameter( 'time', []);
            p.addParameter( 'voltage', []);
            p.addParameter( 'current', []);

            p.parse(varargin{:});
            obj.excitations_.electric = p.Results;
            
            if ~isempty( obj.excitations_.electric.time) && ~isempty( obj.excitations_.electric.current)
                time = obj.excitations_.electric.time;
                current = obj.excitations_.electric.current;
                [freq, ifft] = Comp3d.doFft( time, current);
                obj.excitations_.electric.freq = freq;
                obj.excitations_.electric.ifft = ifft;
            end
        end
        function drawExcitations(obj)
            figure
            subplot(2,1,1)
            if ~isempty( obj.excitations.electric.voltage)
                plot( obj.excitations.electric.time, obj.excitations.electric.voltage)
            end
            grid on
            xlabel('time [s]')
            ylabel('voltage [V]')
            subplot(2,1,2)
            if ~isempty( obj.excitations.electric.current)
                plot( obj.excitations.electric.time, obj.excitations.electric.current)
            end
            grid on
            xlabel('time [s]')
            ylabel('current [A]')
        end
    end
    
    %% Post-processing and validation methods
    methods
        function validateFEMM(obj)
        end
    end
    

    
    %% Display
    methods
        function displayInformation(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            obj.displayInformation@Comp3d.Element(fid);
            
            fprintf(fid,'%s\n', 'Electric Parameters');
            fprintf(fid,'%30s: %6.4g %s\n', 'Inductance', obj.modelParameters_.electric.L, 'H');
            fprintf(fid,'%30s: %6.4g %s\n', 'DC resistance', obj.modelParameters_.electric.rS, 'Ohm');
            fprintf(fid,'%s\n','----------------------------------------------------');
            if ~isempty( obj.outputData_.electric)
                fprintf(fid,'%s\n', 'Output data');
                fprintf(fid,'%30s: %6.4g %s\n', 'Current Dc', obj.outputData_.electric.iDc, 'A');
                fprintf(fid,'%30s: %6.4g %s\n', 'Current Max', obj.outputData_.electric.iMax, 'A');
                fprintf(fid,'%30s: %6.4g %s\n', 'Current RMS', obj.outputData_.electric.iRMS, 'A');
                fprintf(fid,'%30s: %6.4g %s\n', 'Current Ripple', obj.outputData_.electric.iRipple, 'A');
                fprintf(fid,'%30s: %6.4g %s\n', 'Current Density', obj.outputData_.electric.jRms*1e-6, 'A/mm²');
                fprintf(fid,'%30s: %6.4g %s\n', 'Joules losses', obj.outputData_.electric.jouleLosses, 'W');
                fprintf(fid,'%30s: %6.4g %s\n', 'B Max', obj.outputData_.magnetic.BMax , 'Tesla');
                fprintf(fid,'%30s: %6.4g %s\n', 'Core losses', obj.outputData_.magnetic.coreLosses, 'W');
                fprintf(fid,'%30s: %6.4g %s\n', 'Temperature', obj.outputData_.thermal.temperature, '°C');
            else
                fprintf(fid,'%s\n','Output data (losses, temperature...) not calculated yet'); 
            end
            fprintf(fid,'%s\n','====================================================');
            
        end
    end
    
    %%
    methods (Access = protected)
        function computeThermalModelParametersLv1(obj)
            h = 10;
            obj.modelParameters_.thermal.rTh = 1 / (h * obj.outputData_.geometric.externalArea);
        end
    end
    
    methods (Access = protected)
        function computeElectricOutputDataLv1(obj)
            obj.outputData_.electric.iDc =  mean(obj.excitations_.electric.current);
            obj.outputData_.electric.iMax = max(abs(obj.excitations_.electric.current));
            obj.outputData_.electric.iRMS = sqrt( sum(obj.excitations_.electric.current .* obj.excitations_.electric.current) / length(obj.excitations_.electric.current) );
            obj.outputData_.electric.iRipple = max(obj.excitations_.electric.current) - min(obj.excitations_.electric.current);
            
            obj.outputData_.electric.jouleLosses = obj.modelParameters_.electric.rS * obj.outputData_.electric.iRMS^2;
            obj.outputData_.electric.jRms = obj.outputData_.electric.iDc / obj.outputData_.geometric.sectionW;
            
            obj.computeMagneticOutputData;
        end
        function computeElectricOutputDataLv2(obj)
            obj.outputData_.electric.iDc =  mean(obj.excitations_.electric.current);
            obj.outputData_.electric.iMax = max(abs(obj.excitations_.electric.current));
            obj.outputData_.electric.iRMS = sqrt( sum(obj.excitations_.electric.current .* obj.excitations_.electric.current) / length(obj.excitations_.electric.current) );
            obj.outputData_.electric.iRipple = max(obj.excitations_.electric.current) - min(obj.excitations_.electric.current);
            
            obj.outputData_.electric.jRms = obj.outputData_.electric.iRMS / obj.outputData_.geometric.sectionW;
            
            freq = obj.excitations_.electric.freq;
            ifft = obj.excitations_.electric.ifft;
            ifft(freq>0) = ifft(freq>0) / sqrt(2);
            
            rACmodelFreqValVec = obj.modelParameters_.electric.rACmodel.freqValVec;
            rACmodelFreqVec = obj.modelParameters_.electric.rACmodel.freqVec;
            rAC = [ rACmodelFreqValVec(rACmodelFreqVec==0) interp1( log10(rACmodelFreqVec(rACmodelFreqVec>0)), rACmodelFreqValVec(rACmodelFreqVec>0), log10(freq(freq>0)), 'pschip', 'extrap')];
            
            obj.outputData_.electric.jouleLosses = sum( rAC.*(ifft.^2) );
            
            obj.computeMagneticOutputData;
        end
        function computeMagneticOutputData(obj)
            % Calculation of the induction inside the inductor
            t = obj.excitations_.electric.time;
            current = obj.excitations_.electric.current;
            B =  current .* obj.modelParameters_.electric.Lmodel.val ./ (obj.dimensions_.nTurns .* obj.outputData_.geometric.magneticArea) ;
            obj.outputData_.magnetic.BMax = max(abs(B));
            
            obj.outputData_.magnetic.coreLosses = obj.computeCoreLosses( t, B);
        end
        function computeThermalOutputDataLv1(obj)
            obj.outputData_.thermal.losses = obj.outputData_.electric.jouleLosses + obj.outputData_.magnetic.coreLosses;
            obj.outputData_.thermal.temperature = obj.modelParameters_.thermal.rTh * obj.outputData_.thermal.losses + obj.excitations_.thermal.tAir;
        end
    end
    
    %% femm
    methods (Access = protected)
        function femmUpdateMaterials(obj)
            % Set conductor resistivity (MS/m)
            ro = obj.materials.electricConductor.resisElec;
            mi_modifymaterial('Conductor',5,1e-6/ro);

            Mur = obj.materials.magneticCore.mu_e;
            % Set core permeability in x-axis
            mi_modifymaterial('Magnetic',1,Mur)
            % Set core permeability in y-axis
            mi_modifymaterial('Magnetic',2,Mur)
        end
    end
end

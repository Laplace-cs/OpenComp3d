classdef FanDiscreteDC < Comp3d.Element & Cooling.Air
   % FanDiscrete represents a DC fan where all the data cames from a database
   % and a piramidal tube to adapt to the surface of a heatink
   %
   % FanDiscrete inputs:
   % referenceFan   - reference of the fan (part number or id from
   %                   database)
   % widthOutTube   - width of the outer part of the tube (m)
   % heightOutTube  - height of the outer part of the tube (m)
   % lengthTube     - length of perpendicular axe of the tube (m)
   % thicknessFanTube  - thickness of the tube (m)
   % materialTube      - materialTube
   %
   % <a href="matlab:help Comp3d.Element">Comp3d.Element</a> for other properties / methods 
   properties (Access = {?Comp3d.RectangularFins, ?Comp3d.HeatSink})
       % Hidden property
       airSpeed
   end
   
   % Constructor 
   methods
       function obj = FanDiscreteDC(varargin)
            obj = obj@Comp3d.Element(varargin{:});
            obj.setDefaultParameters();
            obj.parse(varargin{:});
       end
   end
   
      %% Auxiliary
      methods ( Access = protected, Hidden = true )
        function update(obj,varargin)
            update@Comp3d.Element(obj,varargin{:});
            obj.parse(varargin{:});
        end
      end
   
    %% Definition methods
    methods ( Access = private, Hidden = true )
        function setDefaultParameters(obj,varargin)
            obj.outputData_.geometric.volumeFan = 0;
            obj.outputData_.geometric.weightFan = 0;
            
            obj.materials_.materialTube = MaterialManager('Conductor',2);
            
            freedomDegrees = [ ...
                {'thicknessFan'},         {'m'},    0.035,        0.04,      0.08,         'setToX0',     {[]}; ... % thicknessFan (m)
                {'sideDistanceFan'},      {'m'},    0.035,        0.04,      0.08,         'setToX0',     {[]}; ... % sideDistanceFan (m)
                {'lengthTube'},            {'m'},    0.001,        0.02,      0.1,         'setToX0',     {[]}; ... % lengthTube (m)
                {'widthOutTube'},          {'m'},    0.001,        0.02,      0.1,         'setToX0',     {[]}; ... % widthOutTube (m)
                {'heightOutTube'},         {'m'},    0.001,        0.02,      0.1,         'setToX0',     {[]}; ... % heightOutTube (m)
                {'thicknessFanTube'},         {'m'},    1e-3,        1e-3,      0.01,         'setToX0',     {[]}; ... % thicknessFanTube (m)
                     ];
             obj.freedomDegrees_.createFreedomDegreesFromTable(obj,freedomDegrees);
             obj.shape_.partNumber = '109P0424J3013';
        end
        function parse(obj,varargin)
           p = inputParser;
           p.KeepUnmatched = true;
           p.addParameter('referenceFan',obj.shape_.partNumber);
           p.addParameter('lengthTube',obj.dimensions_.lengthTube,@(x) x>0);
           p.addParameter('widthOutTube',obj.dimensions_.widthOutTube,@(x) x>0);
           p.addParameter('heightOutTube',obj.dimensions_.heightOutTube,@(x) x>0);
           p.addParameter('thicknessFanTube',obj.dimensions_.thicknessFanTube,@(x) x>0);
           p.addParameter('materialTube',obj.materials_.materialTube.id);
           p.parse(varargin{:});
           
           % We load the fan from the database and then we set each field
           % value
           dataFan = DatabaseManager('Fan','DCFan',p.Results.referenceFan);
           
           % Shape
           obj.shape_.manufacturer = dataFan.manufacturer;
           obj.shape_.partNumber = dataFan.name;
           obj.shape_.idDataBase = dataFan.id;
           
           % Dimensions
           obj.dimensions_.sideDistanceFan = dataFan.length;
           obj.dimensions_.thicknessFan = dataFan.thickness;
           obj.dimensions_.widthOutTube = p.Results.widthOutTube;
           obj.dimensions_.lengthTube = p.Results.lengthTube;
           obj.dimensions_.heightOutTube = p.Results.heightOutTube;
           obj.dimensions_.thicknessFanTube = p.Results.thicknessFanTube;
           
           % Materials
           obj.materials_.materialTube = MaterialManager('Conductor',p.Results.materialTube);
           
           % Geometric Data
           obj.outputData_.geometric.volumeFan = dataFan.volume;
           obj.outputData_.geometric.weightFan = dataFan.weight;
           obj.outputData_.geometric.speed = dataFan.speed; 
           obj.outputData_.geometric.noise = dataFan.noise;
           
           % Cost Data
           % Exchange reference : 1$ = 0.93 €
           obj.outputData_.cost.total = dataFan.price * 0.93;
            
           % Pressure losses curve
           % Volumetric Flow
           volumetricFlow = {                          dataFan.Q1,...
                                                       dataFan.Q2,...
                                                       dataFan.Q3,...
                                                       dataFan.Q4,...
                                                       dataFan.Q5,...
                                                       dataFan.Q6,...
                                                       dataFan.Q7,...
                                                       dataFan.Q8,...
                                                       dataFan.Q9,...
                                                       dataFan.Q10,...
                                                       dataFan.Q11,...
                                                       dataFan.Q12,...
                                                       dataFan.Q13,...
                                                       dataFan.Q14,...
                                                       dataFan.Q15};
              out = cellfun(@(elt) ~ischar(elt),volumetricFlow,'UniformOutput',false);
              idxVolumetric = find([out{:}]);
                                                   
          % Pressure losses                                        
         deltaPressure   = {                          dataFan.P1,...
                                                       dataFan.P2,...
                                                       dataFan.P3,...
                                                       dataFan.P4,...
                                                       dataFan.P5,...
                                                       dataFan.P6,...
                                                       dataFan.P7,...
                                                       dataFan.P8,...
                                                       dataFan.P9,...
                                                       dataFan.P10,...
                                                       dataFan.P11,...
                                                       dataFan.P12,...
                                                       dataFan.P13,...
                                                       dataFan.P14,...
                                                       dataFan.P15};
                                                   out = cellfun(@(elt) ~ischar(elt),deltaPressure,'UniformOutput',false);
                                                   idxPressure = find([out{:}]);
                                                   finalIdx = intersect(idxVolumetric,idxPressure);
                                                   volumetricFlowFinal = [volumetricFlow{finalIdx}];
                                                   deltaPressureFinal = [deltaPressure{finalIdx}];
            obj.outputData_.geometric.volumetricFlow = volumetricFlowFinal;
            obj.outputData_.geometric.deltaPressure =  deltaPressureFinal;
                                                   
            % Electric Parameters
            obj.modelParameters_.electric.voltageMin = dataFan.vMin;
            obj.modelParameters_.electric.voltage = dataFan.voltage;
            obj.modelParameters_.electric.voltageMax = dataFan.vMax;
            obj.modelParameters_.electric.power = dataFan.power;
        end
    end
    
     %% Display method
     methods
         function displayInformation(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            obj.displayInformation@Comp3d.Element(fid);
         end
         function displayPressureLossesCurve(obj,varargin)
             if nargin == 1
                figure()
                xlabel('Volumetric flow [m^3/s]');
                ylabel('Pressure Losses [Pa]');
             end
             hold on
             plot(obj.outputData_.geometric.volumetricFlow,obj.outputData_.geometric.deltaPressure,'LineWidth',2);
         end
     end
     %% Draw method
     methods
         function drawComponent(obj,offset,varargin)
             if nargin < 2
                offset = [1 0 0];
                figure
                hold on
                xlabel('Width (m)');
                ylabel('Length (m)');
                zlabel('Height (m)');
             end
            
             % Drawing of the fan
             dimensions = [obj.dimensions.sideDistanceFan ,obj.dimensions.sideDistanceFan,obj.dimensions.thicknessFan];
             xFanOffset = offset(1) + (obj.dimensions_.widthOutTube - obj.dimensions_.sideDistanceFan)/2;
             yFanOffset = offset(2);
             zFanOffset = offset(3) + (obj.dimensions_.heightOutTube - obj.dimensions_.sideDistanceFan)/2;
             drawParallelepipedWithHole(dimensions,0.45*obj.dimensions.sideDistanceFan,[0,1,0],[xFanOffset,zFanOffset,yFanOffset],[0,0,0]);
             
             % Drawing of the tube
             % Lower
             color = [0.4,0.4,0.4];
             xPoints = [xFanOffset,xFanOffset+obj.dimensions_.sideDistanceFan,offset(1)+obj.dimensions_.widthOutTube,offset(1)];
             yPoints = offset(2) + obj.dimensions_.thicknessFan + [0,0,obj.dimensions_.lengthTube,obj.dimensions_.lengthTube]; 
             zPoints = [zFanOffset,zFanOffset,offset(3),offset(3)];
             fill3(xPoints,yPoints,zPoints,color,'FaceAlpha',0.5);
             
             % Side
              xPoints = [xFanOffset,xFanOffset,offset(1),offset(1)];
              zPoints = [zFanOffset,zFanOffset+obj.dimensions_.sideDistanceFan,offset(3)+obj.dimensions_.heightOutTube,offset(3)];
              fill3(xPoints,yPoints,zPoints,color,'FaceAlpha',0.5);
              
              % Side
              xPoints = [xFanOffset+obj.dimensions_.sideDistanceFan,xFanOffset+obj.dimensions_.sideDistanceFan,offset(1)+obj.dimensions_.widthOutTube,offset(1)+obj.dimensions_.widthOutTube];
              zPoints = [zFanOffset,zFanOffset+obj.dimensions_.sideDistanceFan,offset(3)+obj.dimensions_.heightOutTube,offset(3)];
              fill3(xPoints,yPoints,zPoints,color,'FaceAlpha',0.5);
              
              % Top 
              xPoints = [xFanOffset,xFanOffset+obj.dimensions_.sideDistanceFan,offset(1)+obj.dimensions_.widthOutTube,offset(1)];
              zPoints = [zFanOffset+obj.dimensions_.sideDistanceFan,zFanOffset+obj.dimensions_.sideDistanceFan,offset(3)+obj.dimensions_.heightOutTube,offset(3)+obj.dimensions_.heightOutTube];
              fill3(xPoints,yPoints,zPoints,color,'FaceAlpha',0.5);
         end
     end
     
     %% Choosing interface
     methods
         function chooseFanGUI(obj)
            % We load the DC fan database
            load MatDCfan
            dataBase = MatDCfan;
             obj.Interface(dataBase);
         end
     end
     
     %% 
     methods (Access = protected)
         function Interface(obj,dataBase)
                                     f = figure('Position',[200 100 1100 800]);
            tgroup = uitabgroup('Parent', f);
            tab1 = uitab('Parent', tgroup, 'Title', 'Fan DataBase');
            
            manufacturerField = arrayfun(@(elt) elt.manufacturer,dataBase,'UniformOutput',false);
            nameField = arrayfun(@(elt) elt.name,dataBase,'UniformOutput',false);
            idDataBaseField = arrayfun(@(elt) elt.id,dataBase,'UniformOutput',false);
            sideDimensionField = arrayfun(@(elt) elt.length,dataBase,'UniformOutput',false);
            thicknessFanField = arrayfun(@(elt) elt.thickness,dataBase,'UniformOutput',false);
            volumeField = arrayfun(@(elt) elt.volume,dataBase,'UniformOutput',false);
            weightField = arrayfun(@(elt) elt.weight,dataBase,'UniformOutput',false);
            noiseField = arrayfun(@(elt) elt.noise,dataBase,'UniformOutput',false);
            speedField = arrayfun(@(elt) elt.speed,dataBase,'UniformOutput',false);
            vMinField = arrayfun(@(elt) elt.vMin,dataBase,'UniformOutput',false);
            vMaxField = arrayfun(@(elt) elt.vMax,dataBase,'UniformOutput',false);
            priceField = arrayfun(@(elt) elt.price,dataBase,'UniformOutput',false);
            powerField = arrayfun(@(elt) elt.power,dataBase,'UniformOutput',false);
            matBooleans = arrayfun(@(elt) elt,logical(zeros(size(powerField,1),1)),'UniformOutput',false);

            data = [ ...
                manufacturerField, ...
                nameField,          ...
                idDataBaseField, ...
                sideDimensionField, ...
                thicknessFanField, ...
                volumeField, ...
                weightField, ...
                noiseField, ...
                speedField, ...
                vMinField, ...
                vMaxField, ...
                priceField, ...
                powerField, ...
                matBooleans
                ];
            ax = axes('Units','normalized',...
                'Position',[0.05 0.06 0.40 0.4],...
                'Parent',tab1);
            
            t = uitable( ...
                'Units','normalized',...
                'Position',[0 0.5 1 0.5],...
                'Parent', tab1, ...
                'Data', data, ...
                'ColumnName', {'manufacturer','name','id',      'sideFan(m)','thicknessFan(m)','volume(m^3)','weight(kg)','noise(dB)','speed(rpm)','vMin(V)','vMax(V)','price(€)','power(W)','displayCurve'}, ...
                'ColumnFormat', {'char',      'char','numeric','numeric','numeric',     'numeric',      'numeric',  'numeric',  'numeric',  'numeric','numeric','numeric',  'numeric', 'logical'}, ...
                'ColumnEditable',[false,        false, false,   false,    false,          false,           false,     false,    false,       false,     false,  false,      false  , true], ...
                'ColumnWidth',{'auto'           'auto' 'auto'   'auto'     'auto'       'auto'          'auto'       'auto'       'auto'      'auto'     'auto'    'auto'   'auto' , 'auto'},...
                'CellEditCallBack',@(x,y) changeBoolean(x,y,dataBase));
          
             
             function changeBoolean(hObject,callbackdata,dataBase)
                    
                   indiceCallBack = callbackdata.Indices;
                   dataChange =get(hObject,'Data');
                   
                   if indiceCallBack(2) == 14

                       % We display the chosen data
                       dataBool = find([dataChange{:,14}]);
                      
                       
                       hold off
                       children = hObject.Parent.Children;
                       axesRef = children(find(isa(children,'axes')));
                       axes(axesRef);
                       legendVec = {};
                       % We display the set curves
                       if ~isempty(dataBool)
                       for k = 1:length(dataBool)
                           dataFan= dataBase(dataBool(k));
                           volumetricFlow = {dataFan.Q1,...
                               dataFan.Q2,...
                               dataFan.Q3,...
                               dataFan.Q4,...
                               dataFan.Q5,...
                               dataFan.Q6,...
                               dataFan.Q7,...
                               dataFan.Q8,...
                               dataFan.Q9,...
                               dataFan.Q10,...
                               dataFan.Q11,...
                               dataFan.Q12,...
                               dataFan.Q13,...
                               dataFan.Q14,...
                               dataFan.Q15};
                           % We delete the non numeric values
                           out = cellfun(@(elt) ~ischar(elt),volumetricFlow,'UniformOutput',false);
                           idxVolumetric = find([out{:}]);
                           % Pressure losses
                           deltaPressure   = {dataFan.P1,...
                               dataFan.P2,...
                               dataFan.P3,...
                               dataFan.P4,...
                               dataFan.P5,...
                               dataFan.P6,...
                               dataFan.P7,...
                               dataFan.P8,...
                               dataFan.P9,...
                               dataFan.P10,...
                               dataFan.P11,...
                               dataFan.P12,...
                               dataFan.P13,...
                               dataFan.P14,...
                               dataFan.P15};
                           % We delete the non-numeric values
                           out = cellfun(@(elt) ~ischar(elt),deltaPressure,'UniformOutput',false);
                           idxPressure = find([out{:}]);
                           finalIdx = intersect(idxVolumetric,idxPressure);
                           volumetricFlowFinal = [volumetricFlow{finalIdx}];
                           deltaPressureFinal = [deltaPressure{finalIdx}];
                           
                           
                           plot(volumetricFlowFinal,deltaPressureFinal,'LineWidth',2)
                           hold on
                           legendVec = [legendVec,dataFan.name];
                       end
                       xlabel('Volumetric flow [m^3/s]');
                       ylabel('Pressure Losses [Pa]');
                       legend(legendVec);
                       
                       else
                          plot(0,0); 
                       end
                   end

          end 
           
         end
     end
     
     %% Computation methods (Values calculated without excitations) Not used
     methods (Access = protected)
         function computeGeometry(obj) 
             % Volume
             obj.outputData_.geometric.volumeTube = ((obj.dimensions.sideDistanceFan+  obj.dimensions_.heightOutTube + 2 * obj.dimensions_.thicknessFanTube) +...
                                                         (obj.dimensions.sideDistanceFan + obj.dimensions_.widthOutTube + 2 * obj.dimensions_.thicknessFanTube)) * ...
                                                         obj.dimensions.lengthTube * obj.dimensions_.thicknessFanTube;                                         
             obj.outputData_.geometric.volume = obj.outputData_.geometric.volumeTube + obj.outputData_.geometric.volumeFan;
             
             % Weight
             obj.outputData_.geometric.weightTube = obj.outputData_.geometric.volumeTube * obj.materials_.materialTube.density;
             obj.outputData_.geometric.weight = obj.outputData_.geometric.weightTube + obj.outputData_.geometric.weightFan; 
         
             % Manufacturing volume
             obj.outputData_.geometric.manufacturingVolume = (obj.dimensions_.thicknessFan + obj.dimensions_.lengthTube) * ....
                                        2 * (obj.dimensions_.heightOutTube + obj.dimensions_.widthOutTube);
         
         end
         function computeElectricModelParametersLv1(obj)
         end
         function computeElectricModelParametersLv2(obj)
         end
         function computeThermalModelParametersLv1(obj)
         end
         function computeThermalModelParametersLv2(obj)
         end
     end
     
     %% Setting & getting excitations
     methods 
         function setExcitations(obj,varargin) 
         end
     end
     
     %% ComputeOutputData methods (Not used)
     methods (Access = protected)
         function computeElectricOutputDataLv1(obj)
         end
         function computeElectricOutputDataLv2(obj)
         end
         function computeThermalOutputDataLv1(obj)
         end
         function computeThermalOutputDataLv2(obj)
         end
     end
     
     %% Not used
     methods
         function h = getExchangeCoefficient(obj)
         end
     end
     
     
end
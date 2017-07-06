classdef Interface < handle
    % StoredData.Interface is an interface for StoredData classes.
    %
    % StoredData.Interface methods (Optimizer):
    %   store           - store current data
    %   resetData       - reset stored data
    %
    % StoredData.Interface methods (User):
    %   show            - open an interactive window to plot data (Viewer)
    %
    %   plotData        - plot specific data by name
    %   getFields     	- get fields of stored data
    %   getFieldsOf    	- get fields of specific field of stored data
    %   getData         - get structure with all stored data
    %
    %   See also StoredData.Facture, StoredData.Viewer
    %
    
    properties (  Access = protected, Hidden = true)
        objToSave
    end
    
    methods
        function obj = Interface(objArg)
            obj.objToSave = objArg;
        end
    end
    
    methods (Abstract)
        resetData(obj)
        store(obj)
    end
    
    methods
        function plotData(obj, fieldname1, fieldname2)
            % plotData( fieldname1, fieldname2)
            %   plot storedData.fieldname1.fieldname2{:} side by side in the same figure
            %
            % Arguments:
            %   fieldname1      - optional -> 'all' by default
            %       field or field list of StoredData
            %       use getFields for fieldname1 available options
            %       if fieldname1 is void, 'all' ou list, fieldname2 value is unused and imposed to 'all'
            %
            %   fieldname2      - optional -> 'all' by default
            %       field or field list of StoredData.fieldname1
            %       use getFieldsOf(fieldname1) for fieldname2 available options
            %       if fieldname2 value is 'all', only non constant numeric fields are ploted
            %
            
            if nargin < 2 || ischar(fieldname1) && strcmp(fieldname1, 'all')
                cellfun(@(x) obj.plotData(x), obj.getFields);            
            else
                if ischar( fieldname1)
                    variableFields = textscan(fieldname1,'%s','Delimiter','.');
                    variableFields = variableFields{:};
                elseif iscell( fieldname1)
                    variableFields = fieldname1;
                end
                
                %vector = getfield( obj, variableFields{:});
                vector = obj;
                for k = 1:length( variableFields)
                    vector = [ vector.(variableFields{k})];
                end

                if nargin < 3
                    fieldname2 = 'all';
                end

                if ischar(fieldname2)
                     if strcmp(fieldname2,'all')
                        fieldNameVector = fields(vector);
                        toPlot = cellfun( @(x) isstruct([vector.(x)]) || (isnumeric([vector.(x)]) && length(unique([vector.(x)])) > 1), fieldNameVector);
                        fieldNameVector = fieldNameVector(toPlot);
                     else
                        fieldNameVector = {fieldname2};
                     end
                else
                    fieldNameVector = fieldname2;
                end

                plotRows = ceil(sqrt(length(fieldNameVector)));
                plotLines = ceil(length(fieldNameVector)/plotRows);

                if iscell( fieldname1)
                    if length( fieldname1) > 1
                        figureName = strjoin( fieldname1,' ');
                    else
                        figureName = fieldname1{1};
                    end
                else
                    figureName = fieldname1;
                end
                if ~isempty( obj.objToSave.name)
                    figureName = [ figureName ' stored of ' obj.objToSave.name];
                else
                    figureName = [ figureName ' stored'];
                end
                figure('name', figureName)

                iterations = 0:length(vector)-1;

                for k = 1:length(fieldNameVector)
                    value = [];
                    subplot(plotLines,plotRows,k);
                    xlabel('iterations');
                    ylabel(fieldNameVector{k});
                    hold on
                    grid on

                    switch class( [vector.(fieldNameVector{k})] )
                        case 'double'
                            value = [vector.(fieldNameVector{k})];
                        case 'struct'
                            value0 = [vector.(fieldNameVector{k})];
                            if isfield(value0,'freqVec')
                                value0 = rmfield(value0,'freqVec');
                            end
                            value = squeeze( cell2mat( struct2cell(value0) ) );
                    end

                    if ~isempty( value )
                        if length(iterations) ~= length(value)
                            value = reshape(value,length(value)/length(iterations),length(iterations));
                            if length(iterations) ~= length(value) && length(iterations) == size(value,2)
                                valueMax = max(value);
                                valueMin = min(value);
                                value = [ valueMax; valueMin];
                            end
                        end
                        if length(iterations) == length(value)
                            plot(iterations,value);
                            zoom;
                        end
                    end
                end
            end
        end
        
        function val = getFields(obj)
            % getFields
            %   returns all fields of StoredData
            %
            
            val = properties(obj);
        end
        
        function val = getFieldsOf(obj,fieldname)
            % getFieldsOf(fieldname)
            %   returns all fields of specific field "fieldname"
            %
            
            if ischar( fieldname)
                variableFields = textscan( fieldname,'%s','Delimiter','.');
                variableFields = variableFields{:};
            elseif iscell( fieldname)
                variableFields = fieldname;
            end
            val = fieldnames( getfield( obj, variableFields{:}));
        end
        
        function val = getData(obj)
            % data = getData
            %   Returns a structure with all stored data. See also StoredData.Viewer
            %
            
            fieldNames = properties(obj);
            fieldValues = cellfun(@(field) obj.(field), fieldNames, 'UniformOutput', false);
            val = cell2struct( fieldValues, fieldNames);
        end
        
        function show(obj)
            % show
            %   Opens an interactive window to show all stored data. See also StoredData.Viewer
            %   
            
            StoredData.Viewer(obj.getData);
        end
    end
    
    
    methods (Static)
        function outStruct = convert2struct( inStruct)
            % outStruct = convert2struct( inStruct)
            %   Convert all fields of inStruct to struct and build outStruct with.
            %
            
            function yOut = convertField2struct(yIn)
                % Convert x to struct if it is not yet
                if isnumeric(yIn)
                    if size(yIn,2) == 1
                        yOut = yIn;
                    else
                        yOut = yIn';
                    end
                elseif isstruct(yIn)
                    yOut = convert2struct(yIn);
                elseif ~iscell(yIn) && ~ischar(yIn) && ~islogical(yIn)
                    if isprop( yIn, 'freqValVec')
                        yOut.freqValVec = [yIn.freqValVec];
                    elseif isprop( yIn, 'L')
                        yOut.L = [yIn.L];
                    elseif isprop( yIn, 'val')
                        yOut.val = [yIn.val];
                    else
                        yOut = [];
                    end
                else
                    yOut = [];
                end
            end

            function xOut = convert2struct(xIn)
                fieldValues = cellfun( @convertField2struct, struct2cell(xIn), 'UniformOutput', false);
                xOut = cell2struct( fieldValues, fieldnames( xIn ));
            end
            
            if isempty(inStruct)
                outStruct = [];
            else
                outStruct = convert2struct(inStruct);
            end
        end
    end
end

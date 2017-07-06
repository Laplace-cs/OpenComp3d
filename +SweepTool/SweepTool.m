classdef SweepTool < dynamicprops %handle
    % SweepTool is a class to perform sweeps with many input and output variables.
    % It allows then to plot graphically the results.
    
    properties (Dependent)
        circuitSweep
        solverSweep
    end
    
    properties (Access = protected)
        variableList_ = []  % variable list (struc array) fields: name, value and unit. value is a vector with all required values
        outputList_ = []    % output list   (struc array) fields: name, value and unit. value is a multidimensional matrix with size = [numel(variableList_(:).value)]
        
        solverSweep_
        circuitSweep_ = []  % property to store the circuit composite
        elementList_ = {};       % comp3d element for sweep evaluation
        readyFlag_ = 0      % missing data matrix flag ( 0 - to calculate / 1 - ready)
    end
    
    %%
    methods        
        function obj = SweepTool(varargin)
        end
    end
    
    methods
        function loadGriddedData(obj, data)
            if strcmp( data.type, 'gridded');
                obj.variableList_ = data.variableList;
                obj.outputList_ = data.outputList;
                obj.readyFlag_ = ones( size( obj.outputList_(1).value));
            else
                error('SweepTool: Can not load non gridded data.');
            end
        end
        function data = getGriddedData(obj)
            data.type = 'gridded';
            data.outputList = obj.outputList_;
            data.variableList = obj.variableList_;
        end
        function data = getScatteredData(obj)
            data.type = 'scattered';
            data.outputList = obj.outputList_;
            newOutputValues = cellfun(@(val) val(:), {data.outputList.value}, 'UniformOutput', false);
            [data.outputList.value] = newOutputValues{:};

            data.variableList = obj.variableList_;
            variableValues = cell(size(data.variableList));
            [variableValues{:}] = ndgrid(data.variableList.value);
            newVariableValues = cellfun(@(val) val(:), variableValues, 'UniformOutput', false);
            [data.variableList.value] = newVariableValues{:};
        end
    end
        
    %%
    methods
        function addVariable(obj, name, value, unit)
            % addVariable( 'name', value, 'unit')
            %
            % adds new freedom degree for sweep
            %   - if is a new variable, all output values will be recalculated when evaluate method is called.
            %   - if variable is already inserted, new value vector will be merged with the last one and just missing values will be calculated.
            %
            % arguments:
            %   name            - string with complet field name, ex: 'dimensions.dimensionNo1'
            %   value(numeric)  - numeric array for numeric variables, ex: 0.1:0.01:0.2, [1 2 5 6 8 9] (will be sorted)
            %   value(char)     - cell array for char variables, ex: {'Copper','Aluminium'}
            %   unit(optional)  - string with unit text used in plot method
            %
            
            if nargin < 3
                error('OptimProblem.SensitivityOptimizer: Missing arguments.');
            end
            if nargin < 4
                unit = '-';
            end
            
            % verifies if name is already in the list and takes it index
            if ~isempty(obj.variableList_)
                index = strcmp( name, {obj.variableList_.name});
            else
                index = [];
            end
            
            if any(index)
                % variable name is already defined in the position given by index
                
                % save old value
                oldValue = obj.variableList_(index).value;
                % search index that are already stored in variableList
                LIA = ismembertol( value, obj.variableList_(index).value, sqrt(eps));
                % merge value not stored
                obj.variableList_(index).value = unique( [obj.variableList_(index).value value(~LIA)],'sorted');
                
                if length( obj.variableList_(index).value ) ~= length( oldValue)
                    % take old value index in the new value vector
                    IA = ismembertol( obj.variableList_(index).value, oldValue, sqrt(eps));

                    % expand result matrix with zeros
                    obj.readyFlag_ = obj.expandMatrix( obj.readyFlag_, IA);

                    % expand output value with zeros
                    if ~isempty(obj.outputList_)
                        newOutputValue = cellfun( @(val) obj.expandMatrix( val, IA), {obj.outputList_.value}, 'UniformOutput', false);
                        [obj.outputList_.value] = newOutputValue{:};
                    end
                end
            else
                % define name as new freedom degree (add struct in array)
                newStruct = struct( ...
                    'name', name, ...
                    'value', [], ...
                    'unit', unit  ...
                    );
                % sorte value if numeric
                if isnumeric(value)
                    newStruct.value = unique(value,'sorted');
                else
                    newStruct.value = value;
                end
                % add new freedom degree struct in variable list (struct array)
                obj.variableList_ = [obj.variableList_, newStruct];
                
                % reset all calculate flags
                obj.readyFlag_ = obj.buildMatrix(@zeros);
                
                % build output value matrices with new size
                if ~isempty(obj.outputList_)
                    newOutputValue = cellfun(@(val) obj.buildMatrix(@zeros), {obj.outputList_.value}, 'UniformOutput', false);
                    [obj.outputList_.value] = newOutputValue{:};
                end
            end
        end
        function removeVariable(obj, name, value)
            if nargin < 2
                error('OptimProblem.SensitivityOptimizer: Missing arguments.');
            end
            
            % search name index in variable list
            index = strcmp( name, {obj.variableList_.name});
            if any(index)
                % if name is in the list
                if nargin < 3
                    % remove all values/remove completely 'name' from the variable list
                    obj.variableList_ = obj.variableList_(~index);
                    
                    % reset all calculate flags
                    obj.readyFlag_ = obj.buildMatrix(@zeros);
                    
                    % build output value matrices with new size
                    if ~isempty(obj.outputList_)
                        newOutputValue = cellfun(@(val) obj.buildMatrix(@zeros), {obj.outputList_.value}, 'UniformOutput', false);
                        [obj.outputList_.value] = newOutputValue{:};
                    end
                else
                    % remove only some values
                    if iscell( obj.variableList_(index).value )
                        LIA = strcmp( obj.variableList_(index).value, value);
                    else
                        LIA = ismembertol( obj.variableList_(index).value, value, sqrt(eps));
                    end
                    % value - remaining values
                    obj.variableList_(index).value = obj.variableList_(index).value(~LIA);
                    % IA - index value to remove
                    IA = find(LIA);
                    
                    if isempty( obj.variableList_(index).value )
                        % remove all values
                        warning(['SweepTool: variable ' name ' completelly remove from variable list. Think about fix a new value.']);
                        obj.removeVariable(name);
                    else
                        % remove freedom degree from calculate matrix flag
                        obj.readyFlag_ = obj.removeMatrix( obj.readyFlag_, index, IA);

                        % remove value matrices
                        if ~isempty(obj.outputList_)
                            newOutputValue = cellfun(@(val) obj.removeMatrix( val, index, IA), {obj.outputList_.value}, 'UniformOutput', false);
                            [obj.outputList_.value] = newOutputValue{:};
                        end
                    end
                end
            else
                error('SweepTool: Variable name not recognized.');
            end
        end
        function displayVariableList(obj, fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            
            function string = convert2string( value)
                if isnumeric(value(1)),  string = num2str( value, ' %7.3g');  return;  end
                if iscell(value(1)),     string = [strjoin(value,', ') '.'];  return;  end
            end
            
            data = [ ...
                cellfun( @(name, unit) [name ' [' unit ']'], {obj.variableList_.name}, {obj.variableList_.unit}, 'UniformOutput' ,false); ...
                cellfun( @(value) convert2string( value), {obj.variableList_.value}, 'UniformOutput' ,false)  ...
                 ...
                ];
            
            fprintf(fid,'========================================\n');
            fprintf(fid,'SweepTool variables:\n');
            fprintf(fid,'----------------------------------------\n');
            formatSpecVar = '%40s: %s\n';
            fprintf( fid, formatSpecVar, data{:});
            fprintf(fid,'========================================\n');
        end
    end
        
    %%
    methods
        function addOutput(obj, name, unit)
            % addOutput( 'name', 'unit')
            % add output variable to output list
            %
            % Arguments:
            %   name - new output name
            %   unit - string used in plot (optional)
            %
            
            if nargin < 2
                error('OptimProblem.SensitivityOptimizer: Missing arguments.');
            end
            if nargin < 3
                unit = '-';
            end
            
            if ~isempty(obj.outputList_)
                % search existing names in output list
                index = strcmp( name, {obj.outputList_.name});
            else
                index = [];
            end
            
            if ~any(index)
                % create new output struct
                newStruct = struct( ...
                    'name', name, ...
                    'value', obj.buildMatrix(@zeros), ...
                    'unit', unit  ...
                    );
                
                % add newStruct to the list
                obj.outputList_ = [obj.outputList_, newStruct];
                % reset all result flags
                obj.readyFlag_ = obj.buildMatrix(@zeros);
            else
                warning('SweepTool: This output is already in the list.');
            end
        end
        function removeOutput(obj, name)
            % removeOutput( 'name')
            % remove output variable from output list
            %
            % Arguments:  name - previously added output name
            %
            
            if nargin < 2
                error('OptimProblem.SensitivityOptimizer: Missing arguments.');
            end
            
            % search existing names in output list
            index = strcmp( name, {obj.outputList_.name});
            if any(index)
                obj.outputList_(index)  = [];
            end
        end
        function displayOutputList(obj, fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            data = [ ...
                {obj.outputList_.name}; ...
                {obj.outputList_.unit}  ...
                ];
            
            fprintf(fid,'========================================\n');
            fprintf(fid,'SweepTool outputs:\n');
            fprintf(fid,'----------------------------------------\n');
            formatSpecVar = '%s [%s]\n';
            fprintf( fid, formatSpecVar, data{:});
            fprintf(fid,'========================================\n');
        end
    end
    
    %%
    methods
        function addElement(obj, element)
                obj.elementList_{end+1} = element;
                try
                    obj.addprop(element.name);
                catch
                   warning(['Property ',element.name,' has been already defined, consider clearing the classes to avoid conflicts']);
                end
                obj.(element.name) = element;
        end
    end
    
    %%
    methods
        function evaluate(obj)
            % evaluate
            % Evaluates missing output data
            %
            
            if ~all( obj.readyFlag_(:))
                % build a cell array [nIterations nVariables] with all value combinations for all iterations.
                combinationCellArray = obj.buildCombinationCellArray;
                
                % break variable and output names in single field names for access with setfield/getfield
                % variable cell arrays
                variableNameFields = cellfun(@(name) textscan(name,'%s','Delimiter','.'), {obj.variableList_.name});
                % output cell arrys
                outputNameFields = cellfun(@(name) textscan(name,'%s','Delimiter','.'), {obj.outputList_.name});
                
                % control variables
                iterationNumber = length( obj.readyFlag_(:));
                indexArray = find( obj.readyFlag_(:) == 0)';
                
                h = waitbar(0,'Please Wait');
                for index = indexArray
                    h = waitbar(index/iterationNumber);
                    
                    % FixMe: Add timer to avoid evaluation freezing.
                    try
                        % set each variable value
                        cellfun( @(field,value) setfield( obj, field{:}, value), variableNameFields, combinationCellArray(index,:), 'UniformOutput', false);
                        % compute values
                        obj.computeValues(index);
                        
                        % get each output value
                        outputValue = cellfun( @(field) getfield( obj, field{:}), outputNameFields, 'UniformOutput', false);
                        
                        % save values in properties (not temporary variables) after each iteration to avoid losing data when break/error/crash (less performant, but safer)
                        % put each output value at an outputList_ matrix copy
                        outputValueMatrix = cellfun( @(mat,val) obj.setMat(mat,index,val), {obj.outputList_.value}, outputValue, 'UniformOutput', false);
                        % save each new matrix at outputList_ value
                        [obj.outputList_.value] = outputValueMatrix{:};
                    catch
                        % remove (set to zero) ok flag if there is a problem
                        obj.readyFlag_(index) = 0;
                        
                        % display error message
                        disp('SweepTool: Evaluation failed at combination:')
                        disp([ {obj.variableList_.name}' combinationCellArray(index,:)' ])
                    end
                end
                delete(h);
            end
        end
        
        % Display Results
        function plotOutput(obj, outputName, varargin)
            % plotOutput('output', varargin)
            % plotOutput pre-processor removes all freedom degrees uncorrelated with selected output.
            %
            % Arguments:
            %   'output' - values to plot. ex: 'geometricOutputData.weight'...
            %   varargin - Add optional parameter name-value pair argument to input parser scheme (only fixed variables)
            %
            
            if ~all(obj.readyFlag_)
                warning('SweepTool: Computing missing data.');
                obj.evaluate;
            end
            
            variable = obj.variableList_;
            indexOutputData = strcmp( outputName, {obj.outputList_.name});
            if isempty(indexOutputData)
                error('Output data to plot has not been previously defined');
            end
            
            output = obj.outputList_(indexOutputData);
            
            [ variable, output] = obj.removeConstantVariables2Plot( variable, output);
            if ~isempty( varargin)
                [ variable, output] = obj.removeFixedFields2Plot( variable, output, varargin{:});
            end
            if length(variable) > 1
                [ variable, output] = obj.permuteVariables( variable, output);
            end
            
            %
            % plot
            nVar = length(variable);
            nChar = sum( cellfun( @iscell, {variable.value}));

            variableIsChar = cellfun( @iscell, {variable.value});
            variableAxisValues = {variable.value};
            if any(variableIsChar)
                % create Tick values for char variables
                variableAxisValues(variableIsChar) = cellfun( @(v) 1:1:numel(v), variableAxisValues(variableIsChar), 'UniformOutput', false);
            end
            
            switch nVar
                case 0
                    warning('SweepTool: No variable to plot.');
                case 1
                    switch nChar
                        case 0
                            figure
                            hold on
                            grid on
                            plot(variableAxisValues{:},output.value);
                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                        
                        case 1
                            figure
                            hold on
                            grid on
                            barh(variableAxisValues{:},output.value);
                            xlabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                            set(gca, 'YTick', variableAxisValues{1}, 'YTickLabel', variable(1).value);
                    end
                    
                case 2
                    switch nChar
                        case 0
                            figure
                            hold on
                            grid on
                            [x,y] = ndgrid(variableAxisValues{:});
                            surf(x,y,output.value);
                            zoom;
                            view(3);
                            
                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([variable(2).name '[' variable(2).unit ']']);
                            zlabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                        
                        case 1
                            figure
                            hold on
                            grid on
                            plot(variableAxisValues{1},output.value);
                            zoom;
                            
                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                            legend(variable(2).value);
                        
                        case 2
                            figure
                            hold on
                            grid on
                            barh(output.value);
                            zoom;
                            xlabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                            set(gca, 'YTick', variableAxisValues{1}, 'YTickLabel', variable(1).value);
                            legend(variable(2).value);
                    end
                    
                case 3
                    switch nChar
                        case 0
                            figure
                            hold on
                            grid on
                            [x,y,z] = ndgrid(variableAxisValues{:});
                            c = output.value(:);
                            
                            scatter3(x(:),y(:),z(:),100,c,'filled');
                            cb = colorbar;
                            cb.Label.String = [ output.name ' [' output.unit ']'];
                            view(3);
                            zoom;
                            
                            % put name in each point
                            d = cellfun( @(axv) 0.05*(max(axv) - min(axv))/(numel(axv)-1), variableAxisValues);
                            text( x(:)+d(1), y(:)+d(2), z(:)+d(3), num2str( output.value(:), 3))

                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([variable(2).name '[' variable(2).unit ']']);
                            zlabel([variable(3).name '[' variable(3).unit ']']);
                            legend(output.name);
                        
                        case 1
                            figure
                            hold on
                            grid on
                            colormap('default')
                            [x,y] = ndgrid(variableAxisValues{1:2});
                            outputCell = squeeze(num2cell(output.value,[1 2]));
                            colorCell = num2cell(1:length(outputCell))';
                            cellfun( @(data,color) surf(x,y,data,color*ones(size(data))), outputCell, colorCell);
                            view(3);
                            zoom;

                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([variable(2).name '[' variable(2).unit ']']);
                            zlabel([obj.outputList_(indexOutputData).name '[' obj.outputList_(indexOutputData).unit ']']);
                            legend(variable(3).value)

                            % put name in each surface edge
                            xCell = {variableAxisValues{1}(1) variableAxisValues{1}(1) variableAxisValues{1}(end) variableAxisValues{1}(end)};
                            yCell = {variableAxisValues{2}(1) variableAxisValues{2}(end) variableAxisValues{2}(1) variableAxisValues{2}(end)};
                            zCell = {output.value(1,1,:) output.value(1,end,:) output.value(end,1,:) output.value(end,end,:)};
                            onesVec = ones(size(variable(3).value));
                            cellfun( @(xt,yt,zt) text( xt*onesVec, yt*onesVec, zt, variable(3).value), xCell, yCell, zCell);
                        
                        case {2,3}
                            figure
                            hold on
                            grid on
                            [x,y,z] = ndgrid(variableAxisValues{:});
                            c = output.value(:);
                            
                            scatter3(x(:),y(:),z(:),100,c,'filled');
                            cb = colorbar;
                            cb.Label.String = [ output.name ' [' output.unit ']'];
                            view(3);
                            zoom;
                            
                            % put name in each point
                            d = cellfun( @(axv) 0.05*(max(axv) - min(axv))/(numel(axv)-1), variableAxisValues);
                            text( x(:)+d(1), y(:)+d(2), z(:)+d(3), num2str( output.value(:), 3))
                            
                            xlabel([variable(1).name '[' variable(1).unit ']']);
                            ylabel([variable(2).name '[' variable(2).unit ']']);
                            zlabel([variable(3).name '[' variable(3).unit ']']);

                            tickList = {'XTick','YTick','ZTick'};
                            tickLabelList = {'XTickLabel','YTickLabel','ZTickLabel'};
                            cellfun( @(tick,num,tickLabel,label) set(gca, tick, num, tickLabel, label), ...
                                tickList(variableIsChar), ...
                                variableAxisValues(variableIsChar), ...
                                tickLabelList(variableIsChar), ...
                                {variable(variableIsChar).value});
                    end
                    
                otherwise
                    warning('SwwepTool: Too many variables, fix some variables to plot.');
            end
        end
    end
    methods (Access = protected)
        function [ variable, output] = removeConstantVariables2Plot(~, variable, output)
            % loop last to the first
            for k = length(variable):-1:1
                diffData = abs( diff( output.value,1,k) );
                if ~any(diffData(:) > sqrt(eps))
                    variable(k) = [];
                    output.value = squeeze(mean(output.value,k));
                end
            end
        end
        function [ variable, output] = removeFixedFields2Plot(obj, variable, output, varargin)
            % fixing user variables
            fixedNames = {varargin{1:2:numel(varargin)}};
            fixedValues = {varargin{2:2:numel(varargin)}};
                
            % search fixed variable index in variableList
            removeVariableIndex = cellfun( @(varName) strcmp( varName, {variable.name}), fixedNames, 'UniformOutput', false);
            % remove fixed variables that are not in the variable list
            empty = cellfun(@(x) ~any(x), removeVariableIndex);
            removeVariableIndex(empty) = [];
            fixedValues(empty) = [];

            % remove remaining fixed variable present in variableList.
            if ~isempty(removeVariableIndex)
                if length(removeVariableIndex) > 1
                    % sort fixed variables in the same order that variable list
                    [fixedIndex,I] = sort(cellfun(@find, removeVariableIndex));
                    fixedValues = fixedValues(I);
                else
                    fixedIndex = cellfun(@find, removeVariableIndex);
                end

                variableValueList = {variable(fixedIndex).value};
                iscell_ = cellfun( @iscell, variableValueList);
                
                IA(iscell_) = cellfun( @(listVal,listFixVal) ... 
                    find( prod( cell2mat( cellfun( @(fixVal) ~strcmp(fixVal,listVal), listFixVal', 'UniformOutput', false)), 1)), ...
                    variableValueList(iscell_), fixedValues(iscell_), 'UniformOutput', false);
                
                % takes unwanted variable value index for each fixed variable
                IA(~iscell_) = cellfun( @(val,fixVal) find( ~ismembertol(val,fixVal, sqrt(eps))), variableValueList(~iscell_), fixedValues(~iscell_), 'UniformOutput', false);
            %    [~,IA] = cellfun( @(val,fixVal) setxor(val,fixVal), {variable(fixedIndex).value}, fixedValues, 'UniformOutput', false);

                % Remove constant variables: loop back to front
                for k = length(IA):-1:1
                    output.value = obj.removeMatrix( output.value, fixedIndex(k), IA{k});

                    if length(fixedValues{k}) > 1
                        variable(fixedIndex(k)).value = fixedValues{k};
                    else
                        output.value = squeeze(output.value);
                        variable(fixedIndex(k)) = [];
                    end
                end
            end
        end
        function [ variable, output] = permuteVariables(~, variable, output)
            variableIsChar = cellfun( @iscell, {variable.value});
            % if any but not all are char (and if there is a non char before an numeric => not ordened)
            if any(variableIsChar) && ~all(variableIsChar) && any( diff(variableIsChar) < 0)
                % put char variables in the last dimensions
                order = 1:length(size(output.value));
                % first non cell variables, then cell variables
                permuteVector = [order(find(~variableIsChar)) order(find(variableIsChar))];

                % permute variable list
                variable = variable(permuteVector);
                % permute matrix dimensions
                output.value = permute( output.value, permuteVector);
            end
         end
    end
    
    %%
    %
    methods (Access = protected)
        function combinationCellArray = buildCombinationCellArray(obj)
            % build a cell array [nIterations nVariables] of all value combinations for all iterations.
            
            % cell array with variable values
            variableValueList = {obj.variableList_.value};
            % create a cell array with the same length of variable list hoping to catch all output args of ndgrid function
            combinationCellArray = cell( size( variableValueList));
            
            % ndgrid works only with numeric values
            isNumeric_ = cellfun( @isnumeric, variableValueList);
            if all(isNumeric_)
                % make a grid with all possible combinations
                [combinationCellArray{:}] = ndgrid( variableValueList{:});
            else
                % all non numeric variable (string lists, structs, ...) have to be replacede with numerics before using ndgrid
                variableValueNumericList = variableValueList;
                % replace non numeric variables with numeric array 1:n, were n is variable value length
                variableValueNumericList(~isNumeric_) = cellfun( @(variableValue) 1:length(variableValue), variableValueList(~isNumeric_), 'UniformOutput', false);
                % make a grid with all possible combinations
                [combinationCellArray{:}] = ndgrid( variableValueNumericList{:});
                % replace all non numeric values with the corresponding value in variableList
                combinationCellArray(~isNumeric_) = cellfun( @(valueList,index) valueList(index), variableValueList(~isNumeric_), combinationCellArray(~isNumeric_), 'UniformOutput', false);
            end
            
            % put each numeric value into a cell
            combinationCellArray(isNumeric_) = cellfun( @num2cell, combinationCellArray(isNumeric_), 'UniformOutput', false);
            % put all matrix as column vectors
            combinationCellArray = cellfun( @(val) val(:), combinationCellArray, 'UniformOutput', false);
            % take each variable value
            combinationCellArray = [combinationCellArray{:}];
        end
        function computeValues(obj,index)
            % We compute the parameters
            for k = 1:numel(obj.elementList_)
                if isa(obj.elementList_,'Comp3d.Component')
                    obj.elementList_{k}.computeModelParameters;
                end
            end
            
            % We solve the circuit resolution if necessary
            if ~isempty(obj.circuitSweep_)
                results = obj.solverSweep_.simulate(obj.circuitSweep_);
            end
            
            % We compute the output data if necessary
            for k = 1:numel(obj.elementList_)
                if isa(obj.elementList_,'Comp3d.Component') 
                    if ~isempty(obj.circuitSweep_)
                        data = obj.elementList_{k}.getSimulationData;
                        obj.elementList_{k}.setExcitations(data);
                    end
                    obj.elementList_{k}.computeOutputData;
                end
            end
            % update result flag
            obj.readyFlag_(index) = 1;
        end
    end
    
    %%
    %
    methods (Access = protected)
        function val = buildMatrix(obj, funcHandle)
            % buildMatrix(type)
            % build a matrix with size corresponds with each value length in variableList
            %
            % Arguments: type - function handle, like @ones, @zeros, @rand
            %
            
            if isempty(obj.variableList_)
                val = [];
            else
                sz = cellfun( @numel, {obj.variableList_.value});
                if length(sz) < 2
                    val = funcHandle([sz 1]);
                else
                    val = funcHandle(sz);
                end
            end
        end
        function matNew = expandMatrix(obj, mat, IA)
            % build new matrix with new variable size
            matNew = obj.buildMatrix(@zeros);
            % get both sizes
            szNew = size(matNew);
            sz = size(mat);
            % evaluate shift numbers
            nForward = find( szNew ~= sz ) - 1;
            nBackward = length(sz) - nForward;
            % turn forward
            newShifted = shiftdim( matNew, nForward);
            matShifted = shiftdim( mat, nForward);
            % save old values
            newShifted(IA,:) = matShifted(:,:);
            % turn bachward
            matNew = shiftdim( newShifted, nBackward);
            % reshape (almost always necessary)
            matNew = reshape( matNew, szNew);
        end
    end
    
    methods
         function set.circuitSweep(obj,value)
            obj.circuitSweep_ = value;
         end 
         function value = get.circuitSweep(obj)
             value = obj.circuitSweep_; 
         end
         function set.solverSweep(obj,value)
            obj.solverSweep_ = value;
         end 
         function value = get.solverSweep(obj)
             value = obj.solverSweep_; 
         end
    end
    methods (Static)
        function mat = setMat(mat,ind,val)
            % mat = setMat( mat, ind, val)
            % set matrix by index
            %
            % Arguments:
            %   mat - matrix
            %   ind - index
            %   val - value
            %
            % mat(ind) = val
            %
            if ~isnumeric(val)
                if isnumeric(mat)
                    mat = num2cell(mat);
                end
                mat{ind} = val.copy;
            else
                mat(ind) = val;
            end
        end
        function val = removeMatrix( old, index, IA)
            if length(index) ~= 1
                index = find(index);
            end
            nForward = index - 1;
            nBackward = length(size(old)) - nForward;
            
            oldShifted = shiftdim(old,nForward);
            sz = size(oldShifted);
            sz(1) = sz(1) - numel(IA);
            oldShifted(IA,:) = [];
            oldShifted = reshape(oldShifted, sz);
            val = shiftdim( oldShifted, nBackward);
        end
    end
end
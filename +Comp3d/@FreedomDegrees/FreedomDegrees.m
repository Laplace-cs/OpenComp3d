classdef FreedomDegrees < handle
    %FREEDOMDEGREES is the class that regroups all the freedom degrees
    
    properties
        freedomDegreesArray
    end
    
    properties (Access = protected)
        freedomDegreesArray_
    end
    
    % Constructor
    methods
        function obj = FreedomDegrees()
            obj.freedomDegreesArray_ = [];
        end
        function createFreedomDegreesFromTable(obj,object,table)
            % From a determined table and object we create the freedom
            % degrees array
            % This action replaces the current freedomDegreesArray
            obj.freedomDegreesArray_ = [];
            
            for k = 1:size(table,1)
                obj.freedomDegreesArray_ = [obj.freedomDegreesArray_,...
                    Comp3d.FreedomDegreeUnit(object,'name',table{k,1},...
                    'unit',table{k,2},...
                    'lB',table{k,3},...
                    'x0',table{k,4},...
                    'uB',table{k,5},...
                    'status',table{k,6},...
                    'relation',table(k,7))];
            end
            
            % We are sure now all the dimensions have been described but
            % no update geomtry has been performed. As a result we set a
            % trigger to perform this operation by updating the public to
            % its same value
            % To improve
            valueInitial = obj.freedomDegreesArray_(1).val;
            obj.freedomDegreesArray_(1).val = valueInitial - 1e-6;
              obj.freedomDegreesArray_(1).val = valueInitial;
        end
        function attachFreedomDegrees(obj,freedomDegreeObj)
           if isa(freedomDegreeObj,'Comp3d.FreedomDegrees')
               obj.freedomDegreesArray_ = [obj.freedomDegreesArray_,...
                   freedomDegreeObj.freedomDegreesArray];
           else
               error('Object is not a Comp3d.FreedomDegrees class');
           end
        end
        function detachFreedomDegrees(obj,freedomDegreeObj)
           if isa(freedomDegreeObj,'Comp3d.FreedomDegrees')
               arrayFreedom = freedomDegreeObj.freedomDegreesArray;
               % We detach every element
               for k = 1:numel(arrayFreedom)
                  idx = find(arrayFreedom(k) == obj.freedomDegreesArray_);
                  obj.freedomDegreesArray_(idx) = [];
               end
           else
               error('Object is not a Comp3d.FreedomDegrees class');
           end
        end
        function testDimensions(obj,structureIn)
           valuesStructure = cell2mat(struct2cell(structureIn))';
           idx = arrayfun(@(x) ~strcmp(x.status,'homothetic'),obj.freedomDegreesArray_);
           arrayfun(@(listElt,val) listElt.setVal(val),obj.freedomDegreesArray_(idx),valuesStructure(idx),'UniformOutput',false);
        end
        function var = getFreedomDegreeUnit(obj,name)
            idx = arrayfun(@(elt) strcmp(elt.name,name), obj.freedomDegreesArray, 'UniformOutput', true);
            var = obj.freedomDegreesArray_(find(idx));
        end
        function setFreedomDegreeUnit(obj,name,field,value)
            idx = arrayfun(@(elt) strcmp(elt.name,name), obj.freedomDegreesArray, 'UniformOutput', true);
            var = obj.freedomDegreesArray_(find(idx));
            var.(field) = value;
        end
    end
    
    %% Display Methods
    methods
        function writeText(obj,fid)
            if nargin < 2;   fid = 1;   end  % fid = 1 -> cmd window
            
            if fid == 1
                fprintf(fid,'%s\n','Freedom Degrees are');
                fprintf(fid,'%s\n','------------------------------');
                disp(obj.getTable);
            else
                    formatSpecVarName = '%30s %10s %10s %10s %10s %13s %20s\n';
                    formatSpecVar =     '%30s %10.5g %10.5g %10.5g %10s %13s %20s\n';
                    
                    fprintf(fid,'\n');
                    fprintf(fid,'%s\n',['Freedom Degrees are']);
                    fprintf(fid,'%s\n','------------------------------');
                    
                    % print freedom Degrees field names
                    VariableNames = {'nameFields'; 'lB';'x0';'uB'; 'unit'; 'stauts'; 'with' };
                    fprintf(fid,formatSpecVarName,VariableNames{:});
                    
                    % print a line between field names and data
                    VariableDivider = {'--------------------'; '--------';'--------';'--------'; '--------'; '-----------'; '------------------------------'};
                    fprintf(fid,formatSpecVarName,VariableDivider{:});
                    
                    nameField = arrayfun(@(elt) elt.name,obj.freedomDegreesArray_,'UniformOutput',false);
                    unitField = arrayfun(@(elt) elt.unit,obj.freedomDegreesArray_,'UniformOutput',false);
                    lbField = arrayfun(@(elt) elt.lB,obj.freedomDegreesArray_,'UniformOutput',false);
                    x0Field = arrayfun(@(elt) elt.x0,obj.freedomDegreesArray_,'UniformOutput',false);
                    ubField = arrayfun(@(elt) elt.uB,obj.freedomDegreesArray_,'UniformOutput',false);
                    statusField = arrayfun(@(elt) elt.status,obj.freedomDegreesArray_,'UniformOutput',false);
                    relationField = arrayfun(@(elt) elt.relation,obj.freedomDegreesArray_,'UniformOutput',false);
                    
                    homotheticOption = cellfun(@(x) strcmp('homothetic',x), statusField);
                    emptyWithField = cellfun(@isempty, relationField);
                    relationField(emptyWithField) = {'-'};
                    relationField(emptyWithField & homotheticOption) = {'???????????'};
                    
                    % change freedom Degrees fields sequence and transpose
                    nFields = size(nameField,2);
                    fd = [ ...
                        reshape(nameField,nFields,1), ...
                        reshape(lbField,nFields,1), ...
                        reshape(x0Field,nFields,1), ...
                        reshape(ubField,nFields,1), ...
                        reshape(unitField,nFields,1), ...
                        reshape(statusField,nFields,1), ...
                        reshape(relationField,nFields,1) ...
                        ];
                    % print freedom Degrees
                    for k = 1:nFields
                    fprintf(fid,formatSpecVar,fd{k,:});
                    fprintf(fid,'\n');
                    end
        end
        end
    end
    
    %% GUI methods
    methods
        function GUI(obj)
            f = figure('Position',[200 200 800 400]);
            tgroup = uitabgroup('Parent', f);
            tab1 = uitab('Parent', tgroup, 'Title', 'Freedom Degrees');
            
            statusOptions = {'setToX0','free','homothetic'};
            
            
            nameField = arrayfun(@(elt) elt.name,obj.freedomDegreesArray_,'UniformOutput',false);
            unitField = arrayfun(@(elt) elt.unit,obj.freedomDegreesArray_,'UniformOutput',false);
            lbField = arrayfun(@(elt) elt.lB,obj.freedomDegreesArray_,'UniformOutput',false);
            x0Field = arrayfun(@(elt) elt.x0,obj.freedomDegreesArray_,'UniformOutput',false);
            ubField = arrayfun(@(elt) elt.uB,obj.freedomDegreesArray_,'UniformOutput',false);
            statusField = arrayfun(@(elt) elt.status,obj.freedomDegreesArray_,'UniformOutput',false);
            relationField = arrayfun(@(elt) elt.relation,obj.freedomDegreesArray_,'UniformOutput',false);
            nFields = size(nameField,2);
            data = [ ...
                reshape(lbField,nFields,1), ...
                reshape(x0Field,nFields,1), ...
                reshape(ubField,nFields,1), ...
                reshape(unitField,nFields,1), ...
                reshape(statusField,nFields,1), ...
                reshape(relationField,nFields,1), ...
                ];
               
            t = uitable( ...
                'Parent', tab1, ...
                'Data', data, ...
                'ColumnName', {'lb','x0','ub','unit','status','with'}, ...
                'ColumnFormat', {'numeric','numeric','numeric','char',statusOptions,'char'}, ...
                'RowName',reshape(nameField,nFields,1), ...
                'ColumnEditable',[true true true false true true], ...
                'ColumnWidth',{'auto' 'auto' 'auto' 'auto' 'auto' 200}, ...
                'CellEditCallback',@(x,y) converttonum(obj,x,y));
            function converttonum(obj,hObject,callbackdata)
                try  
                    numval = eval(callbackdata.EditData);
                catch
                    numval = callbackdata.EditData;
                end
                 r = callbackdata.Indices(1);
                 c = callbackdata.Indices(2);
                 hObject.Data{r,c} = numval;
                 switch c
                     case 1 % lb
                         obj.freedomDegreesArray_(r).lB = numval;
                     case 2 % x0
                         obj.freedomDegreesArray_(r).x0 = numval;
                     case 3 % ub
                        obj.freedomDegreesArray_(r).uB = numval;
                     case 5 % status
                         obj.freedomDegreesArray_(r).status = numval;
                         switch numval
                             case {'setToX0','free'}
                                hObject.Data{r,6} = '';
                                
                             case 'homothetic'
                                hObject.Data(r,6) = obj.freedomDegreesArray_(r).relation;
                         end
                         hObject.Data{r,1} = obj.freedomDegreesArray_(r).lB;
                         hObject.Data{r,2} = obj.freedomDegreesArray_(r).x0;
                         hObject.Data{r,3} = obj.freedomDegreesArray_(r).uB;
                     case 6 % with
                         status = obj.getStatus(r);
                         switch status
                             case {'setToX0','free'}
                                hObject.Data{r,c} = ' ';
                             case 'homothetic'
                                hObject.Data{r,c} = numval;
                                obj.freedomDegreesArray_(r).relation = numval;
                             otherwise
                                 error('error');
                         end
                 end
            end
            
            t.Position(3) = t.Extent(3);
            t.Position(4) = t.Extent(4);
            f.Position(3) = t.Extent(3) + 30;
            f.Position(4) = t.Extent(4) + 60;
        end 
    end
    
    %% Loading & saving
    methods
        function saveFreedomDegrees(obj,filename,varargin)
            
            % saveFreedomDegrees(filename)
            %   Saves freedom degree table as text in file called "filename"
            %   Freedom degree fields are separated with comma
            %
            % The file is composed by 7 columns named: 
            %   'nameFields','lB','x0','uB','unit','stauts' and 'with'
            %   'nameFields' and 'unit' are statics.
            %   'lB','x0','uB' are numeric
            %   'stauts' shall be 'free', 'setToX0' or 'homothetic'
            %   'with' shall be void or a math expression containing 'nameFields'
            %   no comma after 'with' field
            %
            % Arguments:    filename - file name (char)
            %
            if nargin > 1
                if ischar(filename)
                    nameField = arrayfun(@(elt) elt.name,obj.freedomDegreesArray_,'UniformOutput',false);
                    unitField = arrayfun(@(elt) elt.unit,obj.freedomDegreesArray_,'UniformOutput',false);
                    lbField = arrayfun(@(elt) elt.lB,obj.freedomDegreesArray_,'UniformOutput',false);
                    x0Field = arrayfun(@(elt) elt.x0,obj.freedomDegreesArray_,'UniformOutput',false);
                    ubField = arrayfun(@(elt) elt.uB,obj.freedomDegreesArray_,'UniformOutput',false);
                    statusField = arrayfun(@(elt) elt.status,obj.freedomDegreesArray_,'UniformOutput',false);
                    relationField = arrayfun(@(elt) elt.relation,obj.freedomDegreesArray_,'UniformOutput',false);
                    
                    fileID = fopen(filename,'w');

                    formatSpecVarName = '%30s, %10s, %10s, %10s, %10s, %13s, %20s\n';
                    formatSpecVar =     '%30s, %10.5g, %10.5g, %10.5g, %10s, %13s, %20s\n';

                    % print freedom Degrees field names
                    VariableNames = {'nameFields'; 'lB';'x0';'uB'; 'unit'; 'status'; 'with' };
                    fprintf(fileID,formatSpecVarName,VariableNames{:});

                    emptyRelationField = cellfun(@isempty, relationField);
                    relationField(emptyRelationField) = {'-'};

                    % change freedomDegrees_ fields sequence and transpose
                    nFields = size(nameField,2);
                    fd = [ ...
                        reshape(nameField,nFields,1),...
                        reshape( lbField,nFields,1),...
                        reshape( x0Field,nFields,1),...
                        reshape( ubField,nFields,1),...
                        reshape(unitField,nFields,1),...
                        reshape(statusField,nFields,1),...
                        ];
                     for k = 1:nFields
                         fprintf(fileID,formatSpecVar,fd{k,:});
                         fprintf(fileID,'\n');
                    end
                    
                    fclose(fileID);
                end
            end
         end
        function loadFreedomDegrees(obj,filename,varargin)
            % loadFreedomDegrees(filename)
            %   Loads freedom degree table from text in file called "filename"
            %   Freedom degree fields are separated with comma
            %   Incomplete files are merged with default values
            %   Undefined 'nameFields' are ignored
            %   Missing columns can ou not generate error message
            %
            % The file is composed by 7 columns named: 
            %   'nameFields','lB','x0','uB','unit','stauts' and 'with'
            %   'nameFields' and 'unit' are statics.
            %   'lB','x0','uB' are numeric
            %   'stauts' shall be 'free', 'setToX0' or 'homothetic'
            %   'with' shall be void or a math expression containing 'nameFields'
            %   no comma after 'with' field
            %
            % Arguments:    filename - file name (char)
            %
            
            cellFD = table2cell( readtable( filename, 'Delimiter', 'comma') );
            
            % merge freedomDegrees_ with cellFD
            nameField = arrayfun(@(elt) elt.name,obj.freedomDegreesArray_,'UniformOutput',false);
            index = cellfun( @(str) find(strcmp( nameField,str)), cellFD(:,1));
            [obj.freedomDegreesArray_(index).lB] = cellFD{:,2};
            [obj.freedomDegreesArray_(index).x0] = cellFD{:,3};
            [obj.freedomDegreesArray_(index).uB] = cellFD{:,4};
            [obj.freedomDegreesArray_(index).unit] = cellFD{:,5};
            [obj.freedomDegreesArray_(index).status] = cellFD{:,6};
            
            % We set the relation field
            finalCell = cellFD(:,6);
            idx = cellfun(@(elt) strcmp(elt,'-'),cellFD(:,6));
            [finalCell{idx}] = deal({[]});
%             [obj.freedomDegreesArray_(:).relation] = finalCell{:};
        end  
    end
    
    %% 
    methods (Access = protected)
        function TB = getTable(obj)
             nameField = arrayfun(@(elt) elt.name,obj.freedomDegreesArray_,'UniformOutput',false);
             unitField = arrayfun(@(elt) elt.unit,obj.freedomDegreesArray_,'UniformOutput',false);
             lbField = arrayfun(@(elt) elt.lB,obj.freedomDegreesArray_,'UniformOutput',false);
             x0Field = arrayfun(@(elt) elt.x0,obj.freedomDegreesArray_,'UniformOutput',false);
             ubField = arrayfun(@(elt) elt.uB,obj.freedomDegreesArray_,'UniformOutput',false);
             statusField = arrayfun(@(elt) elt.status,obj.freedomDegreesArray_,'UniformOutput',false);
             relationField = arrayfun(@(elt) elt.relation,obj.freedomDegreesArray_,'UniformOutput',false);
             
             % We determine the empty fields
             homotheticOption = cellfun(@(x) strcmp('homothetic',x), statusField);
             emptyWithField = cellfun( @isempty, relationField);
             
             relationField(emptyWithField) = {'-'};
             relationField(emptyWithField & homotheticOption) = {'<Missing expression>'};
             relationField(~homotheticOption) = {'-'};
             
             VariableNames = {'nameFields'; 'lB';'x0';'uB'; 'unit'; 'status'; 'relation' };
             nFields = size(nameField,2);
             TB = table(...
                 categorical( reshape(nameField,nFields,1) ),...
                 cell2mat( lbField' ),...
                 cell2mat( x0Field' ),...
                 cell2mat( ubField' ),...
                 categorical(  reshape(unitField,nFields,1)),...
                 categorical( reshape(statusField,nFields,1)),...
                 categorical(reshape(relationField,nFields,1)),...
                 'VariableNames',VariableNames ...
                 );

        end
    end
    
    %% optimization functions
    methods
        function [lB,x0,uB] = getArrayForOptim(obj)
            idx = arrayfun(@(array) strcmp(array.status,'free'),obj.freedomDegreesArray_);
            lB = [obj.freedomDegreesArray(idx).lB];
            x0 = [obj.freedomDegreesArray(idx).x0];
            uB = [obj.freedomDegreesArray(idx).uB]; 
        end  
        function setXVector(obj,X)
           idx = arrayfun(@(x) strcmp(x.status,'free'),obj.freedomDegreesArray_);
           cellValues = num2cell(X);
           [obj.freedomDegreesArray_(idx).val] = cellValues{:};
        end
    end
    
    %% Get and set methods
    methods
        function value = get.freedomDegreesArray(obj)
            value = obj.freedomDegreesArray_;
        end
    end
end


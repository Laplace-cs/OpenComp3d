classdef ConstraintObject < handle
    
    properties (Dependent)
        object
        name
        unit
        ineqSymbol
    end
    
    properties (Access = protected)
        object_
        name_
        unit_
        ineqSymbol_
        
        targetValue_
        targetFunction_
        variableFunction_
    end
    
    methods
        function obj = ConstraintObject(object,name,unit,variableCell,ineqSymbol,targetCell)
            % We point to the object of reference
            obj.object_ = object;
            
            % We set the name and the unit (display methods)
            obj.name_ = name;
            obj.unit_ = unit;
            obj.ineqSymbol_ = ineqSymbol;
            
            % We setup the function to determine both values
              variableFunctionStr = regexprep(variableCell,'obj','obj.object');
              obj.variableFunction_ = str2func(['@(obj)',variableFunctionStr]);
              fixedFunctionStr = regexprep(targetCell,'obj','obj.object');
              obj.targetFunction_ = str2func(['@(obj)',fixedFunctionStr]);
              obj.targetValue_ = obj.targetFunction_(obj);
        end
        
        function [ineq,eq] = getConstraint(obj,scaleType)
            
            % Default value
            [ineq] = [];
            [eq] = [];
            
            % We get the value
           if ~isempty(obj.targetValue_)
               variableValue = obj.variableFunction_(obj);
               if strcmp(obj.ineqSymbol,'>')
                  [ineq] = obj.targetValue_ - variableValue;
               elseif strcmp(obj.ineqSymbol,'<')
                  [ineq] = variableValue - obj.targetValue_ ; 
               elseif strcmp(obj.ineqSymbol,'=')
                      [eq] = variableValue - obj.targetValue_ ; 
               end
               
               % We scale the variables
               if strcmp(scaleType,'norm') && (obj.targetValue_~=0)
                   ineq = ineq / obj.targetValue_;
                   eq = eq / obj.targetValue_;
               end
           end
          
        end
        
        function displayConstraint(obj,argument,fid)
            % Missing arguments
            if nargin == 1
                argument = 'all';
                fid = 1;
            elseif nargin == 2
                fid = 1;
            end
            
            [displayBool] = obj.showOutput(argument,fid);
            % We show the value
            if displayBool
                variableValue = obj.variableFunction_(obj);
                fprintf(fid,'%15s: %6.2g%4s %s %6.2g %4s \n', obj.name_,variableValue,obj.unit_,obj.ineqSymbol_,obj.targetValue_,obj.unit_);
            end
        end
        
        function displayConstraintObject(obj,argument,fid)
             % Missing arguments
            if nargin == 1
                argument = 'all';
                fid = 1;
            elseif nargin == 2
                fid = 1;
            end
            
            [displayBool] = obj.showOutput(argument,fid);
            % We show the value
            if displayBool
                fprintf(fid,'Constraint from %s [%s]\n', obj.object.name,class(obj.object));
                variableValue = obj.variableFunction_(obj);
                fprintf(fid,'%15s: %6.2g%4s %s %6.2g %4s \n', obj.name_,variableValue,obj.unit_,obj.ineqSymbol_,obj.targetValue_,obj.unit_);
                fprintf(fid,'%s\n','----------------------------------------------------');
            end
            
        end
        
        function updateFixedValues(obj)
            obj.targetValue_ = obj.targetFunction_(obj);
        end
    end
    
    %% Write methods
    methods (Access = protected)
        function [displayBool] = showOutput(obj,argument,fid)

            
            [ineq,eq] = obj.getConstraint('none');
            
            % Input error handling
            if ~(strcmp(argument,'all') || strcmp(argument,'non-compliant'))
                error('Argument not recognized, only inputs are "all" or "non-compliant"');
            end
            
            % We find depending on the showing input wheter we have to
            % display the constraint or not
            if (strcmp(argument,'all')) && (~isempty(ineq) || ~isempty(eq))
                displayBool = true;
            elseif ~isempty(eq) && (eq ~= 0)
                displayBool = true;
            elseif ~isempty(ineq) && (ineq > 0)
                displayBool = true;
            else
                displayBool = false;
            end
          
        end
        
    end
    
    %% Get and set methods
    methods
        function value = get.object(obj)
            value = obj.object_;
        end
        
        function value = get.name(obj)
           value = obj.name_; 
        end
        
        function value = get.unit(obj)
            value = obj.unit_;
        end
            
        function value = get.ineqSymbol(obj)
            value = obj.ineqSymbol_;
        end
        
    end
    
end
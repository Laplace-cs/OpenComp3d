classdef FreedomDegreeUnit < handle
    % FREEDOMDEGREEUNIT is the basic class for any freedom degree
    %
    % FREEDOMDEGREEUNIT properties:
    % name                  - name of the freedomDegree
    % lB                    - lower bound of the freedom degree
    % x0                    - initial value of the freedom degree
    % uB                    - upper bound of the freedom degree
    % unit                  - unit of the freedom degree
    % status                - field status for the optimization
    %                       ('setToX0'/'free'/'homothetic')
    % relation              - if status set to homothetic the expression
    % objectRef             - reference object to calculte the value
    %                         of the freedom degree
    % freedomDegreeDepArray - freedomDegrees dependent of this
    %                         freedomDegree
    % relationObject        - if the property is homothetic the value on
    %                         which it depends
    % val                   - value of the freedomDegreeUnit
    
    properties (Dependent)
        name
        lB
        x0
        uB
        unit
        status
        relation
        objectRef
        freedomDegreeDepArray
        relationObj
        val
    end
    
    properties (Access = protected)
        name_
        lB_
        x0_
        uB_
        unit_
        status_
        relation_
        objectRef_
        freedomDegreeDepArray_
        relationObj_
        functionHandle_
        booleanLoop_
        val_
    end
    
    % Constructor
    methods
        function obj = FreedomDegreeUnit(object,varargin)
            obj.objectRef_ = object;
            obj.setDefaultParameters;
            obj.parse(varargin{:});
        end        
    end
    
    methods
       function linkFreedomDegrees(obj,objectHomothetic,objectRelation)
           if nargin == 2
               objectRelation = obj.relationObj_;
           elseif nargin == 3
               obj.relationObj_ = objectRelation;
               obj.status_ = 'homothetic';
           end

           % We determine from the reference object which freedomDegress
           % are going to trig this freedomDegree
           freedomDegreesRelation = objectRelation.freedomDegrees.freedomDegreesArray;
           
            % We get the associated freedom degree names
           fieldsFreedom = {freedomDegreesRelation.name};
           for k = 1:numel(fieldsFreedom)
               if sum(regexp(obj.relation,fieldsFreedom{k}))>0
                  
                   % We set the relation
                   if sum(ismember(objectHomothetic,freedomDegreesRelation(k).freedomDegreeDepArray)) ==0
                       freedomDegreesRelation(k).addFreedomDegreeDepArray(objectHomothetic);
                       % We trigger the homothetic chain
                       freedomDegreesRelation(k).setVal(objectRelation.dimensions.(freedomDegreesRelation(k).name));
                   end
               end
           end
        end      
    end
    
    %%
    methods (Access = {?Comp3d.FreedomDegreeUnit,?Comp3d.FreedomDegrees})
       function out = testValueBetweenBounds(obj,value)
           if value < obj.lB_
               out = obj.lB_;
               warning('Value below the lower bound, setting the value to lower bound');
           elseif value > obj.uB_
               out = obj.uB_;
               warning('Value above the upper bound, setting the value to lower bound');
           else
               out = value;
           end
       end 
       function addFreedomDegreeDepArray(obj,freedomDegreesObject)
           obj.freedomDegreeDepArray_ = [obj.freedomDegreeDepArray,...
                                         freedomDegreesObject];
       end
       function setVal(obj,value)
          if strcmp(obj.status_,'free')
              value = obj.testValueBetweenBounds(value);
          end
          obj.objectRef_.dimensions_.(obj.name_) = value;
          obj.callHomotheticChain;
       end
    end
    %% Auxilary creation methods
    methods (Access = protected)
        function setDefaultParameters(obj)
            obj.name_ = '';
            obj.lB_ = -Inf;
            obj.x0_ = 0;
            obj.uB_ = Inf;
            obj.unit_ = '';
            obj.status_ = 'setToX0';
            obj.relation_ = [];
            obj.freedomDegreeDepArray_ = [];
            obj.relationObj_ = obj.objectRef_;
            obj.functionHandle_ = [];
            obj.booleanLoop_ = false;
        end
        function parse(obj,varargin)
           p = inputParser;
           p.addParameter('name',obj.name_,@ischar);
           p.addParameter('unit',obj.unit_,@ischar);
           p.addParameter('status',obj.status_,@ischar)
           p.addParameter('lB',obj.lB_,@isnumeric);
           p.addParameter('uB',obj.uB_,@isnumeric);
           p.addParameter('x0',obj.x0_,@isnumeric);
           p.addParameter('relation',obj.relation_);
           p.parse(varargin{:})
           obj.name = p.Results.name;
           obj.unit = p.Results.unit;
           
           % We set the starting point
           obj.x0_ = p.Results.x0;
           obj.lB = p.Results.lB;
           obj.uB = p.Results.uB;
           obj.setVal(obj.x0_);
           obj.val_ = obj.x0_;
           
           % IMPORTANT: Relation must be established before the status
           obj.relation_ = p.Results.relation;
           obj.status = p.Results.status;
        end
        function booleanLink(obj)
           if (obj.relationObj_ ~= obj.objectRef_)
               error('The operation cannot be performed for linked freedom degrees');
           end
            
        end
        function callHomotheticChain(obj)
            % We set the value of the homothetic object
            if ~obj.booleanLoop_
                obj.booleanLoop_ = true;
                arrayfun(@(listElt) listElt.evaluateHomothetic,obj.freedomDegreeDepArray)
                obj.booleanLoop_= false;
            else
                error('A loop has been established between all the relation objects')
            end
          
        end
        function evaluateHomothetic(obj)
            obj.setVal(obj.functionHandle_(obj.relationObj_));
        end
    end 
    %% Get & set methods
    methods
        function value = get.name(obj)
            value = obj.name_;
        end
        function value = get.lB(obj)
            if strcmp(obj.status_,'free')
                value = obj.lB_;
            else
                value = NaN;
            end
        end
        function value = get.x0(obj)
            if ~strcmp(obj.status_,'homothetic')
                value = obj.x0_;
            else
                value = NaN;
            end
        end
        function value = get.uB(obj)
            if strcmp(obj.status_,'free')
                    value = obj.uB_;
            else
                value = NaN;
            end
        end
        function value = get.unit(obj)
            value = obj.unit_;
        end
        function value = get.status(obj)
            value = obj.status_;
        end
        function value = get.relation(obj)
            value = obj.relation_;
        end
        function value = get.objectRef(obj)
            value = obj.objectRef_;
        end
        function value = get.freedomDegreeDepArray(obj)
            value = obj.freedomDegreeDepArray_;
        end
        function value = get.relationObj(obj)
            value = obj.relationObj_;
        end
        function set.status(obj,value)
            if any(ismember({'setToX0','homothetic','free'},value))
               % We test if the element is not linked
                obj.booleanLink;
                
                % We verify the relation field has been set
                if strcmp(value,'homothetic') && (isempty(obj.relation_))
                    error('you must set the relation expression before setting the homothetic status')
                end
                obj.status_ = value;
            else
                error('Only accepted values are "setToX0","homothetic" and "free"');
            end        
        end
        function set.x0(obj,value)
            obj.booleanLink;
            out = obj.testValueBetweenBounds(value);
            obj.x0_ = out;
            if ~strcmp(obj.status,'homothetic')
                % We update the value if it is not dependent of other
                % objects
                obj.setVal(obj.x0_);
            end
        end
        function set.name(obj,value)
            obj.name_ = value;
        end
        function set.unit(obj,value)
            obj.unit_ = value;
        end
        function set.lB(obj,value)
           if value > obj.uB_
               error('lower bound cannot be above the upper bound')
           else
               obj.lB_ = value;
               out = obj.testValueBetweenBounds(obj.x0_);
               obj.x0_ = out;
           end
        end
        function set.uB(obj,value)
            if value < obj.lB_
                error('upper bound cannot be above the lower bound')
            else
                obj.uB_ = value;
                out = obj.testValueBetweenBounds(obj.x0_);
                obj.x0_ = out;
            end
        end
        function set.relation(obj,valueIn)
            if ischar(valueIn)
                valueIn = {valueIn};
            end
            value = valueIn{1};
            if ~isempty(value)
                obj.relation_ = value;
                if ~sum(regexp(obj.relation_,'obj.'))
                    error('relation property must contain reference to a certain object property or method');
                end
                obj.functionHandle_ = str2func(['@(obj)',obj.relation_]);
                
                % We associate the objects
                if size(valueIn,2) == 1
                    % Case homothetic relates to the same object
                    obj.linkFreedomDegrees(obj)
                else
                    % Case homothetic relates to different object
                    obj.linkFreedomDegrees(obj,valueIn{2})
                end
            end

        end
        function set.val(obj,value)
           obj.val_ = value;
           obj.objectRef_.dimensions.(obj.name_) = obj.val_;
        end
        function value = get.val(obj)
           value = obj.val_; 
        end
    end
end

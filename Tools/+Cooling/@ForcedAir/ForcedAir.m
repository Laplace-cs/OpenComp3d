classdef ForcedAir < Cooling.Air
    %FORCEDAIR is the class that contains all the methods and properties
    %depending on the airspeed
    %
    %FORCEDAIR inputs
    % airSpeed     - speed of the air (m/s)
    %
     %FORCEDAIR methods
    % h = obj.getExchangeCoefficient()
    %
    % See <a href="matlab:help Cooling.Air">Cooling.Air</a> for other properties / methods
    
    properties (Dependent)
        airSpeed
    end
    
    properties (Access = protected)
       airSpeed_ 
    end
    
    methods
        function obj = ForcedAir(varargin)
            obj = obj@Cooling.Air(varargin{:});
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('airSpeed',2,@(x) x>0);
            p.parse(varargin{:});
            obj.airSpeed_ = p.Results.airSpeed;
        end
        
         function h = getExchangeCoefficient(obj)
             h = 10.45 - obj.airSpeed_ + 10 * sqrt(obj.airSpeed_);
         end
    end
    
    % Get & set methods
    methods 
        function value = get.airSpeed(obj)
           value = obj.airSpeed_; 
        end
        function set.airSpeed(obj,value)
           obj.airSpeed_ = value; 
        end
    end
end



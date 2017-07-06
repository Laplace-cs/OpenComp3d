classdef Air < handle
    %AIR is the mother class for all the types of air in cooling at
    %atmospheric pressure
    %
    %AIR inputs
    % temperature  - external air temperature (°C)
    
    properties (Dependent)
        temperature
        pressure
        density
        specificHeat
        conductivity
        dynamicViscosity
        thermalExpansionCoefficient
        prandtl
    end
    
    properties (Access = protected)
        temperature_
        pressure_
        
        density_
        specificHeat_
        conductivity_
        dynamicViscosity_
        thermalExpansionCoefficient_
        prandtl_
        
        % Interpolation classes
        densityInterpolant_
        specificHeatInterpolant_
        conductivityInterpolant_
        dynamicViscosityInterpolant_
        thermalExpansionCoefficientInterpolant_
    end
   
    methods
        function obj = Air(varargin)
           p = inputParser;
           p.KeepUnmatched = true;
           p.addParameter('temperature',25,@(x) x > 0);
            
           p.parse(varargin{:});
           
           obj.temperature_ = p.Results.temperature;
           obj.pressure_ = 101300;
           
           % We create the intepolation objects
           load AirProperties        
           obj.densityInterpolant_ = griddedInterpolant(airData.temperature,airData.density,'linear','linear'); 
           obj.specificHeatInterpolant_ = griddedInterpolant(airData.temperature,airData.specificHeat,'linear','linear'); 
           obj.conductivityInterpolant_ = griddedInterpolant(airData.temperature,airData.conductivity,'linear','linear'); 
           obj.dynamicViscosityInterpolant_ = griddedInterpolant(airData.temperature,airData.dynamicViscosity,'linear','linear'); 
           obj.thermalExpansionCoefficientInterpolant_ = griddedInterpolant(airData.temperature,airData.thermalExpansionCoefficient,'linear','linear'); 
        
           obj.setProperties;
        end
        
        function data = getProperties(obj,temperature)
            % gets the properties for a certain temperaure
            data.density = obj.densityInterpolant_(temperature);
            data.specificHeat = obj.specificHeatInterpolant_(temperature);
            data.conductivity = obj.conductivityInterpolant_(temperature);
            data.dynamicViscosity = obj.dynamicViscosityInterpolant_(temperature);
            data.thermalExpansionCoefficient = obj.thermalExpansionCoefficientInterpolant_(temperature);
            data.prandtl = data.specificHeat * data.dynamicViscosity / data.conductivity;
        end
    end
    
    methods (Access = protected)
        function setProperties(obj)
           data = obj.getProperties(obj.temperature_);
           obj.density_ = data.density;
           obj.specificHeat_ = data.specificHeat;
           obj.conductivity_ = data.conductivity;
           obj.dynamicViscosity_ = data.dynamicViscosity;
           obj.thermalExpansionCoefficient_ = data.thermalExpansionCoefficient;
           obj.prandtl_ = data.prandtl;
        end
    end
    
    methods (Abstract)
       h = getExchangeCoefficient(obj)
    end
    
    % Get & set methods
    methods
        function value = get.temperature(obj)
            value = obj.temperature_;
            obj.setProperties;
        end
        function set.temperature(obj,value)
            obj.temperature_ = value; 
        end
        function value = get.pressure(obj)
            value = obj.pressure_;
        end
        function value = get.density(obj)
            value = obj.density_;
        end
        function value = get.specificHeat(obj)
            value = obj.specificHeat_;
        end
        function value = get.dynamicViscosity(obj)
            value = obj.dynamicViscosity_;
        end
        function value = get.thermalExpansionCoefficient(obj)
            value = obj.thermalExpasionCoefficient_;
        end
        function value = get.prandtl(obj)
            value = obj.prandtl_;
        end
        function value = get.conductivity(obj)
           value = obj.conductivity_; 
        end
    end
    
end


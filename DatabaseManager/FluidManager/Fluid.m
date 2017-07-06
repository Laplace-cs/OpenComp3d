classdef Fluid < handle
    %Fluid is an object that contains the properties of the cooling fluid
    %for the components
    %
    % Fluid inputs:
    % type          - type of cooling fluid [Air,Water]
    % temperature   - temperature of the fluid (°C)
    % pressure      - pressure of the fluid (Pa)
    
    properties (Dependent)
        temperature
        pressure
        rho
        cP
        k
        nu
        mu
        beta % thermal expansion coefficient
        type
        Pr
    end
    
    properties (Access = protected)
        temperature_
        pressure_
        rho_
        cP_
        k_
        nu_
        mu_
        beta_
        type_
        dataBase_
        Pr_
    end
    
    methods
        
        function obj = Fluid(varargin)
           p = inputParser;
           p.addParameter('type','Air',@ischar);
           p.addParameter('Temperature',25,@isnumeric);
           p.addParameter('Pressure',101300,@(x) x>0);
           p.parse(varargin{:});
           obj.temperature_ = p.Results.Temperature;
           obj.pressure_ = p.Results.Pressure;
           obj.type_ = p.Results.type;
           
           currentPath = pwd;
           
           switch obj.type_
               case 'Air'
                   [Numeric,txt,raw] = xlsread('FluidProperties.xlsx','Air');
                   obj.dataBase_ = Numeric;
               otherwise
                   error('fluid not recognized')
           end
            
           obj.computeProperties;
           
        end
        function changeThermodynamicState(obj,Temperature,Pressure)
           obj.temperature_ = Temperature;
           obj.pressure_ = Pressure;
           obj.computeProperties;
            
        end
        function value = get.temperature(obj)
           value = obj.temperature_; 
        end
        function value = get.pressure(obj)
            value = obj.pressure_;
        end
        function value = get.rho(obj)
            value = obj.rho_;
        end
        function value = get.k(obj)
            value = obj.k_;
        end
        function value = get.cP(obj)
            value = obj.cP_;
        end
        function value = get.nu(obj)
            value = obj.nu_;
        end
        function value = get.mu(obj)
            value = obj.mu_;
        end
        function value = get.beta(obj)
            value = obj.beta_;
        end
         function value = get.Pr(obj)
            value = obj.Pr_;
        end
    end
    
    methods (Access = protected)
        function computeProperties(obj)
           obj.rho_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,3),obj.temperature_,'linear','extrap'); 
           obj.cP_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,4),obj.temperature_,'linear','extrap'); 
           obj.k_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,5),obj.temperature_,'linear','extrap');
           obj.nu_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,6),obj.temperature_,'linear','extrap');
           obj.mu_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,7),obj.temperature_,'linear','extrap');
           obj.beta_ = interp1(obj.dataBase_(:,1),obj.dataBase_(:,7),obj.temperature_,'linear','extrap');
            obj.computePr;
        end
        function computePr(obj)
           obj.Pr_ = obj.cP_ * obj.mu_ / obj.k_; 
        end
    end
    
end


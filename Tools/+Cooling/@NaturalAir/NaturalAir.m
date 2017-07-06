classdef NaturalAir < Cooling.Air
    %NATURALAIR is the class that contains all the methods for the natural
    %convection
    %
    %NATURALAIR methods
    % h = obj.getExchangeCoefficient(Ts,Lc,type)
    % Ts    - surface temperature (°C)
    % Lc    - characteristic length(m) [vertical -> height,
    %                                   horizontal -> area/perimeter]
    % type  - type of wall ['vertical_wall' -> vertical wall
    %                       'horizontal_wall_top' -> cooled top surface
    %                       'horizontal_wall_bot' -> cooled bottom surface]
    
    methods
        function obj = NaturalAir(varargin)
           obj = obj@Cooling.Air(varargin{:});
        end
    
    function h = getExchangeCoefficient(obj,Ts,Lc,type)
    
        % We estimate the mean temperature
        tMean = (Ts + obj.temperature_) / 2;
        
        % We get the properties
        data = obj.getProperties(tMean);
        
        % We calculate the rayleigh number
        Ra = obj.calculateRayleighNumber(Ts,obj.temperature,Lc,data.thermalExpansionCoefficient,...
            data.dynamicViscosity,data.density,data.prandtl);
        
        % We estimate the Nusselt number
        switch type
            case 'vertical_wall'
                Nu = obj.getVerticalCoefficient(Ra,data.prandtl);
            case 'horizontal_wall_top'
                Nu = obj.getHorizontalTopCoefficient(Ra);
            case 'horizontal_wall_bottom'
               Nu = obj.getHorizontalBotCoefficient(Ra);  
            otherwise
                error('Natural Convection type not recognized');
        end
    
        % We calculate the equivalent exchange coefficient
        h = data.conductivity * Nu / Lc;
    
    end
    end
    

    methods (Static, Access = protected)
        % Extimation of Rayleigh
        function Ra = calculateRayleighNumber(Ts,Text,Lc,beta,mu,rho,Pr)
            Ra = 9.81 * beta * (Ts - Text) * Lc ^ 3 / ((mu/rho) ^2 * Pr);
        end
        
        % Nusselt vertical walls
        function Nu = getVerticalCoefficient(Ra,Pr)
            % We calculate the nusselt number
            if Ra <= 1e9
                Nu = 0.68 + (0.67 * Ra ^ (1/4)) / ((1 + (0.492 / Pr) ^(9/16)) ^ (4/9));
            else
                Nu = (0.825 + ( (0.387 * Ra ^(1/6)) / ((1 + (0.492 / Pr) ^ (9/16)) ^ (8/27)))) ^ 2;
            end
        end
        
        % Nusselt top wall
        function Nu = getHorizontalTopCoefficient(Ra)
            if Ra < 1e7
                Nu = 0.54 * Ra ^ (1/4);
            else
                Nu = 0.15 * Ra ^ (1/3);
            end
        end
    
        % Nusselt bottom wall
        function Nu = getHorizontalBotCoefficient(Ra)
            Nu = 0.27 * Ra ^ (1/4);
        end
    end
    
end


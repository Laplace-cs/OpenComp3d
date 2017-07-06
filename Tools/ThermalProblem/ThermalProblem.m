classdef ThermalProblem < handle
% This class describe and solve a problem like   
%   F(x) = E*x^5 + D*x^4 + C*x^3 + B*x^2 + A*x - Z
%
% ThermalProblem Methods:
%  obj = ThermalProblem( nodeNumber)
%  xf = obj.solve( x0)
%
%


    %%
    properties (Access = protected)
        nodeNumber_      % number of nodes
        
        nodeVolume_      % store node volume for excitation
        nodeSurface_     % store node external surface (air interface)
        
        E_
        D_
        C_
        B_
        A_
        
        Z_
        
        options_
    end
    properties ( Dependent )
        options
    end
    
    %%
    methods
        function obj = ThermalProblem( nodeNumber)
            obj.nodeNumber_ = nodeNumber;
            
            obj.nodeVolume_ = zeros([nodeNumber 1]);
            obj.nodeSurface_ = zeros([nodeNumber 1]);
            
            obj.E_ = zeros(nodeNumber);
            obj.D_ = zeros(nodeNumber);
            obj.C_ = zeros(nodeNumber);
            obj.B_ = zeros(nodeNumber);
            obj.A_ = zeros(nodeNumber);
            obj.Z_ = zeros([nodeNumber 1]);
            
            obj.options_.tolFun = 1e-12;
            obj.options_.tolX = 1e-12;
            obj.options_.MaxIterations = 50;
            obj.options_.plotEnable = 0;
            obj.options_.method = 'NewtonRaphson';
        end
    end
    
    %%
    methods
        function xf = solve(obj, x0)
            % solve ThermalProblem
            %
            %   xf = solve( x0)
            %
            % x0:       start point (optional, default: x0 = A\Z)
            %
            % Available methods (set at options_.method):
            %   * Iterative:           xf = 0.5* x0 + 0.5* Ap(x0)\Z,   Ap(x) = E*x^4 + D*x^3 + C*x^2 + B*x + A
            %   * NewtonRaphson     xf = x0 - J(x0)\F(x0),          J(x) = 5*E*x^4 + 4*D*x^3 + 3*C*x^2 + 2*B*x + A
            %

            if nargin < 2 || isempty( x0)
                x0 = obj.A_ \ obj.Z_;
            end

            % Do not work:
            % https://fr.mathworks.com/help/optim/ug/nonlinear-equations-with-jacobian.html
            % https://en.wikipedia.org/wiki/Newton%27s_method
            % https://pt.wikipedia.org/wiki/M%C3%A9todo_de_Newton-Raphson
            %
            % opt = optimoptions('fsolve','SpecifyObjectiveGradient','on');
            % opt.outputFunction = @plotTemperature;
            % xf = fsolve( @obj.problemFJ, x0, setstructfields( opt, obj.options_));
            
            for i = 1:obj.options_.MaxIterations
                switch obj.options_.method
                    case 'Iterative'
                        xf = ( x0 + obj.computeAp(x0)\obj.Z_ )/2;
                    case 'NewtonRaphson'
                        xf = x0 - obj.computeJacobian(x0) \ obj.computeFunction(x0);
                    otherwise
                        error('ThermalProblem.solve: Unknown method. Use ''Alvaro'' or ''NewtonRaphson''.');
                end
                
                if( obj.options_.plotEnable)
                    figure(10)
                    plot( xf(1:obj.nodeNumber_) - 273.15)
                    hold on
                    grid on
                end
                
                tolFun = sum( obj.computeFunction(xf).^2 );
                tolX = max( abs( x0 - xf));
                x0 = xf;

                if tolFun < obj.options_.tolFun
                    break
                end
                if tolX < obj.options_.tolX
                    break
                end
                if i == obj.options_.MaxIterations
                    error('ThermalProblem: Problem do not converge.')
                end
            end

            if( obj.options_.plotEnable)
                figure(10)
                plot( xf(1:obj.nodeNumber_) - 273.15)
                hold on
                grid on
            end
        end
    end
    methods (Access = protected)
        function [F,J] = computeFJ(obj, xi)
            F = obj.computeFunction(xi);
            J = obj.computeJacobian(xi);
        end
        function [F] = computeFunction(obj, xi)
            App = @(xi) obj.E_* diag( xi.^4) + obj.D_* diag( xi.^3) + obj.C_* diag( xi.^2) + obj.B_* diag( xi) + obj.A_;
            Function_ = @(xi) App(xi)* xi - obj.Z_;
            F = Function_(xi);
        end
        function [J] = computeJacobian(obj, xi)
            Jacobian_ = @(xi) 5* obj.E_* diag( xi.^4) + 4* obj.D_* diag( xi.^3) + 3* obj.C_* diag( xi.^2) + obj.B_* diag( xi) + obj.A_;
            J = Jacobian_(xi);
        end
        function [Ap] = computeAp(obj, xi)
            Ap_ = @(xi) obj.E_* diag( xi.^4) + obj.D_* diag( xi.^3) + obj.C_* diag( xi.^2) + obj.B_* diag( xi) + obj.A_;
            Ap = Ap_(xi);
        end
        function plotTemperature(obj)
            if( obj.options_.plotEnable)
                figure(10)
                plot( xf(1:obj.nodeNumber_) - 273.15)
                hold on
                grid on
            end
        end
    end
    
    %%
    % node caracteristics
    methods
        function obj = setNodeVolume(obj, row, volume)
            obj.nodeVolume_(row) = volume;
        end
        function obj = setNodeSurface(obj, row, surface)
            obj.nodeSurface_(row) = surface;
        end
    end
    
    %%
    methods
        function fixTemperature(obj, node, temperature)
            % fix node temperature (insert potential source)
            %
            %   fixTemperature( node, temperature)
            %
            
            % expand matrices
            obj.E_(end+1,end+1) = 0;
            obj.D_(end+1,end+1) = 0;
            obj.C_(end+1,end+1) = 0;
            obj.B_(end+1,end+1) = 0;
            
            obj.A_(end+1,node) = 1;
            obj.A_(node,end+1) = -1;
            obj.Z_(end+1) = temperature;
        end
    end
    
    %%
    methods
        function insertE(obj, row, column, value)
            % insert non linear conductivity (* dT^5) between two nodes
            %
            %   insertE( node1, node2, conductivity)
            %
            
            obj.E_(row,row) = obj.E_(row,row) + value;
            
            if row ~= column && column ~= 0
                obj.E_(column,column) = obj.E_(column,column) + value;
                obj.E_(row,column) = obj.E_(row,column) - value;
                obj.E_(column,row) = obj.E_(column,row) - value;
            end
        end
        function insertEsurface(obj, row, column, value)
            % Insert non linear conductivity (* dT^5) witch is proportional to stored node1 surface.
            % Used conductivity = conductivity * node1 surface
            % 
            %   insertEsurface( node1, node2, conductivity)
            %
            obj.insertE( row, column, value* obj.nodeSurface_(row));
        end
        
        function insertD(obj, row, column, value)
            % insert non linear conductivity (* dT^4) between two nodes
            %
            %   insertD( node1, node2, conductivity)
            %
            
            obj.D_(row,row) = obj.D_(row,row) + value;
            
            if row ~= column && column ~= 0
                obj.D_(column,column) = obj.D_(column,column) + value;
                obj.D_(row,column) = obj.D_(row,column) - value;
                obj.D_(column,row) = obj.D_(column,row) - value;
            end
        end
        function insertDsurface(obj, row, column, value)
            % Insert non linear conductivity (* dT^4) witch is proportional to stored node1 surface.
            % Used conductivity = conductivity * node1 surface
            % 
            %   insertDsurface( node1, node2, conductivity)
            %
            obj.insertD( row, column, value* obj.nodeSurface_(row));
        end
        
        %%
        function insertC(obj, row, column, value)
            % insert non linear conductivity (* dT^3) between two nodes
            %
            %   insertD( node1, node2, conductivity)
            %
            
            obj.C_(row,row) = obj.C_(row,row) + value;
            
            if row ~= column && column ~= 0
                obj.C_(column,column) = obj.C_(column,column) + value;
                obj.C_(row,column) = obj.C_(row,column) - value;
                obj.C_(column,row) = obj.C_(column,row) - value;
            end
        end
        function insertCsurface(obj, row, column, value)
            % Insert non linear conductivity (* dT^3) witch is proportional to stored node1 surface.
            % Used conductivity = conductivity * node1 surface
            % 
            %   insertDsurface( node1, node2, conductivity)
            %
            obj.insertC( row, column, value* obj.nodeSurface_(row));
        end
        
        %%
        function insertB(obj, row, column, value)
            % insert non linear conductivity (* dT^2) between two nodes
            %
            %   insertD( node1, node2, conductivity)
            %
            
            obj.B_(row,row) = obj.B_(row,row) + value;
            
            if row ~= column && column ~= 0
                obj.B_(column,column) = obj.B_(column,column) + value;
                obj.B_(row,column) = obj.B_(row,column) - value;
                obj.B_(column,row) = obj.B_(column,row) - value;
            end
        end
        function insertBsurface(obj, row, column, value)
            % Insert non linear conductivity (* dT^2) witch is proportional to stored node1 surface.
            % Used conductivity = conductivity * node1 surface
            % 
            %   insertDsurface( node1, node2, conductivity)
            %
            obj.insertB( row, column, value* obj.nodeSurface_(row));
        end
        
        %%
        function insertA(obj, row, column, value)
            % insert linear conductivity (* dT) between two nodes
            %
            %   insertA( node1, node2, conductivity)
            %
            obj.A_(row,row) = obj.A_(row,row) + value;
            
            if row ~= column && column ~= 0
                obj.A_(column,column) = obj.A_(column,column) + value;
                obj.A_(row,column) = obj.A_(row,column) - value;
                obj.A_(column,row) = obj.A_(column,row) - value;
            end
        end
        function insertAsurface(obj, row, column, value)
            % Insert linear conductivity (* dT) witch is proportional to stored node1 surface.
            % Used conductivity = conductivity * node1 surface
            % 
            %   insertAsurface( node1, node2, conductivity)
            %
            obj.insertA( row, column, value* obj.nodeSurface_(row));
        end
        
        %%
        function insertZ(obj, row, value)
            % insert flow source at specific node
            %
            %   insertZ( node, flow)        flow (losses) [W]
            %
            obj.Z_(row) = obj.Z_(row) + value;
        end
        function insertZvolume(obj, row, value)
            % insert volumetric losses density at specific node (proportional to stored node volume)
            %
            %   insertZvolume( node, lossesDensity)        lossesDensity [W/m3]
            %
            obj.insertZ( row, value* obj.nodeVolume_(row))
        end
    end
    
    %%
    methods
        function set.options(obj, opt)
            obj.options_ = setstructfields( obj.options_, opt);
        end
        function opt = get.options(obj)
            opt = obj.options_;
        end
    end
end
classdef Interface < handle
    % OptimAlgo.Interface is an interface for all OptimAlgo objects.
    %
    % OptimAlgo.Interface properties:
    %   options      - optimization algorithm options
    %
    % OptimAlgo.Interface methods:
    %   optimize     - starts optimization
    %
    %   See also OptimAlgo.Facture, OptimAlgo.OptimAlgoGradientDescentMatlab
    %

	properties (Access = protected)
		options_
	end
	properties (Dependent)
		options    % structure with optimization tool options. Additional options are accepted.
	end

	methods
		function obj = Interface(varargin)
		end
	end
	
	methods (Abstract)
        %
        % [x,fVal,extFlag] = optimize(objective,X0,LB,UB,constraint)
        % compute optimization with:
        %
        % arguments:
        %    objective      - objective function function handle. Ex: @(x) objective(x)
        %    X0             - initial values
        %    LB             - lower bound values
        %    UB             - upper bound values
        %    constraint     - constraint function function handle. Ex: @(x) constraint(x)
        %
        % return values:
        %    x              - optimum values
        %    fVal           - objective function value at x
        %    extFlag        - optimization exit flag / status
        %
		[x,fVal,extFlag] = optimize(obj,objective,X0,LB,UB,constraint,varargin)
        
	end
	
	methods
        function val = get.options(obj)
			val = obj.options_;
		end
			
		function set.options(obj, varargin)
			p = inputParser;
            p.KeepUnmatched = true;
            p.parse(varargin{:});
            
            if ~isempty(p.Unmatched)
                obj.options_ = setNewStructure( obj.options_, p.Unmatched);

                % /!\ /!\ /!\ /!\ /!\ /!\ /!\   /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\
                % /!\ sensible parameter: ScaleProblem  = 'obj-and-constr'. /!\
                % /!\ Optimisation do not work for ScaleProblem = 'none'.   /!\
                % /!\ that is now MATLAB default value. How it was maybe    /!\
                % /!\ overwritten in merge, we shal reset it now.           /!\
                % /!\ /!\ /!\ /!\ /!\ /!\ /!\   /!\ /!\ /!\ /!\ /!\ /!\ /!\ /!\
                obj.options_.ScaleProblem = 'obj-and-constr';
            end
		end	
	end
end

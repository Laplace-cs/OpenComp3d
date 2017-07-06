classdef OptimAlgoTemplate < OptimAlgo.Interface

	methods
		function obj = OptimAlgoTemplate(varargin)
			obj@OptimAlgo.Interface(varargin{:});
			
            % default options
            obj.options_ = [];
            %obj.options_.toto = 123;
			
			% update options with varargin
            if ~isempty( varargin )
                obj.options = varargin;
            end
		end
	end
	
	methods
		function [x,fVal,extFlag] = computeOptimization(obj,objective,X0,LB,UB,constraint,varargin)
            if ~isempty( varargin )
                obj.options = varargin;
            end
			
            % optimization code
            % ...
            % ...
			
			x = X0;
			fVal = inf;
			extFlag = -2;	
		end
	end
end
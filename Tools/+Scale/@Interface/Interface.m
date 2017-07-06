classdef Interface < handle
    % Interface is an interface for all scale objects and scale decorators.
    %
    % Interface Properties:
    %
    % Interface Methods:
    %    setup(lb,ub)               - scale bounds setup method
    %    xScaled = scale(x)         - scale method
    %    x = unscale(xScaled)       - unscale method
    %
    % Arguments and return data:
    %    x  - data vector
    %    lb - lower bound
    %    ub - lower bound
    %    xScaled -  data vector scaled
    %    lbScaled - lower bound scaled
    %    ubScaled - lower bound scaled
    %
    % Exemple:
    %   myScale = ScaleFacture.makeScale('norm')               % Create scale object "myScale" type "Normalisation" [0~1] using ScaleFacture
    %   [lbScaled,ubScaled] = myScale.setup([1 5],[2 10])      % Setup of the scale object giving original bounds
    %       % >> lbScaled = [0 0]
    %       % >> ubScaled = [1 1]
    %
    %   myScale.scale([1 5])          % >>  [0 0]
    %   myScale.unscale([0 0])        % >>  [1 5]
    %
    %   myScale.scale([1.5 7.5])      % >>  [0.5 0.5]
    %   myScale.unscale([0.5 0.5])    % >>  [1.5 7.5]
    %
    %   myScale.scale([2 10])         % >>  [1 1]
    %   myScale.unscale([1 1])        % >>  [2 10]
    %
    %
    %   See also Scale.Facture
    %
    
    methods
        function obj = Interface(varargin)
        end
    end
    
    methods (Abstract)
        % [lbScaled,ubScaled] = setup(lb,ub)
        %   scale both bounds
        %   save internal data for scale/unscale
        %
        % arguments:
        %   lb - lower bound
        %   ub - upper bound
        %
        % return values:
        %   lbScaled - lower bound scaled
        %   ubScaled - upper bound scaled
        %
        [lbScaled,ubScaled] = setup(lb,ub)
        
        % scale method:
        %   takes data vector and scales
        %
        % arguments:
        %   x - data vector
        %
        % return values:
        %   xScaled - data vector scaled
        %
        xScaled = scale(x)
        
        % unscale method:
        %   takes scaled data vector and unscales
        %
        % arguments:
        %   xScaled - data vector scaled
        %
        % return values:
        %   x - data vector unscaled
        %
        x = unscale(xScaled)
    end
    
end

classdef Facture < handle
% Facture is a facture of scale objects according with user options.
%
% * Scale.Facture.make( scaleType )
%      makes a scale of type scaleType
%
% * Scale.Facture.typeList
%      lists all scale type availables
%
%
% Exemples:
% - No scale:
%       scaleObj = Scale.Facture.make;
% - No offset scale (values starts from 0):
%       scaleObj = Scale.Facture.make('offset');
% - Normalized scale (between 0 and 1):
%       scaleObj = Scale.Facture.make('norm');
% - Logarithmic scale (log10):
%       scaleObj = Scale.Facture.make('log');
% - Logarithmic scale without offset:
%       scaleObj = Scale.Facture.make({'log','offset'});
% - Logarithmic scale normalized:
%       scaleObj = Scale.Facture.make({'log','norm'});
%
%
% Recommended sets:
%   1- Logarithmic scale without offset
%   2- Logarithmic scale normalized (normalized scale adds a bias)
%
%
% Advices:
%       Logarithmic scale allows evaluation of stopping criteria "StepTolerance"
%       (TolX) in relative variation (like percentual variation).
%       Relative variation evaluation avoids problems with StepTolerance when 
%       variables have important magnitude order differences.
%
%       ex1 - Absolute variation:
%           TolX1 = 101 - 100 = 1
%           TolX2 = 101e-6 - 100e-6 = 1e-6
%           A variation of 1% give a variation rate of TolX1/ TolX2 = 1e6.
%       ex2 - Relative variation:
%           TolX1 = log10(101) - log10(100) = 0.0043
%           TolX2 = log10(101e-6) - log10(100e-6) = 0.0043
%           A variation of 1% represents variation of 0.0043 in both cases.
%
%       For non normalized logarithmic scale:
%           percentualVariation = 100*(10^tolX - 1);
%           tolX = log10(percentualVariation + 100) - 2;
%
%
%   See also Scale.Interface, Scale.Decorator
%
    
    properties ( Constant )
        typeList = { ...
            {'log','offset'}, ...    
            {'log','norm'},  ...
            {'log'}, ...
            {'norm'}, ...
            {'offset'}, ...            
            {} ...
            };
    end
    
    methods
        function obj = Facture(varargin)
        end
    end
    
    methods (Static)
        % All scale options are added like invisible envelopes without changing interface (decorator design pattern).
        function scaleObj = make( scaleType, varargin)
            scaleObj = Scale.ScaleNone;
            
            if nargin > 0
                if ~iscell(scaleType)
                    scaleType = {scaleType};
                end
                for k = 1:length(scaleType)
                    if ~isempty(scaleType{k})
                        if ischar(scaleType{k})
                            scaleObj = addScaleDecorator( scaleType{k}, scaleObj);
                        else
                            error('Scale.Facture: scaleType must be string or string list.')
                        end
                        
                    end
                end
            end
        end
    end
end

% Static function
function scaleObj = addScaleDecorator( scaleType, scaleObj)
    switch scaleType
        case 'offset'
            scaleObj = Scale.DecoratorOffset(scaleObj);
        case 'norm'
            scaleObj = Scale.DecoratorNorm(scaleObj);
        case 'log'
            scaleObj = Scale.DecoratorLog(scaleObj);
        otherwise
            warning(['Scale.Facture: Scale type "' scaleType '" not available.']);
    end
end
        
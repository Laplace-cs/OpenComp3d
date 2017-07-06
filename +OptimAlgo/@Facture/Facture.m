classdef Facture < handle
% OptimAlgo.Facture is a facture of OptimAlgo objects
%
% OptimAlgo.Facture methods:
%   make( algorithm )   - makes an OptimAlgo of type algorithm
%
% OptimAlgo.Facture properties:
%   typeList           -  lists all optimization algorithm types availables
%
% Optimization algorithm types:
%   GradientDescent      - Gradient Descent
%   GradientDescentMS    - Gradient Descent Multi-Start
%   GradientDescentGS    - Gradient Descent Global Search
%   GaMATLAB             - Genetic Algorithm MATLAB
%   GaES                 - Genetic Algorithm ES
%   GaAPSO               - Genetic Algorithm APSO
%   GaAGNE               - Genetic Algorithm AGNE
%
%   See also OptimAlgo.Interface, OptimAlgo.OptimAlgoGradientDescentMatlab
%

    properties ( Constant )
        typeList = { ...
            'GradientDescent', ...
            'GradientDescentMS', ...
            'GradientDescentGS', ...
            'GaMatlab', ...
            };
    end
    
    methods
        function obj = Facture(varargin)
        end
    end
    
    methods (Static)
        function optimAlgo = make( algorithm, varargin)
            
            software = 'matlab';
            
            switch software
                case 'matlab'
                    switch algorithm
                        case 'GradientDescent'
                            optimAlgo = OptimAlgo.OptimAlgoGradientDescentMatlab(varargin{:});
                        case 'GradientDescentMS'
                            optimAlgo = OptimAlgo.OptimAlgoMultiStartMatlab(varargin{:});
                        case 'GradientDescentGS'
                            optimAlgo = OptimAlgo.OptimAlgoGlobalSearchMatlab(varargin{:});
                        case 'GaMatlab'
                            optimAlgo = OptimAlgo.OptimAlgoGaMatlab(varargin{:});
                        otherwise
                            optimAlgo = OptimAlgo.OptimToolTemplate;
                    end
                    
                otherwise
                    error('optimTool not identified')
            end
        end
        
    end
    
end

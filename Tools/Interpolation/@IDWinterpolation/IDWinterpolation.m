classdef IDWinterpolation < handle
    % IDWINTERPOLATION is a class to perform inverse distance interpolation
    %
    % IDWinterpolation( Xmat, V, varargin)
    %
    %   Xmat - matrix of known inputs  (m x n) 
    %       m = number of data
    %       n = number of variables
    %   V - matrix of know ouptuts (m x 1)
    %
    % varargin options:
    %   alpha - distance weight (default = 2)
    %   opt - option of inverse interpolation
    %         'nb' = number of neighbours (default)
    %         'fr' = fixed radius
    %   val - value of the option
    %         if 'nb' val = number of neighbours (default = 10)
    %         if 'fr' val = radius

    
    properties
        Xmat_
        V_
        alpha_
        opt_
        val_
    end
    
    methods
        function obj = IDWinterpolation( Xmat, V, varargin)
            obj.Xmat_ = Xmat;
            obj.V_ = V;
            
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter( 'alpha', 2, @isnumeric);
            p.addParameter( 'opt', 'nb', @ischar);
            p.addParameter( 'val', 10, @isnumeric);
            p.parse(varargin{:});

            obj.alpha_ = p.Results.alpha;
            obj.opt_ = p.Results.opt;
            obj.val_ = p.Results.val;
        end
        
        function v = evaluate(obj, x)
            x = repmat(x, size(obj.Xmat_,1), 1);
            distanceVector = sqrt(sum((x - obj.Xmat_).^2 ,2));

            if any( distanceVector == 0 )
                v = obj.V_( distanceVector == 0 );
            else
                switch obj.opt_
                    case 'fr'
                        isInside = distanceVector < obj.val_;
                        if any( isInside )
                            distanceVector = distanceVector(isInside);
                            V = obj.V_(isInside);
                            weightVector = distanceVector .^ obj.alpha_;
                            v = sum( V .* weightVector) / sum(weightVector);
                        else
                            v = NaN;
                        end
                        
                    case 'nb'
                        [~,index] = sort(distanceVector);
                        index = index(1:obj.val_);

                        distanceVector = distanceVector( index);
                        V = obj.V_( index);
                        weightVector = distanceVector .^ obj.alpha_;
                        v = sum( V .* weightVector) / sum(weightVector);

                    otherwise
                        error('method is not recognized');
                end
            end
        end
    end
    
end

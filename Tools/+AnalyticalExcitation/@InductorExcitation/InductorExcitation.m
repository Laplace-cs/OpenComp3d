classdef InductorExcitation < AnalyticalExcitation.Interface
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden = true)
        vHv_ = [];
        vLv_ = [];
        iDc_ = [];
        fSw_ = [];
    end
    
    properties (Dependent)
        vHv
        vLv
        iDc
        fSw
    end
    
    methods
        function obj = InductorExcitation(varargin)
            obj = obj@AnalyticalExcitation.Interface(varargin);
            
            p = inputParser;
            p.KeepUnmatched = true;
            p.addParameter('vHv', obj.vHv_, @(x) x>0);
            p.addParameter('vLv', obj.vLv_, @(x) x>0);
            p.addParameter('iDc', obj.iDc_);
            p.addParameter('fSw', obj.fSw_, @(x) x>0);
            p.addParameter('nSample', obj.nSample_, @(x) x>0);
            
            p.parse(varargin{:});
            obj.vHv_ = p.Results.vHv;
            obj.vLv_ = p.Results.vLv;
            obj.iDc_ = p.Results.iDc;
            obj.fSw_ = p.Results.fSw;
            obj.nSample = p.Results.nSample; % dependent propertie: round and update
            
            obj.excitations = struct('time',[],'voltage',[],'current',[]);
        end
    end
    
    methods
        function update(obj)
            if ~isempty(obj.vHv_) && ~isempty(obj.vLv_) && ~isempty(obj.fSw_) && ~isempty(obj.nSample_)
                % internal calcul variables
                dutyCycle = obj.vLv_/obj.vHv_;  % dutyCycle
                T = 1/obj.fSw_;        % period [s]
                Ts = T/obj.nSample_;   % sample period [s]

                % time and current vectors calculation
                time = 0:Ts:T-Ts;
                obj.excitations.time = time;
                obj.excitations.voltage = obj.vHv_ * ((time < T*dutyCycle/2) + (time > T*(1 - dutyCycle/2))) - obj.vLv_ * ones(size(time));
                obj.computeInductorCurrent;
            end
        end
        function computeInductorCurrent(obj)
            obj.comp3d_.computeModelParameters;
            L = obj.comp3d_.modelParameters.electric.Lmodel.val;
            T = 1/obj.fSw_;        % period [s]
            Ts = T/obj.nSample_;   % sample period [s]

            current = Ts/L * cumsum( obj.excitations.voltage);
            current = current - mean(current) + obj.iDc_;
            obj.excitations.current = current;
        end
    end
    
    methods
        function val = get.vHv(obj)
            val = obj.vHv_;
        end
        function val = get.vLv(obj)
            val = obj.vLv_;
        end
        function val = get.iDc(obj)
            val = obj.iDc_;
        end
        function val = get.fSw(obj)
            val = obj.fSw_;
        end
        
        function set.vHv(obj, val)
            if val > 0
                obj.vHv_ = val;
                obj.generateExcitations;
            else
                warning('InductorExcitation: Invalid value');
            end
        end
        function set.vLv(obj, val)
            if val > 0
                obj.vLv_ = val;
                obj.generateExcitations;
            else
                warning('InductorExcitation: Invalid value');
            end
        end
        function set.iDc(obj, val)
            obj.iDc_ = val;
            obj.generateExcitations;
        end
        function set.fSw(obj, val)
            if val > 0
                obj.fSw_ = val;
                obj.generateExcitations;
            else
                warning('InductorExcitation: Invalid value');
            end
        end
    end
end


classdef OptimAlgoFactureTest < matlab.unittest.TestCase
    % http://fr.mathworks.com/help/optim/ug/fmincon.html
    
    properties
        optimAlgo
    end
    
    properties (ClassSetupParameter)
        algorithm = { ...
            'GradientDescent', ...
            'GradientDescentMS', ...
            'GradientDescentGS', ...
            };

    end
    
    methods (TestClassSetup)
        function ClassSetup(testCase, algorithm)
            testCase.optimAlgo = OptimAlgo.Facture.make(algorithm);
        end
    end
    
    
    methods (Test, TestTags = {'Unbounded'})
        function linearInequalityConstraintMatlabExempleTest(testCase)
            objective = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
            X0 = [-1,2];
            LB = [];
            UB = [];
            nonlcon = @testCase.linearInequalityConstraint;
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [0.5022, 0.2489], 'AbsTol', 1e-3, 'Erro 1')
        end
        
        function nonDefaultOptionsMatlabExempleTest(testCase)
            objective = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
            X0 = [0,0];
            LB = [];
            UB = [];
            nonlcon = @testCase.unitdisk;
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [0.7864, 0.6177], 'AbsTol', 1e-3, 'Erro 1')
        end
    end

    methods (Test)
        function linearInequalityAndEqualityConstraintMatlabExempleTest(testCase)
            objective = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
            X0 = [0,0];
            LB = [-1,-1];
            UB = [1,1];
            nonlcon = @testCase.linearInequalityAndEqualityConstraint;
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [0.4149, 0.1701], 'AbsTol', 1e-3, 'Erro 1')
        end
        
        function boundsConstraintsMatlabExempleTest(testCase)
            objective = @(x) 1+x(1)/(1+x(2)) - 3*x(1)*x(2) + x(2)*(1+x(1));
            X0 = [0.5,1];
            LB = [0,0];
            UB = [1,2];
            nonlcon = [];
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [1.0000,2.0000], 'AbsTol', 1e-3, 'Erro 1')
        end
        
        function boundsConstraints2MatlabExempleTest(testCase)
            objective = @(x)1+x(1)/(1+x(2)) - 3*x(1)*x(2) + x(2)*(1+x(1));
            X0 = [0.1,0.2];
            LB = [0,0];
            UB = [1,2];
            nonlcon = @testCase.unitdisk;
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [0.4e-6, 00.4e-6], 'AbsTol', 1e-3, 'Erro 1')
        end
        
        function nonLinearConstraintMatlabExempleTest(testCase)
            objective = @(x)100*(x(2)-x(1)^2)^2 + (1-x(1))^2;
            X0 = [1/4,1/4];
            LB = [0,0.2];
            UB = [0.5,0.8];
            nonlcon = @testCase.circlecon;
            
            [x,fVal,extFlag] = testCase.optimAlgo.optimize( objective, X0, LB, UB, nonlcon);
            
            testCase.verifyEqual( x, [0.5000,0.2500], 'AbsTol', 1e-3, 'Erro 1')
        end
    end
    
    methods (Static)
        function [ineq,eq] = linearInequalityConstraint(x)
            ineq = x(1) + 2*x(2) - 1;
            eq = [];
        end
        
        function [ineq,eq] = linearInequalityAndEqualityConstraint(x)
            ineq = x(1) + 2*x(2) - 1;
            eq = 2*x(1) + x(2) - 1;
        end
        
        
        function [ineq,eq] = unitdisk(x)
            ineq = x(1)^2 + x(2)^2 - 1;
            eq = [ ];
        end
        
        % circle centered at [1/3,1/3] with radius 1/3.
        function [c,ceq] = circlecon(x)
            c = (x(1)-1/3)^2 + (x(2)-1/3)^2 - (1/3)^2;
            ceq = [];
        end
    end
end
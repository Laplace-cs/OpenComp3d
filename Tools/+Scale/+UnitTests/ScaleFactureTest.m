classdef ScaleFactureTest < matlab.unittest.TestCase
    
    properties
        scale
    end
    
    properties (ClassSetupParameter)
        scaleType = Scale.Facture.typeOptionList;
    end
    
    methods (TestClassSetup)
        function ClassSetup(testCase, scaleType)
            testCase.scale = Scale.Facture.make(scaleType);
        end
    end
    
    methods (Test)
        function ScaleTest(testCase)
            x = [5 20 50];
            lb = [1 1 10];
            ub = [10 100 100];
            
            testCase.scale.setup(lb,ub);
            xScaled = testCase.scale.scale(x);
            xUnscaled = testCase.scale.unscale(xScaled);
            
            testCase.verifyEqual( xUnscaled, x, 'AbsTol', 1e-9, 'Erro 1');
        end
    end
end
    
    
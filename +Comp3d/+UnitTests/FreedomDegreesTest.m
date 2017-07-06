classdef FreedomDegreesTest < matlab.unittest.TestCase
    
    properties
        myHeatSink
        myBasePlate
        myRectangularFins
        mySurface
        myFlow
        myInductor
    end

    %%
    
    methods(TestClassSetup)
        function createFreedomDegreesTest(testCase)
            testCase.myHeatSink = Comp3d.HeatSink( ...
                'name', 'heatSink',...
                'level',1);
            testCase.myBasePlate = Comp3d.BasePlate('name','baseplate',...
                                  'width',0.15,...
                                  'length',0.2,...
                                  'height',5e-3,...
                                  'level',1,...
                                  'conductingMaterial',2);
            testCase.myRectangularFins = Comp3d.RectangularFins('name','fins',...
                                        'thickness',1e-3,...
                                        'length',0.3,...
                                        'height',5e-2,...
                                        'gapBetweenFins',1e-3,...
                                        'numberOfFins',10,...
                                        'level',1,...
                                        'conductingMaterial',2);
            testCase.myFlow = Cooling.ForcedAir('name','forcedAir','airSpeed',0.1,'temperature',25);
            testCase.mySurface = Comp3d.HeatingSurface('name','heatingSurface','power',50);
            testCase.myInductor = Comp3d.InductorCustomEI('name','inductor');
        end
    end
        
    %%
    methods(Test)
        
        function linkTest(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % We verify both magnitudes are different before
            lengthBasePlate = testCase.myBasePlate.dimensions.length;
            lengthFins = testCase.myRectangularFins.dimensions.length;
            
            testCase.verifyThat( lengthBasePlate, IsEqualTo( 0.2,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myBasePlate),' lvl ',num2str(testCase.myBasePlate.level),' value is incorrect']);
            testCase.verifyThat( lengthFins, IsEqualTo( 0.3,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myRectangularFins),' lvl ',num2str(testCase.myRectangularFins.level),' value is incorrect']);
            
            % Addition
            testCase.myHeatSink.addElement(testCase.myBasePlate);
            testCase.myHeatSink.addElement(testCase.myRectangularFins);
            testCase.myHeatSink.addElement(testCase.myFlow);
            testCase.myHeatSink.addElement(testCase.mySurface);
            
            % We verify the link
            lengthBasePlate = testCase.myBasePlate.dimensions.length;
            lengthFins = testCase.myRectangularFins.dimensions.length;
            
            testCase.verifyThat( lengthBasePlate, IsEqualTo(lengthFins,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myBasePlate),' lvl ',num2str(testCase.myBasePlate.level),' value is incorrect']);
            
            % We verify that if one changes the other one does as well
            testCase.myRectangularFins.dimensions.length = 0.15;
            lengthBasePlate = testCase.myBasePlate.dimensions.length;
            lengthFins = testCase.myRectangularFins.dimensions.length;
            
            testCase.verifyThat( lengthBasePlate, IsEqualTo( 0.15,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myBasePlate),' lvl ',num2str(testCase.myBasePlate.level),' value is incorrect']);
            testCase.verifyThat( lengthFins, IsEqualTo( 0.15,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myRectangularFins),' lvl ',num2str(testCase.myRectangularFins.level),' value is incorrect']);
        end
        function boundTest(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            lB = testCase.myInductor.freedomDegrees.freedomDegreesArray(1).lB;
            uB = testCase.myInductor.freedomDegrees.freedomDegreesArray(1).uB;
            
            % Free Test
            testCase.myInductor.freedomDegrees.freedomDegreesArray(1).status = 'free';
            testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0 = -1e20;
            value = testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0;
            testCase.verifyThat( value, IsEqualTo( lB,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myBasePlate),' lvl ',num2str(testCase.myBasePlate.level),' value is incorrect']);
            testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0 = 1e20;
            value = testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0;
            testCase.verifyThat( value, IsEqualTo( uB,'Within',RelativeTolerance(1e-3)),['length ',class(testCase.myBasePlate),' lvl ',num2str(testCase.myBasePlate.level),' value is incorrect']);
        end
        function saveAndLoadTest(testCase)
           import matlab.unittest.constraints.IsEqualTo;
           import matlab.unittest.constraints.RelativeTolerance;
           
           testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0 = 1e-2;
           
           % We change the path
           currentPath = pwd;
           pathToGo = getpref('OpenComp3d','path');
           cd([pathToGo,'/OpenComp3d/+Comp3d/+UnitTests/DataTest']);
           
           % We save the configuration
           testCase.myInductor.freedomDegrees.saveFreedomDegrees('testTextFreedom');
           
           testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0 = 0.5e-2;
           
           % We load the configuration
           testCase.myInductor.freedomDegrees.loadFreedomDegrees('testTextFreedom');
           
           value = testCase.myInductor.freedomDegrees.freedomDegreesArray(1).x0;
           
           testCase.verifyThat( value, IsEqualTo(1e-2,'Within',RelativeTolerance(1e-3)),['saving and loading function not working']);
           
           cd(currentPath);
        end
        function displayTest(testCase)
            testCase.myInductor.freedomDegrees.writeText;
        end
        function homotheticTest(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            testCase.myInductor.freedomDegrees.freedomDegreesArray(1).relation = '2 * obj.dimensions.legThickness';
            testCase.myInductor.freedomDegrees.freedomDegreesArray(1).status = 'homothetic';
            
            testCase.myInductor.dimensions.legThickness = 0.03;
            value = testCase.myInductor.dimensions.legWidth;
            
            testCase.verifyThat( value, IsEqualTo(0.06,'Within',RelativeTolerance(1e-3)),['homothetic function']);

        end
        function setAndGet(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            testCase.myInductor.freedomDegrees.setFreedomDegreeUnit('nTurns','x0',10)
            val = testCase.myInductor.freedomDegrees.getFreedomDegreeUnit('nTurns');
            value = val.x0;
            testCase.verifyThat( value, IsEqualTo(10,'Within',RelativeTolerance(1e-3)),['get and set freedomDegreeUnit function']);
        end
    end
    

    
end
classdef HeatSinkTest < matlab.unittest.TestCase
    
    properties
        myElement
        myBasePlate
        myRectangularFins
        mySurface
        myFlow
    end

    %%
    
    methods(TestClassSetup)
        function createHeatSinkTest(testCase)
            testCase.myElement = Comp3d.HeatSink( ...
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
            testCase.myFlow = Cooling.ForcedAir('name','forcedAir','airSpeed',2,'temperature',25);
            testCase.mySurface = Comp3d.HeatingSurface('name','heatingSurface','power',50);
        end
    end
        
    %%
    methods(Test)
        
        function compositionTest(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Addition
            testCase.myElement.addElement(testCase.myBasePlate);
            testCase.myElement.addElement(testCase.myRectangularFins);
            testCase.myElement.addElement(testCase.myFlow);
            testCase.myElement.addElement(testCase.mySurface);
            
            % removal
            testCase.myElement.removeElement(testCase.mySurface);
            testCase.myElement.addElement(testCase.mySurface);
            
            mySurface2 = Comp3d.HeatingSurface;
            testCase.myElement.addElement(mySurface2);
            testCase.myElement.removeElement(mySurface2);
           
            % We verify that lenghts are equal
            lengthBP = testCase.myBasePlate.dimensions.length;
            lengthFins = testCase.myRectangularFins.dimensions.length;
            testCase.verifyThat(lengthBP, IsEqualTo(lengthFins,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
        end
        
        function computeModelParametersTestLv1(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            testCase.myElement.computeModelParameters;
            
            weightBP = testCase.myBasePlate.outputData.geometric.weight;
            weightFins = testCase.myRectangularFins.outputData.geometric.weight;
            weightHeatSink = testCase.myElement.outputData.geometric.weight;
            volumeHeatSink = testCase.myElement.outputData.geometric.manufacturingVolume;
            rThBasePlate = testCase.myBasePlate.modelParameters.thermal.rTh;
            rThFins = testCase.myRectangularFins.modelParameters.thermal.rTh;
            rThHeatSink = testCase.myElement.thermalModel.rTh;
            
            testCase.verifyThat(weightBP, IsEqualTo( 0.4050,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(weightFins, IsEqualTo( 0.405,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(weightHeatSink, IsEqualTo( weightBP+weightFins,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(volumeHeatSink, IsEqualTo( 4.35e-04,'Within',RelativeTolerance(1e-3)),['volume ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            
            testCase.verifyThat( rThBasePlate, IsEqualTo( 7.0323e-04,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat( rThFins, IsEqualTo( 0.432507956662521,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat( rThHeatSink, IsEqualTo( rThBasePlate + rThFins,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
        
        end
        
        function computeOutputDataTestLv1(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Data calculation
            testCase.myElement.computeOutputData;
            
            baseTemperature = testCase.myElement.outputData.thermal.baseTemperature;
            exitTemperature = testCase.myElement.outputData.thermal.exitTemperature;
            pressureLosses = testCase.myElement.outputData.thermal.pressureLosses;
            speedBetweenFins = testCase.myElement.outputData.thermal.speedBetweenFins;
            insideTemperature = testCase.mySurface.outputData.thermal.insideTemperature;
            
            testCase.verifyThat(baseTemperature, IsEqualTo( 46.660559577148561, 'Within', RelativeTolerance(1e-3)), ['base temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(exitTemperature, IsEqualTo( 27.263712250000001, 'Within', RelativeTolerance(1e-3)), ['exit temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(pressureLosses, IsEqualTo( 97.626993454466856, 'Within', RelativeTolerance(1e-3)), ['Pressure losses ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(speedBetweenFins, IsEqualTo( 4.222222222222222, 'Within', RelativeTolerance(1e-3)), ['Speed between fins ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(insideTemperature, IsEqualTo( 46.660559577148561, 'Within', RelativeTolerance(1e-3)), ['Inside temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
        end
        
        function displayTest(testCase)
            path = getpref('OpenComp3d','path');
            currentDir = pwd;
            cd([path,'/OpenComp3d/+Comp3d/+UnitTests'])
            fid = fopen('testUnitsOutputText.txt', 'a');
            testCase.myElement.displayInformation(fid);
            fclose(fid);
            cd(currentDir)
        end
        
        function drawTest(testCase)
            figure
            testCase.myElement.drawComponent([0 0 0]);
            if Utils.log4m.getLogger().plotTests == false
                close
            end
        end
        
        function drawPressureLosses(testCase)
            testCase.myElement.displayPressureLossesCurve();
            if Utils.log4m.getLogger().plotTests == false
                close
            end
        end
   %% Lvl 2     
        function computeModelParametersTestLv2(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % We change all the level of the elements
            testCase.myElement.updateObj('level',2);
            testCase.myBasePlate.updateObj('level',2);
            testCase.myRectangularFins.updateObj('level',2);
            testCase.myElement.computeModelParameters;
            
            weightBP = testCase.myBasePlate.outputData.geometric.weight;
            weightFins = testCase.myRectangularFins.outputData.geometric.weight;
            weightHeatSink = testCase.myElement.outputData.geometric.weight;
            volumeHeatSink = testCase.myElement.outputData.geometric.manufacturingVolume;
            rThBasePlate = testCase.myBasePlate.modelParameters.thermal.rTh;
            rThFins = testCase.myRectangularFins.modelParameters.thermal.rTh;
            rThHeatSink = testCase.myElement.thermalModel.rTh;
            
            testCase.verifyThat(weightBP, IsEqualTo( 0.4050,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(weightFins, IsEqualTo( 0.405,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(weightHeatSink, IsEqualTo( weightBP+weightFins,'Within',RelativeTolerance(1e-3)),['weight ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat(volumeHeatSink, IsEqualTo( 4.35e-04,'Within',RelativeTolerance(1e-3)),['volume ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            
            testCase.verifyThat( rThBasePlate, IsEqualTo( 0.489262237072932,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat( rThFins, IsEqualTo(0.432507956662521,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
            testCase.verifyThat( rThHeatSink, IsEqualTo( rThBasePlate + rThFins,'Within',RelativeTolerance(1e-3)),['rth ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' value is incorrect']);
        
        end


        
        function computeOutputDataTestLv2(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Data calculation
            testCase.myElement.computeOutputData;
            
            baseTemperature = testCase.myElement.outputData.thermal.baseTemperature;
            exitTemperature = testCase.myElement.outputData.thermal.exitTemperature;
            pressureLosses = testCase.myElement.outputData.thermal.pressureLosses;
            speedBetweenFins = testCase.myElement.outputData.thermal.speedBetweenFins;
            insideTemperature = testCase.mySurface.outputData.thermal.insideTemperature;
            
            testCase.verifyThat(baseTemperature, IsEqualTo( 71.088509686772653, 'Within', RelativeTolerance(1e-3)), ['base temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(exitTemperature, IsEqualTo( 27.263712250000001, 'Within', RelativeTolerance(1e-3)), ['exit temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(pressureLosses, IsEqualTo( 97.626993454466856, 'Within', RelativeTolerance(1e-3)), ['Pressure losses ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(speedBetweenFins, IsEqualTo( 4.222222222222222, 'Within', RelativeTolerance(1e-3)), ['Speed between fins ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
            testCase.verifyThat(insideTemperature, IsEqualTo( 71.088509686772653, 'Within', RelativeTolerance(1e-3)), ['Inside temperature ',class(testCase.myElement),' lvl ',num2str(testCase.myElement.level),' is incorrect']);
        end
        
        
        

        
    end
    

    
end




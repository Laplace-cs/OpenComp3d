classdef InductorCustomEITest < matlab.unittest.TestCase
    
    properties
        myElement
    end
    
            
    
    methods (Static)
        function r = ooteeSimulate( Inductor, varargin)
            Vin = Vdc(100,'Vin',1);
            Load = Resistor(1.5,'Load',1);
            
            % converter instantiation
            Conv = Chopper('Topology',[1,1,1]);
            Conv.modul.fCar = 20e3;
            Conv.opPoint.alphaBuck = 0.5;
            
            main = Ckt.CktComposite;
            main.createNode({'Hv','Lv','Load'},[0 1 1]);
            main.addGnd;
            
            main.addCkt(Vin,[1 0]);
            main.addCkt(Conv,[1 2 0]);
            main.addCkt(Inductor,[2 3]);
            main.addCkt(Load,[3 0]);
            
            solver = ConvertSystSolver();
            res = solver.simulate( main, varargin{:});
            %resFormat = solver.formatX(res);
            %solver.ventilX(res)
            
            main.removeCkt(Inductor);
            
            r.simuTime = res.simuTime;
            r.vLv = res.vLv;
            r.vLoad = res.vLoad;
            r.iHv = res.iVin;
            r.iLv = res.iLoad;
        end
    end
    
    %%
    
    methods(TestClassSetup)
        function rectangularCreateInductorTest(testCase)
            testCase.myElement = Comp3d.InductorCustomEI( ...
                'name', 'LcEIrct', ...
                'level', 1, ...
                'recordObj', true, ...
                ...
                ...'correctValues', true, ...
                'conductorShape', 'rectangular', ...
                ...
                'materialMagnetic', 1, ...
                'materialConductor', 1, ...
                ...
                'legWidth', 10e-3, ...
                'legThickness', 20e-3, ...
                'interTurnSpace', 1e-3, ...
                'airGap', 2e-3, ...
                ...
                'nTurns', 10, ...
                ...
                'conductorWidth', 3e-3, ...
                'conductorHeight', 5e-2 ...
                );
        end
    end
        
    %%
    methods(Test)
        %% rectangular Lv1
        function rectangularComputeModelParametersTestLv1(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            testCase.myElement.computeModelParameters;
            
            weight = testCase.myElement.outputData.geometric.weight;
            rDCValue = testCase.myElement.modelParameters.electric.rS;
            
            testCase.verifyThat( weight, IsEqualTo( 2.180864,'Within',RelativeTolerance(1e-3)),'weight (Lv1,CustomEIrectangular) is incorrect');
            testCase.verifyThat( rDCValue, IsEqualTo( 3.3935e-4,'Within',RelativeTolerance(1e-3)),'rDC Value (Lv1,CustomEIrectangular) is incorrect');
        
        end
        
        function rectangularElectricModelTestLv1(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            
            testCase.myElement.buildElectricModel;
        
            % For simulation
            r = testCase.ooteeSimulate( ...
                testCase.myElement.electricModel, ...
                'switchingBw', 10e6, ...
                'design', false ...
                );
            
            if Utils.log4m.getLogger().plotTests == true
                figure('Color', [1 1 1], 'Name', 'rectangularElectricModelTest')
                subplot(2,1,1);
                    xlabel('time (s)');
                    ylabel('Current (A)');
                    hold on
                    grid on
                    plot( r.simuTime, r.vLv, 'DisplayName', 'vLv');
                    plot( r.simuTime, r.vLoad, 'DisplayName', 'vLoad');
                    legend('show')    
                subplot(2,1,2);
                    xlabel('time (s)');
                    ylabel('Voltage (V)');
                    hold on
                    grid on
                    plot( r.simuTime, r.iHv, 'DisplayName', 'iHv');
                    plot( r.simuTime, r.iLv, 'DisplayName', 'iLv');
                    legend('show')
            end
            
             % load non-regression test data
            [ffolder,fname] = fileparts(which('Comp3d.UnitTests.InductorCustomEITest'));
            filename = [ffolder '\DataTest\' fname 'simulateRectangularInductorCustomEIlv1TestNRT.mat'];
            try
                load(filename)
            catch
                rNRT = r;
                save( filename, 'rNRT');
                warning('/!\ rectangularInductorCustomEI Lv1 non-regression test data not availeble /!\');
            end
            
            testCase.verifyThat( r.simuTime, IsEqualTo( rNRT.simuTime, 'Within', RelativeTolerance(1e-3)), 'simutime in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.vLv, IsEqualTo( rNRT.vLv, 'Within', RelativeTolerance(1e-3)), 'vLv in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.vLoad, IsEqualTo( rNRT.vLoad, 'Within', RelativeTolerance(1e-3)), 'vLoad in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.iHv, IsEqualTo( rNRT.iHv, 'Within', RelativeTolerance(1e-3)), 'iHv in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.iLv, IsEqualTo( rNRT.iLv, 'Within', RelativeTolerance(1e-3)), 'iLv in Non-regression test of rectangularInductorCustomEI does not match');
            
        end
        
        function rectangularGetSimulationDataSetExcitationsTestLv1(testCase)
            data = testCase.myElement.getSimulationData;
            testCase.myElement.setExcitations(data);
        end
        
        function rectangularComputeOutputDataTestLv1(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Data calculation
            testCase.myElement.computeOutputData;
            
            jouleLossesValue = testCase.myElement.outputData.electric.jouleLosses;
            coreLossesValue = testCase.myElement.outputData.magnetic.coreLosses;
            BMaxValue = testCase.myElement.outputData.magnetic.BMax;
            temperature = testCase.myElement.outputData.thermal.temperature;
            
            testCase.verifyThat( jouleLossesValue, IsEqualTo( 0.528872937652937, 'Within', RelativeTolerance(1e-3)), 'Default copper losses (Lv1,CustomEIrectangular) is incorrect');
            testCase.verifyThat( coreLossesValue, IsEqualTo( 0.723346692178970, 'Within', RelativeTolerance(1e-3)), 'Default core losses (Lv1,CustomEIrectangular) is incorrect');
            testCase.verifyThat( BMaxValue, IsEqualTo( 0.195818171362054, 'Within', RelativeTolerance(1e-3)), 'Default BMax (Lv1,CustomEIrectangular) is incorrect');
            testCase.verifyThat( temperature, IsEqualTo( 27.673982591053012, 'Within', RelativeTolerance(1e-3)), 'Default deltaT (Lv1,CustomEIrectangular) is incorrect');
        end
        
        function displayTest(testCase)
            path = getpref('OpenComp3d','path');
            currentDir = pwd;
            cd([path,'/OpenComp3d/+Comp3d/+UnitTests'])
            fid = fopen('testUnitsOutputText.txt', 'a');
            testCase.myElement.displayInformation(fid);
            fclose(fid);
        end
        
        function drawTest(testCase)
            figure
            testCase.myElement.drawComponent([0 0 0]);
            if Utils.log4m.getLogger().plotTests == false
                close
            end
        end
        
    
        %% rectangular Lv2
        %
        function rectangularComputeModelParametersTestLv2(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.RelativeTolerance;
            
            testCase.myElement.level = 2;
            testCase.myElement.computeModelParameters;
            
            weight = testCase.myElement.outputData.geometric.weight;
            rDCValue = testCase.myElement.modelParameters.electric.rS;
            
            testCase.verifyThat(weight,IsEqualTo(2.180864,'Within',RelativeTolerance(1e-3)),'Default mass (Lvl2,CustomEIrectangular) is incorrect');
            testCase.verifyThat(rDCValue,IsEqualTo(3.39352e-04,'Within',RelativeTolerance(1e-3)),'Default rDC Value (Lvl2,CustomEIrectangular) is incorrect');
        
        end
        
        function rectangularElectricModelTestLv2(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            
            testCase.myElement.buildElectricModel;
        
            % For simulation
            r = testCase.ooteeSimulate( ...
                testCase.myElement.electricModel, ...
                'switchingBw', 10e6, ...
                'design', false ...
                );
            
            if Utils.log4m.getLogger().plotTests == true
                figure('Color', [1 1 1], 'Name', 'rectangularElectricModelTest')
                subplot(2,1,1);
                    xlabel('time (s)');
                    ylabel('Current (A)');
                    hold on
                    grid on
                    plot( r.simuTime, r.vLv, 'DisplayName', 'vLv');
                    plot( r.simuTime, r.vLoad, 'DisplayName', 'vLoad');
                    legend('show')    
                subplot(2,1,2);
                    xlabel('time (s)');
                    ylabel('Voltage (V)');
                    hold on
                    grid on
                    plot( r.simuTime, r.iHv, 'DisplayName', 'iHv');
                    plot( r.simuTime, r.iLv, 'DisplayName', 'iLv');
                    legend('show')
            end
            
            % load non-regression test data
            [ffolder,fname] = fileparts(which('Comp3d.UnitTests.InductorCustomEITest'));
            filename = [ffolder '\DataTest\' fname 'simulateRectangularInductorCustomEIlv2TestNRT.mat'];
            try
                load(filename)
            catch
                rNRT = r;
                save( filename, 'rNRT');
                warning('/!\ rectangularInductorCustomEI Lv2 non-regression test data not availeble /!\');
            end
            
            testCase.verifyThat( r.simuTime, IsEqualTo( rNRT.simuTime, 'Within', RelativeTolerance(1e-3)), 'simutime in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.vLv, IsEqualTo( rNRT.vLv, 'Within', RelativeTolerance(1e-3)), 'vLv in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.vLoad, IsEqualTo( rNRT.vLoad, 'Within', RelativeTolerance(1e-3)), 'vLoad in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.iHv, IsEqualTo( rNRT.iHv, 'Within', RelativeTolerance(1e-3)), 'iHv in Non-regression test of rectangularInductorCustomEI does not match');
            testCase.verifyThat( r.iLv, IsEqualTo( rNRT.iLv, 'Within', RelativeTolerance(1e-3)), 'iLv in Non-regression test of rectangularInductorCustomEI does not match');
            
        end
        
        function rectangularGetSimulationDataSetExcitationsTestLv2(testCase)
            data = testCase.myElement.getSimulationData;
            testCase.myElement.setExcitations(data);
        end
        
        function rectangularComputeOutputDataTestLv2(testCase)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            
            % Data calculation
            testCase.myElement.computeOutputData;
            
            jouleLossesValue = testCase.myElement.outputData.electric.jouleLosses;
            coreLossesValue = testCase.myElement.outputData.magnetic.coreLosses;
            BMaxValue = testCase.myElement.outputData.magnetic.BMax;
            temperature = testCase.myElement.outputData.thermal.temperature;
            
            testCase.verifyThat( jouleLossesValue, IsEqualTo( 61.928168044287894, 'Within', RelativeTolerance(1e-3)), 'Default copper losses (Lvl2,CustomEIrectangular) is incorrect');
            testCase.verifyThat( coreLossesValue, IsEqualTo(  0.626812420143395, 'Within', RelativeTolerance(1e-3)), 'Default core losses (Lvl2,CustomEIrectangular) is incorrect');
            testCase.verifyThat( BMaxValue, IsEqualTo(  0.189328698007665, 'Within', RelativeTolerance(1e-3)), 'Default BMax (Lvl2,CustomEIrectangular) is incorrect');
            testCase.verifyThat( temperature, IsEqualTo( 3.094386829128941e+02, 'Within', RelativeTolerance(1e-3)), 'Default deltaT (Lvl2,CustomEIrectangular) is incorrect');
        end
        
    end
   
end
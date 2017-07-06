%% This script evaluate the rAcFactor of an InductorCustomEI
% 

%%
myInductorEI = Comp3d.InductorCustomEI( 'name', 'myInductorEI');
myInductorEI.level = 1;
myInductorEI.shape.conductorShape = 'rectangular';

myInductorEI.setFreedomDegreeField('name','airGap','status','free');
myInductorEI.setFreedomDegreeField('name','nTurns','status','free');
myInductorEI.setFreedomDegreeField('name','conductorWidth','status','free');
myInductorEI.setFreedomDegreeField('name','conductorHeight','status','free');

myInductorEI.setFreedomDegreeField('name','legWidth',           'status','homothetic','with','conductorHeight/3');
myInductorEI.setFreedomDegreeField('name','windingCoreDistance','status','homothetic','with','conductorHeight/3/15');
myInductorEI.setFreedomDegreeField('name','interTurnSpace',     'status','homothetic','with','conductorHeight/3/30');

% 
%%
mySweepTool = SweepTool.SweepTool;
mySweepTool.addComp3d( myInductorEI);

%%
mySweepTool.addVariable( 'excitations.femm.frequency', SweepTool.logspace(5e2,50e6,6), 'Hz');
mySweepTool.addVariable( 'materials.magneticCore.mu_e', SweepTool.logspace(20,2000,3), 'ur');
mySweepTool.addVariable( 'materials.electricConductor.resisElec', [ 1.69e-8, 2.67e-8], 'Ohm.m');  % cuivre / aluminium
mySweepTool.addVariable( 'dimensions.airGap', SweepTool.logspace(3e-5,3e-3,5), 'meter');
mySweepTool.addVariable( 'dimensions.conductorWidth', SweepTool.logspace(0.25e-3,2e-3,4), 'meter');
mySweepTool.addVariable( 'dimensions.conductorHeight', SweepTool.logspace(15e-3,60e-3,3), 'meter');
mySweepTool.addVariable( 'dimensions.nTurns', [ 5, 10, 20], 'turns');


%% Add Outputs to save
mySweepTool.addOutput( 'femmCompute');
mySweepTool.addOutput( 'outputData.femm.rAcFacteur');
mySweepTool.addOutput( 'outputData.femm.LacLinear', 'H/m');

%%
mySweepTool.displayVariableList
%%
mySweepTool.displayOutputList
%%
t1 = datetime('now');
mySweepTool.evaluate;
t2 = datetime('now');
diff([t1 t2])
%%
save PreProcessing/Comp3d/InductorCustomEI/mySweepTool  'mySweepTool'
%%
RacFactorInductorCustomEIrectangularDataBase = mySweepTool.getGriddedData;
RacFactorInductorCustomEIrectangularDataBase.outputList([1 3]) = [];
save PreProcessing/Comp3d/InductorCustomEI/RacFactorInductorCustomEIrectangularDataBase 'RacFactorInductorCustomEIrectangularDataBase'


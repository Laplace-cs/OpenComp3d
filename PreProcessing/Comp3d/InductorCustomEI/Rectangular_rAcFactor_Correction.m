%% This script evaluate the rAcFactor of an InductorCustomEI
% 

%%
load PreProcessing/Comp3d/InductorCustomEI/mySweepTool  'mySweepTool'
myInductorEI = mySweepTool.comp3d;

%%
mySweepTool.displayVariableList
%%
freq = SweepTool.logspace(5e4,50e6,5);
mySweepTool.removeVariable( 'excitations.femm.frequency', freq(2:end-1));
mySweepTool.displayVariableList
mySweepTool.addVariable( 'excitations.femm.frequency', SweepTool.logspace(5e3,50e6,5), 'Hz');
mySweepTool.displayVariableList
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


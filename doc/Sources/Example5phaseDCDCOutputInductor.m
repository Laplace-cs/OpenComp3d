%% Example output inductor 5-phase DC-DC converter
% <html>
% <h2> Problem Description </h2>
% <p>The following example describes the optimization of the output inductor
% of a DC-DC with 5 cells in parallel as shown in the following figure</p>
%   <img src="../Sources/Images/5PhaseDCDC.png" alt="Object Icon"
%   style="width:95%;display:block;margin:auto";" </img>
% <br></br>
% <h2> Problem Setup </h2>
% <p>First, the 5 output inductors are created. These inductors must be
% exactly equal. As a result, we will make use of the copy function.
% First the element that will serve as reference object is created.</p>
% </html>
myInd1 = Comp3d.InductorCustomEI('record',1,...
                                 'name','inductor1');
%% 
% <html>
% <p>The rest of the <b>equal</b> inductors are derived from the
% reference inductor using the following syntax: <i>new variable</i> =
% <i>reference variable</i>.copyWithReference('name',<i>new name</i>).</p>
% </html>
myInd2 = myInd1.copyWithReference('name','inductor2');
myInd3 = myInd1.copyWithReference('name','inductor3');
myInd4 = myInd1.copyWithReference('name','inductor4');
myInd5 = myInd1.copyWithReference('name','inductor5');

%%
% <html>
% <p>The optimization problem is created and all the elements are added to
% it.</p>
% </html>
myOptProblem = OptimProblem.Optimizer();
myOptProblem.addComp3d(myInd1);
myOptProblem.addComp3d(myInd2);
myOptProblem.addComp3d(myInd3);
myOptProblem.addComp3d(myInd4);
myOptProblem.addComp3d(myInd5);

%%
% <html>
% <p>The circuit is described. In these case, interleaving  is used to for 
% the parallel cells.</p>
% </html>
circuit = Ckt.CktComposite();
n = circuit.createNode(9);
circuit.addGnd(n(2));
circuit.addCkt(Vdc(200),{n{1},n{2}});
dcdcConvert = Chopper('topology',[1 1 5]);
dcdcConvert.modul.fCar = 5*20e3;
dcdcConvert.opPoint.alphaBuck = 0.7;
circuit.addCkt(dcdcConvert,{n{1},n{3},n{4},n{5},n{6},n{7},n{2}});
circuit.addCkt(myInd1.electricModel,{n{3},n{8}});
circuit.addCkt(myInd2.electricModel,{n{4},n{8}});
circuit.addCkt(myInd3.electricModel,{n{5},n{8}});
circuit.addCkt(myInd4.electricModel,{n{6},n{8}});
circuit.addCkt(myInd5.electricModel,{n{7},n{8}});
circuit.addCkt(Inductor(100e-6,'out',1),{n{8},n{9}});
circuit.addCkt(Resistor(1,'load',0),{n{9},n{2}});
myOptProblem.circuit = circuit;

%%
% <html>
% <p> In this case the objective function will be to minimize the volume, and the 
% Multi-Start algorithm will be used using 10 start points.</p>
% </html>
myOptProblem.criteria = {'volume'};
myOptProblem.optimAlgoType = 'GradientDescentMS';
myOptProblem.optimAlgo.options.UseParallel = false;
myOptProblem.optimAlgo.options.NbStartingPoints = 10;
myOptProblem.optimAlgo.options.Display = 'final';
myOptProblem.solveOptimizationProblem;
%%
% <html>
% <p> We display the optimal solution, as shown all the elements are equal.</p>
% <table>
% <tr><td>
% </html>
myInd1.displayInformation;

%%
% <html>
% </td><td>
% </html>
myInd2.displayInformation;

%%
% <html>
% </td></tr></table>
% </html>

%%
% <html>
% <p> Waveform drawing.</p>
% </html>
figure();
plot(myInd1.excitations.electric.time,myInd1.excitations.electric.current,...
    myInd2.excitations.electric.time,myInd2.excitations.electric.current,...
    myInd3.excitations.electric.time,myInd3.excitations.electric.current,...
    myInd4.excitations.electric.time,myInd4.excitations.electric.current,...
    myInd5.excitations.electric.time,myInd5.excitations.electric.current);
xlabel('Time [s]');
ylabel('Current [A]');
legend({'Inductor 1','Inductor 2','Inductor 3','Inductor 4','Inductor 5'});

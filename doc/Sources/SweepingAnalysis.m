%% Sweeping Analysis
% <html>
% <p>In some cases, the designer wants to know what is the impact of changing
% a certain parameter in the design or what is the impact in the final
% solution if a certain design constraint is modified</p>
% <h2> Inputs sweeping</h2>
% <p>Once the model is defined, the user might want to know what is the
% impact in some parameters when one the inputs is modified</p>
% <p>The tool to perform this kind of sweep analysis is called
% <i>SweepTool.SweepTool</i>.
% </html>
mySweepTool = SweepTool.SweepTool;

%%
% <html>
% <p>Then we add the element that we want to look the sensitivity. In this
% case we will look the variation of an Inductor.</p>
% </html>
myInductor = Comp3d.InductorCustomEI('name','inductorSweep');
mySweepTool.addElement(myInductor);

%%
% <html>
% <p>We select the variables that we are going to change to look the sensibility.
% In this case, the variables we are going to change are:</p>
% <ul>
%   <li>Magnetic materials (3C85,3C90)</li>
%   <li>Winding materials (Copper, Aluminium)</li>
%   <li>Leg width</li>
% </ul>
% <p>The command to add the sweeping variable is 
% <i>SweepTool variable</i>.(<i>Name of the component.Name of the variable</i>,<i>vector(numeric)
% or cell(char) values to vary</i>,<i>units</i>)</p>
% </html>
mySweepTool.addVariable( 'inductorSweep.materials.magneticCore', {'3C85 Philips(20-100kHz)','3C90 TM(25-200kHz)'}, 'core');
mySweepTool.addVariable( 'inductorSweep.materials.electricConductor', {'Copper','Aluminium'}, 'conductor');
mySweepTool.addVariable( 'inductorSweep.dimensions.legWidth', 0.010:0.02:0.020, 'meter');

%% 
% <html>
% <p>Once the sweep variables have been determined we need to determine which are
% the variables we want to display the impact. The command to add the the
% outputs is <i>Sweep Tool variable</i>.addOuput(<i>name of the
% output</i>,<i>units</i>)</p>
% <p>In this case the chosen outputs to plot are the mass and the inductance value</p>
% </html>
mySweepTool.addOutput( 'inductorSweep.outputData.geometric.weight', 'Kg');
mySweepTool.addOutput( 'inductorSweep.modelParameters.electric.Lmodel.val', 'H');

%%
% <html>
% <p>Once all the input/output variables have been determined we proceed to
% the evaluation. The instruction is <i>SweepTool
% variable</i>.evaluate.</p>
% </html>
mySweepTool.evaluate;

%%
% <html>
% <p>Then, we can perform various plots to show the sensibility. In these
% plots, we can show the sensibility up to three different variables. The command
% to perform this operation is <i>Sweep Tool variable</i>.plotOutput(<i>name of the component.name of
% the output</i>,<i>name of input </i>,...)</p>
% <p>For example, let us plot the inductance value as function of the
% electricConductor when we chose a 3C85 magnetic core and
% legWidth of 0.02</p>
% </html>
mySweepTool.plotOutput('inductorSweep.modelParameters.electric.Lmodel.val','myInductor.materials.magneticCore',{'3C85 Philips(20-100kHz)'},...
                                                   'myInductor.dimensions.legWidth',0.02);
                                               
%%
% <html>
% <p>We can plot as well the mass as a function of all the inputs (up to
% 3)</p>
% </html>
mySweepTool.plotOutput('inductorSweep.outputData.geometric.weight');

%%
% <html>
% <h2>Sweeping analysis using a circuit solver</h2>
% <p>In some case we might want to plot using a circuit solver, where a
% circuit element parameter changes.</p>
% <p>For example, let us consider we want to look what is the impact in the
% losses when the switching frequency of a buck converter is changed.</p>
% </html>
mySweepTool = SweepTool.SweepTool;                                                   
myInductor = Comp3d.InductorCustomEI('name','inductorSweepCircuit');

%%
% <html>
% <p>We describe the circuit.</p>
% </html>
circuit = Ckt.CktComposite();
n = circuit.createNode(4);
circuit.addGnd(n(2));
circuit.addCkt(Vdc(200),{n{1},n{2}});
dcdcConvert = Chopper();
dcdcConvert.modul.fCar = 10e3;
dcdcConvert.opPoint.alphaBuck = 0.5;
circuit.addCkt(dcdcConvert,{n{1},n{3},n{2}});
circuit.addCkt(myInductor.electricModel,{n{3},n{4}});
circuit.addCkt(Resistor(1),{n{4},n{2}});


%%
% <html>
% <p>The excitation object is set according to our particular problem</p>
% </html>
myInductor.excitationsElectricAnalytic = AnalyticalExcitation.InductorExcitation;
myInductor.excitationsElectricAnalytic.vHv = 200;
myInductor.excitationsElectricAnalytic.vLv = 100;
myInductor.excitationsElectricAnalytic.iDc = 100;
myInductor.excitationsElectricAnalytic.fSw = 20e3;
myInductor.excitationsElectricAnalytic.nSample = 1000;

%%
% <html>
% <p>We add the inductor to the sweep tool.</p>
% </html>
mySweepTool.addElement(myInductor);


%%
% <html>
% <p>And we determine the inputs, the outputs and the elements.</p>
% </html>
mySweepTool.addVariable( 'inductorSweepCircuit.materials.electricConductor', {'Copper','Aluminium'}, 'conductor');
mySweepTool.addVariable( 'inductorSweepCircuit.materials.magneticCore', {'3C85 Philips(20-100kHz)','3C90 TM(25-200kHz)'}, 'core');
mySweepTool.addVariable( 'inductorSweepCircuit.excitationsElectricAnalytic.fSw', 10e3:10e3:100e3, 'Hz');
mySweepTool.addOutput( 'inductorSweepCircuit.outputData.thermal.losses','W');



%%
% <html>
% <p>Once all the input/output variables have been determined we proceed to
% the evaluation.</p>
% </html>
mySweepTool.evaluate;

%%
% <html>
% <p>And we plot the losses for the 3C85 material.</p>
% </html>
mySweepTool.plotOutput('inductorSweepCircuit.outputData.thermal.losses','inductorSweepCircuit.materials.magneticCore',{'3C85 Philips(20-100kHz)'});

%%
% <html>
% <p>Or just for a frequency of 20 kHz.</p>
% </html>
mySweepTool.plotOutput('inductorSweepCircuit.outputData.thermal.losses','inductorSweepCircuit.materials.magneticCore',{'3C85 Philips(20-100kHz)'},...
                       'inductorSweepCircuit.excitationsElectricAnalytic.fSw',20e3);

%%
% <html>
% <h2> Optimization parameter sweeping</h2>
% <p>In the previous case we looked what was the impact of the switching frequency for a certain
% inductor. However, the user might want to know what is the impact in the final mass when performing
% an optimization and a variation of the switching frequency.</p>
% <p>The class that regroups the optimization methods and the sweeping tool
% functionalities is <i>SweepTool.SweepTool</i></p>
% <p>For example, let us see the impact on the optimal component mass as
% function of the switching frequency. First we create the class and add it as an optimization.</p>
% </html>
mySensitivityOptimizer = OptimProblem.SensitivityOptimizer();
myInductor = Comp3d.InductorCustomEI('name','inductorSensitivity');
mySensitivityOptimizer.addComp3d(myInductor);

%%
% <html>
% <p>We create the analytical circuit and add it to the optimization</p>
% </html>
myInductor.excitationsElectricAnalytic = AnalyticalExcitation.InductorExcitation;
myInductor.excitationsElectricAnalytic.vHv = 200;
myInductor.excitationsElectricAnalytic.vLv = 100;
myInductor.excitationsElectricAnalytic.iDc = 100;
myInductor.excitationsElectricAnalytic.fSw = 20e3;
myInductor.excitationsElectricAnalytic.nSample = 1000;

%%
% <html>
% <p>In this case, the parameters that vary are:</p>
% <ul>
%   <li>Core Material : N88 (Ferrite), 500F PC (Nanocrystallin)</li>
%   <li>Switching frequency: [10kHz,50kHz]</li>
%   <li>Maximal temperature : [80,100]</i>
% </ul>
% <p>And the output is the mass of the inductor.</p>
% </html>
mySensitivityOptimizer.addElement(myInductor);

mySensitivityOptimizer.addVariable( 'inductorSensitivity.materials.magneticCore', {'N88','500F PC'}, 'core');
mySensitivityOptimizer.addVariable( 'inductorSensitivity.excitationsElectricAnalytic.fSw', 10e3:10e3:50e3, 'Hz');
mySensitivityOptimizer.addVariable( 'inductorSensitivity.constraints.temperatureMax', 80:5:100, '°C');
mySensitivityOptimizer.addOutput( 'inductorSensitivity.outputData.geometric.weight','kg');

%%
% <html>
% <p>We can set the optimization criteria and the algorithm as in any optimization problem</p>
% </html>
mySensitivityOptimizer.criteria = {'mass'};
mySensitivityOptimizer.optimAlgoType = 'GradientDescent';
%%
% <html>
% <p>The sensitivity analysis is launched, in this case the sensitivity parameters that give the optimal mass are given</p>
% </html>
mySensitivityOptimizer.optimAlgo.options.Display = 'off';
[x, fval] = mySensitivityOptimizer.evaluate;
%%
% <html>
% <p>The final results can be plotted as well</p>
% </html>
mySensitivityOptimizer.plotOutput('inductorSensitivity.outputData.geometric.weight');

%%
% <html>
% <p>The axes are not very lisible and can be modified manually.</p>
% </html>
xlabel('Switching frequency [Hz]');
ylabel('Maximal temperature [°C]');
zlabel('Mass [kg]');

%%
% <html>
% <p>We show as well the optimal combination of parameters and the optimal value of the objective function
% at this point</p>
% </html>
x
fval
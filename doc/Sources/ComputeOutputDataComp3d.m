%% Output Data Calculation
% <html>
% <h2> Introduction</h2>
% <p>In the design of power electronic components it is necessary to estimate
% certain physical data inherent to the component (temperature, magnetic
% field,...) to test if the component is feasible.</p>
% <p>In our framework, two necessary steps are required:</p>
% <lu>
% <li><p>Definition/Creation of the component <a href="CreateComp3dElement.html"> More
%                                          Information</a></p></li>
% <li><p>Definition of the excitations <a href="SetExcitations.html"> More
%                                          Information</a></p></li>
% </lu>
% <h2>Compute Output Data Example</h2>
% </html>
myInd = Comp3d.InductorCustomEI('record',true);
myInd.computeModelParameters;
circuit = Ckt.CktComposite();
n = circuit.createNode(4);
circuit.addGnd(n(2));
circuit.addCkt(Vdc(100),{n{1},n{2}});
circuit.addCkt(Chopper(),{n{1},n{3},n{2}});
circuit.addCkt(myInd.electricModel,{n{3},n{4}});
circuit.addCkt(Capacitor(1e-3),{n{4},n{2}});
circuit.addCkt(Resistor(1),{n{4},n{2}});
solver = ConvertSystSolver;
results = solver.simulate(circuit);
data = myInd.getSimulationData;
myInd.setExcitations(data);

%% 
% <html>
% If the method <i>class</i>.displayOuputs is used no information is given
% about the temperatures, current ... Ex:
% </html>
myInd.displayInformation;

%% 
% <html>
% To calculate these outputs the  <i>class</i>.computeOutputData needs to be
% launched. Ex:
% </html>
myInd.computeOutputData;
myInd.displayInformation;
%% Optimization Problem
% <html>
% <p>The framework posseses a series of implemented functionalities to help in
% the design of power converters</p>
% <h2> Description of the optimization procedure </h2>
% The general algorithm description and the different steps are described
% in the following figure:
% <br></br>
%   <img src="../Sources/Images/OptimisationProcess.png" alt="Optimization Icon"
%   style="width:100%"; display="block"; margin="auto"> </img>
% <br></br>
% It is composed of the following steps:
% <br></br>
% <ol type="1">
%   <li> Problem Definition: In this step the optimization problem is
%   described that is the topology, the operation point of the
%   system, the different elements of the system to be optimized, the
%   objective function, the constraints of the problem and the optimization
%   algorithm to be used </li>
%   <li> Optimization: at this step the whole optimization procedure is
%   launched:
%       <ol type="1">
%       <li> Input definition: at the beginning of each iteration the optimization
%            algorithm defines the inputs (dimensions) of the element to be
%            optimized</li>
%       <li> Parameter computation: the different parameters of the
%       elements (mass, volume...) as well as the equivalent simulation
%       models (electrical, thermal...) are calculated</li>
%       <li> Simulation resolution: the solver (analytic, time or
%       frequency) gets the equivalent circuits of each component and
%       assembles them according to topology defined at the beginning of
%       the problem (Step 1). Then it performs a simulation and dispatches
%       the different waveforms to the components</li>
%       <li> Output Data calculation : once the component knows the
%       excitations it is withstanding it can calculate a series of
%       additional data (temperature, losses, magnetic field...) which is
%       necessary for the design of the components</li>
%       <li> Objective function and constraints calculation: the
%       optimization gets the contribution of each component to the
%       objective function to minimize (mass, volume, cost...) and
%       assembles all the constraints related to the problem</li>
%       <li> Next iteration determination: the optimization algorithm
%       (gradient-descent...) determines wether the current iteration point
%       is a minimum point or not. In case it is not, it determines the
%       next iteration point</li>
%       </ol>
%   </li>
%   <li> Solution validation: the optimal solution using different numerical simulations
%        to validate the solution based in analytic equations. If the error does not fall 
%        below a certain threshold, reconsideration of the model in this exploration area
%        needs to be performed</li>
%   <ul>
%  </ol>
%  <h2> Specific instructions for the optimization problem</h2>
%   The main <i>class</i> that contains all the methods and that need to be
%   defined at the begining of each optimization problem is the Optimizer
%   class. To create it we type <i>var1</i> =
%   OptimProblem.Optimizer(<i>arguments</i>). Ex:
%   </html>
myOptProblem = OptimProblem.Optimizer();

%%
% <html>
% As it was shown in the figure above, at the beginning of the
% optimization problem we need to define as well which components are
% going to be optimized. The instruction to add a component is
% <i>optimizer variable</i>.addComponent(<i>component variable</i>). An
% extra parameter can be added if the several equal elements are going to
% be introduced. Ex. suppose we want to optimize an inductor.
% </html>

myOptProblem = OptimProblem.Optimizer;
myInductor = Comp3d.InductorCustomEI;
myOptProblem.addComp3d(myInductor);
%%
% <html>
% Supposse we want to design a converter with two equal elements. For
% example, we have a converter with two cells in parallel and therefore two
% equal output inductors
% </html>
myOptProblem = OptimProblem.Optimizer;
myInductor = Comp3d.InductorCustomEI;
myOptProblem.addComp3d(myInductor,2);

%%
% <html>
%  <h2> Objective function </h2>
%  All the optimization algorithms try to <b>minimize</b> the objective
%  function. The different objective criteria that can be minimized are:
% <br></br>
%  <ul>
%       <li> mass </li>
%       <li> losses </li>
%       <li> volume </li>
%       <li> cost </li>
%  </ul>
%  The property to define the objective function is 'criteria' with the
%  instruction <i>optimization_problem</i>.criteria = {<i>list of
%  criterias</i>}. In addition, the objectives functions can be combined
%  to create a new objective function (property <i>weights</i>). 
%  Ex. Imagine we want to determine a new objective function taking into
%  account a 90% of the mass and a 10% of the losses
% </html>
myOptProblem = OptimProblem.Optimizer;
myOptProblem.criteria = {'mass','losses'};
myOptProblem.weights = [0.9 0.1];

%%
% <html>
% <h2> Scaling inputs </h2>
% For the mathematical optimization algorithm the variables can be set into
% a different scale to improve convergence. These options are:
% <br></br>
% <ul>
%   <li> Logarithmic scale with offset(Recommended): the bounds and the inital points are
%   transformed into a logarithmic scale and then from 0 onwards(option = <i>{'log' 'offset'}</i>)</li>
%   <li> Logarithmic scale normalized: the bounds and the inital points are
%   transformed into a logarithmic scale and the set between 0 and 1 (option = <i>{'log' 'norm'}</i>)</li>
%   <li> Logarithmic scale: the bounds and the inital points are
%   transformed into a logarithmic scale (option = <i>'log'</i>)</li>
%   <li> Normal scale: the bounds and the inital points are
%   transformed into a linear scale between 0 and 1 (option = <i>'norm'</i>)</li>
%   <li> Offset: an offset is added to the initial point and bounds (option = <i>'offset'</i>)</li>
% </ul>
% Example:
% </html>
myOptProblem = OptimProblem.Optimizer;
myOptProblem.scale = {'log' 'offset'};

%%
% <html>
% <h2> Optimization algorithms </h2>
% Several optimization algorithms can be employed in the optimization
% framework. These are:
% <br></br>
% <ul>
%   <li>MATLAB fmincon algorihtm: more information is found <a
%   href="matlab:doc fmincon"> here</a>. (option = <i>'GradientDescent'</i>)</li>
%   <li>MATLAB MultiStart algorithm: more information is found <a
%   href="matlab:doc MultiStart"> here</a>. (option = <i>'GradientDescentMS'</i>)</li>
%   <li>MATLAB GlobalSearch algorithm: more information is found <a
%   href="matlab:doc GlobalSearch"> here</a>. (option = <i>'GradientDescentGS'</i>)</li>
%   <li>MATLAB Genetic Algorithm: more information is found <a
%   href="matlab:doc GA"> here</a>. (option = <i>'Ga'</i>)</li>
% </ul>
% Example:
% </html>
myOptProblem = OptimProblem.Optimizer;
myOptProblem.optimAlgo = 'GradientDescent';

%% 
% <html>
% <h2>Optimization constraints</h2>
% <p>The design of the components to certain physical constraints (maximal
% temperature, magnetic saturation...) or system constraints (standards,
% maximal pressure loss,...)</p>
% <p>The physical constraints are defined in the constraints property of
% the object. Ex. imagine we want to set the maximal temperature of the
% inductor at 90°C</p>
% </html>
myInductor = Comp3d.InductorCustomEI;
myInductor.constraints
myInductor.constraints.temperatureMax = 90;

%%
% <html>
% <h2> Optimization example </h2>
% In the presented example, we will optimize the output inductor of a DC-DC
% converter as shown in the following figure. We will follow the optimization 
% procedure step by step
% <br></br>
%   <img src="../Sources/Images/BuckConverter.png" alt="Optimization Icon"
%   style="width:70%"; display="block"; margin="auto"> </img>
% <br></br>
% <ol>
% <li> We create the optimization problem class</li>
% </html>
myOptProblem = OptimProblem.Optimizer;
%%
% <html>
% <li> We create the inductor, in this case we will use the InductorCustomEI class.
%      For more information about class creation click <a href="CreateComp3dElement.html">here</a>
%      We declare the inductor as the element to be optimized with <i>addComp3d</i> method</li>
% </html>
myInductor = Comp3d.InductorCustomEI();
myOptProblem.addComp3d(myInductor);
%%
% <html>
% <li> We declare the circuit (For more information about circuit creation
%      see OOTEE documentation) and add it to the <i>circuit</i> property
%      of the <i>optimizer</i> class</li>
% </html>
circuit = Ckt.CktComposite();
n = circuit.createNode(4);
circuit.addGnd(n(2));
circuit.addCkt(Vdc(100),{n{1},n{2}});
dcdcConvert = Chopper();
dcdcConvert.modul.fCar = 20e3;
dcdcConvert.opPoint.alphaBuck = 0.5;
circuit.addCkt(dcdcConvert,{n{1},n{3},n{2}});
circuit.addCkt(myInductor.electricModel,{n{3},n{4}});
circuit.addCkt(Resistor(10,'load',1),{n{4},n{2}});
myOptProblem.circuit = circuit;

%%
% <html>
% <p>In this example, we want to see as well the output voltage and the output 
% cell voltage.</p>
% </html>
n{3}.name = 'mid';
n{3}.record = 1;
n{4}.name = 'out';
n{4}.record = 1;

%%
% <html>
% We determine as wel the air temperature and we set the maximal current 
% ripple at 1 A
% </html>
myInductor.excitations.thermal.tAir = 30;
myInductor.constraints.iRippleMax = 1;

%%
% <html>
% <li>Once the problem has been determined we choose the scaling type and the
% optimization algorithm and the mass as objective function</li>
% </html>
myOptProblem.optimAlgo = 'GradientDescent';
myOptProblem.scale = {'log' 'offset'};
myOptProblem.criteria = {'mass'};
%%
% <html>
% <li>The optimization is then launched</li>
% </html>
myOptProblem.solveOptimizationProblem;
%%
% <html>
% <li>The optimal result is validated with FEMM simulations for this case
% </html>
myInductor.validateFEMM;
%%
% <html>
% The error for copper losses is below 0.1% and as a consequence, the
% optimal solution is accepted </li>
% </html>
%%
% <html>
% <li>The optimal solution is displayed</li>
% </html>
myInductor.displayInformation;


myInductor.drawExcitations;

myInductor.drawComponent;
%%
% <html>
% <p>As shown, the constraints (Maximal temperature and current ripple are
% respected)</p>
% <p>Another important utility is the display GUI of the simulation
% waveforms in the time and frequency domains
% (<i>Optim Problem class</i>.simulationSolver.displayCurves)</p>
% </html>
myOptProblem.simulationSolver.showResults;
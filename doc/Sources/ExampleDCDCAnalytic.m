%% Example DC-DC Analytic
% <html>
% <h2>Problem description </h2>
% <p>The following problem addresses the optimization of an output inductor in
% a DC-DC buck converter as shown in the figure below. This time however,
% the excitations of the inductors will be determined by an analytical
% waveform previously known or will be calculated using an analytical
% calculation.</p>
%   <img src="../Sources/Images/BuckConverter.png" alt="Optimization Icon"
%   style="width:70%"; display="block"; margin="auto"> </img>
% <h2> Optimization using an analytical waveform</h2>
% <p>In the previous system, let us suppose we want to design an inductor
% of 1.3mH. By analytical approximations of a classical DC-DC converter, we
% know that the low voltage DC current is and the current ripple is
% determined by the following equation:</p
% </html>

%%
%
% $$\Delta I = \frac{E \cdot \alpha \cdot (1 - \alpha)}{f_{sw} \cdot L}$$
%

%%
% <html>
% with the following parameters:
% <ul>
%   <li> E : High DC voltage </li>
%   <li> &alpha; : transformation ratio </li>
%   <li> f<sub>sw</sub> : the switching frequency </li>
%   <li> L : the inductor value </li>
% </ul>
% <p>The waveform is the following one</p>
% </html>
Idc = 5;
deltaI = 1;
fSw = 20e3;
timeSignal = linspace(0,1/fSw,1000);
valueSignal = Idc + deltaI * Signal.Triangle(2 * pi * fSw * timeSignal);
plot(timeSignal,valueSignal);

%%
% <html>
% <p> The voltage at the terminals can be approximated to a square
% waveform</p>
% </html>
voltageSignal = 50*square(2*pi*fSw*timeSignal,50);
plot(timeSignal,voltageSignal);

%%
% <html>
% <p>The inductor and the problem is then created, in this case we will use
% the InductorCustomEI class, as no external solver is used, the record property 
% is set to "false"</p>
% </html>
myOptProblem = OptimProblem.Optimizer;
myInductor = Comp3d.InductorCustomEI('record',false);
myOptProblem.addComp3d(myInductor);

%%
% <html>
% <p>The inductor constraint value is set to 1.3mH as it is the valued we 
% will have in the optimization process and the air temperature is set at 30</p>
% </html>
myInductor.constraints.Leq = 1.3e-3;
myInductor.excitations.thermal.tAir = 30;

%%
% <html>
% <p>Then the excitations of the inductor are added analytically/p>
% </html>
myInductor.setExcitations('time',timeSignal,'current',valueSignal,'voltage',voltageSignal);
myInductor.drawExcitations;

%%
% <html>
% <p>The optimization is launched, in this case, the objective function is the mass and the 
% MATLAB fmincon function is used</p>
% </html>
myOptProblem.criteria = {'mass'};
myOptProblem.optimAlgoType = 'GradientDescent';
myOptProblem.optimAlgo.options.Display = 'final';
myOptProblem.solveOptimizationProblem;
%%
% <html>
% <p>The optimal solutions are displayed and validated</p>
% </html>
myInductor.displayInformation;
myInductor.drawComponent;
myInductor.validateFEMM;

%%
% <html>
% <h2>Optimization using an analytical object</h2>
% <p>In some particular cases, we might know what is the waveform of the
% object depending on its value making some assumptions. For example, using
% the equations presented above we can know what is the output current as a
% function of the inductance value. The steps are the same, first the inductor
% and the optimization problem are created</p>
% </html>
myInductor = Comp3d.InductorCustomEI('record',false);
myOptProblem = OptimProblem.Optimizer();
myOptProblem.addComp3d(myInductor);

%%
% <html>
% <p>Then the inductor object is "coupled" with the "exctation" object that
% will give the excitations values as function of the inductance value. In this
% case the excitation object is called "InductorExcitation" and it is set in the 
% excitationsElectricAnalytic field</p>
% </html>
myInductor.excitationsElectricAnalytic = AnalyticalExcitation.InductorExcitation;

%%
% <html>
% <p>The excitation object is set according to our paricular problem</p>
% </html>
myInductor.excitationsElectricAnalytic.vHv = 100;
myInductor.excitationsElectricAnalytic.vLv = 50;
myInductor.excitationsElectricAnalytic.iDc = 5;
myInductor.excitationsElectricAnalytic.fSw = 20e3;
myInductor.excitationsElectricAnalytic.nSample = 1000;
myInductor.drawExcitations();

%%
% <html>
% <p>We set the optimization constraints</p>
% </html>
myInductor.constraints.Leq = 1.3e-3;
myInductor.excitations.thermal.tAir = 30;

%%
% <html>
% <p>The same fmincon algorithm options and objective are set.</p>
% </html>
myOptProblem.criteria = {'mass'};
myOptProblem.optimAlgoType = 'GradientDescent';
myOptProblem.optimAlgo.options.Display = 'final';
myOptProblem.solveOptimizationProblem;
%%
% <html>
% <p>The optimal solutions are displayed and validated</p>
% </html>
myInductor.displayInformation;
myInductor.drawComponent;
myInductor.validateFEMM;

%% Heatsink with Fan Optimization

%%
% <html>
% <h2>Problem description</h2>
% <p>In this example, we consider a surface of 0.05x0.1 m that needs to
% dissipate 75 W. In this case, we need to design the necessary
% heatsink</p>
% <h2>Problem implementation</h2>
% <p>First the surface is created, in this case the temperature of this
% surface must be kept below 100°C</p>
% </html>
mySurface = Comp3d.HeatingSurface('name','heatingSurface','power',75,'length',0.1,'width',0.05,'tMax',100);

%%
% <html>
% <p>The heatsink is then created by the assemby of the baseplate, fins and
% fan</p>
% </html>
myBasePlate = Comp3d.BasePlate('name','basePlate','level',2,'length',0.22,'width',0.12,'conductingMaterial',2);
myFins = Comp3d.RectangularFins('name','fins','level',2,'length',0.22,'numberOfFins',30,...
    'thickness',2e-3,'height',5e-2,'gapBetweenFins',2e-3,'conductingMaterial',2);
myBlowingElement = Comp3d.FanDiscreteDC('name','fan','temperature',25, 'widhOutTube',0.11, 'heightOutTube',0.11, 'lengthTube',0.02,...
                    'thicknessFanTube',2e-3,'materialTube','Aluminium');


%%
% <html>
% <p>Then the composite is created, the elements are added to the heat sink and the parameters are
% computed </p>
% </html>
myHeatSink = Comp3d.HeatSink('name','heatSink');
myHeatSink.addElement(myBasePlate);
myHeatSink.addElement(myFins);
myHeatSink.addElement(myBlowingElement);
myHeatSink.addElement(mySurface);

%%
% <html>
% <p>The heatsink is add to an optimization problem and the optimization
% process is launched. In this case, the sqp algorithm of Matlab will be
% used </p>
% </html>
myOptProblem = OptimProblem.Optimizer;
myOptProblem.addComp3d(myHeatSink);
myOptProblem.optimAlgoType = 'GradientDescent';
myOptProblem.optimAlgo.options.Algorithm = 'sqp';

%%
% <html>
% <p>The optimization is launched and the results are displayed and
% plotted</p>
% </html>
myOptProblem.solveOptimizationProblem;
% myHeatSink.computeOutputData;
myOptProblem.displayInformation;
myHeatSink.drawComponent;
myHeatSink.displayPressureLossesCurve;
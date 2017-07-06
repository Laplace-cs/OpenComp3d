close all
clear all

try
    pathOfOpenComp3d = getpref('OpenComp3d','path');
catch
    ConfigurationFileOpenComp3d;
    pathOfOpenComp3d = getpref('OpenComp3d','path');
end
pathToGo = [pathOfOpenComp3d,'/OpenComp3d'];

currentPath = pwd;
cd([pathToGo,'/doc/Sources']);

% % main directory
 publish('Main.m','outputDir',[pathToGo,'/doc']);
% 
% % Installation Instructions
% publish('InstallationInstructions.m','outputDir',[pathToGo,'/doc/html'])
% 
% % general overview OpenComp3d
% publish('GeneralOverView.m','outputDir',[pathToGo,'/doc/html']);
% 
% % General example OpenComp3d
% publish('CreateComp3dElement.m','outputDir',[pathToGo,'/doc/html']);
% 
% % set excitations
% publish('SetExcitations.m','outputDir',[pathToGo,'/doc/html']);
% 
% % Comp3d Library
publish('OpenComp3dLibrary.m','outputDir',[pathToGo,'/doc/html']);
% 
% % general overview OpenComp3d
% publish('ComputeOutputDataComp3d.m','outputDir',[pathToGo,'/doc/html']);
% 
% % optimization OpenComp3d
% publish('SetOptimizationProblem.m','outputDir',[pathToGo,'/doc/html']);
% 
% % sweeping analysis
%publish('SweepingAnalysis.m','outputDir',[pathToGo,'/doc/html']);
% 
% % optimization example list
%  publish('OptimizationExamplesList.m','outputDir',[pathToGo,'/doc/html']);

% optimization example output inductor 5-phase DC-DC
% publish('Example5phaseDCDCOutputInductor.m','outputDir',[pathToGo,'/doc/html']);

% optimization example analytic buck
% publish('ExampleDCDCAnalytic.m','outputDir',[pathToGo,'/doc/html']);

% optimization example heatsink
%publish('HeatsinkWithFanOptimization.m','outputDir',[pathToGo,'/doc/html']);

% % Specific model methods
% 
% % HeatSink
% publish('HeatSinkModel.m','outputDir',[pathToGo,'/doc/html'])
% 
% % BasePlate
% publish('BasePlateModel.m','outputDir',[pathToGo,'/doc/html'])
% 
% % Rectangular fins
% publish('RectangularFinsModel.m','outputDir',[pathToGo,'/doc/html'])
% 
% % Blowing Air
% publish('BlowingAir.m','outputDir',[pathToGo,'/doc/html'])
% 
% % DC Fan
% publish('DCFan.m','outputDir',[pathToGo,'/doc/html'])

% Inductor Model
publish('InductorModel.m','outputDir',[pathToGo,'/doc/html'])
 close all;

cd(currentPath);


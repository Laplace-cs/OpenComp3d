close all
clear all

try
    pathOfOpenComp3d = getpref('OpenComp3d','path');
catch
    ConfigurationFileOpenComp3d;
    pathOfOpenComp3d = getpref('OpenComp3d','path');
end
pathToGo = [pathOfOpenComp3d,'/OpenComp3d'];

publish('FreedomDegreesUnit.m','outputDir',[pathToGo,'/docDeveloper/html']);
publish('FreedomDegrees.m','outputDir',[pathToGo,'/docDeveloper/html']);
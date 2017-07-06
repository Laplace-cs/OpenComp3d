clear all; clc;
% This script sets the configuration for all the scripts needing a path

% We get the current path of this file
str = which('ConfigurationFileOpenComp3d.m');

% %On récupère l'OS de l'ordinateur
os = getenv('OS');
switch os
    case {'Window NT','Window','Windows_NT'}
        strPath = regexprep(str,'\\OpenComp3d\\ConfigurationFiles\\ConfigurationFileOpenComp3d\.m','');
        strPath = regexprep(strPath,'\\','/');
        cd(strPath)
    case ''
        strPath = regexprep(str,'/OpenComp3d/ConfigurationFiles/ConfigurationFileOpenComp3d.m','');
        cd(strPath)
end


% We test if the preference exist or not
boolTRUE = ispref('OpenComp3d','path');
if boolTRUE
   setpref('OpenComp3d','path',strPath); 
   display('OpenComp3d configuration path has been correctly updated!!!')
else
   addpref('OpenComp3d','path',strPath); 
   display('OpenComp3d configuration path has been correctly created!!!')
end


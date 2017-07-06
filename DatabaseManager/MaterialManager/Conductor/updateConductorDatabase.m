function updateConductorDatabase
% Read Parameters of the Loss Models for Conductor Materials 
% stored in the excell sheet ConductorDatabase.xls.
% Stores them in the structure MatCond which is saved in the file MatCond.mat

% For example, the density of Material Nr i is : MatCond(i).Density
pathFile = getpref('OpenComp3d','path');
pathFile = [pathFile,'/OpenComp3d/DataBaseManager/MaterialManager/Conductor'];
currentPath = pwd;
cd(pathFile);
[NUMERIC,PropName,RAW]=xlsread('./ConductorDataBase.xlsx','Cond','a2:i2');
[NUMERIC,TXT,RAW]=xlsread('./ConductorDataBase.xlsx','Cond','a3:i5');


MatCond=struct(char(PropName(1)),TXT(:,1),char(PropName(2)),num2cell(NUMERIC(:,1)),char(PropName(3)),TXT(:,3),...
    char(PropName(4)),num2cell(NUMERIC(:,3)),char(PropName(5)),num2cell(NUMERIC(:,4)),char(PropName(6)),num2cell(NUMERIC(:,5)),...
    char(PropName(7)),num2cell(NUMERIC(:,6)),char(PropName(8)),num2cell(NUMERIC(:,7)),char(PropName(9)),num2cell(NUMERIC(:,8)));

ListMatCond = TXT(:,1);

%save MatCond MatCond
save('MatCond','MatCond')
save('ListMatCond','ListMatCond');
cd(currentPath);

end
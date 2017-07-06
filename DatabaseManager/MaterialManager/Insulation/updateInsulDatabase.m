function updateInsulDatabase
pathFile = getpref('OpenComp3d','path');
pathFile = [pathFile,'/OpenComp3d/DataBaseManager/MaterialManager/Insulation'];
currentPath = pwd;
cd(pathFile);
[NUMERIC,PropName,RAW]=xlsread('./InsulationDataBase.xlsx','Cond','a2:j2');
[NUMERIC,TXT,RAW]=xlsread('./InsulationDataBase.xlsx','Cond','a3:j5');

MatInsul=struct(char(PropName(1)),TXT(:,1),char(PropName(2)),num2cell(NUMERIC(:,1)),char(PropName(3)),TXT(:,3),...
    char(PropName(4)),num2cell(NUMERIC(:,3)),char(PropName(5)),num2cell(NUMERIC(:,4)),char(PropName(6)),num2cell(NUMERIC(:,5)),...
    char(PropName(7)),num2cell(NUMERIC(:,6)),char(PropName(8)),num2cell(NUMERIC(:,7)),char(PropName(9)),num2cell(NUMERIC(:,8)),...
    char(PropName(10)),num2cell(NUMERIC(:,9)));

save('MatInsul','MatInsul');
cd(currentPath);

end
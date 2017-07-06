function updateDielectricDatabase
pathFile = getpref('OpenComp3d','path');
pathFile = [pathFile,'/OpenComp3d/DataBaseManager/MaterialManager/Dielectric'];
currentPath = pwd;
cd(pathFile);
[NUMERIC,PropName,RAW]=xlsread('./DielectricDataBase.xlsx','Cond','a2:l2');
[NUMERIC,TXT,RAW]=xlsread('./DielectricDataBase.xlsx','Cond','a3:l11');

MatDielec=struct(char(PropName(1)),TXT(:,1),char(PropName(2)),num2cell(NUMERIC(:,1)),char(PropName(3)),TXT(:,3),...
    char(PropName(4)),num2cell(NUMERIC(:,3)),char(PropName(5)),num2cell(NUMERIC(:,4)),char(PropName(6)),num2cell(NUMERIC(:,5)),...
    char(PropName(7)),num2cell(NUMERIC(:,6)),char(PropName(8)),num2cell(NUMERIC(:,7)),char(PropName(9)),num2cell(NUMERIC(:,8)),...
    char(PropName(10)),num2cell(NUMERIC(:,9)),char(PropName(11)),num2cell(NUMERIC(:,10)),char(PropName(12)),num2cell(NUMERIC(:,11)));

save('MatDielec','MatDielec');
cd(currentPath);

end

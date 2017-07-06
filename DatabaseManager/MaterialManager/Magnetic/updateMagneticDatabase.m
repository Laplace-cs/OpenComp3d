function updateMagneticDatabase
% Read Parameters of the Loss Models for Magnetic Materials 
% stored in the excell sheet Materials.xls.
% Stores them in the structure MatMag which is saved in the file MatMag.mat
% For example, the density of Material Nr i is : MatMag(i).Density
% Other Properties are given by the text in Materials.xls sheet/Mag/ b8:z8:
% Material	Model	Domain	k100	ct2	ct1	ct0	s	alpha_s	t	u	alpha_u	v	alpha_v	w	beta_w	x	beta_x	y	z	beta_z	Bsat	mu_e	Density	Price	Material

pathFile = getpref('OpenComp3d','path');
pathFile = [pathFile,'/OpenComp3d/DataBaseManager/MaterialManager/Magnetic'];
currentPath = pwd;
cd(pathFile);
[NUMERIC,PropName,RAW]=xlsread('./MagneticDataBase.xlsx','Mag','a5:ae5');
[NUMERIC,TXT,RAW]=xlsread('./MagneticDataBase.xlsx','Mag','a6:ae62');
% [NUMERIC,PropName,RAW]=xlsread('..\..\Components\Materials.xls','Mag','b8:z8');
% [NUMERIC,TXT,RAW]=xlsread('..\..\Components\Materials.xls','Mag','b9:z39');

%MatMag=struct(char(PropName(1)),TXT(:,1),char(PropName(2)),TXT(:,2),'ModelDomain',TXT(:,3),'k100',num2cell(NUMERIC(:,1)),'ct2',num2cell(NUMERIC(:,2)))
MatMag=struct(char(PropName(1)),TXT(:,1),char(PropName(2)),TXT(:,2),char(PropName(3)),TXT(:,3),...
    char(PropName(4)),num2cell(NUMERIC(:,1)),char(PropName(5)),num2cell(NUMERIC(:,2)),char(PropName(6)),num2cell(NUMERIC(:,3)),...
    char(PropName(7)),num2cell(NUMERIC(:,4)),char(PropName(8)),num2cell(NUMERIC(:,5)),char(PropName(9)),num2cell(NUMERIC(:,6)),...
     char(PropName(10)),num2cell(NUMERIC(:,7)),char(PropName(11)),num2cell(NUMERIC(:,8)),char(PropName(12)),num2cell(NUMERIC(:,9)),...
     char(PropName(13)),num2cell(NUMERIC(:,10)),char(PropName(14)),num2cell(NUMERIC(:,11)),char(PropName(15)),num2cell(NUMERIC(:,12)),...
     char(PropName(16)),num2cell(NUMERIC(:,13)),char(PropName(17)),num2cell(NUMERIC(:,14)),char(PropName(18)),num2cell(NUMERIC(:,15)),...
     char(PropName(19)),num2cell(NUMERIC(:,16)),char(PropName(20)),num2cell(NUMERIC(:,17)),char(PropName(21)),num2cell(NUMERIC(:,18)),...
     char(PropName(22)),num2cell(NUMERIC(:,19)),char(PropName(23)),num2cell(NUMERIC(:,20)),char(PropName(24)),num2cell(NUMERIC(:,21)),...
     char(PropName(25)),num2cell(NUMERIC(:,22)),char(PropName(27)),num2cell(NUMERIC(:,24)),char(PropName(29)),num2cell(NUMERIC(:,26)),...
     char(PropName(30)),num2cell(NUMERIC(:,27)),char(PropName(31)),num2cell(NUMERIC(:,28)));
 
ListMatMag = TXT(:,1);

%save MatMag MatMag

save('MatMag','MatMag');
save('ListMatMag','ListMatMag');
cd(currentPath);

end
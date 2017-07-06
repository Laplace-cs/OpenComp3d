function  updateFluidProperties
%UPDATEFLUIDPROPERTIES updates the fluid properties matrix to be loaded by
%the cooling class

[numeric,txt,raw] = xlsread('FluidProperties.xlsx','Air');

airData = struct('temperature',numeric(:,1),...
              'pressure',numeric(:,2),...
              'density',numeric(:,3),...
              'specificHeat',numeric(:,4),...
              'conductivity',numeric(:,5),...
              'dynamicViscosity',numeric(:,7),...
              'thermalExpansionCoefficient',numeric(:,8));
       
% We look for the path and save it    
pathRepo = getpref('OpenComp3d','path');
currentPath = pwd;       
cd([pathRepo,'/OpenComp3d/DatabaseManager/FluidManager']);
save('AirProperties','airData');
cd(currentPath);

end


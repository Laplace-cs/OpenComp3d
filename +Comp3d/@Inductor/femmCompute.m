function [ rAcFacteur, LacLinear] = femmCompute(obj,freq)
% Run 2D finite element analysis and improve estimates for Rac and Lac
%
% Draw the generic window of an inductor in FEMM,
% simulate it in 2D and extract values of :
% rAcFacteur
% LacLinear
%

%%
tic
fprintf('FEMM analysis started... ')

% try to load file or make a new one
obj.femmLoadDraw;

% updata properties
obj.femmUpdateMaterials;

% Parameters of the simulation : 
if nargin < 2
    freq = obj.excitations_.femm.frequency;
end
% mi_probdef(freq,units,type,precision,depth,minangle,(acsolver))
mi_probdef(freq,'meters','planar',1e-9,1,30,0);

 %% Solve and display
mi_analyze()
mi_loadsolution()

%%
result = mo_getcircuitproperties('U1');
roAcLinearFemm = real(result(2));  % Résistance linéique AC à freq calculée par FEMM (H/m)
LacLinearFemm = real(result(3));   % Inductance linéique AC à freq calculée par FEMM (H/m)

roAcLinear = roAcLinearFemm/obj.dimensions_.nTurns;
LacLinear = 2 * LacLinearFemm; % The core section is double

switch obj.shape_.conductorShape
    case 'round'
        crossSection = pi* obj.outputData_.geometric.diameterExtW^2;
    case 'rectangular'
        crossSection = obj.dimensions_.conductorWidth * obj.dimensions_.conductorHeight;
end
roDcLinear = obj.materials.electricConductor.resisElec/crossSection;

rAcFacteur = roAcLinear/roDcLinear;
obj.outputData_.femm.rAcFacteur = rAcFacteur;
obj.outputData_.femm.LacLinear = LacLinear;

%%
toc

end

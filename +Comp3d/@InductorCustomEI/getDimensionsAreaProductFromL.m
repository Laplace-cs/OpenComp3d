function getDimensionsAreaProductFromL(obj,L,sideType,fSw,vHVnom,iLVnom)
% getDimensionsAreaProductFromL(L,sideType,fSw,vHVnom,iLVnom) functions
% calculates the dimensions from the L value and using the methodology from
% [1] "Analysis and Design of Multicell DC/DC converters using vectorized
% models" T. Meynard
% This methodology is specificly adapted for an output inductor in a buck
% converter
%
% function inputs:
% L         - desired inductance value (H)
% sideType  - if the inductor is situated in the "LV" or "HV" side
% fSw       - switching frequency (Hz)
% vHVnom    - voltage in high voltage side (V)
% iLVnom    - current in the low voltage side (V)
%
% Hypothesis for the area product
% Filling factor (kW) = 0.8
% Jrms = 4.7 A/mm^2 (Copper) & 3.7 A/mm^2
% Core losses density = 500 mW/cm^3

kW = 0.8;
lossDensCopper = 2;

jRMSVec = [3.3,4.7,5.8;2.6,3.7,4.5].*1e6;
jRMS = jRMSVec(obj.materials.electricConductor.id,lossDensCopper);
coreLossesDensityVec = [250,500,750] * 1e3;
coreLossesDensity = coreLossesDensityVec(lossDensCopper);

% Calculation of the maximal Bac field
Bsat = obj.materials.magneticCore.Bsat;
if strcmp(sideType,'LV')
    % We estimate the core losses
    % Hyp for core losses temperature
    Tref = 80;
    k100 = obj.materials.magneticCore.k100;
    ct2 = obj.materials.magneticCore.ct2;
    ct1 = obj.materials.magneticCore.ct1;
    ct0 = obj.materials.magneticCore.ct0;
    k100 = k100 * (ct2 * Tref^2 - ct1 * Tref + ct0);
    s = obj.materials.magneticCore.s;
    alpha_s = obj.materials.magneticCore.alpha_s;
    u = obj.materials.magneticCore.u;
    alpha_u = obj.materials.magneticCore.alpha_u;
    y = obj.materials.magneticCore.y;
    z = obj.materials.magneticCore.z;
    beta_z = obj.materials.magneticCore.beta_z;
    bACLosses = ((coreLossesDensity./ ( k100 .* (s .* fSw .^alpha_s + ...
        u .* fSw .^alpha_u))) .^ (1./(y - z .* fSw .^ beta_z)));
    
    % We check if whether the saturation field or the losses are limiting
    % our problem
    bACMax = min([Bsat,bACLosses]);
elseif strcmp(sideType,'HV')
    % in this case the limit is the magnetic saturation field
    bACMax = Bsat;  
end

% Factor for skin effect (Hypothesis: NEEDS TO BE RECONSIDERED!!)
fSkin = 50e3;
rACDCnSf = sqrt(1 + fSw/fSkin);

% Factors determination for optimal uncoupled inductor (Refer to [1])
aa = 2;
bb = Bsat/bACMax;
Xi = (vHVnom) / 4 / L / fSw / iLVnom;
cc = rACDCnSf /12;

% Area product calculation
if strcmp(sideType,'LV')
    AwAc = (vHVnom * iLVnom /8 / fSw/ Bsat/kW/ jRMS) * ...
        (max(1+aa/Xi,bb) * (1+cc*Xi^2)^0.5);
elseif strcmp(sideType,'HV')
    AwAc = L * iLVnom^2 ./ kW ./ Bsat ./ jRMS;
else
    error('sideType not recognized');
end

% Once the area product has been calculated the dimensions need to be
% specified

% Material densities
densCond = obj.materials.electricConductor.density;
densMag = obj.materials.magneticCore.density;

% Form factors (refer to [1})
kzH = 0.5;
kxR = 1;
kNAw = 0.38919 + 0.64007 * kzH + 0.11399 * kxR + 0.11047 * kxR*kzH - 0.047134 * kxR^2;
alphaNAw = 0.49993 - 0.053889 * kxR + 0.014065 * kxR^2;

% Winding cross section area
Aw = sqrt(AwAc) * kNAw * ( densMag / (kW * densCond) )^ alphaNAw ;

% Dimensions of the core (cross section)
xC =( Aw*AwAc*densCond*kW / ( densCond*kW*Aw^2 + AwAc*densMag*kzH + AwAc*densMag*kxR*kzH) )^(1/2);
yC = AwAc / Aw / xC ;

% Dimensions of the winding (cross section)
xW =( Aw*AwAc*densMag/4 / ( densCond*kW*Aw^2 + AwAc*densMag*kzH ) *(kxR + 1) )^(1/2);
zW = Aw / xW ;

obj.outputData_.geometric.areaProduct = AwAc;

% Determination of dimensions in the objtect
obj.dimensions_.legWidth = xC/2;
obj.dimensions_.legThickness = yC;
obj.dimensions_.conductorHeight = zW;


% For the rest of the inputs
% Number of turns
if strcmp(sideType,'LV')
    nTurn = jRMS * kW * Aw / (iLVnom * (1 + cc * Xi ^ 2)^ 0.5);
elseif strcmp(sideType,'HV')
    nTurn = jRMS * kW * Aw / iLVnom;
end

% The number of turns must be between 2 and 100
nTurn = max(nTurn,1);
nTurn = min(nTurn,100);
obj.dimensions_.nTurns = nTurn;
obj.dimensions_.conductorWidth = kW * Aw /(obj.dimensions_.nTurns * zW);
obj.dimensions_.interTurnSpace = (1 - kW) * Aw /((obj.dimensions_.nTurns + 1) * zW) ;

% Airgap calculation
% Required inductance
relTotReq = nTurn^2 / L;

% % Vertical Reluctance
% lVert = zW + xC/2;
 aVert = xC * yC;
% relVert = lVert / (4* pi *1e-7 * obj.material.matMag.mu_e * aVert);
% 
% % Horizontal reluctance
% lHoriz = 2 *(xW + xC/2);
% aHoriz = aVert;
% relHoriz = lHoriz / (4* pi *1e-7 * obj.material.matMag.mu_e * aHoriz);
% 
% % Rough estimation of the leakage inductance
% lLeak = zW + xC/2;
% aLeak = 2 * (xC + 2 * xW) * (xC/2 + yC/2);
% relLeak = lLeak / (4* pi *1e-7 * aLeak);


magPathLength = 2 * (xW+ zW + 2 * pi /8 * 2 * xC/2);

% relReturnReq = relLeak * (relTotReq - relVert) / (relLeak - relTotReq + relVert) - relHoriz;
relReturnReq = relTotReq - magPathLength /  (4* pi *1e-7 * obj.materials.magneticCore.mu_e * aVert);
% lReturn = lVert;
% aReturn = aVert;
airGap = relReturnReq * (4 * pi * 1e-7 * aVert) ;
if airGap < 0
    warning('Calculation model found negative airgap');
end

obj.dimensions.airGap = max(airGap/2,0);

% Computation of the form
obj.computeGeometry;
obj.computeModelParameters;
end



function varargout = validateFEMM(obj)
%VALIDATEFEMM this function performs 2D electromagnetic simulations to
%compare the analytic and numerical simulation data of resistance,
%inductance and losses

% For the validation the number of turns is rounded to calculate only the
% model errors
obj.dimensions.nTurns = round(obj.dimensions.nTurns);
obj.computeGeometry;
obj.computeModelParameters;

% We get the analytic values:
% Resistance
freqVecAnalytic = obj.modelParameters_.electric.rACmodel.freqVec;
% The DC values are replaced by 0
freqVecAnalytic(freqVecAnalytic==0) = deal(1);
freqValVecRACAnalytic = obj.modelParameters_.electric.rACmodel.freqValVec;
rACAnalyticCorrection = freqValVecRACAnalytic ./ obj.modelParameters_.electric.rS;
% Inductance
lValueAnalytic = obj.modelParameters_.electric.L .* ones(1,length(freqVecAnalytic));

% FEMM calculation (linear calculations [magnitude/m])
[rACCorrectionFEMM,lFEMM] = arrayfun(@obj.femmCompute,freqVecAnalytic,'UniformOutput',true);
lFEMM = lFEMM .* obj.dimensions_.legThickness;

% Results comparison plotting
% Resistance
figure()
subplot(2,1,1)
title('Correction Factor Abs.');
loglog(freqVecAnalytic,rACAnalyticCorrection,'-o',freqVecAnalytic,rACCorrectionFEMM,'-o','LineWidth',2);
xlabel('Frequency (Hz)');
ylabel('R_{AC}/R_{DC}');
legend({'Analytic','FEMM'});
subplot(2,1,2)
title('Correction Factor Abs.');
semilogx(freqVecAnalytic,(rACAnalyticCorrection - rACCorrectionFEMM)./rACCorrectionFEMM .* 100,'-o','LineWidth',2);
xlabel('Frequency (Hz)');
ylabel('Relative Error (%)');
meanErrorRAC = mean((rACAnalyticCorrection - rACCorrectionFEMM)./rACCorrectionFEMM .* 100);

% Inductance 
figure()
subplot(2,1,1)
title('Correction Factor Abs.');
semilogx(freqVecAnalytic,lValueAnalytic,'-o',freqVecAnalytic,lFEMM,'-o','LineWidth',2);
xlabel('Frequency (Hz)');
ylabel('Inductance (H)');
legend({'Analytic','FEMM'});
subplot(2,1,2)
title('Correction Factor Abs.');
semilogx(freqVecAnalytic,(lValueAnalytic - lFEMM)./lFEMM .* 100,'-o','LineWidth',2);
xlabel('Frequency (Hz)');
ylabel('Relative Error (%)');
meanErrorL = mean((lValueAnalytic - lFEMM)./lFEMM .* 100);

% Print in screen
fid = 1;
fprintf(fid,'\n');
fprintf(fid,'%s\n','====================================================');
fprintf(fid,'Validation of %s [%s]\n', obj.name_, class(obj));
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n', 'rAC Factor');
formatSpecVar = '%30s: %6.4g %1s \n';
textData = {'Rel. Mean Error',meanErrorRAC,'%'};
fprintf( fid, formatSpecVar, textData{:});
fprintf(fid,'%s\n','----------------------------------------------------');
fprintf(fid,'%s\n', 'L value');
formatSpecVar = '%30s: %6.4g %1s \n';
textData = {'Rel. Mean Error',meanErrorL,'%'};
fprintf( fid, formatSpecVar, textData{:});
fprintf(fid,'%s\n','----------------------------------------------------');                

% To recover the data (if desired)
data.rACCorrectionFEMM = rACCorrectionFEMM;
data.meanErrorRAC = meanErrorRAC;
data.LFEMM = lFEMM;
data.meanErrorL = meanErrorL;

% Validation of core losses
if ~isempty(obj.outputData_.electric)
   analyticJouleLosses = obj.outputData_.electric.jouleLosses;
   
   % Calculation of losses using FEMM data
   rACFEMM = rACCorrectionFEMM .* obj.modelParameters.electric.rS;
   
   % Excitations
   freq = obj.excitations_.electric.freq;
   ifft = obj.excitations_.electric.ifft;
   ifft(freq>0) = ifft(freq>0) / sqrt(2);
   
   rACValues = [ rACFEMM(freqVecAnalytic==1) interp1( log10(freqVecAnalytic(freqVecAnalytic>0)), rACFEMM(freqVecAnalytic>0), log10(freq(freq>0)), 'pschip', 'extrap')];
   lossesFEMM = sum(rACValues .*(ifft.^2) );
   meanRelErrorLosses = (analyticJouleLosses - lossesFEMM) / lossesFEMM * 100;
   
   % print in screen
   fprintf(fid,'%s\n', 'Winding Losses');
   formatSpecVar = '%30s: %6.4g %1s \n';
   textData = {'Analytic',analyticJouleLosses,'W'};
   fprintf( fid, formatSpecVar, textData{:});
   textData = {'FEMM',lossesFEMM,'W'};
   fprintf( fid, formatSpecVar, textData{:});
   textData = {'Rel. Error',meanRelErrorLosses,'%'};
   fprintf( fid, formatSpecVar, textData{:});
   fprintf(fid,'%s\n','----------------------------------------------------');
   
   data.meanRelErrorLosses = meanRelErrorLosses;
   data.femmLosses = lossesFEMM;
end

fprintf(fid,'%s\n','====================================================');
fprintf(fid,'\n');

if nargout >= 1
    varargout{1} = data;
end
end


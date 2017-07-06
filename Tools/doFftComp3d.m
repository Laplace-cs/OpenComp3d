function [vectorOut,result] = doFftComp3d(fftType, nPoint,vectorIn,variable,option)
% doFft     Do Fast Fourrier Transform
%   doFft(fftType, nPoint, variable) perform FFT or iFFT according to
%   'fftType', for the given 'variable' on 'nPoint' size. For the FFT 
%   case, negative frequencies are removed in the 'result' spectrum.
%
%   - Inputs:
%       'fftType' specifies the type of FFT
%           'dir' to perform FFT
%           'inv' to perform iFFT
%
%       'nPoint' corresponds to number of points
%           its parity gives information about nyquist frequency presence
%
%       'variable' are the datas on which FFT or iFFT has to be applied
%       'vectorIn' is the time vector
%
%   - Outputs:
%       'result' is the computed datas
%           frequency spectrum for FFT,
%       	time domain for iFFT.
%
% Example
%       freqVec = doFft('dir',nbPoint,timeVec);
%       timeVec = doFft('inv',nbPoint,freqVec);

warning('Use Comp3d.doFft function. This function will be removed.')

if (strcmpi(fftType,'dir')),
        tmp = 2/length(variable)*fft(variable);
        if rem(nPoint,2),
            % Nyquist frequency does not exist
            result = tmp(1:ceil(nPoint/2));
        else
            % Nyquist frequency exists
            result = tmp(1:(nPoint/2)+1);
            % nyquist component has to be divided by 2 (may be)
            result(nPoint/2+1) = result(nPoint/2+1)/2;
        end
        % mean component has to be divided by 2
        result(1) = result(1)/2;
        
        % Frequency vector
        [outFreq] = Solver.FftFreq(vectorIn);
   if strcmp(option,'complete')

        vectorOut = (outFreq(1:length(result)));
        result = abs(result);
    else
        vectorOut = outFreq;
        auxVec = result./2;
        result = [auxVec,fliplr(auxVec(2:end))];
        result(1) = result(1)*2;
    end
    
    
elseif (strcmpi(fftType,'inv'))
%     the doFft('dir') gives 
    variable(1) = variable(1)*2;
    if rem(nPoint,2),
        % Nyquist frequency does not exist
        tmp = [variable(1:end) conj(variable(end:-1:2))]/2;
    else
        % Nyquist frequency exists
        tmp = [variable(1:end-1) variable(end)*2 conj(variable(end-1:-1:2))]/2;
    end
    result = real(length(tmp)*ifft(tmp));
    
else
    % Wrong argument error
    error('Ootee:WrongArgument', ...
        'doFft can''t handle the ''fftType'' you have given.');
    
end


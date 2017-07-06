function [ freqVec, valVec] = doFft( time, value)

% Frequency vector
freqVec = GetFrequencyVector(time);

% Vector of values
valVec  = abs( ComputeFftVector(length(value), value));
end
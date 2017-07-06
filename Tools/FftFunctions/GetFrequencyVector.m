function [freqVec] = GetFrequencyVector(time)
% compute the frequency vector associated to a time vector to be used with fft.
nElements = length(time);
tStep = time(2) - time(1);
fStep = 1/(time(end) + tStep);
if ~rem(nElements,2) % pair (nyquist freq exist)
    k = nElements/2;
    fk = (1:(k-1))*fStep;
    freqVec = [0 fk k*fStep -fliplr(fk)];
else
    k = (nElments - 1)/2;
    fk = (1:k)*fStep;    
    freqVec = [0 fk -fliplr(fk)];
end
end
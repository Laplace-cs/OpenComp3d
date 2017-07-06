function [freqVec, fftVec] =  removeNegativeFrequencies( freqVecFull, fftVecFull)
% transform full fft to half positive fft

if any( freqVecFull < 0)
    freqVec = freqVecFull( freqVecFull >= 0);
    fftVec = 2 * abs(fftVecFull( freqVecFull >= 0 ));
    fftVec(1) = fftVec(1)/2;
else
    warning('Comp3d.removeNegativeFrequencies: None negative frequency found.')
    freqVec = freqVecFull;
    fftVec = fftVecFull;
end
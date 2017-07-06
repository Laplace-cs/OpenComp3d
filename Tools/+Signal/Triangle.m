function waveform= Triangle(timeVec)
% Triangle creates a triangle signal between -1 and 1
waveform = 2/(pi) * (timeVec - pi*floor(timeVec/(pi) + 1/2)) .* (-1).^floor(timeVec/(pi) + 1/2);

end


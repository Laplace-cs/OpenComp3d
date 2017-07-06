function result = ComputeFftVector(nPoint, variable)
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
end


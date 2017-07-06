function data = ooteeGetSimulationDataLv1(obj)

data.voltage = obj.model_.electric.portList{1}.intNode.data.v - obj.model_.electric.portList{2}.intNode.data.v;

% time domaine
data.time = obj.modelParameters.electric.Lmodel.data.time;
data.current = obj.modelParameters.electric.Lmodel.data.i;

% freq domaine
freq = obj.modelParameters.electric.Lmodel.data.freq;
ifft = full(obj.modelParameters.electric.Lmodel.data.ifft);

                    
[freqVec, fftVec] = Comp3d.removeNegativeFrequencies(freq,ifft);
data.freq = freqVec;
data.ifft = fftVec;

end

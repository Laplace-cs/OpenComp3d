function data = ooteeGetSimulationDataLv2(obj)

data.voltage = obj.model_.electric.portList{1}.intNode.data.v - obj.model_.electric.portList{2}.intNode.data.v;

% time domaine
data.time = obj.modelParameters_.electric.rACmodel.data.time;
data.current = obj.modelParameters_.electric.rACmodel.data.i;

% freq domaine
freq = obj.modelParameters_.electric.rACmodel.data.freq;
ifft = full(obj.modelParameters_.electric.rACmodel.data.ifft);

[data.freq, data.ifft] = Comp3d.removeNegativeFrequencies( freq, ifft);

end

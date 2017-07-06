function ooteeBuildElectricModelLv1(obj)
% The model is a simple R-L circuit

% name is defined because we need identify it for results
obj.modelParameters_.electric.rSmodel = Resistor( obj.modelParameters.electric.rS, ['rS_' obj.name], obj.record_);

obj.modelParameters_.electric.Lmodel = Inductor(obj.modelParameters.electric.L, ['L_' obj.name]);
obj.modelParameters_.electric.Lmodel.recordObj = 1;

% create ckt model
obj.model_.electric = Ckt.CktComposite('inductorElecModel');
n = obj.model_.electric.createNode(3);
n{1}.recordObj = 1;
n{1}.name = [obj.name_,'_plus'];
n{3}.recordObj = 1;
n{3}.name = [obj.name_,'_minus'];
obj.model_.electric.addPort(n{1});
obj.model_.electric.addPort(n{3});

% connect
obj.model_.electric.addCkt(obj.modelParameters.electric.Lmodel, n(2:3));
obj.model_.electric.addCkt(obj.modelParameters.electric.rSmodel, n(1:2));

end
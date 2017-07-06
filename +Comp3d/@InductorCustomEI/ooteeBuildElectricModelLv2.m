function ooteeBuildElectricModelLv2(obj)

%obj.modelParameters_.electric.rACmodel = Impedance( obj.modelParameters_.electric.rACmodel.freqVec, obj.modelParameters_.electric.rACmodel.freqValVec, ['Rs_',obj.name], obj.record_);

behaviour = Ckt.LookTabLog( obj.modelParameters_.electric.rACmodel.freqVec, obj.modelParameters_.electric.rACmodel.freqValVec);
obj.modelParameters_.electric.rACmodel = Impedance( [],[], ['Rs_',obj.name], obj.record_);
obj.modelParameters_.electric.rACmodel.behaviour = behaviour;
obj.modelParameters_.electric.rACmodel.recordObj = 1;

obj.modelParameters_.electric.Lmodel = Inductor(obj.modelParameters_.electric.Lmodel.val,['l_',obj.name_]);

obj.modelParameters_.magnetic.CoreModel = InductorResistor( obj.modelParameters_.magnetic.CoreModel.L, obj.modelParameters_.magnetic.CoreModel.r, ['CoreModel_',obj.name_]);
obj.modelParameters_.magnetic.RLosses = Impedance( obj.modelParameters_.magnetic.RLosses.freqVec, obj.modelParameters_.magnetic.RLosses.freqValVec, ['RLosses_',obj.name_]);

% create ckt model
obj.model_.electric = Ckt.CktComposite('inductorElecModel');
% name is defined because we need identify it for results
n = obj.model_.electric.createNode(3);
n{1}.name = [obj.name_,'_plus'];
n{3}.name = [obj.name_,'_minus'];
obj.model_.electric.addPort(n{1});
obj.model_.electric.addPort(n{3});
node1 = obj.model_.electric.portList{1}.intNode;
node1.recordObj = 1;
node2 = obj.model_.electric.portList{2}.intNode;
node2.recordObj = 1;

% Copper Losses
obj.model_.electric.addCkt( obj.modelParameters_.electric.rACmodel, n(1:2));
% Core Model
obj.model_.electric.addCkt( obj.modelParameters_.magnetic.CoreModel, n(2:3));
obj.model_.electric.addCkt( obj.modelParameters_.magnetic.RLosses, n(2:3));

end
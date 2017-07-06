function ooteeBuildElectricModel(obj)
% model_.electricPort is an external model container who keeps the
% external connexions with the other models.
% 
% model_.electric is an internal model created according with the level desired
%
% creates the external and/or internal models if they are not already
% available


% verify if the electrical model exists
% than creates the model according with the level
if ~isa( obj.model_.electric, 'Ckt.CktComposite')
    warning(['The electric model of ',class(obj),':',obj.name_,' has changed']); 
end

switch obj.level_
    case 1
        obj.ooteeBuildElectricModelLv1();
    case 2
        obj.ooteeBuildElectricModelLv2();
end


% connect the model_.electric to obj.model_.electricPort
if ~isa( obj.model_.electricPort, 'Ckt.CktComposite')
    % create the obj.model_.electricPort
    obj.model_.electricPort = Ckt.CktComposite(obj.name);

    % and take the port information (number, names) from de modelLv
    nPort = length( obj.model_.electric.portList);
    nodes = obj.model_.electricPort.createNode(nPort);
    cellfun( @(node,port) obj.model_.electricPort.addPort(node, port.name), nodes, obj.model_.electric.portList, 'UniformOutput', false);
elseif length(obj.model_.electric.portList) ~= length( obj.model_.electricPort.nodeList)
    error('ooteeBuildElectricModel: submodel can not be connected because port number does not match.')
end

% Modification alvaro: each time the circuit needs to be added not only if
% it is empty
obj.model_.electricPort.addCkt( obj.model_.electric, obj.model_.electricPort.nodeList);

end

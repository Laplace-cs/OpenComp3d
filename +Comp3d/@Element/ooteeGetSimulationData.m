function data = ooteeGetSimulationData(obj)
switch obj.level_
    case 1
        data = obj.ooteeGetSimulationDataLv1();
    case 2
        data = obj.ooteeGetSimulationDataLv2();
    case 3
        data = obj.ooteeGetSimulationDataLv3();
    otherwise
        error('Level not available.')
end


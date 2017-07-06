function list = MaterialList(type)

switch type
    case 'Conductor'
        load ListMatCond;
        list = ListMatCond;
    case 'Magnetic'
        load ListMatMag;
        list = ListMatMag;
    case 'Insulant'
        
    case 'Dielectric'
        load ListMatDielec;
        list = ListMatDielec;
    case 'Insulation'
        load ListMatInsul;
        list = ListMatInsul;
        
    otherwise
        error ('Material type not defined');
end

end


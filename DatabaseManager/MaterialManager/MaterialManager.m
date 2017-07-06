
       function out = MaterialManager(type,id)
        % Function that determines the material properties for given inpus
        % type - Material type: Conductor, Magnetic, Insulant
        % id   - Material id (name or number)
%         addpath ('.\Conductor');
%         addpath ('.\Magnetic');
        
        if ~isstruct(id)
             switch type
                 case 'Conductor'
                        load MatCond;
                        DataBase = MatCond;
                 case 'Magnetic'
                          load MatMag;
                        DataBase = MatMag;    
                 case 'Insulant'

                 case 'Dielectric'
                     load MatDielec;
                     DataBase = MatDielec;
                 case 'Insulation'
                     load MatInsul;
                     DataBase = MatInsul;

                 otherwise
                     error ('Material type not defined');

             end


             if isnumeric(id)
                 out = getbyId(DataBase,id);
             elseif ischar(id)
                 out = getByMaterialName(DataBase,id);
             elseif iscell(id)
                 out = getByMaterialName(DataBase,id{:});
             end
        else
            out = id;
        end
                 
       end

        function out = getbyId(DataBase,id)
           % Determines the material properties for a given id number
            out = DataBase(id);            
        end
        
        function out = getByMaterialName(DataBase,modele)
            % Determines the id correspondant to the materials name
            id = find( cellfun(@(x) strcmp(modele,x), {DataBase.name}));
            out = getbyId(DataBase,id);
        end
        


    
    
 
 
       function [out, entitled] = DatabaseManager(type,sheet,id)
        % Function that determines the material properties for given inpus
        % type - Choice of components
        % id   - Material id (name or number)
        
         switch type
             case 'Fan'
                 switch sheet
                     case 'DCFan'
                        load MatDCfan;
                        DataBase = MatDCfan;
                     otherwise
                         error('technology not implemented');
                 end                 
             otherwise
                 error ('Component type not defined');
                 
         end
                 if isnumeric(id) && id > 0
                     out = getbyId(DataBase,id);
                     
                 elseif ischar(id)
                     out = getByMaterialName(DataBase,id);
                     
                 elseif id == -1
                     out = DataBase;
                 end
                 
       end

        function out = getbyId(DataBase,id)
           % Determines the material properties for a given id number
            out = DataBase(id);
        end
        
        function out = getByMaterialName(DataBase,modele)
            % Determines the id correspondant to the materials name
            for k = 1:length(DataBase)
                if  strcmp(modele,DataBase(k).name)
                    out = getbyId(DataBase,k);
                    break
                end
            end
        end       
        


    
    
 
 


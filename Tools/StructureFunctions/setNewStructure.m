function [outputStruct] = setNewStructure(oldStruct,newStruct)
%SETNEWSTRUCTURE is a function to change the fields of oldStruct by the
%fields in new structure

outputStruct = oldStruct;

if (~isstruct(oldStruct)) || (~isstruct(newStruct))
    if isempty(oldStruct) && isempty(newStruct)
        return
    else
    error('inputs must be structures'); 
    end
end

% Preparation of the fields
fieldsNewStruct = fields(newStruct);

for k = 1:length(fieldsNewStruct)
    valueNewField = fieldsNewStruct{k};
   if isstruct(newStruct.(valueNewField))
       outputStruct.(valueNewField) = setNewStructure(oldStruct.(valueNewField),newStruct.(valueNewField));
   elseif isfield(oldStruct,valueNewField)
       outputStruct.(valueNewField) = newStruct.(valueNewField);
   end  
end

end


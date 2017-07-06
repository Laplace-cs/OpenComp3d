function outputArray = createConstraintArray(object,table)
    
% We get the number of fieds for the structure
nFields = size(table,1);

outputArray = [];
for k = 1:nFields
   outputArray =  [outputArray,OptimProblem.ConstraintObject(object,table{k,:})];  
end

end
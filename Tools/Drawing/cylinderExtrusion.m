function cylinderExtrusionExtrusion(radius,curve,color)
%CYLINDEREXTRUSION draws a cylinder along a 3d curve
%
%CYLINDEREXTRUSION inputs:
% radius        - value of the cylinder to extrude
% curve         - 3D 3xN matrix describing the extruding line [X;Y;Z]
% color         - RGB triplet for the color

nPointsCirc = 10;
angleTot = linspace(0,2*pi,nPointsCirc);
basePoints = radius.*[cos(angleTot);sin(angleTot);zeros(1,nPointsCirc)];
numberOfPoints = size(basePoints,2);

% We calculate the derivative of the curve
if size(curve,2) >= 3 
   curveDerivative  = [curve(:,1:3)*[-3; 4; -1]/2  [curve(:,3:end) - curve(:,1:end-2)]/2 curve(:,end-2:end)*[1; -4; 3]/2];
else
    curveDerivative = curve(:,[2 2]) - curve(:,[1 1]);
end

idxZero = find(sum(abs(curveDerivative),1) == 0,1);    %Check for stagnation points
if ~isempty(idxZero) 
    idxNonZero = find(sum(abs(idxZero),1) ~= 0);
    curve = curve(:,idxNonZero); % 
    curveDerivative = curveDerivative(:,idxNonZero); % 
end

numberElements = size(curveDerivative,2);
matrixPoints = nan(3,numberOfPoints,numberElements);

dCvec_prev = [0;0;1];
for k = 1:numberElements
    % We want to rotate [0;0;1] 180degrees around an axis 'z' to become dC
    
    dCvec = curveDerivative(:,k)/norm(curveDerivative(:,k));
    z = cross(dCvec_prev,dCvec);
    
    if norm(z) ~= 0
        z = z/norm(z);
        q = real(acos(dot(dCvec_prev,dCvec)/norm(dCvec_prev)/norm(dCvec)));
        
        Z = repmat(z,1,numberOfPoints);
        basePoints = basePoints*cos(q) + cross(Z,basePoints)*sin(q)+Z*(1-cos(q))*diag(dot(Z,basePoints));
        dCvec_prev = dCvec;
    end
    
    matrixPoints(:,:,k) = basePoints + repmat(curve(:,k),1,numberOfPoints);
    
end
X = squeeze(matrixPoints(1,:,:));
Y = squeeze(matrixPoints(2,:,:));
Z = squeeze(matrixPoints(3,:,:));

colorMat = ones(size(X,1),size(X,2),3);
colorMat(:,:,1) = color(1) * colorMat(:,:,1);
colorMat(:,:,2) = color(2) * colorMat(:,:,2);
colorMat(:,:,3) = color(3) * colorMat(:,:,3);
surf(X,Y,Z,colorMat);
axis equal


end


function [] = drawParallelepipedWithHole(outerDimensionsVector,radiusHole,axisHole,offset,color)
% drawParallelepipedWithHole draws a prism with a defined hole
%
% drawParallelepipedWithHole inputs
% outerDimensionsVector    - dimensions of the prism [x,y,z] x and y
%                            perpendicular to the axisHole
% radiusHole               - radius of the hole 
% axisHole                 - direction of the hole : Ex. [1,0,0] for X axis
% offset                   - offset of the drawing
% color                    - color of the drawing (specified RGB)
%
% Ex:
% drawParallelpidedWithHole(outerDimensionsVector,radiusHole,axisHole,offset)

if ~(((sum(axisHole == 0)) == 2 && (sum(axisHole == 1) == 1)))
     error('Axis must be along x,y,z dimension');
end

xLength = outerDimensionsVector(1);
yLength = outerDimensionsVector(2);
zLength = outerDimensionsVector(3);

% inside cylinder
[x0 y0 z0]=cylinder(radiusHole,30);
x0 = x0 + xLength/2;
y0 = y0 + yLength/2;
z0 =  z0 * zLength;
C(:,:,1)=color(1)*ones(2,30);
C(:,:,2)=color(2)*ones(2,30);
C(:,:,3)=color(3)*ones(2,30);

if axisHole(1)==1
    surf(z0+offset(3),x0+offset(1),y0+offset(2),C)
elseif axisHole(2) == 1
    surf(x0+offset(1),z0+offset(3),y0+offset(2),C);
elseif axisHole(3) == 1
    surf(x0+offset(1),y0+offset(2),z0+offset(3),C);
end
hold on

% one side surface
xPoints = offset(1) + [x0(1,:),xLength,0,       0,xLength,xLength];
yPoints = offset(2) + [y0(1,:),yLength,yLength,0,0,xLength];
zPoints = offset(3) + [z0(1,:),z0(1,1),z0(1,1),z0(1,1),z0(1,1),z0(1,1)];

if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end


% Other side surface
xPoints = offset(1) + [x0(1,:),xLength,0,0,xLength,xLength];
yPoints = offset(2) + [y0(1,:),yLength,yLength,0,0,xLength];
zPoints = offset(3) + [z0(2,:),z0(2,1),z0(2,1),z0(2,1),z0(2,1),z0(2,1)];
if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end

% The surround rectangular surface
xPoints = offset(1) + [0,0,xLength,xLength];
yPoints = offset(2) + [0,0,0,0];
zPoints = offset(3) + [z0(1,1),z0(2,1),z0(2,1),z0(1,1)];
if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end

xPoints = offset(1) + [0,0,0,0];
yPoints = offset(2) + [0,0,yLength,yLength];
zPoints = offset(3) + [z0(1,1),z0(2,1),z0(2,1),z0(1,1)];
if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end

xPoints = offset(1) + [xLength,xLength,xLength,xLength];
yPoints = offset(2) + [0,-0,yLength,yLength];
zPoints = offset(3) + [z0(1,1),z0(2,1),z0(2,1),z0(1,1)];
if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end

xPoints = offset(1) + [0,0,xLength,xLength];
yPoints = offset(2) + [yLength,yLength,yLength,yLength];
zPoints = offset(3) + [z0(1,1),z0(2,1),z0(2,1),z0(1,1)];

if axisHole(1)==1
    fill3(zPoints,xPoints,yPoints,color);
elseif axisHole(2) == 1
    fill3(xPoints,zPoints,yPoints,color);
elseif axisHole(3) == 1
    fill3(xPoints,yPoints,zPoints,color);
end



axis equal
end
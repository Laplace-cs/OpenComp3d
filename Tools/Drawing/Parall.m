function [] = draw_Parallepiped(dimensions,offset,color)
%PARALL is a function to draw a parallepiped
%
% Ex. Parall([3 1 2],[0,0,0],[1,1,1]);
%
% Parall arguments
% dimensions        - vector of the three dimensions [x1 y1 z1]
% offset            - offset vector of the drawing [x0,y0,z0]
% color             - RGB triplet for the color [x,y,z]
%
ParX = dimensions(1) / 2 * [-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 -1 -1 -1;1 1 1 1]';
ParY = dimensions(2) / 2 * [-1 -1 1 1;-1 -1 1 1;-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;-1 1 1 -1]';
ParZ = dimensions(3) / 2 * [-1 -1 -1 -1;1 1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1]';

xCenter = offset(1);
yCenter = offset(2);
zCenter = offset(3);

patch(xCenter + ParX , yCenter + ParY , zCenter + ParZ,color1);

end


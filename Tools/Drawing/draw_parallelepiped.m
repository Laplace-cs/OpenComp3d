function [] = draw_parallelepiped(dimensions,offset,color)
%PARALL is a function to draw a parallepiped
%
% Ex. Parall([3 1 2],[0,0,0],[1,1,1]);
%
% Parall arguments
% dimensions        - vector of the three dimensions [x1 y1 z1]
% offset            - offset vector of the drawing [x0,y0,z0] for the
%                     corner
% color            - RGB color vector, the fourth value can be specified
%                   between 0 and 1 to determine the transparency
%
ParX = dimensions(1) / 2 * [-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 -1 -1 -1;1 1 1 1]';
ParY = dimensions(2) / 2 * [-1 -1 1 1;-1 -1 1 1;-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;-1 1 1 -1]';
ParZ = dimensions(3) / 2 * [-1 -1 -1 -1;1 1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1]';

xCenter = offset(1) + dimensions(1)/2;
yCenter = offset(2) + dimensions(2)/2;
zCenter = offset(3) + dimensions(3)/2;

if length(color) == 4
    transparencyValue = color(4);
else
    transparencyValue = 1;
end
patch(xCenter + ParX , yCenter + ParY , zCenter + ParZ,color,'FaceAlpha',transparencyValue);
view(3)
axis equal

end


function [ParX,ParY,ParZ] = drawParall(X,Y,Z)
%Coordonn�es d'un parall�lepip�de de cotes X,Y,Z centr�
%       ordres des 6 faces
%       dessous    dessus  devant derri�re gauche droite
% X=2;Y=3;Z=4;
% Original file: Comp3d.Magnetic.m
ParX = X / 2 * [-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 -1 -1 -1;1 1 1 1]';
ParY = Y / 2 * [-1 -1 1 1;-1 -1 1 1;-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;-1 1 1 -1]';
ParZ = Z / 2 * [-1 -1 -1 -1;1 1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1]';
end
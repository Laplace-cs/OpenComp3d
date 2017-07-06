function [ParX,ParY,ParZ] = drawParall(X,Y,Z)
%Coordonnées d'un parallélepipède de cotes X,Y,Z centré
%       ordres des 6 faces
%       dessous    dessus  devant derrière gauche droite
% X=2;Y=3;Z=4;
% Original file: Comp3d.Magnetic.m
ParX = X / 2 * [-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 1 1 -1;-1 -1 -1 -1;1 1 1 1]';
ParY = Y / 2 * [-1 -1 1 1;-1 -1 1 1;-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;-1 1 1 -1]';
ParZ = Z / 2 * [-1 -1 -1 -1;1 1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1]';
end
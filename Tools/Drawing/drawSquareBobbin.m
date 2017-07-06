function [SqBobX,SqBobY,SqBobZ] = drawSquareBobbin(Intx,Inty,Extx,Exty,H)
% Original file: Comp3d.Magnetic.m
%Intx=2;Inty=3; Extx=1;Exty=2;H=3;

%Coordonn�es d'une bobine  carr�e centr�e
% Patron pour faces verticales
%       devant derri�re gauche droite
Xbv = 0.5 * [-1 1 1 -1;-1 1 1 -1;-1 -1 -1 -1;1 1 1 1];
Ybv = 0.5 * [-1 -1 -1 -1;1 1 1 1;-1 1 1 -1;-1 1 1 -1];
Zbv = 0.5 * [-1 -1 1 1;-1 -1 1 1;-1 -1 1 1;-1 -1 1 1];

%Faces horizontales
%     desssous(droite derri�re gauche devant)+...
%       desssus(droite derri�re gauche devant)
Xbh = 0.5 * [Extx Extx Intx Intx; Extx -Extx -Intx Intx; -Extx -Extx -Intx -Intx;-Extx Extx Intx -Intx;...
    Extx Extx Intx Intx; Extx -Extx -Intx Intx; -Extx -Extx -Intx -Intx;-Extx Extx Intx -Intx];
Ybh = 0.5 * [-Exty Exty Inty -Inty;Exty Exty Inty Inty;Exty -Exty -Inty Inty;-Exty -Exty -Inty -Inty;...
    -Exty Exty Inty -Inty;Exty Exty Inty Inty;Exty -Exty -Inty Inty;-Exty -Exty -Inty -Inty];
Zbh = 0.5 * [-1 -1 -1 -1;-1 -1 -1 -1;-1 -1 -1 -1;-1 -1 -1 -1;1 1 1 1;1 1 1 1;1 1 1 1;1 1 1 1];

% Assemblage
SqBobX = [Xbv'*Intx Xbv'*Extx Xbh'];
SqBobY = [Ybv'*Inty Ybv'*Exty Ybh'];
SqBobZ = [Zbv'*H Zbv'*H Zbh'*H];

axis equal
% view(3)
end
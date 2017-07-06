function [] = drawCylinder(rint,e,z,RGB,Offset,rotationAxis,angleRot,origin)
%draw_cylinder draws a 3d cilinder with the following inputs
% 
%draw_cylinder(rint,e,z,RGB,Offset,rotationAxis,angleRot,origin)
% 
% rint          - internal radius (m)
% e             - thickness of the cilinder (m)
% z             - height of the cilinder (m)
% RGB           - RGB color vector the fourth value can be specified
%                 between 0 and 1 to determine the transparency
% offset        - offset coordinate vector [x y z]
% rotationAxis  - rotation axis  [x y z]
% angleRot      - rotation angle (degrees)
% origin        - origin of the rotation    

% Extraction of the walls of the cilinder
[x0 y0 z0]=cylinder(rint,30);
z0=z0*z;
[x1 y1 z1]=cylinder(rint+e,30);
z1=z1*z;

% Extraction of the top botton surfaces
x3=[x0(1,:);x1(1,:)];
y3=[y0(1,:);y1(1,:)];
z3=[z0(1,:);z0(1,:)];
z4=[z1(2,:);z1(2,:)];
hold on

if length(RGB) == 4
    transparencyValue = RBG(4);
else
    transparencyValue = 1;
end

% For the color
C(:,:,1)=RGB(1)*ones(2,30);
C(:,:,2)=RGB(2)*ones(2,30);
C(:,:,3)=RGB(3)*ones(2,30);

% plotting of the result
h1 = surf(x0 + Offset(1),y0 + Offset(2),z0 + Offset(3),C,'FaceAlpha',transparencyValue);
h2 = surf(x1 + Offset(1),y1 + Offset(2),z1 + Offset(3),C,'FaceAlpha',transparencyValue);
h3 = surf(x3 + Offset(1),y3 + Offset(2),z3 + Offset(3),C,'FaceAlpha',transparencyValue);
h4 = surf(x3 + Offset(1),y3 + Offset(2),z4 + Offset(3),C,'FaceAlpha',transparencyValue);

if sum(rotationAxis) ~= 0
rotate(h3,rotationAxis,angleRot,origin);
rotate(h4,rotationAxis,angleRot,origin);
rotate(h1,rotationAxis,angleRot,origin);
rotate(h2,rotationAxis,angleRot,origin);

end
view(3)
axis equal
end


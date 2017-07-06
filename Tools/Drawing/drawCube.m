function drawCube(x,y,z,RGB)
% Function for drawing 3D cubes
index(1,:) = [1 2 3 4 1];
index(2,:) = [5 6 7 8 5];
index(3,:) = [1 2 6 5 1];
index(4,:) = [2 6 7 3 2];
index(5,:) = [4 3 7 8 4];
index(6,:) = [1 5 8 4 1];

for k = 1:6
    fill3(x(index(k,:)),y(index(k,:)),z(index(k,:)),RGB);
end
end